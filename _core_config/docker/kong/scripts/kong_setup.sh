#!/bin/bash

# =================================================================
# Kong API Gateway 初期設定スクリプト
# =================================================================

set -e

echo "🚀 Kong API Gateway 初期設定開始..."

# Kong Admin API URL
KONG_ADMIN_URL="http://localhost:8001"

# Kong健康チェック
wait_for_kong() {
    echo "⏳ Kong起動を待機中..."
    for i in {1..60}; do
        if curl -s "$KONG_ADMIN_URL" > /dev/null 2>&1; then
            echo "✅ Kong Admin API接続確認"
            return 0
        fi
        echo "  待機中... ($i/60)"
        sleep 5
    done
    echo "❌ Kong起動タイムアウト"
    exit 1
}

# サービス作成関数
create_service() {
    local name=$1
    local url=$2
    
    echo "📡 サービス作成: $name"
    curl -s -X POST "$KONG_ADMIN_URL/services" \
        -d "name=$name" \
        -d "url=$url" \
        -d "protocol=http" \
        -d "connect_timeout=60000" \
        -d "write_timeout=60000" \
        -d "read_timeout=60000" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ サービス '$name' 作成完了"
    else
        echo "⚠️  サービス '$name' 作成スキップ（既存またはエラー）"
    fi
}

# ルート作成関数
create_route() {
    local service_name=$1
    local path=$2
    local methods=$3
    
    echo "🛣️  ルート作成: $service_name → $path"
    curl -s -X POST "$KONG_ADMIN_URL/services/$service_name/routes" \
        -d "paths[]=$path" \
        -d "methods[]=$methods" \
        -d "strip_path=true" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ ルート '$path' 作成完了"
    else
        echo "⚠️  ルート '$path' 作成スキップ（既存またはエラー）"
    fi
}

# プラグイン適用関数
apply_plugin() {
    local service_name=$1
    local plugin_name=$2
    local config=$3
    
    echo "🔌 プラグイン適用: $plugin_name → $service_name"
    curl -s -X POST "$KONG_ADMIN_URL/services/$service_name/plugins" \
        -d "name=$plugin_name" \
        $config > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ プラグイン '$plugin_name' 適用完了"
    else
        echo "⚠️  プラグイン '$plugin_name' 適用スキップ（既存またはエラー）"
    fi
}

# Kong起動待機
wait_for_kong

echo ""
echo "🏗️  サービス・ルート設定開始..."

# 1. API Gateway Service
create_service "api-gateway" "http://api-gateway:8000"
create_route "api-gateway" "/api/v1/gateway" "GET,POST,PUT,DELETE"

# 2. Ollama LLM Service
create_service "ollama-llm" "http://ollama:11434"
create_route "ollama-llm" "/api/v1/llm" "GET,POST"

# 3. N8N Workflow Service (将来対応)
create_service "n8n-workflow" "http://n8n:5678"
create_route "n8n-workflow" "/api/v1/workflow" "GET,POST,PUT,DELETE"

# 4. Jupyter Lab Service (将来対応)
create_service "jupyter-lab" "http://jupyter:8888"
create_route "jupyter-lab" "/api/v1/jupyter" "GET,POST"

echo ""
echo "🔒 セキュリティプラグイン設定..."

# Rate Limiting プラグイン
apply_plugin "api-gateway" "rate-limiting" "-d config.minute=100 -d config.hour=1000"
apply_plugin "ollama-llm" "rate-limiting" "-d config.minute=50 -d config.hour=500"

# CORS プラグイン
apply_plugin "api-gateway" "cors" "-d config.origins=http://localhost:*,http://127.0.0.1:*"
apply_plugin "ollama-llm" "cors" "-d config.origins=http://localhost:*,http://127.0.0.1:*"

# Prometheus メトリクス
curl -s -X POST "$KONG_ADMIN_URL/plugins" \
    -d "name=prometheus" \
    -d "config.per_consumer=true" > /dev/null

echo "✅ Prometheusメトリクス有効化完了"

echo ""
echo "📊 設定確認..."

# 設定確認
echo "🔍 登録サービス一覧:"
curl -s "$KONG_ADMIN_URL/services" | python3 -m json.tool | grep '"name"' || echo "  設定確認スキップ"

echo ""
echo "🔍 登録ルート一覧:"
curl -s "$KONG_ADMIN_URL/routes" | python3 -m json.tool | grep '"paths"' || echo "  設定確認スキップ"

echo ""
echo "🎉 Kong初期設定完了！"
echo ""
echo "📡 Kong API Gateway アクセス情報:"
echo "  Admin API: http://localhost:8001"
echo "  Proxy:     http://localhost:8080"
echo "  Manager:   http://localhost:8002"
echo ""
echo "🔗 テスト用URL:"
echo "  API Gateway: http://localhost:8080/api/v1/gateway/"
echo "  Ollama LLM:  http://localhost:8080/api/v1/llm/"
echo "" 