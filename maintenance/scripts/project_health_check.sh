#!/bin/bash
# === AI Agent最適化環境 プロジェクト健全性チェック ===
# ~/Development/maintenance/scripts/project_health_check.sh

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$HOME/Development/_project_management/status/project_health.log"
REPORT_FILE="$HOME/Development/_project_management/status/project_health_report.md"

echo "🔍 プロジェクト健全性チェック開始: $TIMESTAMP"

# ===== 1. AI Agent最適化プロジェクト =====
check_development_project() {
    echo "📋 AI Agent最適化プロジェクト確認..."
    
    local dev_path="$HOME/Development"
    local structure_ok=true
    
    # 重要ディレクトリの確認
    local required_dirs=(
        "_ai_workspace"
        "_core_config"
        "_project_management"
        "maintenance"
        "active_projects"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dev_path/$dir" ]; then
            local file_count=$(find "$dev_path/$dir" -type f | wc -l)
            echo "  ✅ $dir: $file_count ファイル" | tee -a "$LOG_FILE"
        else
            echo "  ❌ $dir: ディレクトリが存在しません" | tee -a "$LOG_FILE"
            structure_ok=false
        fi
    done
    
    # 重要ファイルの確認
    local required_files=(
        "README.md"
        "AI_AGENT_OPTIMIZATION_PLAN.md"
        "CURRENT_STATE_INVENTORY.md"
        "_ai_workspace/context/current_session.md"
        "_ai_workspace/context/project_overview.md"
        "_project_management/status/active_tasks.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$dev_path/$file" ]; then
            local size=$(wc -c < "$dev_path/$file")
            echo "  ✅ $file: ${size}B" | tee -a "$LOG_FILE"
        else
            echo "  ❌ $file: ファイルが存在しません" | tee -a "$LOG_FILE"
            structure_ok=false
        fi
    done
    
    if $structure_ok; then
        echo "✅ AI Agent最適化プロジェクト: 正常" | tee -a "$LOG_FILE"
        return 0
    else
        echo "⚠️  AI Agent最適化プロジェクト: 問題あり" | tee -a "$LOG_FILE"
        return 1
    fi
}

# ===== 2. 実験プロジェクト群 =====
check_lab_projects() {
    echo "📋 実験プロジェクト群確認..."
    
    local projects=(
        "flux-lab:FLUX.1 WebUI"
        "llama-lab:LLaMA実験環境"
        "sd-lab:Stable Diffusion"
    )
    
    local healthy=0
    local total=${#projects[@]}
    
    for project_info in "${projects[@]}"; do
        local project=$(echo "$project_info" | cut -d: -f1)
        local description=$(echo "$project_info" | cut -d: -f2)
        local project_path="$HOME/$project"
        
        if [ -d "$project_path" ]; then
            local file_count=$(find "$project_path" -type f | wc -l)
            local dir_count=$(find "$project_path" -type d | wc -l)
            local total_size=$(du -sh "$project_path" | cut -f1)
            
            echo "  ✅ $project ($description)" | tee -a "$LOG_FILE"
            echo "    📁 $file_count ファイル, $dir_count ディレクトリ, $total_size" | tee -a "$LOG_FILE"
            
            # 重要ファイルの確認
            if [ -f "$project_path/.cursorrules" ]; then
                echo "    📋 .cursorrules 設定済み" | tee -a "$LOG_FILE"
            fi
            
            if [ -f "$project_path/README.md" ] || [ -f "$project_path/readme.md" ]; then
                echo "    📖 README ドキュメント確認" | tee -a "$LOG_FILE"
            fi
            
            ((healthy++))
        else
            echo "  ❌ $project ($description): ディレクトリが存在しません" | tee -a "$LOG_FILE"
        fi
        echo "" | tee -a "$LOG_FILE"
    done
    
    echo "📊 実験プロジェクト健全性: $healthy/$total 正常" | tee -a "$LOG_FILE"
    return 0
}

# ===== 3. MCP統合状況 =====
check_mcp_integration() {
    echo "📋 MCP統合状況確認..."
    
    local mcp_file="$HOME/.cursor/mcp.json"
    if [ -f "$mcp_file" ]; then
        echo "  ✅ MCP設定ファイル存在" | tee -a "$LOG_FILE"
        
        # サーバー数確認
        local server_count=$(python3 -c "
import json
with open('$mcp_file') as f:
    data = json.load(f)
    print(len(data.get('mcpServers', {})))
" 2>/dev/null || echo "0")
        
        echo "  📊 MCP servers: $server_count 個" | tee -a "$LOG_FILE"
        
        # filesystem設定確認
        if grep -q "flux-lab" "$mcp_file" && grep -q "llama-lab" "$mcp_file" && grep -q "sd-lab" "$mcp_file"; then
            echo "  ✅ 全実験プロジェクトがMCPアクセス可能" | tee -a "$LOG_FILE"
        else
            echo "  ⚠️  一部実験プロジェクトがMCPアクセス不可" | tee -a "$LOG_FILE"
        fi
    else
        echo "  ❌ MCP設定ファイルが存在しません" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # 環境変数ファイル確認
    if [ -f "$HOME/.env.secure" ]; then
        echo "  ✅ セキュア環境変数ファイル存在" | tee -a "$LOG_FILE"
        local key_count=$(grep -c "^export" "$HOME/.env.secure" || echo "0")
        echo "  🔑 環境変数: $key_count 個" | tee -a "$LOG_FILE"
    else
        echo "  ❌ セキュア環境変数ファイルが存在しません" | tee -a "$LOG_FILE"
        return 1
    fi
    
    return 0
}

# ===== 4. 自動化システム状況 =====
check_automation_status() {
    echo "📋 自動化システム状況確認..."
    
    local scripts_dir="$HOME/Development/maintenance/scripts"
    local automation_health=true
    
    # 重要スクリプトの確認
    local required_scripts=(
        "security_audit.sh"
        "project_health_check.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [ -f "$scripts_dir/$script" ]; then
            if [ -x "$scripts_dir/$script" ]; then
                echo "  ✅ $script: 実行可能" | tee -a "$LOG_FILE"
            else
                echo "  ⚠️  $script: 実行権限なし" | tee -a "$LOG_FILE"
                automation_health=false
            fi
        else
            echo "  ❌ $script: ファイルが存在しません" | tee -a "$LOG_FILE"
            automation_health=false
        fi
    done
    
    if $automation_health; then
        echo "✅ 自動化システム: 正常" | tee -a "$LOG_FILE"
        return 0
    else
        echo "⚠️  自動化システム: 問題あり" | tee -a "$LOG_FILE"
        return 1
    fi
}

# ===== 5. レポート生成 =====
generate_report() {
    echo "📋 健全性レポート生成..."
    
    cat > "$REPORT_FILE" << EOF
# プロジェクト健全性レポート

**生成日時**: $TIMESTAMP

## 📊 全体状況

### AI Agent最適化プロジェクト
$(check_development_project >/dev/null 2>&1 && echo "✅ 正常" || echo "⚠️ 問題あり")

### 実験プロジェクト群
$(check_lab_projects >/dev/null 2>&1 && echo "✅ 正常" || echo "⚠️ 問題あり")

### MCP統合
$(check_mcp_integration >/dev/null 2>&1 && echo "✅ 正常" || echo "⚠️ 問題あり")

### 自動化システム
$(check_automation_status >/dev/null 2>&1 && echo "✅ 正常" || echo "⚠️ 問題あり")

## 📈 統計情報

### ディスク使用量
- **Development**: $(du -sh "$HOME/Development" | cut -f1)
- **flux-lab**: $(du -sh "$HOME/flux-lab" 2>/dev/null | cut -f1 || echo "N/A")
- **llama-lab**: $(du -sh "$HOME/llama-lab" 2>/dev/null | cut -f1 || echo "N/A")
- **sd-lab**: $(du -sh "$HOME/sd-lab" 2>/dev/null | cut -f1 || echo "N/A")

### ファイル数
- **Development**: $(find "$HOME/Development" -type f | wc -l | tr -d ' ') ファイル
- **全プロジェクト**: $(find "$HOME/Development" "$HOME/flux-lab" "$HOME/llama-lab" "$HOME/sd-lab" -type f 2>/dev/null | wc -l | tr -d ' ') ファイル

## 🔧 推奨アクション

EOF

    # 問題がある場合の推奨アクション追加
    if ! check_development_project >/dev/null 2>&1; then
        echo "- AI Agent最適化プロジェクトの構造を確認・修復" >> "$REPORT_FILE"
    fi
    
    if ! check_mcp_integration >/dev/null 2>&1; then
        echo "- MCP設定を確認・修復" >> "$REPORT_FILE"
    fi
    
    if ! check_automation_status >/dev/null 2>&1; then
        echo "- 自動化スクリプトの権限・配置を確認" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
    echo "**詳細ログ**: _project_management/status/project_health.log" >> "$REPORT_FILE"
    
    echo "✅ レポート生成完了: $REPORT_FILE" | tee -a "$LOG_FILE"
}

# ===== メイン実行 =====
main() {
    local errors=0
    
    echo "🔍 AI Agent最適化環境 プロジェクト健全性チェック" | tee -a "$LOG_FILE"
    echo "================================================" | tee -a "$LOG_FILE"
    
    check_development_project || ((errors++))
    echo "" | tee -a "$LOG_FILE"
    
    check_lab_projects
    echo "" | tee -a "$LOG_FILE"
    
    check_mcp_integration || ((errors++))
    echo "" | tee -a "$LOG_FILE"
    
    check_automation_status || ((errors++))
    echo "" | tee -a "$LOG_FILE"
    
    generate_report
    
    echo "================================================" | tee -a "$LOG_FILE"
    
    if [ $errors -eq 0 ]; then
        echo "✅ プロジェクト健全性チェック完了: 問題なし" | tee -a "$LOG_FILE"
        echo "📊 チェック終了: $TIMESTAMP" | tee -a "$LOG_FILE"
        return 0
    else
        echo "⚠️  プロジェクト健全性チェック完了: $errors 個の問題検出" | tee -a "$LOG_FILE"
        echo "📋 詳細は $REPORT_FILE を確認してください" | tee -a "$LOG_FILE"
        echo "📊 チェック終了: $TIMESTAMP" | tee -a "$LOG_FILE"
        return 1
    fi
}

# スクリプト実行
main "$@" 