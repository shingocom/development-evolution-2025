#!/bin/bash
# === AIエージェント トラブルシューティングガイド ===
# ~/Development/maintenance/scripts/troubleshoot.sh

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 AIエージェント トラブルシューティングガイド${NC}"
echo -e "${BLUE}実行時刻: $TIMESTAMP${NC}"
echo "======================================================="

# ===== 1. システム状況診断 =====
diagnose_system() {
    echo -e "\n${YELLOW}📊 システム状況診断${NC}"
    echo "-------------------"
    
    # ディスク使用量チェック
    local home_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}' | sed 's/%//')
    echo -e "💽 ディスク使用率: ${home_usage}%"
    if [ "$home_usage" -gt 90 ]; then
        echo -e "${RED}⚠️ 警告: ディスク使用率が90%を超過${NC}"
        echo "   対処: 不要ファイルの削除またはアーカイブが必要"
    elif [ "$home_usage" -gt 80 ]; then
        echo -e "${YELLOW}⚠️ 注意: ディスク使用率が80%を超過${NC}"
        echo "   対処: ファイル整理を推奨"
    else
        echo -e "${GREEN}✅ ディスク使用率: 正常範囲${NC}"
    fi
    
    # メモリ使用量
    echo -e "\n🧠 システムロード: $(uptime | awk -F'load average:' '{print $2}')"
    
    # プロセス数確認
    local cursor_processes=$(ps aux | grep -i cursor | grep -v grep | wc -l)
    echo -e "🖥️ Cursorプロセス数: ${cursor_processes}"
    
    if [ "$cursor_processes" -gt 5 ]; then
        echo -e "${YELLOW}⚠️ 注意: Cursorプロセスが多数実行中${NC}"
        echo "   対処: Cursor再起動を推奨"
    fi
}

# ===== 2. MCP診断 =====
diagnose_mcp() {
    echo -e "\n${YELLOW}🔌 MCP設定診断${NC}"
    echo "----------------"
    
    # MCP設定ファイル存在確認
    if [ -f "$HOME/.cursor/mcp.json" ]; then
        echo -e "${GREEN}✅ MCP設定ファイル: 存在${NC}"
        
        # サーバー数確認
        local server_count=$(python3 -c "
import json
try:
    with open('$HOME/.cursor/mcp.json') as f:
        data = json.load(f)
    print(len(data.get('mcpServers', {})))
except:
    print('0')
" 2>/dev/null || echo "0")
        
        echo -e "🔧 設定済みサーバー数: ${server_count}"
        
        if [ "$server_count" -eq 4 ]; then
            echo -e "${GREEN}✅ MCP サーバー数: 正常（4サーバー）${NC}"
        else
            echo -e "${RED}⚠️ 異常: MCP サーバー数が4と異なります${NC}"
            echo "   期待値: 4 (n8n, puppeteer, filesystem, airtable)"
            echo "   実際値: $server_count"
        fi
        
        # 環境変数確認
        if [ -f "$HOME/.env.secure" ]; then
            echo -e "${GREEN}✅ 環境変数ファイル: 存在${NC}"
            local env_count=$(grep -c "^export" "$HOME/.env.secure" 2>/dev/null || echo "0")
            echo -e "🔐 設定済み環境変数: ${env_count}"
        else
            echo -e "${RED}❌ 環境変数ファイル: 不存在${NC}"
            echo "   対処: ~/.env.secureファイルの作成が必要"
        fi
        
    else
        echo -e "${RED}❌ MCP設定ファイル: 不存在${NC}"
        echo "   対処: ~/.cursor/mcp.jsonの設定が必要"
    fi
}

# ===== 3. プロジェクト診断 =====
diagnose_projects() {
    echo -e "\n${YELLOW}📁 プロジェクト診断${NC}"
    echo "-----------------"
    
    # Development プロジェクト
    if [ -d "$HOME/Development" ]; then
        local dev_size=$(du -sh "$HOME/Development" | cut -f1)
        local dev_files=$(find "$HOME/Development" -type f | wc -l)
        echo -e "${GREEN}✅ Development: 存在 (${dev_size}, ${dev_files} files)${NC}"
    else
        echo -e "${RED}❌ Development: 不存在${NC}"
    fi
    
    # flux-lab プロジェクト
    if [ -d "$HOME/flux-lab" ]; then
        local flux_size=$(du -sh "$HOME/flux-lab" | cut -f1)
        local flux_files=$(find "$HOME/flux-lab" -type f | wc -l)
        echo -e "${GREEN}✅ flux-lab: 存在 (${flux_size}, ${flux_files} files)${NC}"
    else
        echo -e "${YELLOW}⚠️ flux-lab: 不存在${NC}"
    fi
    
    # llama-lab プロジェクト
    if [ -d "$HOME/llama-lab" ]; then
        local llama_size=$(du -sh "$HOME/llama-lab" | cut -f1)
        local llama_files=$(find "$HOME/llama-lab" -type f | wc -l)
        echo -e "${GREEN}✅ llama-lab: 存在 (${llama_size}, ${llama_files} files)${NC}"
    else
        echo -e "${YELLOW}⚠️ llama-lab: 不存在${NC}"
    fi
}

# ===== 4. セキュリティ診断 =====
diagnose_security() {
    echo -e "\n${YELLOW}🔒 セキュリティ診断${NC}"
    echo "------------------"
    
    # API キー検索
    local api_key_files=$(find "$HOME/Development" -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) -exec grep -l "sk-[a-zA-Z0-9]" {} \; 2>/dev/null | wc -l)
    
    if [ "$api_key_files" -eq 0 ]; then
        echo -e "${GREEN}✅ APIキー: 平文検出なし${NC}"
    else
        echo -e "${RED}⚠️ 警告: ${api_key_files} ファイルでAPIキー平文を検出${NC}"
        echo "   対処: セキュリティ監査スクリプトの実行を推奨"
        echo "   コマンド: ./maintenance/scripts/security_audit_final.sh"
    fi
    
    # 権限確認
    if [ -f "$HOME/.env.secure" ]; then
        local env_perms=$(stat -f %A "$HOME/.env.secure")
        if [ "$env_perms" = "600" ]; then
            echo -e "${GREEN}✅ .env.secure権限: 正常 (600)${NC}"
        else
            echo -e "${YELLOW}⚠️ .env.secure権限: ${env_perms} (600推奨)${NC}"
            echo "   対処: chmod 600 ~/.env.secure"
        fi
    fi
}

# ===== 5. よくある問題と解決策 =====
show_common_issues() {
    echo -e "\n${YELLOW}🆘 よくある問題と解決策${NC}"
    echo "========================="
    
    cat << 'EOF'

### 📝 1. MCPサーバーが応答しない
**症状**: MCP関数（airtable、puppeteer等）が使用できない
**解決策**:
```bash
# Cursor再起動
# ターミナルで環境変数読み込み
source ~/.env.secure

# MCP設定確認
cat ~/.cursor/mcp.json | python3 -m json.tool
```

### 🔐 2. API認証エラー
**症状**: "Authentication failed" 等のエラー
**解決策**:
```bash
# 環境変数確認
cat ~/.env.secure

# API キー有効性確認（Airtable）
curl -H "Authorization: Bearer $AIRTABLE_API_KEY" \
     https://api.airtable.com/v0/meta/bases
```

### 💾 3. ディスク容量不足
**症状**: ファイル作成・編集ができない
**解決策**:
```bash
# 不要ファイル削除
find ~/Development -name "*.tmp" -delete
find ~/Development -name ".DS_Store" -delete

# ディスク使用量確認
du -sh ~/Development ~/flux-lab ~/llama-lab
```

### 🐌 4. パフォーマンス低下
**症状**: Cursorの動作が重い
**解決策**:
```bash
# AI最適化実行
./maintenance/scripts/ai_agent_optimizer.sh

# プロセス確認・整理
ps aux | grep cursor
```

### 📁 5. プロジェクトにアクセスできない
**症状**: filesystemでプロジェクトが見えない
**解決策**:
```bash
# MCP filesystem設定確認
cat ~/.cursor/mcp.json | grep -A 20 filesystem

# プロジェクトディレクトリ確認
ls -la ~/flux-lab ~/llama-lab ~/Development
```

EOF
}

# ===== 6. 自動修復提案 =====
suggest_fixes() {
    echo -e "\n${YELLOW}🔧 自動修復提案${NC}"
    echo "-----------------"
    
    echo "実行推奨コマンド："
    echo ""
    echo "1. 包括的チェック："
    echo "   ./maintenance/scripts/project_health_check.sh"
    echo ""
    echo "2. セキュリティ監査："
    echo "   ./maintenance/scripts/security_audit_final.sh"
    echo ""
    echo "3. AI最適化："
    echo "   ./maintenance/scripts/ai_agent_optimizer.sh"
    echo ""
    echo "4. MCP再設定（問題がある場合）："
    echo "   cp secure_mcp_template.json ~/.cursor/mcp.json"
    echo "   source ~/.env.secure"
    echo ""
    echo "5. Cursor再起動"
    echo "   Cursor終了 → 再起動"
}

# ===== メイン実行 =====
main() {
    diagnose_system
    diagnose_mcp
    diagnose_projects
    diagnose_security
    show_common_issues
    suggest_fixes
    
    echo ""
    echo "======================================================="
    echo -e "${GREEN}✅ トラブルシューティング診断完了${NC}"
    echo "詳細な問題がある場合は、提案されたコマンドを実行してください。"
    echo ""
}

# 引数によって部分実行も可能
case "${1:-all}" in
    "system") diagnose_system ;;
    "mcp") diagnose_mcp ;;
    "projects") diagnose_projects ;;
    "security") diagnose_security ;;
    "help") show_common_issues ;;
    "fix") suggest_fixes ;;
    *) main ;;
esac 