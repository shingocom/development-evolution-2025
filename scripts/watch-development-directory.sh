#!/bin/bash
# Development直下の不正ファイル作成を即座に検出・移動
WATCH_DIR="/Users/shingoyamaguchi02/Library/CloudStorage/GoogleDrive-shingo.yamaguchi219@gmail.com/My Drive/Development"
TEMP_DIR="$WATCH_DIR/workspace/temp"
mkdir -p "$TEMP_DIR"
echo "🔍 Development監視開始: $(date)"
while true; do
    ILLEGAL_FILES=$(find "$WATCH_DIR" -maxdepth 1 -type f ! -name "README.md" ! -name ".gitignore" ! -name ".directory-rules.json" ! -name ".DS_Store")
    if [[ -n "$ILLEGAL_FILES" ]]; then
        echo "🚨 $(date): 不正ファイル検出！移動中..."
        echo "$ILLEGAL_FILES" | while read file; do mv "$file" "$TEMP_DIR/" && echo "移動: $(basename "$file")"; done
    fi
    sleep 5
done
