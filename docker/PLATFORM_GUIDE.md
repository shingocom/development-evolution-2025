#!/bin/bash

# =========================================
# プラットフォーム自動検出・設定スクリプト
# Mac/Linux 自動判定・最適化設定
# =========================================

set -e

echo "🌍 プラットフォーム自動設定開始..."

# =========================================
# プラットフォーム検出
# =========================================
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)

echo "📊 検出情報:"
echo "  OS: $OS_TYPE"
echo "  Architecture: $ARCH_TYPE"

# =========================================
# 設定値決定
# =========================================
if [[ "$OS_TYPE" == "Darwin" ]]; then
    HOST_OS="mac"
    if [[ "$ARCH_TYPE" == "arm64" ]]; then
        HOST_ARCH="arm64"
        echo "✅ Mac Apple Silicon 検出"
    else
        HOST_ARCH="amd64"
        echo "✅ Mac Intel 検出"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    HOST_OS="linux"
    HOST_ARCH="amd64"
    echo "✅ Linux 検出"
else
    echo "❌ 未対応OS: $OS_TYPE"
    exit 1
fi

# =========================================
# .env ファイル更新
# =========================================
if [[ ! -f .env ]]; then
    echo "📝 .env ファイル作成"
    cp docker.env.template .env
fi

echo "⚙️  プラットフォーム設定更新..."

# プラットフォーム設定更新
if [[ "$OS_TYPE" == "Darwin" ]]; then
    sed -i '' "s/HOST_OS=.*/HOST_OS=$HOST_OS/" .env
    sed -i '' "s/HOST_ARCH=.*/HOST_ARCH=$HOST_ARCH/" .env
else
    sed -i "s/HOST_OS=.*/HOST_OS=$HOST_OS/" .env
    sed -i "s/HOST_ARCH=.*/HOST_ARCH=$HOST_ARCH/" .env
fi

# =========================================
# Docker 環境確認
# =========================================
echo "🐳 Docker 環境確認..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker が見つかりません"
    echo "📋 インストール手順:"
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        echo "  brew install --cask docker"
    else
        echo "  curl -fsSL https://get.docker.com | sh"
    fi
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose が見つかりません"
    exit 1
fi

echo "✅ Docker 環境OK"

# =========================================
# 権限設定（Linux）
# =========================================
if [[ "$OS_TYPE" == "Linux" ]]; then
    echo "🔐 Linux 権限設定..."
    
    # Docker グループ確認
    if ! groups $USER | grep -q docker; then
        echo "⚠️  Docker グループに追加が必要です:"
        echo "  sudo usermod -aG docker $USER"
        echo "  その後、再ログインしてください"
    fi
    
    # AI Projects フォルダ権限
    if [[ -d "../AI Projects" ]]; then
        echo "📁 AI Projects フォルダ権限設定..."
        sudo chown -R $USER:$USER "../AI Projects" 2>/dev/null || true
    fi
fi

# =========================================
# 設定確認表示
# =========================================
echo ""
echo "🎉 設定完了！"
echo "📊 現在の設定:"
grep "HOST_" .env

echo ""
echo "🚀 次のステップ:"
echo "  docker-compose up -d"
echo ""
echo "📋 利用可能サービス:"
echo "  • Jupyter Lab: http://localhost:8888"
echo "  • Flux.1 UI: http://localhost:7860"
echo "  • Ollama API: http://localhost:11434"

# =========================================
# 動作テスト提案
# =========================================
read -p "🧪 Docker 設定テストを実行しますか？ (y/N): " TEST_CONFIRM

if [[ "$TEST_CONFIRM" == "y" || "$TEST_CONFIRM" == "Y" ]]; then
    echo "🧪 設定テスト実行..."
    
    # Compose 設定確認
    docker-compose config --quiet && echo "✅ docker-compose.yml OK" || echo "❌ docker-compose.yml エラー"
    
    # 基本イメージ取得テスト
    docker pull python:3.11-slim > /dev/null 2>&1 && echo "✅ Docker pull OK" || echo "❌ Docker pull エラー"
    
    echo "🎉 設定テスト完了！"
fi 