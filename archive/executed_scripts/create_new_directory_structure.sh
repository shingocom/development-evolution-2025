#!/bin/bash
# Day 2: 新しいディレクトリ構造作成スクリプト
# AI Agent最適化開発環境整理企画

set -e

echo "🏗️  Day 2: 新しいディレクトリ構造を作成します..."

# カラーコード定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_DIR="$HOME/development"

echo -e "${BLUE}📁 ベースディレクトリ: $BASE_DIR${NC}"

# AI Agent専用領域の作成
echo -e "${YELLOW}🤖 AI Agent専用領域を作成中...${NC}"
mkdir -p "$BASE_DIR/_ai_workspace/context"
mkdir -p "$BASE_DIR/_ai_workspace/rules"
mkdir -p "$BASE_DIR/_ai_workspace/knowledge/solutions"
mkdir -p "$BASE_DIR/_ai_workspace/knowledge/patterns"
mkdir -p "$BASE_DIR/_ai_workspace/knowledge/resources"
mkdir -p "$BASE_DIR/_ai_workspace/templates/project_init"
mkdir -p "$BASE_DIR/_ai_workspace/templates/documentation"
mkdir -p "$BASE_DIR/_ai_workspace/templates/workflow"

echo -e "${GREEN}✅ AI Workspace構造作成完了${NC}"

# 核となる設定エリアの作成
echo -e "${YELLOW}🔧 核となる設定エリアを作成中...${NC}"
mkdir -p "$BASE_DIR/_core_config/mcp/backup_configs"
mkdir -p "$BASE_DIR/_core_config/mcp/templates"
mkdir -p "$BASE_DIR/_core_config/environments"
mkdir -p "$BASE_DIR/_core_config/git"
mkdir -p "$BASE_DIR/_core_config/docker"

echo -e "${GREEN}✅ Core Config構造作成完了${NC}"

# プロジェクト管理エリアの作成
echo -e "${YELLOW}📊 プロジェクト管理エリアを作成中...${NC}"
mkdir -p "$BASE_DIR/_project_management/status"
mkdir -p "$BASE_DIR/_project_management/planning"
mkdir -p "$BASE_DIR/_project_management/completed"
mkdir -p "$BASE_DIR/_project_management/metrics"

echo -e "${GREEN}✅ Project Management構造作成完了${NC}"

# アクティブプロジェクトエリアの作成
echo -e "${YELLOW}🚀 アクティブプロジェクトエリアを作成中...${NC}"
mkdir -p "$BASE_DIR/active_projects"

echo -e "${GREEN}✅ Active Projects構造作成完了${NC}"

# アーカイブエリアの作成
echo -e "${YELLOW}🗃️  アーカイブエリアを作成中...${NC}"
mkdir -p "$BASE_DIR/archive/old_configs"
mkdir -p "$BASE_DIR/archive/deprecated_projects"
mkdir -p "$BASE_DIR/archive/migration_logs"

echo -e "${GREEN}✅ Archive構造作成完了${NC}"

# メンテナンスエリアの作成
echo -e "${YELLOW}🧹 メンテナンスエリアを作成中...${NC}"
mkdir -p "$BASE_DIR/maintenance/cleanup_scripts"
mkdir -p "$BASE_DIR/maintenance/backup_scripts"
mkdir -p "$BASE_DIR/maintenance/health_check"

echo -e "${GREEN}✅ Maintenance構造作成完了${NC}"

# 権限設定
echo -e "${YELLOW}🔐 適切なディレクトリ権限を設定中...${NC}"
chmod 755 "$BASE_DIR"
chmod 700 "$BASE_DIR/_ai_workspace"
chmod 700 "$BASE_DIR/_core_config"
chmod 755 "$BASE_DIR/_project_management"
chmod 755 "$BASE_DIR/active_projects"
chmod 755 "$BASE_DIR/archive"
chmod 755 "$BASE_DIR/maintenance"

echo -e "${GREEN}✅ ディレクトリ権限設定完了${NC}"

# 構造確認
echo -e "${BLUE}🔍 作成されたディレクトリ構造:${NC}"
tree "$BASE_DIR" -L 3 -d 2>/dev/null || find "$BASE_DIR" -type d | sort

echo ""
echo -e "${GREEN}🎉 Day 2: 新しいディレクトリ構造作成完了！${NC}"
echo ""
echo "📋 作成された主要エリア:"
echo "  🤖 _ai_workspace/      - AI Agent専用領域"
echo "  🔧 _core_config/       - 核となる設定"
echo "  📊 _project_management/ - プロジェクト管理"
echo "  🚀 active_projects/    - アクティブな開発プロジェクト"
echo "  🗃️  archive/           - アーカイブ"
echo "  🧹 maintenance/        - メンテナンス"
echo ""
echo -e "${YELLOW}📍 次のステップ:${NC}"
echo "  1. 既存ファイルのバックアップと整理"
echo "  2. 現在のMCP設定を_core_config/に移行"
echo "  3. AI Workspace用コンテキストファイル作成"
echo "  4. プロジェクトの段階的移行" 