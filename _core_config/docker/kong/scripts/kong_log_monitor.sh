#!/bin/bash

# Kong Gateway ログ監視スクリプト
# 作成日: 2025年6月10日
# 目的: Kong API Gateway の運用状況をリアルタイム監視

set -euo pipefail

# 設定
KONG_CONTAINER="ai-kong"
LOG_DIR="/tmp/kong_logs"
ALERT_LOG="$LOG_DIR/alerts.log"
METRICS_LOG="$LOG_DIR/metrics.log"
ERROR_THRESHOLD=5  # 5分間でのエラー閾値
RESPONSE_TIME_THRESHOLD=1000  # 1秒以上のレスポンス時間

# ログディレクトリ作成
mkdir -p "$LOG_DIR"

echo "🔍 Kong Gateway ログ監視開始 $(date)"
echo "=== 設定 ==="
echo "Container: $KONG_CONTAINER"
echo "Error Threshold: $ERROR_THRESHOLD errors/5min"
echo "Response Time Threshold: ${RESPONSE_TIME_THRESHOLD}ms"
echo "Log Directory: $LOG_DIR"
echo "===================="

# ログ監視関数
monitor_kong_logs() {
    echo "📊 Kong ログ解析開始..."
    
    # 最新100行のログを取得・解析
    docker logs "$KONG_CONTAINER" --tail 100 2>/dev/null | while read -r line; do
        # エラーレスポンス検出（4xx, 5xx）
        if echo "$line" | grep -E " (4[0-9]{2}|5[0-9]{2}) " >/dev/null; then
            echo "⚠️  ERROR: $line" | tee -a "$ALERT_LOG"
        fi
        
        # レスポンス時間チェック（ここでは簡易実装）
        if echo "$line" | grep -E "HTTP/1\.[01]\" [0-9]{3}" >/dev/null; then
            echo "📈 REQUEST: $line" >> "$METRICS_LOG"
        fi
    done
}

# Kong ヘルスチェック
check_kong_health() {
    echo "🏥 Kong ヘルスチェック..."
    
    # Admin API ヘルスチェック
    if curl -sf "http://localhost:8001/status" >/dev/null; then
        echo "✅ Kong Admin API: 正常"
    else
        echo "❌ Kong Admin API: 異常" | tee -a "$ALERT_LOG"
        return 1
    fi
    
    # Proxy ヘルスチェック
    if curl -sf "http://localhost:8080" >/dev/null; then
        echo "✅ Kong Proxy: 正常"
    else
        echo "❌ Kong Proxy: 異常" | tee -a "$ALERT_LOG"
        return 1
    fi
    
    # データベース接続チェック
    db_status=$(curl -s "http://localhost:8001/status" | python3 -c "import sys, json; print(json.load(sys.stdin)['database']['reachable'])" 2>/dev/null || echo "false")
    if [ "$db_status" = "True" ]; then
        echo "✅ Kong Database: 正常"
    else
        echo "❌ Kong Database: 異常" | tee -a "$ALERT_LOG"
        return 1
    fi
}

# メトリクス収集
collect_metrics() {
    echo "📊 メトリクス収集..."
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Kong統計情報取得
    kong_stats=$(curl -s "http://localhost:8001/status" 2>/dev/null || echo '{"error": "connection_failed"}')
    
    # Prometheus メトリクス取得
    prometheus_metrics=$(curl -s "http://localhost:8080/metrics" 2>/dev/null | grep -E "kong_.*_total|kong_.*_bucket" | head -10 || echo "# メトリクス取得失敗")
    
    # メトリクスログ出力
    {
        echo "=== METRICS $timestamp ==="
        echo "Kong Stats: $kong_stats"
        echo "Prometheus Sample:"
        echo "$prometheus_metrics"
        echo "========================="
    } >> "$METRICS_LOG"
}

# アラート集計
check_alerts() {
    echo "🚨 アラート確認..."
    
    # 過去5分のエラー数カウント
    error_count=0
    if [ -f "$ALERT_LOG" ]; then
        # 簡易実装：最新行からエラー数をカウント
        error_count=$(tail -20 "$ALERT_LOG" 2>/dev/null | grep -c "ERROR:" || echo 0)
    fi
    
    if [ "$error_count" -gt "$ERROR_THRESHOLD" ]; then
        echo "🚨 高エラー率検出: ${error_count}件のエラー（閾値: $ERROR_THRESHOLD）"
        echo "$(date) - HIGH ERROR RATE: $error_count errors" >> "$ALERT_LOG"
    else
        echo "✅ エラー率正常: ${error_count}件"
    fi
}

# メイン監視ループ
main() {
    echo "🚀 Kong監視開始..."
    
    # 初期ヘルスチェック
    if ! check_kong_health; then
        echo "❌ Kong初期ヘルスチェック失敗"
        exit 1
    fi
    
    # 監視実行
    monitor_kong_logs
    collect_metrics
    check_alerts
    
    echo "✅ Kong監視サイクル完了 $(date)"
    echo "📁 ログファイル:"
    echo "   - アラート: $ALERT_LOG"
    echo "   - メトリクス: $METRICS_LOG"
}

# スクリプト実行
main "$@" 