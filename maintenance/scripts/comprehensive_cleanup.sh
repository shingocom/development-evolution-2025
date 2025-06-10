#!/bin/bash
# =========================================
# 🧹 包括的自動クリーニングスクリプト
# =========================================
# 目的: 手動チェックで発見された全項目の自動化
# 実行: 定期実行 + Git作業前 + 新AI Agent引き継ぎ時
# ベース: 2025-06-10 手動チェック結果を反映

set -e

# カラー定義
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 包括的自動クリーニング開始...${NC}"
echo "実行時刻: $(date)"

# 作業ディレクトリ設定
DEV_DIR="$HOME/Development"
if [[ ! -d "$DEV_DIR" ]]; then
    echo -e "${RED}❌ Development ディレクトリが見つかりません: $DEV_DIR${NC}"
    exit 1
fi

cd "$DEV_DIR"

# 統計カウンター
MOVED_FILES=0
DELETED_FILES=0
CLEANED_DUPLICATES=0
ERRORS=0

# バックアップディレクトリ作成
BACKUP_DIR="archive/auto_cleanup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}📋 事前バックアップ作成: $BACKUP_DIR${NC}"

# =========================================
# フェーズ1: ルートディレクトリ古いファイル検出・処理
# =========================================
echo -e "\n${PURPLE}=== フェーズ1: ルートディレクトリ古いファイル処理 ===${NC}"

# 古いスクリプト自動検出・アーカイブ移動
OLD_SCRIPTS=(
    "create_new_directory_structure.sh"
    "fix_mcp_environment.sh"
    "setup_*.sh"
    "execute_*.sh"
    "*_setup.sh"
    "day[0-9]*.sh"
)

for pattern in "${OLD_SCRIPTS[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        mkdir -p "archive/executed_scripts"
        for file in $pattern; do
            if [[ -f "$file" ]]; then
                cp "$file" "$BACKUP_DIR/"
                mv "$file" "archive/executed_scripts/"
                echo -e "${GREEN}✅ 古いスクリプト移動: $file → archive/executed_scripts/${NC}"
                MOVED_FILES=$((MOVED_FILES + 1))
            fi
        done
    fi
done

# =========================================
# フェーズ2: 重複設定ファイル検出・削除
# =========================================
echo -e "\n${PURPLE}=== フェーズ2: 重複設定ファイル処理 ===${NC}"

# MCP設定重複チェック（正規版: _core_config/mcp/templates/secure_template.json）
DUPLICATE_MCP_PATTERNS=(
    "secure_mcp_*.json"
    "*mcp_config*.json"
    "*mcp_template*.json"
)

CANONICAL_MCP="_core_config/mcp/templates/secure_template.json"

for pattern in "${DUPLICATE_MCP_PATTERNS[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        for file in $pattern; do
            if [[ -f "$file" && "$file" != "$CANONICAL_MCP" ]]; then
                # バックアップして削除
                cp "$file" "$BACKUP_DIR/DUPLICATE_MCP_$(basename "$file")"
                rm "$file"
                echo -e "${GREEN}✅ 重複MCP設定削除: $file (正規版: $CANONICAL_MCP 保持)${NC}"
                CLEANED_DUPLICATES=$((CLEANED_DUPLICATES + 1))
            fi
        done
    fi
done

# Docker設定重複チェック
if [[ -f "docker-compose.yml" && -f "docker/docker-compose.yml" ]]; then
    cp "docker-compose.yml" "$BACKUP_DIR/"
    rm "docker-compose.yml"
    echo -e "${GREEN}✅ 重複Docker設定削除: ルート版削除 (docker/内保持)${NC}"
    CLEANED_DUPLICATES=$((CLEANED_DUPLICATES + 1))
fi

# 環境変数テンプレート重複チェック
ENV_DUPLICATES=(
    ".env.template"
    "env.template"
    "*env_template*"
)

for pattern in "${ENV_DUPLICATES[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        for file in $pattern; do
            if [[ -f "$file" && ! "$file" =~ docker/ ]]; then
                cp "$file" "$BACKUP_DIR/"
                rm "$file"
                echo -e "${GREEN}✅ 重複環境変数テンプレート削除: $file${NC}"
                CLEANED_DUPLICATES=$((CLEANED_DUPLICATES + 1))
            fi
        done
    fi
done

# =========================================
# フェーズ3: 一時・テストファイル削除
# =========================================
echo -e "\n${PURPLE}=== フェーズ3: 一時・テストファイル削除 ===${NC}"

# テストファイルパターン
TEMP_PATTERNS=(
    "*test_*.md"
    "*_test_*.md"
    "*connection_test*.md"
    "test_*.json"
    "*_temp_*"
    "temp_*"
    "*.tmp"
    "*~"
    "*.bak"
    ".#*"
)

for pattern in "${TEMP_PATTERNS[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        for file in $pattern; do
            if [[ -f "$file" ]]; then
                cp "$file" "$BACKUP_DIR/" 2>/dev/null || true
                rm "$file"
                echo -e "${GREEN}✅ 一時ファイル削除: $file${NC}"
                DELETED_FILES=$((DELETED_FILES + 1))
            fi
        done
    fi
done

# =========================================
# フェーズ4: システム生成ファイル削除
# =========================================
echo -e "\n${PURPLE}=== フェーズ4: システム生成ファイル削除 ===${NC}"

# .DS_Store (Mac)
DS_STORE_COUNT=$(find . -name ".DS_Store" | wc -l | tr -d ' ')
if [ "$DS_STORE_COUNT" -gt 0 ]; then
    find . -name ".DS_Store" -delete
    echo -e "${GREEN}✅ .DS_Storeファイル削除: $DS_STORE_COUNT 個${NC}"
    DELETED_FILES=$((DELETED_FILES + DS_STORE_COUNT))
fi

# Thumbs.db (Windows)
THUMBS_COUNT=$(find . -name "Thumbs.db" | wc -l | tr -d ' ')
if [ "$THUMBS_COUNT" -gt 0 ]; then
    find . -name "Thumbs.db" -delete
    echo -e "${GREEN}✅ Thumbs.dbファイル削除: $THUMBS_COUNT 個${NC}"
    DELETED_FILES=$((DELETED_FILES + THUMBS_COUNT))
fi

# ._* (Mac Resource Fork)
RESOURCE_FORK_COUNT=$(find . -name "._*" | wc -l | tr -d ' ')
if [ "$RESOURCE_FORK_COUNT" -gt 0 ]; then
    find . -name "._*" -delete
    echo -e "${GREEN}✅ Macリソースフォーク削除: $RESOURCE_FORK_COUNT 個${NC}"
    DELETED_FILES=$((DELETED_FILES + RESOURCE_FORK_COUNT))
fi

# =========================================
# フェーズ5: 散在ファイル適切配置
# =========================================
echo -e "\n${PURPLE}=== フェーズ5: 散在ファイル適切配置 ===${NC}"

# 重要文書以外のMarkdownファイル移動
IMPORTANT_MD=(
    "README.md"
    "DEVELOPMENT_EVOLUTION_PROJECT_2025.md"
    "CURRENT_STATE_INVENTORY.md" 
    "QUICK_SETUP_REFERENCE.md"
    "SECURITY_IMPROVEMENT_PLAN.md"
)

for file in *.md 2>/dev/null; do
    if [[ -f "$file" ]]; then
        is_important=false
        for important in "${IMPORTANT_MD[@]}"; do
            if [[ "$file" == "$important" ]]; then
                is_important=true
                break
            fi
        done
        
        if [[ "$is_important" == false ]]; then
            mkdir -p "_project_management/status"
            cp "$file" "$BACKUP_DIR/"
            mv "$file" "_project_management/status/"
            echo -e "${GREEN}✅ 一般文書移動: $file → _project_management/status/${NC}"
            MOVED_FILES=$((MOVED_FILES + 1))
        fi
    fi
done

# =========================================
# フェーズ6: 重複チェック（詳細）
# =========================================
echo -e "\n${PURPLE}=== フェーズ6: 詳細重複チェック ===${NC}"

# セッションファイル重複
SESSION_DUPLICATES=$(find . -name "*session*" | grep -v "_ai_workspace/context/current_session.md" | wc -l | tr -d ' ')
if [ "$SESSION_DUPLICATES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  セッション関連重複: $SESSION_DUPLICATES 個${NC}"
    find . -name "*session*" | grep -v "_ai_workspace/context/current_session.md" | while read file; do
        cp "$file" "$BACKUP_DIR/DUPLICATE_SESSION_$(basename "$file")"
        rm "$file"
        echo -e "${GREEN}✅ 重複セッションファイル削除: $file${NC}"
        CLEANED_DUPLICATES=$((CLEANED_DUPLICATES + 1))
    done
fi

# 設定ファイル系重複（_core_config外）
STRAY_CONFIGS=$(find . -maxdepth 1 \( -name "*config*" -o -name "*template*" -o -name "*.json" \) | wc -l | tr -d ' ')
if [ "$STRAY_CONFIGS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  散在設定ファイル: $STRAY_CONFIGS 個${NC}"
    find . -maxdepth 1 \( -name "*config*" -o -name "*template*" -o -name "*.json" \) | while read file; do
        mkdir -p "_core_config/misc"
        cp "$file" "$BACKUP_DIR/"
        mv "$file" "_core_config/misc/"
        echo -e "${GREEN}✅ 散在設定移動: $file → _core_config/misc/${NC}"
        MOVED_FILES=$((MOVED_FILES + 1))
    done
fi

# =========================================
# フェーズ7: 権限・セキュリティ修正
# =========================================
echo -e "\n${PURPLE}=== フェーズ7: 権限・セキュリティ修正 ===${NC}"

# セキュア環境変数ファイル
if [[ -f "$HOME/.env.secure" ]]; then
    chmod 600 "$HOME/.env.secure"
    echo -e "${GREEN}✅ ~/.env.secure 権限を600に設定${NC}"
fi

# スクリプト実行権限
find maintenance/scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find docker -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
echo -e "${GREEN}✅ スクリプト実行権限設定完了${NC}"

# Docker環境ファイル権限
if [[ -f "docker/.env" ]]; then
    chmod 600 "docker/.env"
    echo -e "${GREEN}✅ docker/.env 権限を600に設定${NC}"
fi

# =========================================
# フェーズ8: 構造検証
# =========================================
echo -e "\n${PURPLE}=== フェーズ8: 構造検証 ===${NC}"

# 重要ディレクトリ存在確認
REQUIRED_DIRS=(
    "_ai_workspace/context"
    "_ai_workspace/rules"
    "_core_config/mcp/templates"
    "_project_management/status"
    "maintenance/scripts"
    "docker"
    "archive/executed_scripts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo -e "${YELLOW}⚠️  必須ディレクトリ作成: $dir${NC}"
    fi
done

# =========================================
# フェーズ9: Git対応
# =========================================
echo -e "\n${PURPLE}=== フェーズ9: Git対応 ===${NC}"

# Gitステータス確認
if git status &>/dev/null; then
    echo -e "${BLUE}📍 Git リポジトリ内で実行中${NC}"
    
    # 削除されたファイルをGitから除去
    git ls-files --deleted -z | xargs -0 git rm 2>/dev/null || true
    
    # 新しく移動したファイルを追加
    git add archive/ _core_config/ _project_management/ maintenance/ 2>/dev/null || true
    
    echo -e "${GREEN}✅ Git インデックス更新完了${NC}"
else
    echo -e "${YELLOW}⚠️  Git リポジトリ外で実行${NC}"
fi

# =========================================
# 最終結果レポート
# =========================================
echo -e "\n${BLUE}📊 包括的クリーニング結果${NC}"
echo "=============================================="
echo -e "${GREEN}✅ 移動ファイル数: $MOVED_FILES${NC}"
echo -e "${GREEN}✅ 削除ファイル数: $DELETED_FILES${NC}"
echo -e "${GREEN}✅ 重複解消数: $CLEANED_DUPLICATES${NC}"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ エラー発生数: $ERRORS${NC}"
else
    echo -e "${GREEN}✅ エラー: なし${NC}"
fi

echo ""
echo -e "${BLUE}📝 バックアップ場所: $BACKUP_DIR${NC}"
echo -e "${BLUE}📅 実行完了時刻: $(date)${NC}"

# ログ保存
LOG_FILE="_project_management/status/comprehensive_cleanup_$(date +%Y%m%d_%H%M%S).log"
{
    echo "包括的自動クリーニングログ - $(date)"
    echo "移動ファイル数: $MOVED_FILES"
    echo "削除ファイル数: $DELETED_FILES" 
    echo "重複解消数: $CLEANED_DUPLICATES"
    echo "エラー数: $ERRORS"
    echo "バックアップ場所: $BACKUP_DIR"
} > "$LOG_FILE"

echo -e "${GREEN}📝 ログ保存: $LOG_FILE${NC}"

# 構造検証実行
if [[ -f "maintenance/scripts/structure_validator.sh" ]]; then
    echo -e "\n${BLUE}🔍 構造検証実行...${NC}"
    bash "maintenance/scripts/structure_validator.sh" || true
fi

echo -e "\n${GREEN}🎉 包括的自動クリーニング完了！${NC}" 