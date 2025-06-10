#!/bin/bash
# MCP環境変数展開修正スクリプト

set -e

echo "🔧 MCP環境変数展開を修正します..."

# 環境変数を読み込み
source ~/.env.secure

# 動的にMCP設定ファイルを生成
cat > ~/.cursor/mcp.json << EOF
{
  "mcpServers": {
    "n8n-workflow-builder": {
      "command": "npx",
      "args": ["-y", "@kernel.salacoste/n8n-workflow-builder"],
      "env": {
        "N8N_HOST": "http://localhost:5678/api/v1/",
        "N8N_API_KEY": "${N8N_API_KEY}",
        "READ_ONLY": "false"
      }
    },
    "puppeteer": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-puppeteer"
      ],
      "env": {
        "PUPPETEER_EXECUTABLE_PATH": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/shingoyamaguchi02/Desktop",
        "/Users/shingoyamaguchi02/Documents",
        "/Users/shingoyamaguchi02/Downloads",
        "/Users/shingoyamaguchi02/development",
        "/Users/shingoyamaguchi02/Library/Mobile Documents/com~apple~CloudDocs"
      ]
    },
    "airtable": {
      "command": "npx",
      "args": ["@felores/airtable-mcp-server"],
      "env": {
        "AIRTABLE_API_KEY": "${AIRTABLE_API_KEY}"
      }
    }
  }
}
EOF

echo "✅ MCP設定ファイルを環境変数で更新しました"
echo "🔍 設定確認:"

# APIキーが環境変数に置換されているか確認（最初の10文字のみ表示）
echo "  N8N API Key: $(echo $N8N_API_KEY | cut -c1-10)..."
echo "  Airtable API Key: $(echo $AIRTABLE_API_KEY | cut -c1-10)..."

echo ""
echo "🗑️ Notion MCPサーバーは使用停止により削除済み"
echo "🎉 環境変数展開修正完了！"
echo "⚠️  Cursorを再起動してMCP接続を確認してください" 