#!/bin/bash
# === AI Agent最適化環境 セキュリティ監査スクリプト ===
# ~/Development/maintenance/scripts/security_audit.sh

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$HOME/Development/_project_management/status/security_audit.log"
ALERT_FILE="$HOME/Development/_project_management/status/security_alerts.md"

echo "🔍 セキュリティ監査開始: $TIMESTAMP"
echo "🔍 セキュリティ監査開始: $TIMESTAMP" >> "$LOG_FILE"

# ===== 1. API Key セキュリティチェック =====
check_api_keys() {
    echo "📋 APIキーセキュリティチェック..."
    
    # 平文APIキー検出（リアルタイムチェック）
    cd "$HOME/Development"
    local found_keys=false
    
    # 実際のファイル検索
    local files_with_keys=$(find . -type f \( -name "*.json" -o -name "*.md" -o -name "*.txt" \) -exec grep -l "patn[0-9A-Za-z]" {} \; 2>/dev/null)
    
    if [ -n "$files_with_keys" ]; then
        echo "$files_with_keys" | while read -r file; do
            if [ -f "$file" ]; then
                echo "⚠️  平文APIキー検出: $file" | tee -a "$LOG_FILE"
                found_keys=true
                
                # アラートファイルに記録
                echo "## 🚨 セキュリティアラート - $TIMESTAMP" >> "$ALERT_FILE"
                echo "**問題**: 平文APIキー検出" >> "$ALERT_FILE"
                echo "**ファイル**: $file" >> "$ALERT_FILE"
                echo "**対応**: 即座に環境変数化または削除" >> "$ALERT_FILE"
                echo "" >> "$ALERT_FILE"
            fi
        done
        found_keys=true
    fi
    
    if [ "$found_keys" = false ]; then
        echo "✅ APIキーセキュリティ: 正常" | tee -a "$LOG_FILE"
        return 0
    else
        return 1
    fi
}

# ===== 2. ファイル権限チェック =====
check_file_permissions() {
    echo "📋 ファイル権限チェック..."
    
    # .env.secure の権限確認
    if [ -f "$HOME/.env.secure" ]; then
        local perms=$(stat -f "%Lp" "$HOME/.env.secure")
        if [ "$perms" != "600" ]; then
            echo "⚠️  警告: .env.secure の権限が不適切 ($perms)" | tee -a "$LOG_FILE"
            echo "## 🚨 セキュリティアラート - $TIMESTAMP" >> "$ALERT_FILE"
            echo "**問題**: .env.secure 権限不適切 ($perms)" >> "$ALERT_FILE"
            echo "**対応**: chmod 600 ~/.env.secure" >> "$ALERT_FILE"
            echo "" >> "$ALERT_FILE"
            return 1
        else
            echo "✅ .env.secure 権限: 正常 (600)" | tee -a "$LOG_FILE"
        fi
    fi
    
    return 0
}

# ===== 3. MCP設定検証 =====
check_mcp_config() {
    echo "📋 MCP設定検証..."
    
    local mcp_file="$HOME/.cursor/mcp.json"
    if [ -f "$mcp_file" ]; then
        # JSON形式確認
        if ! python3 -m json.tool "$mcp_file" > /dev/null 2>&1; then
            echo "⚠️  警告: MCP設定ファイルが無効なJSON" | tee -a "$LOG_FILE"
            return 1
        fi
        
        # 環境変数使用確認
        local plain_keys=$(grep -v '${' "$mcp_file" | grep -E '(API_KEY|Authorization)' | grep -v 'Bearer ${' || true)
        if [ -n "$plain_keys" ]; then
            echo "⚠️  警告: MCP設定に平文APIキー検出" | tee -a "$LOG_FILE"
            return 1
        fi
        
        echo "✅ MCP設定: 正常" | tee -a "$LOG_FILE"
    else
        echo "⚠️  警告: MCP設定ファイルが存在しません" | tee -a "$LOG_FILE"
        return 1
    fi
    
    return 0
}

# ===== 4. プロジェクト健全性チェック =====
check_project_health() {
    echo "📋 プロジェクト健全性チェック..."
    
    local projects=("flux-lab" "llama-lab" "sd-lab")
    local healthy=0
    local total=${#projects[@]}
    
    for project in "${projects[@]}"; do
        local project_path="$HOME/$project"
        if [ -d "$project_path" ]; then
            local file_count=$(find "$project_path" -type f | wc -l)
            echo "  ✅ $project: $file_count ファイル" | tee -a "$LOG_FILE"
            ((healthy++))
        else
            echo "  ❌ $project: ディレクトリが存在しません" | tee -a "$LOG_FILE"
        fi
    done
    
    echo "📊 プロジェクト健全性: $healthy/$total 正常" | tee -a "$LOG_FILE"
    return 0
}

# ===== 5. ディスク使用量チェック =====
check_disk_usage() {
    echo "📋 ディスク使用量チェック..."
    
    local development_usage=$(du -sh "$HOME/Development" | cut -f1)
    local total_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    echo "💾 Development: $development_usage" | tee -a "$LOG_FILE"
    echo "💾 ホーム使用率: ${total_usage}%" | tee -a "$LOG_FILE"
    
    if [ "$total_usage" -gt 90 ]; then
        echo "⚠️  警告: ディスク使用率が90%を超過" | tee -a "$LOG_FILE"
        echo "## 🚨 リソースアラート - $TIMESTAMP" >> "$ALERT_FILE"
        echo "**問題**: ディスク使用率高 (${total_usage}%)" >> "$ALERT_FILE"
        echo "**対応**: クリーンアップ実行推奨" >> "$ALERT_FILE"
        echo "" >> "$ALERT_FILE"
    fi
    
    return 0
}

# ===== メイン実行 =====
main() {
    local errors=0
    
    echo "🔍 AI Agent最適化環境 セキュリティ監査" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
    
    check_api_keys || ((errors++))
    check_file_permissions || ((errors++))
    check_mcp_config || ((errors++))
    check_project_health
    check_disk_usage
    
    echo "========================================" | tee -a "$LOG_FILE"
    
    if [ $errors -eq 0 ]; then
        echo "✅ セキュリティ監査完了: 問題なし" | tee -a "$LOG_FILE"
        echo "📊 監査終了: $TIMESTAMP" | tee -a "$LOG_FILE"
        return 0
    else
        echo "⚠️  セキュリティ監査完了: $errors 個の問題検出" | tee -a "$LOG_FILE"
        echo "📋 詳細は $ALERT_FILE を確認してください" | tee -a "$LOG_FILE"
        echo "📊 監査終了: $TIMESTAMP" | tee -a "$LOG_FILE"
        return 1
    fi
}

# スクリプト実行
main "$@" 