#!/bin/bash
# セキュアな環境設定スクリプト
# Phase 1: 緊急セキュリティ対応

set -e

echo "🔒 セキュア環境設定を開始します..."

# カラーコード定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# セキュリティ警告の表示
echo -e "${RED}⚠️  重要な注意事項 ⚠️${NC}"
echo "このスクリプトは現在のAPIキーを環境変数化します。"
echo "本来は各サービスでAPIキーを再生成することを強く推奨します。"
echo ""
read -p "続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "処理を中断しました。"
    exit 1
fi

# バックアップディレクトリ作成
BACKUP_DIR="$HOME/Development/secure_backups"
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${YELLOW}📁 セキュアバックアップディレクトリを作成: $BACKUP_DIR${NC}"

# 現在のMCP設定をマスクしてバックアップ
echo -e "${YELLOW}💾 現在の設定をマスクしてバックアップ中...${NC}"

# APIキーをマスクした設定ファイル作成
cat ~/.cursor/mcp.json | \
    sed 's/"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9[^"]*"/"[MASKED_N8N_JWT_TOKEN]"/g' | \
    sed 's/"ntn_[^"]*"/"[MASKED_NOTION_API_KEY]"/g' | \
    sed 's/"patn[^"]*"/"[MASKED_AIRTABLE_API_KEY]"/g' > \
    "$BACKUP_DIR/mcp_masked_$TIMESTAMP.json"

echo -e "${GREEN}✅ マスクされた設定をバックアップ: $BACKUP_DIR/mcp_masked_$TIMESTAMP.json${NC}"

# 環境変数ファイルの作成
ENV_FILE="$HOME/.env.secure"

echo -e "${YELLOW}🔑 環境変数ファイルを作成中...${NC}"

# 現在のAPIキーを環境変数ファイルに保存（一時的）
cat > "$ENV_FILE" << 'EOF'
# === セキュア環境変数 ===
# 注意: これらのキーは各サービスで再生成することを強く推奨

# N8N API Key (JWT Token)
export N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhNjFiMjgyNy1mNTMyLTQ3MGUtYWY3YS0zYjY4NDIxNTJmM2QiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzQ4MjE3NTI5fQ.xD08ybuEDKyLPG7oy-Vqwv3yTwNK-XAUlCAfA0G3lgU"

# Notion API Key  
export NOTION_API_KEY="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"

# Airtable API Key
export AIRTABLE_API_KEY="patn[MASKED_API_KEY]"

EOF

# ファイル権限を厳格に設定
chmod 600 "$ENV_FILE"

echo -e "${GREEN}✅ 環境変数ファイル作成完了: $ENV_FILE${NC}"
echo -e "${YELLOW}🔐 ファイル権限を600（所有者のみ読み書き）に設定${NC}"

# 元のMCP設定をバックアップ
cp ~/.cursor/mcp.json "$BACKUP_DIR/original_mcp_$TIMESTAMP.json"

# 新しいセキュアなMCP設定を適用
echo -e "${YELLOW}⚙️  セキュアなMCP設定を適用中...${NC}"

# 環境変数を読み込んでテンプレートを展開
source "$ENV_FILE"
envsubst < "$(dirname "$0")/secure_mcp_template.json" > ~/.cursor/mcp.json

echo -e "${GREEN}✅ セキュアなMCP設定を適用完了${NC}"

# 権限確認
echo -e "${YELLOW}🔍 設定ファイルの権限確認:${NC}"
ls -la ~/.cursor/mcp.json
ls -la "$ENV_FILE"

# セキュリティ状況の表示
echo ""
echo -e "${GREEN}🎉 Phase 1 セキュリティ対応完了！${NC}"
echo ""
echo "📋 実行された内容:"
echo "  ✅ セキュアバックアップディレクトリ作成"
echo "  ✅ 現在の設定をマスクしてバックアップ"
echo "  ✅ 環境変数ファイル作成 (~/.env.secure)"
echo "  ✅ MCP設定の環境変数化"
echo "  ✅ ファイル権限の適切な設定"
echo ""
echo -e "${YELLOW}⚠️  次のステップ:${NC}"
echo "  1. 各サービスでAPIキーを再生成"
echo "  2. ~/.env.secure ファイルのキーを新しいものに更新"  
echo "  3. Cursorを再起動してMCP接続を確認"
echo ""
echo -e "${RED}🚨 セキュリティ重要事項:${NC}"
echo "  - 現在のAPIキーは各サービスで無効化して再生成してください"
echo "  - ~/.env.secure ファイルは機密情報です。共有しないでください"
echo "  - バックアップファイルも適切に管理してください" 