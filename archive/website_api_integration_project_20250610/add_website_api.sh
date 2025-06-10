#!/bin/bash

# Website API Kong Gateway統合スクリプト
# 作成日: 2025年6月10日
# 目的: 外部Website APIの簡単Kong統合

set -euo pipefail

# Kong設定
KONG_ADMIN_URL="http://localhost:8001"
KONG_PROXY_URL="http://localhost:8080"

# スクリプト使用方法
usage() {
    echo "🔗 Website API Kong Gateway統合スクリプト"
    echo "========================================="
    echo ""
    echo "使用方法:"
    echo "  $0 <API_NAME> <API_URL> <KONG_PATH> [OPTIONS]"
    echo ""
    echo "引数:"
    echo "  API_NAME    : APIサービス名 (例: twitter-api)"
    echo "  API_URL     : API URL (例: https://api.twitter.com)"
    echo "  KONG_PATH   : Kong経由パス (例: /api/v1/twitter)"
    echo ""
    echo "オプション:"
    echo "  --auth      : API Key認証を有効化"
    echo "  --rate-limit: Rate Limiting適用 (デフォルト: 100req/min)"
    echo "  --cors      : CORS設定適用"
    echo "  --monitoring: Prometheus監視適用"
    echo ""
    echo "使用例:"
    echo "  $0 twitter-api https://api.twitter.com /api/v1/twitter --auth --rate-limit"
    echo "  $0 github-api https://api.github.com /api/v1/github --auth --cors --monitoring"
}

# パラメータチェック
if [ $# -lt 3 ]; then
    usage
    exit 1
fi

API_NAME="$1"
API_URL="$2"
KONG_PATH="$3"
shift 3

# オプション解析
ENABLE_AUTH=false
ENABLE_RATE_LIMIT=false
ENABLE_CORS=false
ENABLE_MONITORING=false
RATE_LIMIT_MINUTE=100
RATE_LIMIT_HOUR=1000

while [[ $# -gt 0 ]]; do
    case $1 in
        --auth)
            ENABLE_AUTH=true
            shift
            ;;
        --rate-limit)
            ENABLE_RATE_LIMIT=true
            shift
            ;;
        --cors)
            ENABLE_CORS=true
            shift
            ;;
        --monitoring)
            ENABLE_MONITORING=true
            shift
            ;;
        --rate-minute)
            RATE_LIMIT_MINUTE="$2"
            shift 2
            ;;
        --rate-hour)
            RATE_LIMIT_HOUR="$2"
            shift 2
            ;;
        *)
            echo "❌ 不明なオプション: $1"
            usage
            exit 1
            ;;
    esac
done

echo "🚀 Website API Kong統合開始..."
echo "================================"
echo "API名: $API_NAME"
echo "API URL: $API_URL"
echo "Kong パス: $KONG_PATH"
echo "認証: $ENABLE_AUTH"
echo "Rate Limiting: $ENABLE_RATE_LIMIT"
echo "CORS: $ENABLE_CORS"
echo "監視: $ENABLE_MONITORING"
echo ""

# Step 1: Kong Service作成
echo "📝 Step 1: Kong Service作成..."
SERVICE_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services" \
    -d "name=$API_NAME" \
    -d "url=$API_URL" \
    2>/dev/null || echo '{"error": "service creation failed"}')

if echo "$SERVICE_RESPONSE" | grep -q "error"; then
    echo "❌ Service作成エラー: $SERVICE_RESPONSE"
    exit 1
fi

SERVICE_ID=$(echo "$SERVICE_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "")
if [ -z "$SERVICE_ID" ]; then
    echo "❌ Service ID取得失敗"
    exit 1
fi

echo "✅ Service作成完了: $SERVICE_ID"

# Step 2: Kong Route作成
echo "📝 Step 2: Kong Route作成..."
ROUTE_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services/$SERVICE_ID/routes" \
    -d "paths[]=$KONG_PATH" \
    -d "methods[]=GET" \
    -d "methods[]=POST" \
    -d "methods[]=PUT" \
    -d "methods[]=DELETE" \
    -d "methods[]=PATCH" \
    2>/dev/null || echo '{"error": "route creation failed"}')

if echo "$ROUTE_RESPONSE" | grep -q "error"; then
    echo "❌ Route作成エラー: $ROUTE_RESPONSE"
    exit 1
fi

ROUTE_ID=$(echo "$ROUTE_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "")
echo "✅ Route作成完了: $ROUTE_ID"

# Step 3: Plugin設定
echo "📝 Step 3: Plugin設定..."

# API Key認証
if [ "$ENABLE_AUTH" = true ]; then
    echo "🔐 API Key認証プラグイン追加..."
    AUTH_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services/$SERVICE_ID/plugins" \
        -d "name=key-auth" \
        -d "config.key_names[]=X-API-Key" \
        -d "config.key_names[]=apikey" \
        2>/dev/null)
    
    if echo "$AUTH_RESPONSE" | grep -q "id"; then
        echo "✅ API Key認証プラグイン追加完了"
    else
        echo "⚠️ API Key認証プラグイン追加失敗: $AUTH_RESPONSE"
    fi
fi

# Rate Limiting
if [ "$ENABLE_RATE_LIMIT" = true ]; then
    echo "⏱️ Rate Limitingプラグイン追加..."
    RATE_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services/$SERVICE_ID/plugins" \
        -d "name=rate-limiting" \
        -d "config.minute=$RATE_LIMIT_MINUTE" \
        -d "config.hour=$RATE_LIMIT_HOUR" \
        -d "config.policy=local" \
        2>/dev/null)
    
    if echo "$RATE_RESPONSE" | grep -q "id"; then
        echo "✅ Rate Limitingプラグイン追加完了 ($RATE_LIMIT_MINUTE req/min, $RATE_LIMIT_HOUR req/hour)"
    else
        echo "⚠️ Rate Limitingプラグイン追加失敗: $RATE_RESPONSE"
    fi
fi

# CORS
if [ "$ENABLE_CORS" = true ]; then
    echo "🌐 CORSプラグイン追加..."
    CORS_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services/$SERVICE_ID/plugins" \
        -d "name=cors" \
        -d "config.origins[]=http://localhost:3000" \
        -d "config.origins[]=http://localhost:8080" \
        -d "config.origins[]=https://localhost:3000" \
        -d "config.methods[]=GET" \
        -d "config.methods[]=POST" \
        -d "config.methods[]=PUT" \
        -d "config.methods[]=DELETE" \
        -d "config.headers[]=Accept" \
        -d "config.headers[]=Accept-Version" \
        -d "config.headers[]=Content-Length" \
        -d "config.headers[]=Content-MD5" \
        -d "config.headers[]=Content-Type" \
        -d "config.headers[]=Date" \
        -d "config.headers[]=X-Auth-Token" \
        -d "config.headers[]=X-API-Key" \
        2>/dev/null)
    
    if echo "$CORS_RESPONSE" | grep -q "id"; then
        echo "✅ CORSプラグイン追加完了"
    else
        echo "⚠️ CORSプラグイン追加失敗: $CORS_RESPONSE"
    fi
fi

# Prometheus監視
if [ "$ENABLE_MONITORING" = true ]; then
    echo "📊 Prometheus監視プラグイン追加..."
    PROMETHEUS_RESPONSE=$(curl -s -X POST "$KONG_ADMIN_URL/services/$SERVICE_ID/plugins" \
        -d "name=prometheus" \
        2>/dev/null)
    
    if echo "$PROMETHEUS_RESPONSE" | grep -q "id"; then
        echo "✅ Prometheus監視プラグイン追加完了"
    else
        echo "⚠️ Prometheus監視プラグイン追加失敗: $PROMETHEUS_RESPONSE"
    fi
fi

# Step 4: 設定確認
echo "📝 Step 4: 設定確認..."
echo "🔍 作成されたService:"
curl -s "$KONG_ADMIN_URL/services/$SERVICE_ID" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'  ID: {data[\"id\"]}')
    print(f'  名前: {data[\"name\"]}')
    print(f'  URL: {data[\"protocol\"]}://{data[\"host\"]}:{data[\"port\"]}')
except:
    print('  設定確認エラー')
"

echo "🔍 作成されたRoute:"
curl -s "$KONG_ADMIN_URL/routes/$ROUTE_ID" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'  ID: {data[\"id\"]}')
    print(f'  パス: {data[\"paths\"]}')
    print(f'  メソッド: {data[\"methods\"]}')
except:
    print('  Route確認エラー')
"

# Step 5: テスト用コマンド生成
echo ""
echo "🧪 テストコマンド:"
echo "================================"

if [ "$ENABLE_AUTH" = true ]; then
    echo "# 認証付きテスト (ai-dev-key-2025 API Key使用):"
    echo "curl -H \"X-API-Key: ai-dev-key-2025\" \"$KONG_PROXY_URL$KONG_PATH\""
    echo ""
    echo "# 新しいConsumer・API Key作成が必要な場合:"
    echo "curl -X POST $KONG_ADMIN_URL/consumers -d \"username=${API_NAME}-user\""
    echo "curl -X POST $KONG_ADMIN_URL/consumers/${API_NAME}-user/key-auth -d \"key=${API_NAME}-api-key-2025\""
else
    echo "# 認証なしテスト:"
    echo "curl \"$KONG_PROXY_URL$KONG_PATH\""
fi

echo ""
echo "# Kong設定確認:"
echo "curl $KONG_ADMIN_URL/services/$SERVICE_ID"
echo "curl $KONG_ADMIN_URL/routes/$ROUTE_ID"
echo "curl $KONG_ADMIN_URL/services/$SERVICE_ID/plugins"

echo ""
echo "✅ Website API Kong統合完了!"
echo "Kong Proxy URL: $KONG_PROXY_URL$KONG_PATH"
echo "元のAPI URL: $API_URL" 