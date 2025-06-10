# 🐳 Docker AI/ML開発環境 - 運用ガイド

**対象**: AI Agent・開発者・運用担当者  
**目的**: Docker環境での日常開発・運用の完全ガイド  
**プラットフォーム**: Mac/Linux 完全対応

---

## ⚡ **クイックスタート：5分で環境起動**

### **1. 環境準備 (1分)**
```bash
cd ~/Development/docker

# 環境変数設定（初回のみ）
cp docker.env.template .env

# プラットフォーム確認
uname -m  # arm64 (Mac) / x86_64 (Linux)
```

### **2. 基本サービス起動 (2分)**
```bash
# 全サービス起動
docker-compose up -d

# 起動確認
docker-compose ps
```

### **3. アクセス確認 (2分)**
- **Jupyter Lab**: http://localhost:8888 (token: `ai-development-2025`)
- **AI開発コンテナシェル**: `docker exec -it ai-dev-main bash`

---

## 🔧 **日常運用ルール**

### **📝 開発ワークフローパターン**

#### **パターンA: Jupyter開発**
```bash
# 1. 環境起動
docker-compose up -d ai-dev

# 2. Jupyter Lab アクセス
# http://localhost:8888 → token: ai-development-2025

# 3. 作業完了後
docker-compose logs ai-dev     # ログ確認
docker-compose stop ai-dev     # 停止
```

#### **パターンB: コンテナ内開発**
```bash
# 1. コンテナ内シェル開始
docker exec -it ai-dev-main bash

# 2. 開発作業
cd /workspace/projects
python your_script.py

# 3. Git作業（コンテナ内）
git add .
git commit -m "✨ 新機能追加"

# 4. ホストでプッシュ（推奨）
exit  # コンテナから出る
git push origin main
```

#### **パターンC: API開発・テスト**
```bash
# 1. 開発サーバー起動
docker exec -it ai-dev-main bash
cd /workspace/projects
python -m uvicorn main:app --host 0.0.0.0 --port 8000

# 2. API テスト
curl http://localhost:8000/docs  # FastAPI docs

# 3. TensorBoard起動（AI実験用）
tensorboard --logdir=/workspace/logs --host=0.0.0.0 --port=6006
```

### **🔄 サービス管理**

#### **個別サービス制御**
```bash
# AI開発環境のみ
docker-compose up -d ai-dev
docker-compose logs -f ai-dev
docker-compose stop ai-dev

# Flux.1画像生成のみ
docker-compose up -d flux-service
# アクセス: http://localhost:7860

# Ollama LLMのみ
docker-compose up -d ollama
# API: http://localhost:11434

# 全サービス
docker-compose up -d      # 全起動
docker-compose down       # 全停止
docker-compose restart    # 全再起動
```

#### **リソース管理**
```bash
# 現在の状況確認
docker-compose ps
docker stats

# ディスク使用量確認
docker system df

# 不要イメージ・コンテナ削除
docker-compose down --volumes --remove-orphans
docker system prune -a
```

---

## 🌍 **Mac/Linux クロスプラットフォーム運用**

### **プラットフォーム切り替え手順**

#### **Mac → Linux 移行**
```bash
# 1. 現在の設定確認
cat .env | grep HOST_

# 2. Linux設定に変更
sed -i 's/HOST_OS=mac/HOST_OS=linux/' .env
sed -i 's/HOST_ARCH=arm64/HOST_ARCH=amd64/' .env

# 3. 再ビルド（アーキテクチャ変更時）
docker-compose build --no-cache

# 4. 起動確認
docker-compose up -d
```

#### **共有データの注意点**
```bash
# Google Drive同期が有効な場合
# Mac: /Users/[user]/Library/CloudStorage/GoogleDrive-[email]/My Drive
# Linux: ~/googledrive/My Drive (Google Drive Streamを使用)

# パス確認
echo $PWD  # 現在のパス
ls -la ../AI\ Projects/  # 共有プロジェクトフォルダ確認
```

### **プラットフォーム別最適化**

#### **Mac用設定**
```bash
# Docker Desktop Memory設定
# Docker Desktop → Settings → Resources → Memory: 8GB+

# ファイル共有最適化（.envで設定済み）
# :delegated オプション使用

# M1/M2 Mac用GPU設定（将来対応）
# PYTORCH_ENABLE_MPS_FALLBACK=1
```

#### **Linux用設定**
```bash
# NVIDIA GPU対応（GPU搭載時）
# nvidia-docker2 インストール必要
sudo apt install nvidia-docker2

# Docker Compose GPU設定は既に含まれています
# deploy.resources.reservations.devices設定済み
```

---

## 📊 **データ管理・永続化**

### **ボリューム管理**
```bash
# ボリューム一覧確認
docker volume ls | grep ai-development

# 重要データボリューム:
# - ai-models: AI/MLモデル保存
# - ai-datasets: データセット保存
# - jupyter-config: Jupyter設定
# - ollama-data: Ollamaモデル
```

### **バックアップ・復元**
```bash
# 重要データバックアップ
docker run --rm -v ai-models:/data -v ${PWD}/backup:/backup alpine \
  tar czf /backup/ai-models-$(date +%Y%m%d).tar.gz -C /data .

# 復元
docker run --rm -v ai-models:/data -v ${PWD}/backup:/backup alpine \
  tar xzf /backup/ai-models-20250610.tar.gz -C /data

# 設定バックアップ
cp .env .env.backup.$(date +%Y%m%d)
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d)
```

### **プロジェクトデータ同期**
```bash
# AIプロジェクトフォルダは自動マウント
# docker-compose.yml設定:
# - "${PWD}/../AI Projects:/workspace/projects"

# 開発中ファイルは即座に同期
ls /workspace/projects/  # コンテナ内からホストフォルダ確認
```

---

## 🚨 **トラブルシューティング**

### **起動関連問題**

#### **ポート競合エラー**
```bash
# ポート使用状況確認
lsof -i :8888  # Jupyter
lsof -i :7860  # Flux.1
lsof -i :11434 # Ollama

# 解決方法1: 使用中サービス停止
docker-compose down

# 解決方法2: ポート変更（docker-compose.yml編集）
# "8888:8888" → "8889:8888"
```

#### **メモリ不足エラー**
```bash
# メモリ使用状況確認
docker stats

# Docker Desktop メモリ増加（Mac）
# Docker Desktop → Settings → Resources → Memory: 8GB→12GB

# Linux: スワップ設定
sudo swapon --show
```

### **ビルド関連問題**

#### **依存関係エラー**
```bash
# キャッシュクリア再ビルド
docker-compose build --no-cache ai-dev

# 個別問題調査
docker-compose logs ai-dev

# requirements.txt 問題時
docker exec -it ai-dev-main pip list | grep [問題ライブラリ]
```

#### **プラットフォーム互換性問題**
```bash
# アーキテクチャ確認
docker exec -it ai-dev-main uname -m

# マルチプラットフォームビルド強制
docker buildx build --platform linux/amd64,linux/arm64 ./ai-dev
```

### **データ同期問題**

#### **ボリュームマウントエラー**
```bash
# パス確認
echo $PWD
ls -la "../AI Projects"

# 権限問題（Linux）
sudo chown -R $USER:$USER "../AI Projects"

# SELinux問題（RHEL系）
sudo setsebool -P container_use_cgroup_namespace 1
```

---

## 🔒 **セキュリティ・運用指針**

### **環境変数管理**
```bash
# 機密情報は.envに格納（Git除外済み）
# 本番環境では必ず変更:
JUPYTER_TOKEN=ai-development-2025  # → 強力なトークン
AI_SERVICE_API_KEY=...             # → 実際のAPIキー
```

### **ネットワークセキュリティ**
```bash
# 本番環境では外部アクセス制限
# docker-compose.yml ports設定:
# "127.0.0.1:8888:8888"  # localhost のみ

# ファイアウォール設定（Linux）
sudo ufw allow from 192.168.1.0/24 to any port 8888
```

### **コンテナセキュリティ**
```bash
# 定期的な基本イメージ更新
docker-compose pull
docker-compose build --no-cache

# セキュリティスキャン
docker scout cves ai-dev-main
```

---

## 📈 **パフォーマンス最適化**

### **リソース配分**
```bash
# CPU/メモリ制限設定（docker-compose.yml）
deploy:
  resources:
    limits:
      cpus: '4.0'
      memory: 8G
    reservations:
      cpus: '2.0'
      memory: 4G
```

### **ストレージ最適化**
```bash
# イメージサイズ最適化
docker images | grep ai-development
docker image prune

# ビルドキャッシュ活用
# Dockerfile: COPY requirements.txt . を COPY . . より先に配置済み
```

---

## 🎯 **次のステップ・拡張計画**

### **Phase 3: 本格運用準備**
1. **CI/CD統合**: GitHub Actions + Docker
2. **モニタリング**: Prometheus + Grafana
3. **ログ管理**: ELK Stack統合

### **拡張可能サービス**
```bash
# PostgreSQL追加
# docker-compose.yml に追加済み設計

# Nginx リバースプロキシ
# 複数サービス統一アクセス

# GPU最適化
# CUDA 12.0+ 対応
```

---

## 📞 **サポート・参考情報**

### **ドキュメント参照**
- **メイン**: [../README.md](../README.md)
- **プラットフォーム切り替え**: [PLATFORM_GUIDE.md](PLATFORM_GUIDE.md)
- **トラブルシューティング**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### **コミュニティリソース**
- **Docker Compose リファレンス**: https://docs.docker.com/compose/
- **PyTorch Docker**: https://pytorch.org/get-started/locally/
- **Jupyter Docker**: https://jupyter-docker-stacks.readthedocs.io/

---

**🎉 運用成功の定義**: 新しい開発者がこのドキュメントだけで、5分以内にDocker AI環境での開発を開始できる状態

*最終更新: 2025-06-10 | 次回更新: サービス拡張時* 