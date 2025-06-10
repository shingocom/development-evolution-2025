# =========================================
# AI開発環境 - Python + PyTorch + Jupyter
# Mac ARM64 / Linux x86_64 クロスプラットフォーム対応
# =========================================

# マルチアーキテクチャ対応ベースイメージ
FROM --platform=linux/amd64 python:3.11-slim AS base-amd64
FROM --platform=linux/arm64 python:3.11-slim AS base-arm64

# プラットフォーム別選択
ARG TARGETPLATFORM
FROM base-${TARGETPLATFORM#linux/} AS base

# =========================================
# システム依存関係インストール
# =========================================
RUN apt-get update && apt-get install -y \
    # 開発ツール
    git \
    curl \
    wget \
    vim \
    htop \
    tree \
    
    # Python開発依存
    build-essential \
    python3-dev \
    python3-pip \
    
    # 画像・動画処理
    ffmpeg \
    libsm6 \
    libxext6 \
    libfontconfig1 \
    libxrender1 \
    libgl1-mesa-glx \
    
    # その他システムライブラリ
    libglib2.0-0 \
    libgstreamer1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# =========================================
# Python環境設定
# =========================================
WORKDIR /workspace

# pip アップグレード
RUN pip install --upgrade pip setuptools wheel

# =========================================
# AI/ML 基本ライブラリインストール
# =========================================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# =========================================
# Jupyter Lab 設定
# =========================================
RUN jupyter lab --generate-config

# Jupyter設定ファイル作成
RUN echo "c.ServerApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = 'ai-development-2025'" >> /root/.jupyter/jupyter_lab_config.py

# =========================================
# 作業ディレクトリ構造作成
# =========================================
RUN mkdir -p \
    /workspace/projects \
    /workspace/ai_workspace \
    /workspace/development \
    /workspace/models \
    /workspace/datasets \
    /workspace/notebooks \
    /workspace/scripts \
    /workspace/output

# =========================================
# 開発環境設定
# =========================================

# Git設定（コンテナ内での開発用）
RUN git config --global user.name "AI Development Container" && \
    git config --global user.email "ai-dev@development-evolution-2025"

# Python パス設定
ENV PYTHONPATH="/workspace:/workspace/projects:/workspace/ai_workspace"

# =========================================
# ポート公開
# =========================================
EXPOSE 8888 8000 6006

# =========================================
# 起動設定
# =========================================

# 起動スクリプト作成
RUN echo '#!/bin/bash\n\
echo "🚀 AI開発環境が起動しました！"\n\
echo ""\n\
echo "📊 利用可能なサービス:"\n\
echo "   • Jupyter Lab: http://localhost:8888 (token: ai-development-2025)"\n\
echo "   • 開発サーバー: http://localhost:8000"\n\
echo "   • TensorBoard: http://localhost:6006"\n\
echo ""\n\
echo "📁 マウントされたディレクトリ:"\n\
echo "   • /workspace/projects     → AI Projects"\n\
echo "   • /workspace/development  → Development"\n\
echo "   • /workspace/ai_workspace → _ai_workspace"\n\
echo ""\n\
echo "🔧 利用可能なコマンド:"\n\
echo "   • jupyter lab --ip=0.0.0.0 --port=8888 --allow-root"\n\
echo "   • python -m http.server 8000"\n\
echo "   • tensorboard --logdir=/workspace/logs --host=0.0.0.0"\n\
echo ""\n\
\n\
# Jupyter Lab をバックグラウンドで起動\n\
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser &\n\
\n\
# シェル保持\n\
exec "$@"\n\
' > /workspace/start.sh && chmod +x /workspace/start.sh

# デフォルトコマンド
CMD ["/workspace/start.sh", "bash"] 