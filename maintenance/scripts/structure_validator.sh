#!/bin/bash
# 🔍 Development ディレクトリ構造検証スクリプト
# Author: AI Agent
# Created: 2024-01-01
# Purpose: 散在ファイル・重複ファイル・構造違反の検出

set -e

# カラー定義
RED='\033[0;31m'
YELLOW='\033[1;33m' 
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Development ディレクトリ構造検証開始...${NC}"

# 作業ディレクトリ設定
DEV_DIR="$HOME/Development"
cd "$DEV_DIR"

# 検証結果格納
ISSUES_FOUND=0

echo -e "\n${BLUE}📁 ディレクトリ構造確認...${NC}"

# 必須ディレクトリ存在確認
REQUIRED_DIRS=(
    "_ai_workspace"
    "_ai_workspace/context"
    "_ai_workspace/rules"
    "_ai_workspace/knowledge"
    "_ai_workspace/templates"
    "_core_config"
    "_core_config/mcp"
    "_core_config/mcp/templates"
    "_project_management"
    "_project_management/planning"
    "_project_management/security"
    "_project_management/status"
    "active_projects"
    "archive"
    "maintenance"
    "maintenance/scripts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo -e "${RED}❌ 必須ディレクトリが見つかりません: $dir${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

# 散在ファイルチェック
echo -e "\n${BLUE}📄 散在ファイルチェック...${NC}"

SCATTERED_MD=$(find . -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SCATTERED_JSON=$(find . -maxdepth 1 -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
SCATTERED_SH=$(find . -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
SCATTERED_PY=$(find . -maxdepth 1 -name "*.py" 2>/dev/null | wc -l | tr -d ' ')

if [ "$SCATTERED_MD" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  散在Markdownファイル発見: $SCATTERED_MD 個${NC}"
    find . -maxdepth 1 -name "*.md" 2>/dev/null | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + SCATTERED_MD))
fi

if [ "$SCATTERED_JSON" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  散在JSONファイル発見: $SCATTERED_JSON 個${NC}"
    find . -maxdepth 1 -name "*.json" 2>/dev/null | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + SCATTERED_JSON))
fi

if [ "$SCATTERED_SH" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  散在シェルスクリプト発見: $SCATTERED_SH 個${NC}"
    find . -maxdepth 1 -name "*.sh" 2>/dev/null | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + SCATTERED_SH))
fi

if [ "$SCATTERED_PY" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  散在Pythonファイル発見: $SCATTERED_PY 個${NC}"
    find . -maxdepth 1 -name "*.py" 2>/dev/null | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + SCATTERED_PY))
fi

# 重複ファイルチェック
echo -e "\n${BLUE}🔄 重複ファイルチェック...${NC}"

# Current Session重複チェック
SESSION_FILES=$(find . -name "*session*" -o -name "*current*" | wc -l | tr -d ' ')
if [ "$SESSION_FILES" -gt 1 ]; then
    echo -e "${YELLOW}⚠️  セッション関連ファイル重複の可能性: $SESSION_FILES 個${NC}"
    find . -name "*session*" -o -name "*current*" | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# MCP設定重複チェック  
MCP_TEMPLATES=$(find . -name "*mcp*template*" -o -name "*secure*mcp*" | wc -l | tr -d ' ')
if [ "$MCP_TEMPLATES" -gt 1 ]; then
    echo -e "${YELLOW}⚠️  MCP設定テンプレート重複の可能性: $MCP_TEMPLATES 個${NC}"
    find . -name "*mcp*template*" -o -name "*secure*mcp*" | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# 不要ファイルチェック
echo -e "\n${BLUE}🗑️  不要ファイルチェック...${NC}"

DS_STORE_COUNT=$(find . -name ".DS_Store" | wc -l | tr -d ' ')
if [ "$DS_STORE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  .DS_Storeファイル発見: $DS_STORE_COUNT 個${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + DS_STORE_COUNT))
fi

TEMP_FILES=$(find . -name "*.tmp" -o -name "temp*" -o -name "*~" | wc -l | tr -d ' ')
if [ "$TEMP_FILES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  一時ファイル発見: $TEMP_FILES 個${NC}"
    find . -name "*.tmp" -o -name "temp*" -o -name "*~" | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + TEMP_FILES))
fi

# 権限チェック
echo -e "\n${BLUE}🔒 権限チェック...${NC}"

if [ -f "$HOME/.env.secure" ]; then
    SECURE_PERMS=$(stat -f %A "$HOME/.env.secure" 2>/dev/null || echo "不明")
    if [ "$SECURE_PERMS" != "600" ]; then
        echo -e "${RED}❌ セキュア環境変数ファイルの権限が不適切: $SECURE_PERMS (推奨: 600)${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi

# 結果表示
echo -e "\n${BLUE}📊 検証結果サマリー${NC}"
echo "================================="

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ 構造検証完了 - 問題なし${NC}"
    echo -e "${GREEN}🎯 ディレクトリ構造は完璧です！${NC}"
else
    echo -e "${RED}⚠️  発見された問題: $ISSUES_FOUND 件${NC}"
    echo -e "${YELLOW}💡 修正推奨: 以下のコマンドで自動修正可能${NC}"
    echo "    bash ~/Development/maintenance/scripts/auto_cleanup.sh"
fi

# ログファイル出力
LOG_FILE="_project_management/status/structure_validation_$(date +%Y%m%d_%H%M%S).log"
{
    echo "# 構造検証ログ"
    echo "**実行日時**: $(date)"
    echo "**発見された問題数**: $ISSUES_FOUND"
    echo ""
    echo "## 詳細"
    if [ $ISSUES_FOUND -gt 0 ]; then
        echo "- 散在Markdownファイル: $SCATTERED_MD 個"
        echo "- 散在JSONファイル: $SCATTERED_JSON 個" 
        echo "- 散在シェルスクリプト: $SCATTERED_SH 個"
        echo "- 散在Pythonファイル: $SCATTERED_PY 個"
        echo "- 重複セッションファイル: 検出"
        echo "- .DS_Storeファイル: $DS_STORE_COUNT 個"
        echo "- 一時ファイル: $TEMP_FILES 個"
    else
        echo "問題なし - 構造は完璧な状態です"
    fi
} > "$LOG_FILE"

echo -e "\n${BLUE}📝 検証ログ保存: $LOG_FILE${NC}"

# 終了コード
exit $ISSUES_FOUND 