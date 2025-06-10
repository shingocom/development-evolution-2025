#!/usr/bin/env python3
"""
AI Model API Gateway
統合AI/MLサービスのAPIゲートウェイ
"""

import os
import asyncio
from typing import Dict, List, Optional, Any
from contextlib import asynccontextmanager

import httpx
import redis.asyncio as redis
from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
import structlog
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

# 設定
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./ai_gateway.db")

# ログ設定
logger = structlog.get_logger()

# メトリクス
REQUEST_COUNT = Counter('api_requests_total', 'Total API requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('api_request_duration_seconds', 'Request duration')

# Redisクライアント
redis_client: Optional[redis.Redis] = None

# Pydanticモデル
class ChatRequest(BaseModel):
    model: str = Field(default="llama2", description="使用するLLMモデル")
    prompt: str = Field(description="入力プロンプト")
    temperature: float = Field(default=0.7, ge=0.0, le=2.0, description="温度パラメータ")
    max_tokens: int = Field(default=1000, gt=0, le=4000, description="最大トークン数")

class ChatResponse(BaseModel):
    response: str
    model: str
    tokens_used: int
    processing_time: float

class HealthResponse(BaseModel):
    status: str
    services: Dict[str, str]
    version: str = "1.0.0"

class ModelListResponse(BaseModel):
    models: List[str]

# ライフサイクル管理
@asynccontextmanager
async def lifespan(app: FastAPI):
    """アプリケーションのライフサイクル管理"""
    global redis_client
    
    # 起動時の処理
    logger.info("AI Gateway starting up...")
    
    # Redis接続
    try:
        redis_client = redis.from_url(REDIS_URL)
        await redis_client.ping()
        logger.info("Redis connected successfully")
    except Exception as e:
        logger.error(f"Redis connection failed: {e}")
        redis_client = None
    
    yield
    
    # 終了時の処理
    logger.info("AI Gateway shutting down...")
    if redis_client:
        await redis_client.close()

# FastAPIアプリケーション
app = FastAPI(
    title="AI Model API Gateway",
    description="統合AI/MLサービスのAPIゲートウェイ",
    version="1.0.0",
    lifespan=lifespan
)

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 依存関数
async def get_redis():
    """Redis依存関数"""
    if redis_client is None:
        raise HTTPException(status_code=503, detail="Redis not available")
    return redis_client

async def get_ollama_client():
    """Ollama HTTPXクライアント"""
    return httpx.AsyncClient(base_url=OLLAMA_URL, timeout=30.0)

# エンドポイント
@app.get("/health", response_model=HealthResponse)
async def health_check():
    """ヘルスチェック"""
    services = {}
    
    # Ollama接続確認
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_URL}/api/tags", timeout=5.0)
            services["ollama"] = "healthy" if response.status_code == 200 else "unhealthy"
    except Exception:
        services["ollama"] = "unhealthy"
    
    # Redis接続確認
    try:
        if redis_client:
            await redis_client.ping()
            services["redis"] = "healthy"
        else:
            services["redis"] = "unhealthy"
    except Exception:
        services["redis"] = "unhealthy"
    
    status = "healthy" if all(s == "healthy" for s in services.values()) else "degraded"
    
    return HealthResponse(status=status, services=services)

@app.get("/metrics")
async def metrics():
    """Prometheusメトリクス"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/models", response_model=ModelListResponse)
async def list_models():
    """利用可能なモデル一覧"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_URL}/api/tags", timeout=10.0)
            if response.status_code == 200:
                data = response.json()
                models = [model["name"] for model in data.get("models", [])]
                return ModelListResponse(models=models)
            else:
                raise HTTPException(status_code=502, detail="Ollama service unavailable")
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Ollama service timeout")
    except Exception as e:
        logger.error(f"Error listing models: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.post("/chat", response_model=ChatResponse)
async def chat_completion(
    request: ChatRequest,
    background_tasks: BackgroundTasks,
    redis_client: redis.Redis = Depends(get_redis)
):
    """チャット補完"""
    import time
    start_time = time.time()
    
    try:
        # Ollamaにリクエスト送信
        ollama_request = {
            "model": request.model,
            "prompt": request.prompt,
            "options": {
                "temperature": request.temperature,
                "num_predict": request.max_tokens
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json=ollama_request,
                timeout=60.0
            )
            
            if response.status_code == 200:
                data = response.json()
                processing_time = time.time() - start_time
                
                # レスポンス作成
                chat_response = ChatResponse(
                    response=data.get("response", ""),
                    model=request.model,
                    tokens_used=len(data.get("response", "").split()),
                    processing_time=processing_time
                )
                
                # 使用量をRedisに記録（バックグラウンド）
                background_tasks.add_task(
                    log_usage,
                    redis_client,
                    request.model,
                    chat_response.tokens_used,
                    processing_time
                )
                
                # メトリクス記録
                REQUEST_COUNT.labels(method="POST", endpoint="/chat", status="200").inc()
                REQUEST_DURATION.observe(processing_time)
                
                return chat_response
            else:
                raise HTTPException(status_code=502, detail=f"Ollama error: {response.text}")
                
    except httpx.TimeoutException:
        REQUEST_COUNT.labels(method="POST", endpoint="/chat", status="504").inc()
        raise HTTPException(status_code=504, detail="Request timeout")
    except Exception as e:
        REQUEST_COUNT.labels(method="POST", endpoint="/chat", status="500").inc()
        logger.error(f"Chat completion error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/usage/{model}")
async def get_usage_stats(
    model: str,
    redis_client: redis.Redis = Depends(get_redis)
):
    """モデル使用統計"""
    try:
        usage_key = f"usage:{model}"
        usage_data = await redis_client.hgetall(usage_key)
        
        if not usage_data:
            return {"model": model, "total_requests": 0, "total_tokens": 0, "avg_processing_time": 0}
        
        return {
            "model": model,
            "total_requests": int(usage_data.get(b"requests", 0)),
            "total_tokens": int(usage_data.get(b"tokens", 0)),
            "avg_processing_time": float(usage_data.get(b"avg_time", 0))
        }
    except Exception as e:
        logger.error(f"Usage stats error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

# バックグラウンドタスク
async def log_usage(redis_client: redis.Redis, model: str, tokens: int, processing_time: float):
    """使用量をRedisに記録"""
    try:
        usage_key = f"usage:{model}"
        await redis_client.hincrby(usage_key, "requests", 1)
        await redis_client.hincrby(usage_key, "tokens", tokens)
        
        # 平均処理時間を更新
        current_avg = await redis_client.hget(usage_key, "avg_time")
        if current_avg:
            current_avg = float(current_avg)
            requests = await redis_client.hget(usage_key, "requests")
            new_avg = (current_avg * (int(requests) - 1) + processing_time) / int(requests)
        else:
            new_avg = processing_time
        
        await redis_client.hset(usage_key, "avg_time", new_avg)
        await redis_client.expire(usage_key, 86400 * 7)  # 7日間保持
        
    except Exception as e:
        logger.error(f"Usage logging error: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 