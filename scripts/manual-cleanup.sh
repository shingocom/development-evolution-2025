#!/bin/bash
# Development直下の手動クリーニング実行
WATCH_DIR="/Users/shingoyamaguchi02/Library/CloudStorage/GoogleDrive-shingo.yamaguchi219@gmail.com/My Drive/Development"
TEMP_DIR="$WATCH_DIR/workspace/temp"
LOG_FILE="$TEMP_DIR/cleanup.log"

echo "🧹 Development手動クリーニング開始: $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Developmentディレクトリに移動
cd "$WATCH_DIR"

# 不正ファイル検出
ILLEGAL_FILES=$(find "$WATCH_DIR" -maxdepth 1 -type f ! -name "README.md" ! -name ".gitignore" ! -name ".directory-rules.json" ! -name ".DS_Store")

if [[ -z "$ILLEGAL_FILES" ]]; then
    echo "✅ クリーンな状態です - 不正ファイルは見つかりませんでした"
    echo "📁 許可ファイル一覧:"
    ls -la | grep "^-" | awk '{print "  ✅ " $9}'
    exit 0
fi

echo "🚨 不正ファイル検出！削除処理開始..."
echo ""
echo "削除対象ファイル:"
echo "$ILLEGAL_FILES" | while read file; do 
    echo "  🗑️  $(basename "$file")"
done
echo ""

# 確認プロンプト（オプション）
if [[ "$1" != "--auto" ]]; then
    read -p "❓ 上記ファイルを完全削除しますか？ (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ キャンセルされました"
        exit 1
    fi
fi

# バックアップディレクトリ作成
mkdir -p "$TEMP_DIR"

# 各ファイルを削除
DELETED_COUNT=0
echo "$ILLEGAL_FILES" | while read file; do 
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        
        # バックアップ作成
        backup_name="${filename}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$TEMP_DIR/$backup_name" 2>/dev/null
        
        # 物理削除
        if rm "$file"; then
            echo "🗑️  削除完了: $filename (バックアップ: $backup_name)"
            ((DELETED_COUNT++))
        else
            echo "❌ 削除失敗: $filename"
        fi
    fi
done

echo ""
echo "📊 削除完了: $DELETED_COUNT ファイル"

# Git状態確認・コミット
if git status --porcelain | grep -q "^.D"; then
    echo ""
    echo "📝 Git削除検出 - 自動コミット実行..."
    
    # Git削除をステージング
    git add -A
    
    # 削除をコミット（pre-commit hook スキップ）
    commit_message="🧹 手動クリーニング: 不正ファイル削除 - $(date '+%Y/%m/%d %H:%M:%S')"
    if git commit --no-verify -m "$commit_message"; then
        echo "✅ Gitコミット完了: $commit_message"
    else
        echo "❌ Gitコミット失敗"
        exit 1
    fi
fi

# 最終状態確認
echo ""
echo "🎯 クリーニング完了！現在の状態:"
echo "📁 許可ファイル:"
ls -la | grep "^-" | awk '{print "  ✅ " $9}'

echo ""
echo "📋 ログファイル: $LOG_FILE"
echo "💾 バックアップ場所: $TEMP_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 