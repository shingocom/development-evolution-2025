#!/bin/bash
# 🧹 自動ファイル整理スクリプト
# Author: AI Agent
# Created: 2024-01-01
# Purpose: 散在ファイル・重複ファイル・不要ファイルの自動整理

set -e

# カラー定義
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 自動ファイル整理開始...${NC}"

# 作業ディレクトリ設定
DEV_DIR="$HOME/Development"
cd "$DEV_DIR"

# 整理統計
MOVED_FILES=0
DELETED_FILES=0
ERRORS=0

# バックアップディレクトリ作成
BACKUP_DIR="archive/auto_cleanup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "\n${BLUE}📋 事前バックアップ作成: $BACKUP_DIR${NC}"

# 散在ファイルのバックアップ
if ls *.{md,json,sh,py} 1> /dev/null 2>&1; then
    cp *.{md,json,sh,py} "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ 散在ファイルをバックアップしました${NC}"
fi

# 不要ファイル削除
echo -e "\n${BLUE}🗑️  不要ファイル削除...${NC}"

# .DS_Store削除
DS_STORE_COUNT=$(find . -name ".DS_Store" | wc -l | tr -d ' ')
if [ "$DS_STORE_COUNT" -gt 0 ]; then
    find . -name ".DS_Store" -delete
    echo -e "${GREEN}✅ .DS_Storeファイル削除: $DS_STORE_COUNT 個${NC}"
    DELETED_FILES=$((DELETED_FILES + DS_STORE_COUNT))
fi

# 一時ファイル削除
TEMP_COUNT=$(find . -name "*.tmp" -o -name "temp*" -o -name "*~" | wc -l | tr -d ' ')
if [ "$TEMP_COUNT" -gt 0 ]; then
    find . -name "*.tmp" -o -name "temp*" -o -name "*~" -delete 2>/dev/null || true
    echo -e "${GREEN}✅ 一時ファイル削除: $TEMP_COUNT 個${NC}"
    DELETED_FILES=$((DELETED_FILES + TEMP_COUNT))
fi

# 散在ファイル整理
echo -e "\n${BLUE}📁 散在ファイル整理...${NC}"

# Markdownファイル整理
MD_FILES=$(find . -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$MD_FILES" -gt 0 ]; then
    # _project_management/status/が存在しない場合は作成
    mkdir -p "_project_management/status"
    
    find . -maxdepth 1 -name "*.md" -exec mv {} "_project_management/status/" \; 2>/dev/null || {
        echo -e "${RED}❌ Markdownファイルの移動に失敗${NC}"
        ERRORS=$((ERRORS + 1))
    }
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Markdownファイル移動: $MD_FILES 個 → _project_management/status/${NC}"
        MOVED_FILES=$((MOVED_FILES + MD_FILES))
    fi
fi

# JSONファイル整理  
JSON_FILES=$(find . -maxdepth 1 -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
if [ "$JSON_FILES" -gt 0 ]; then
    # _core_config/mcp/templates/が存在しない場合は作成
    mkdir -p "_core_config/mcp/templates"
    
    find . -maxdepth 1 -name "*.json" -exec mv {} "_core_config/mcp/templates/" \; 2>/dev/null || {
        echo -e "${RED}❌ JSONファイルの移動に失敗${NC}"
        ERRORS=$((ERRORS + 1))
    }
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ JSONファイル移動: $JSON_FILES 個 → _core_config/mcp/templates/${NC}"
        MOVED_FILES=$((MOVED_FILES + JSON_FILES))
    fi
fi

# シェルスクリプト整理
SH_FILES=$(find . -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SH_FILES" -gt 0 ]; then
    # maintenance/scripts/が存在しない場合は作成
    mkdir -p "maintenance/scripts"
    
    find . -maxdepth 1 -name "*.sh" -exec mv {} "maintenance/scripts/" \; 2>/dev/null || {
        echo -e "${RED}❌ シェルスクリプトの移動に失敗${NC}"
        ERRORS=$((ERRORS + 1))
    }
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ シェルスクリプト移動: $SH_FILES 個 → maintenance/scripts/${NC}"
        MOVED_FILES=$((MOVED_FILES + SH_FILES))
        
        # 実行権限付与
        chmod +x maintenance/scripts/*.sh 2>/dev/null || true
        echo -e "${GREEN}✅ スクリプトに実行権限を付与${NC}"
    fi
fi

# Pythonファイル整理
PY_FILES=$(find . -maxdepth 1 -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PY_FILES" -gt 0 ]; then
    # active_projects/scripts/が存在しない場合は作成
    mkdir -p "active_projects/scripts"
    
    find . -maxdepth 1 -name "*.py" -exec mv {} "active_projects/scripts/" \; 2>/dev/null || {
        echo -e "${RED}❌ Pythonファイルの移動に失敗${NC}"
        ERRORS=$((ERRORS + 1))
    }
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Pythonファイル移動: $PY_FILES 個 → active_projects/scripts/${NC}"
        MOVED_FILES=$((MOVED_FILES + PY_FILES))
    fi
fi

# 重複ファイル整理（強化版）
echo -e "\n${BLUE}🔄 重複ファイル整理（強化版）...${NC}"

# セッションファイル重複チェック
SESSION_FILES=$(find . -name "*session*" | grep -v "_ai_workspace/context/current_session.md" | wc -l | tr -d ' ')
if [ "$SESSION_FILES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  セッション関連ファイル重複検出${NC}"
    find . -name "*session*" | grep -v "_ai_workspace/context/current_session.md" | while read file; do
        backup_file="$BACKUP_DIR/$(basename "$file")"
        cp "$file" "$backup_file" 2>/dev/null || true
        rm "$file" 2>/dev/null || true
        echo -e "${GREEN}✅ 重複セッションファイル削除: $file${NC}"
    done
fi

# 設定ファイル重複チェック（追加）
CONFIG_DUPLICATES=$(find . -name "*config*" -o -name "*template*" | grep -v "_core_config" | wc -l | tr -d ' ')
if [ "$CONFIG_DUPLICATES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  設定/テンプレートファイル重複検出${NC}"
    find . -name "*config*" -o -name "*template*" | grep -v "_core_config" | while read file; do
        echo -e "${YELLOW}⚠️  要確認: $file${NC}"
        backup_file="$BACKUP_DIR/DUPLICATE_$(basename "$file")"
        cp "$file" "$backup_file" 2>/dev/null || true
    done
fi

# MCP設定重複チェック（追加）
MCP_DUPLICATES=$(find . -name "*mcp*" | grep -v "_core_config/mcp" | wc -l | tr -d ' ')
if [ "$MCP_DUPLICATES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  MCP設定重複検出${NC}"
    find . -name "*mcp*" | grep -v "_core_config/mcp" | while read file; do
        echo -e "${RED}🚨 緊急要確認: $file${NC}"
        backup_file="$BACKUP_DIR/MCP_DUPLICATE_$(basename "$file")"
        cp "$file" "$backup_file" 2>/dev/null || true
    done
fi

# 権限修正
echo -e "\n${BLUE}🔒 権限修正...${NC}"

if [ -f "$HOME/.env.secure" ]; then
    chmod 600 "$HOME/.env.secure"
    echo -e "${GREEN}✅ セキュア環境変数ファイルの権限を600に設定${NC}"
fi

# スクリプトに実行権限付与
find maintenance/scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# 結果表示
echo -e "\n${BLUE}📊 整理結果サマリー${NC}"
echo "================================="
echo -e "${GREEN}✅ 移動ファイル数: $MOVED_FILES${NC}"
echo -e "${GREEN}✅ 削除ファイル数: $DELETED_FILES${NC}"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ エラー発生数: $ERRORS${NC}"
else
    echo -e "${GREEN}✅ エラー: なし${NC}"
fi

echo -e "\n${BLUE}📝 バックアップ場所: $BACKUP_DIR${NC}"

# 整理後の構造検証実行
echo -e "\n${BLUE}🔍 整理後の構造検証実行...${NC}"
if [ -f "maintenance/scripts/structure_validator.sh" ]; then
    bash "maintenance/scripts/structure_validator.sh" || true
else
    echo -e "${YELLOW}⚠️  構造検証スクリプトが見つかりません${NC}"
fi

# ログファイル出力
LOG_FILE="_project_management/status/auto_cleanup_$(date +%Y%m%d_%H%M%S).log"
{
    echo "# 自動整理ログ"
    echo "**実行日時**: $(date)"
    echo "**移動ファイル数**: $MOVED_FILES"
    echo "**削除ファイル数**: $DELETED_FILES"
    echo "**エラー数**: $ERRORS"
    echo "**バックアップ場所**: $BACKUP_DIR"
    echo ""
    echo "## 詳細"
    echo "- Markdownファイル: $MD_FILES 個移動"
    echo "- JSONファイル: $JSON_FILES 個移動"
    echo "- シェルスクリプト: $SH_FILES 個移動"
    echo "- Pythonファイル: $PY_FILES 個移動"
    echo "- .DS_Storeファイル: $DS_STORE_COUNT 個削除"
    echo "- 一時ファイル: $TEMP_COUNT 個削除"
    echo "- 重複セッションファイル: $SESSION_FILES 個処理"
} > "$LOG_FILE"

echo -e "\n${BLUE}📝 整理ログ保存: $LOG_FILE${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 自動整理が正常に完了しました！${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  いくつかのエラーが発生しましたが、整理は完了しました${NC}"
    exit 1
fi 