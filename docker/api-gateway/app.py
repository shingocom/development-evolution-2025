#!/usr/bin/env python3
"""
AI Development API Gateway
Kong統合用のシンプルなAPI Gatewayサービス
"""

import os
import json
import time
import logging
from datetime import datetime
from typing import Dict, Any

import uvicorn
import redis
import psycopg2
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# ログ設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPIアプリケーション初期化
app = FastAPI(
    title="AI Development API Gateway",
    description="Kong統合API Gateway for AI Development Platform",
    version="1.0.0"
)

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 環境変数
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://ai_user:ai-development-2025@localhost:5432/ai_development")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")

# グローバル接続
redis_client = None
db_connection = None

def init_connections():
    """データベース・Redis接続初期化"""
    global redis_client, db_connection
    
    try:
        # Redis接続
        redis_client = redis.from_url(REDIS_URL, decode_responses=True)
        redis_client.ping()
        logger.info("✅ Redis接続成功")
        
        # PostgreSQL接続
        db_connection = psycopg2.connect(DATABASE_URL)
        logger.info("✅ PostgreSQL接続成功")
        
    except Exception as e:
        logger.error(f"❌ 接続エラー: {e}")

@app.on_event("startup")
async def startup_event():
    """起動時処理"""
    logger.info("🚀 API Gateway起動開始...")
    init_connections()
    logger.info("✅ API Gateway起動完了")

@app.get("/")
async def root():
    """ルートエンドポイント"""
    return {
        "service": "AI Development API Gateway",
        "version": "1.0.0",
        "status": "running",
        "timestamp": datetime.now().isoformat(),
        "kong_integration": "ready"
    }

@app.get("/health")
async def health_check():
    """ヘルスチェックエンドポイント"""
    health_status = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "services": {}
    }
    
    try:
        # Redis ヘルスチェック
        if redis_client:
            redis_client.ping()
            health_status["services"]["redis"] = "healthy"
        else:
            health_status["services"]["redis"] = "unhealthy"
            
        # PostgreSQL ヘルスチェック
        if db_connection and not db_connection.closed:
            with db_connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            health_status["services"]["postgresql"] = "healthy"
        else:
            health_status["services"]["postgresql"] = "unhealthy"
            
        # 全体ステータス判定
        unhealthy_services = [k for k, v in health_status["services"].items() if v == "unhealthy"]
        if unhealthy_services:
            health_status["status"] = "degraded"
            health_status["unhealthy_services"] = unhealthy_services
            
    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["error"] = str(e)
        
    return health_status

@app.get("/api/status")
async def api_status():
    """API統計情報"""
    try:
        stats = {
            "api_gateway": {
                "uptime": "running",
                "requests_handled": "tracking",
                "last_health_check": datetime.now().isoformat()
            },
            "integrations": {
                "kong_gateway": "active",
                "redis_cache": "connected",
                "postgresql_db": "connected",
                "ollama_llm": "available"
            }
        }
        
        if redis_client:
            # Redis統計
            stats["redis_info"] = {
                "connected_clients": "available",
                "used_memory": "monitoring",
                "keyspace": "active"
            }
            
        return stats
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Statistics error: {str(e)}")

@app.get("/api/metrics")
async def get_metrics():
    """メトリクス情報（Kong Prometheus統合用）"""
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "api_gateway_requests_total": "counter",
        "api_gateway_request_duration_seconds": "histogram",
        "api_gateway_active_connections": "gauge",
        "redis_operations_total": "counter",
        "database_queries_total": "counter"
    }
    
    return metrics

@app.post("/api/cache/set")
async def cache_set(request: Request):
    """Redis キャッシュ設定"""
    try:
        data = await request.json()
        key = data.get("key")
        value = data.get("value")
        ttl = data.get("ttl", 3600)  # デフォルト1時間
        
        if not key or value is None:
            raise HTTPException(status_code=400, detail="Key and value are required")
            
        if redis_client:
            redis_client.setex(key, ttl, json.dumps(value))
            return {"status": "success", "key": key, "ttl": ttl}
        else:
            raise HTTPException(status_code=503, detail="Redis not available")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Cache set error: {str(e)}")

@app.get("/api/cache/get/{key}")
async def cache_get(key: str):
    """Redis キャッシュ取得"""
    try:
        if redis_client:
            value = redis_client.get(key)
            if value:
                return {"key": key, "value": json.loads(value), "found": True}
            else:
                return {"key": key, "value": None, "found": False}
        else:
            raise HTTPException(status_code=503, detail="Redis not available")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Cache get error: {str(e)}")

@app.get("/api/info")
async def gateway_info():
    """API Gateway情報"""
    return {
        "name": "AI Development API Gateway",
        "version": "1.0.0",
        "environment": {
            "redis_url": REDIS_URL.replace(REDIS_URL.split('@')[1] if '@' in REDIS_URL else '', '***') if REDIS_URL else None,
            "database_url": "postgresql://***@***/ai_development",
            "ollama_url": OLLAMA_URL
        },
        "features": [
            "Kong Integration",
            "Redis Caching", 
            "PostgreSQL Database",
            "Health Monitoring",
            "Metrics Collection"
        ],
        "endpoints": {
            "health": "/health",
            "status": "/api/status",
            "metrics": "/api/metrics",
            "cache": "/api/cache/*",
            "info": "/api/info"
        }
    }

if __name__ == "__main__":
    logger.info("🚀 Starting AI Development API Gateway...")
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        log_level="info",
        access_log=True
    ) 