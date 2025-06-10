#!/bin/bash

# 🔒 セキュアCursor起動スクリプト
# 作成日: 2024年1月
# 用途: 環境変数を安全に読み込んでCursorを起動

set -e  # エラー時に停止

echo "🔒 セキュア環境でCursorを起動中..."

# 環境変数ファイルの存在確認
if [ ! -f ~/.env.secure ]; then
    echo "❌ エラー: ~/.env.secure が見つかりません"
    echo "💡 以下のコマンドでファイルを作成してください:"
    echo "   touch ~/.env.secure && chmod 600 ~/.env.secure"
    exit 1
fi

# ファイル権限確認
PERMS=$(stat -f "%A" ~/.env.secure 2>/dev/null || stat -c "%a" ~/.env.secure 2>/dev/null)
if [ "$PERMS" != "600" ]; then
    echo "⚠️  警告: ~/.env.secure の権限が安全ではありません (現在: $PERMS)"
    echo "🔧 権限を修正しています..."
    chmod 600 ~/.env.secure
    echo "✅ 権限を600に修正しました"
fi

# 環境変数読み込み
echo "📁 環境変数を読み込み中..."
source ~/.env.secure

# 必要な環境変数の確認
REQUIRED_VARS=("N8N_API_KEY" "AIRTABLE_API_KEY")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "⚠️  警告: $var が設定されていません"
    else
        echo "✅ $var: 設定済み"
    fi
done

echo "✅ 環境変数読み込み完了"

# Cursorの存在確認
CURSOR_PATH="/Applications/Cursor.app/Contents/MacOS/Cursor"
if [ ! -f "$CURSOR_PATH" ]; then
    echo "❌ エラー: Cursorが見つかりません ($CURSOR_PATH)"
    echo "💡 Cursorがインストールされていることを確認してください"
    exit 1
fi

# 作業ディレクトリの設定
WORK_DIR="$HOME/Development"
if [ -d "$WORK_DIR" ]; then
    echo "📁 作業ディレクトリに移動: $WORK_DIR"
    cd "$WORK_DIR"
else
    echo "⚠️  作業ディレクトリが見つかりません: $WORK_DIR"
fi

# セキュリティ最終確認
echo "🔍 セキュリティ最終確認..."
echo "  - 環境変数ファイル権限: $(ls -la ~/.env.secure | awk '{print $1}')"
echo "  - 現在の作業ディレクトリ: $(pwd)"

# Cursor起動
echo "🚀 Cursorを起動しています..."
exec "$CURSOR_PATH" "$@" 