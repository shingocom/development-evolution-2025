#!/bin/bash

# Kong Gateway 監視アラートシステム
# 作成日: 2025年6月10日
# 目的: プロダクション環境での包括的監視・アラート

set -euo pipefail

# 設定
KONG_ADMIN_URL="http://localhost:8001"
KONG_PROXY_URL="http://localhost:8080"
ALERT_LOG="/tmp/kong_alerts.log"
METRICS_LOG="/tmp/kong_metrics.log"
ALERT_EMAIL="admin@ai-development-2025.local"

# アラート閾値
ERROR_RATE_THRESHOLD=5        # 5% エラー率
RESPONSE_TIME_THRESHOLD=500   # 500ms レスポンス時間
MEMORY_THRESHOLD=80          # 80% メモリ使用率
CONNECTION_THRESHOLD=100     # 100 アクティブ接続
DATABASE_LAG_THRESHOLD=1000  # 1秒 データベース遅延

echo "🚨 Kong Gateway 監視アラートシステム"
echo "=================================="
echo "開始時刻: $(date)"

# ログ関数
log_alert() {
    local level="$1"
    local message="$2"
    echo "[$(date)] [$level] $message" | tee -a "$ALERT_LOG"
}

log_metric() {
    local metric="$1"
    local value="$2"
    echo "[$(date)] METRIC $metric=$value" >> "$METRICS_LOG"
}

# Kong接続確認
check_kong_connectivity() {
    echo "🔗 Kong接続性チェック..."
    
    # Admin API チェック
    if ! curl -sf "$KONG_ADMIN_URL/status" >/dev/null 2>&1; then
        log_alert "CRITICAL" "Kong Admin API unreachable"
        return 1
    fi
    
    # Proxy チェック
    proxy_status=$(curl -s -w "%{http_code}" "http://localhost:8080/" -o /dev/null 2>/dev/null || echo "000")
    if [ "$proxy_status" = "000" ]; then
        log_alert "CRITICAL" "Kong Proxy unreachable"
        return 1
    fi
    
    log_alert "INFO" "Kong connectivity: OK"
    return 0
}

# パフォーマンス監視
monitor_performance() {
    echo "⚡ パフォーマンス監視..."
    
    # Kong統計取得
    kong_stats=$(curl -s "$KONG_ADMIN_URL/status" 2>/dev/null || echo '{}')
    
    if [ "$kong_stats" = "{}" ]; then
        log_alert "ERROR" "Failed to retrieve Kong statistics"
        return 1
    fi
    
    # リクエスト統計
    total_requests=$(echo "$kong_stats" | python3 -c "import sys, json; print(json.load(sys.stdin).get('server', {}).get('total_requests', 0))" 2>/dev/null || echo 0)
    active_connections=$(echo "$kong_stats" | python3 -c "import sys, json; print(json.load(sys.stdin).get('server', {}).get('connections_active', 0))" 2>/dev/null || echo 0)
    
    log_metric "total_requests" "$total_requests"
    log_metric "active_connections" "$active_connections"
    
    # 接続数チェック
    if [ "$active_connections" -gt "$CONNECTION_THRESHOLD" ]; then
        log_alert "WARNING" "High active connections: $active_connections > $CONNECTION_THRESHOLD"
    fi
    
    # データベース接続チェック
    db_reachable=$(echo "$kong_stats" | python3 -c "import sys, json; print(json.load(sys.stdin).get('database', {}).get('reachable', False))" 2>/dev/null || echo False)
    if [ "$db_reachable" != "True" ]; then
        log_alert "CRITICAL" "Database unreachable"
    else
        log_metric "database_status" "healthy"
    fi
}

# セキュリティ監視
monitor_security() {
    echo "🛡️ セキュリティ監視..."
    
    # Rate Limiting状況確認
    plugins_response=$(curl -s "$KONG_ADMIN_URL/plugins" 2>/dev/null || echo '{"data": []}')
    rate_limiting_count=$(echo "$plugins_response" | python3 -c "import sys, json; plugins=json.load(sys.stdin)['data']; print(len([p for p in plugins if p['name']=='rate-limiting']))" 2>/dev/null || echo 0)
    
    log_metric "rate_limiting_plugins" "$rate_limiting_count"
    
    if [ "$rate_limiting_count" -eq 0 ]; then
        log_alert "WARNING" "No rate limiting plugins active"
    fi
    
    # Key Auth状況確認
    key_auth_count=$(echo "$plugins_response" | python3 -c "import sys, json; plugins=json.load(sys.stdin)['data']; print(len([p for p in plugins if p['name']=='key-auth']))" 2>/dev/null || echo 0)
    
    log_metric "key_auth_plugins" "$key_auth_count"
    
    if [ "$key_auth_count" -eq 0 ]; then
        log_alert "WARNING" "No key authentication plugins active"
    fi
}

# エラー率監視
monitor_error_rate() {
    echo "📊 エラー率監視..."
    
    # Kong ログから最新エラーをチェック
    error_count=0
    if docker logs ai-kong --tail 50 2>/dev/null | grep -E " (4[0-9]{2}|5[0-9]{2}) " >/dev/null; then
        error_count=$(docker logs ai-kong --tail 50 2>/dev/null | grep -c -E " (4[0-9]{2}|5[0-9]{2}) " || echo 0)
    fi
    
    log_metric "recent_errors" "$error_count"
    
    if [ "$error_count" -gt "$ERROR_RATE_THRESHOLD" ]; then
        log_alert "WARNING" "High error rate detected: $error_count errors in recent requests"
    fi
}

# レスポンス時間テスト
test_response_time() {
    echo "⏱️ レスポンス時間テスト..."
    
    # API Gateway レスポンス時間測定
    start_time=$(date +%s%3N)
    if curl -sf -H "X-API-Key: ai-dev-key-2025" "$KONG_PROXY_URL/api/v1/gateway/" >/dev/null 2>&1; then
        end_time=$(date +%s%3N)
        response_time=$((end_time - start_time))
        
        log_metric "api_gateway_response_time_ms" "$response_time"
        
        if [ "$response_time" -gt "$RESPONSE_TIME_THRESHOLD" ]; then
            log_alert "WARNING" "Slow API Gateway response: ${response_time}ms > ${RESPONSE_TIME_THRESHOLD}ms"
        else
            log_alert "INFO" "API Gateway response time: ${response_time}ms"
        fi
    else
        log_alert "ERROR" "API Gateway response test failed"
    fi
    
    # Ollama LLM レスポンス時間測定
    start_time=$(date +%s%3N)
    if curl -sf "$KONG_PROXY_URL/api/v1/llm/api/tags" >/dev/null 2>&1; then
        end_time=$(date +%s%3N)
        response_time=$((end_time - start_time))
        
        log_metric "ollama_response_time_ms" "$response_time"
        
        if [ "$response_time" -gt "$RESPONSE_TIME_THRESHOLD" ]; then
            log_alert "WARNING" "Slow Ollama response: ${response_time}ms > ${RESPONSE_TIME_THRESHOLD}ms"
        else
            log_alert "INFO" "Ollama response time: ${response_time}ms"
        fi
    else
        log_alert "ERROR" "Ollama response test failed"
    fi
}

# アラート集計・通知
generate_alert_summary() {
    echo "📋 アラート集計..."
    
    if [ ! -f "$ALERT_LOG" ]; then
        echo "アラートログなし"
        return 0
    fi
    
    # 最近のアラート統計
    critical_count=$(grep -c "\[CRITICAL\]" "$ALERT_LOG" 2>/dev/null || echo 0)
    warning_count=$(grep -c "\[WARNING\]" "$ALERT_LOG" 2>/dev/null || echo 0)
    error_count=$(grep -c "\[ERROR\]" "$ALERT_LOG" 2>/dev/null || echo 0)
    
    echo "📊 アラート統計:"
    echo "  CRITICAL: $critical_count"
    echo "  WARNING: $warning_count"
    echo "  ERROR: $error_count"
    
    # 重要アラートがある場合の通知準備
    if [ "$critical_count" -gt 0 ] || [ "$warning_count" -gt 3 ]; then
        echo "🚨 注意が必要なアラートが検出されました"
        echo "最新のCRITICAL/WARNINGアラート:"
        tail -10 "$ALERT_LOG" | grep -E "\[(CRITICAL|WARNING)\]" || echo "なし"
    fi
}

# ヘルスチェックレポート
generate_health_report() {
    echo "🏥 Kong ヘルスレポート生成..."
    
    report_file="/tmp/kong_health_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Kong Gateway ヘルスレポート"
        echo "========================="
        echo "生成日時: $(date)"
        echo ""
        
        echo "=== システム状況 ==="
        curl -s "$KONG_ADMIN_URL/status" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'総リクエスト数: {data[\"server\"][\"total_requests\"]}')
    print(f'アクティブ接続: {data[\"server\"][\"connections_active\"]}')
    print(f'Worker数: {len(data[\"memory\"][\"workers_lua_vms\"])}')
    print(f'データベース: {\"正常\" if data[\"database\"][\"reachable\"] else \"異常\"}')
except:
    print('統計情報取得失敗')
"
        
        echo ""
        echo "=== 設定概要 ==="
        curl -s "$KONG_ADMIN_URL/services" | python3 -c "import sys, json; print(f'Services: {len(json.load(sys.stdin)[\"data\"])}件')" 2>/dev/null
        curl -s "$KONG_ADMIN_URL/routes" | python3 -c "import sys, json; print(f'Routes: {len(json.load(sys.stdin)[\"data\"])}件')" 2>/dev/null  
        curl -s "$KONG_ADMIN_URL/consumers" | python3 -c "import sys, json; print(f'Consumers: {len(json.load(sys.stdin)[\"data\"])}件')" 2>/dev/null
        curl -s "$KONG_ADMIN_URL/plugins" | python3 -c "import sys, json; print(f'Plugins: {len(json.load(sys.stdin)[\"data\"])}件')" 2>/dev/null
        
        if [ -f "$ALERT_LOG" ]; then
            echo ""
            echo "=== 最新アラート ==="
            tail -5 "$ALERT_LOG"
        fi
        
    } > "$report_file"
    
    echo "✅ ヘルスレポート生成完了: $report_file"
}

# メイン監視実行
main() {
    echo "🚀 Kong監視開始..."
    
    # 各監視項目実行
    check_kong_connectivity || exit 1
    monitor_performance
    monitor_security
    monitor_error_rate
    test_response_time
    
    # レポート生成
    generate_alert_summary
    generate_health_report
    
    echo "✅ Kong監視完了 $(date)"
    echo "📁 ログファイル:"
    echo "   - アラート: $ALERT_LOG"
    echo "   - メトリクス: $METRICS_LOG"
}

# 実行
main "$@" 