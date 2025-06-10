#!/bin/bash
# === 最終版セキュリティ監査スクリプト ===

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "🔍 セキュリティ監査開始: $TIMESTAMP"

cd "$HOME/Development"

# 1. 平文APIキーチェック（リアルタイム）
echo "📋 平文APIキーチェック..."
API_KEY_RESULTS=$(grep -r "patn[0-9A-Za-z]" . 2>/dev/null)
if [ -n "$API_KEY_RESULTS" ]; then
    echo "⚠️  平文APIキー検出:"
    echo "$API_KEY_RESULTS" | cut -d: -f1 | sort -u
    API_SECURITY=1
else
    echo "✅ 平文APIキー: 検出されませんでした"
    API_SECURITY=0
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
        # 環境変数使用確認
        if grep -q '${.*}' "$HOME/.cursor/mcp.json"; then
            echo "✅ MCP設定: 環境変数使用"
            MCP_SECURITY=0
        else
            echo "⚠️  MCP設定: 環境変数未使用"
            MCP_SECURITY=1
        fi
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
PROJECTS_FOUND=0
for project in "flux-lab" "llama-lab" "sd-lab"; do
    if [ -d "$HOME/$project" ]; then
        echo "  ✅ $project: 存在"
        ((PROJECTS_FOUND++))
    else
        echo "  ⚠️  $project: 存在しません"
    fi
done

if [ $PROJECTS_FOUND -ge 2 ]; then
    echo "📊 プロジェクト: $PROJECTS_FOUND/3 存在（許容範囲）"
    PROJECTS_OK=0
else
    echo "📊 プロジェクト: $PROJECTS_FOUND/3 存在（要確認）"
    PROJECTS_OK=1
fi

# 5. ディスク使用量チェック
echo "📋 ディスク使用量チェック..."
DEVELOPMENT_SIZE=$(du -sh "$HOME/Development" | cut -f1)
HOME_USAGE=$(df -h "$HOME" | tail -1 | awk '{print $5}' | sed 's/%//')
echo "💾 Development: $DEVELOPMENT_SIZE"
echo "💾 ホーム使用率: ${HOME_USAGE}%"

if [ "$HOME_USAGE" -gt 90 ]; then
    echo "⚠️  ディスク使用率が90%を超過"
    DISK_OK=1
else
    echo "✅ ディスク使用率: 正常"
    DISK_OK=0
fi

# 結果サマリー
echo "========================================="
TOTAL_ISSUES=$((API_SECURITY + ENV_SECURITY + MCP_SECURITY + PROJECTS_OK + DISK_OK))

echo "📊 監査結果サマリー:"
echo "  - APIキーセキュリティ: $([ $API_SECURITY -eq 0 ] && echo "✅ 正常" || echo "⚠️ 問題あり")"
echo "  - 環境変数権限: $([ $ENV_SECURITY -eq 0 ] && echo "✅ 正常" || echo "⚠️ 問題あり")"
echo "  - MCP設定: $([ $MCP_SECURITY -eq 0 ] && echo "✅ 正常" || echo "⚠️ 問題あり")"
echo "  - プロジェクト: $([ $PROJECTS_OK -eq 0 ] && echo "✅ 正常" || echo "⚠️ 要確認")"
echo "  - ディスク使用量: $([ $DISK_OK -eq 0 ] && echo "✅ 正常" || echo "⚠️ 問題あり")"

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "✅ セキュリティ監査完了: 問題なし"
    echo "📊 監査終了: $TIMESTAMP"
    exit 0
else
    echo "⚠️  セキュリティ監査完了: $TOTAL_ISSUES 個の問題検出"
    echo "📊 監査終了: $TIMESTAMP"
    exit 1
fi 