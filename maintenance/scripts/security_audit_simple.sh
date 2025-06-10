#!/bin/bash
# === シンプルセキュリティ監査スクリプト ===

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "🔍 セキュリティ監査開始: $TIMESTAMP"

cd "$HOME/Development"

# 1. 平文APIキーチェック
echo "📋 平文APIキーチェック..."
API_KEY_FILES=$(find . -type f \( -name "*.json" -o -name "*.md" -o -name "*.txt" \) -exec grep -l "patn[0-9A-Za-z]" {} \; 2>/dev/null)

if [ -z "$API_KEY_FILES" ]; then
    echo "✅ 平文APIキー: 検出されませんでした"
    API_SECURITY=0
else
    echo "⚠️  平文APIキー検出:"
    echo "$API_KEY_FILES"
    API_SECURITY=1
fi

# 2. .env.secure権限チェック
echo "📋 環境変数ファイル権限チェック..."
if [ -f "$HOME/.env.secure" ]; then
    PERMS=$(stat -f "%Lp" "$HOME/.env.secure")
    if [ "$PERMS" = "600" ]; then
        echo "✅ .env.secure 権限: 正常 (600)"
        ENV_SECURITY=0
    else
        echo "⚠️  .env.secure 権限: 不適切 ($PERMS)"
        ENV_SECURITY=1
    fi
else
    echo "❌ .env.secure: ファイルが存在しません"
    ENV_SECURITY=1
fi

# 3. MCP設定チェック
echo "📋 MCP設定チェック..."
if [ -f "$HOME/.cursor/mcp.json" ]; then
    if python3 -m json.tool "$HOME/.cursor/mcp.json" > /dev/null 2>&1; then
        echo "✅ MCP設定: 有効なJSON"
        MCP_SECURITY=0
    else
        echo "⚠️  MCP設定: 無効なJSON"
        MCP_SECURITY=1
    fi
else
    echo "❌ MCP設定: ファイルが存在しません"
    MCP_SECURITY=1
fi

# 4. プロジェクト存在確認
echo "📋 プロジェクト存在確認..."
PROJECTS_OK=0
for project in "flux-lab" "llama-lab" "sd-lab"; do
    if [ -d "$HOME/$project" ]; then
        echo "  ✅ $project: 存在"
    else
        echo "  ❌ $project: 存在しません"
        PROJECTS_OK=1
    fi
done

# 結果サマリー
echo "========================================="
TOTAL_ISSUES=$((API_SECURITY + ENV_SECURITY + MCP_SECURITY + PROJECTS_OK))

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "✅ セキュリティ監査完了: 問題なし"
    exit 0
else
    echo "⚠️  セキュリティ監査完了: $TOTAL_ISSUES 個の問題検出"
    exit 1
fi 