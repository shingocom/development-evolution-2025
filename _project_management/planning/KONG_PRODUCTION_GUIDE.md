# 🚀 Kong Gateway 本格運用ガイド

**作成日**: 2025年6月10日  
**対象**: AI開発チーム・運用チーム  
**バージョン**: Kong 3.9.1 + PostgreSQL + AI Services

---

## 📋 **目次**

1. [システム概要](#システム概要)
2. [アーキテクチャ構成](#アーキテクチャ構成)
3. [運用手順](#運用手順)
4. [監視・アラート](#監視アラート)
5. [トラブルシューティング](#トラブルシューティング)
6. [セキュリティ](#セキュリティ)
7. [パフォーマンス調整](#パフォーマンス調整)
8. [バックアップ・復旧](#バックアップ復旧)

---

## 🎯 **システム概要**

### **Kong Gateway統合プラットフォーム**
- **目的**: AI開発環境のAPI管理統合・セキュリティ向上・運用効率化
- **導入期間**: 2025年6月10日〜21日（Hotfixプロジェクト）
- **技術スタック**: Kong Gateway 3.9.1、PostgreSQL、Redis、Prometheus

### **主要機能**
- ✅ **API Key認証**: セキュアなAPI アクセス制御
- ✅ **Rate Limiting**: DDoS攻撃対策・負荷制御
- ✅ **CORS設定**: ブラウザ間アクセス制御
- ✅ **Bot Detection**: 自動化攻撃対策
- ✅ **Prometheus監視**: リアルタイム性能監視
- ✅ **Request Transformer**: リクエストトレーシング

---

## 🏗️ **アーキテクチャ構成**

### **システム構成図**
```
[Client] 
    ↓
[Kong Gateway :8080] (Proxy)
    ├─ API Key認証・Rate Limiting・CORS
    ├─ Bot Detection・Request Transformer
    ├─ IP制限・リクエストサイズ制限
    ├─ Prometheus監視・ログ出力
    └─ Upstream Services:
        ├─ AI API Gateway (host.docker.internal:8000)
        └─ Ollama LLM (ai-ollama:11434)

[Kong Admin API :8001] (Management)
    ├─ 設定管理・統計情報
    └─ プラグイン管理

[PostgreSQL :5432] (Data Store)
    ├─ Kong設定データ
    └─ セッション・ログデータ

[Redis :6379] (Cache)
    ├─ セッションキャッシュ
    └─ Rate Limiting カウンター
```

### **ネットワーク構成**
- **Kong Proxy**: `localhost:8080`
- **Kong Admin**: `localhost:8001`
- **PostgreSQL**: `ai-postgres:5432`
- **Redis**: `ai-redis:6379`
- **API Gateway**: `host.docker.internal:8000`
- **Ollama LLM**: `ai-ollama:11434`

---

## 🔄 **運用手順**

### **日常運用チェックリスト**

#### **毎日実施**
- [ ] Kong ヘルスチェック (`curl http://localhost:8001/status`)
- [ ] レスポンス時間確認 (目標: <100ms)
- [ ] エラーログ確認 (`docker logs ai-kong --tail 50`)
- [ ] アクティブ接続数確認 (警告: >100接続)

#### **毎週実施**
- [ ] Kong設定バックアップ実行
- [ ] パフォーマンステスト実行
- [ ] セキュリティプラグイン動作確認
- [ ] 容量・ログ容量確認

#### **毎月実施**
- [ ] Kong バージョン更新検討
- [ ] プラグイン設定見直し
- [ ] API利用統計レビュー
- [ ] 災害復旧テスト実行

### **起動・停止手順**

#### **Kong Gateway起動**
```bash
# 1. 依存サービス起動
cd /Users/shingoyamaguchi02/Development/_core_config/docker
docker compose up -d ai-postgres ai-redis

# 2. Kong Gateway起動
docker compose up -d ai-kong

# 3. 起動確認
curl http://localhost:8001/status
curl http://localhost:8080/
```

#### **Kong Gateway停止**
```bash
# 1. Kong Gateway停止
docker compose stop ai-kong

# 2. 依存サービス停止（必要に応じて）
docker compose stop ai-postgres ai-redis
```

---

## 📊 **監視・アラート**

### **監視項目**

#### **1. システムヘルス**
- Kong Admin API応答性 (目標: <100ms)
- Kong Proxy応答性 (目標: <100ms)
- PostgreSQL接続状況
- Redis接続状況

#### **2. パフォーマンス**
- リクエスト処理時間 (警告: >500ms, 重大: >1000ms)
- スループット (リクエスト/秒)
- アクティブ接続数 (警告: >100, 重大: >200)
- メモリ使用量 (警告: >80%, 重大: >90%)

#### **3. セキュリティ**
- 認証失敗回数 (警告: >10回/分)
- Rate Limit到達回数
- 不正IPアクセス試行
- 異常なリクエストサイズ

### **アラート閾値**
```bash
# レスポンス時間
WARNING: >500ms
CRITICAL: >1000ms

# エラー率
WARNING: >5%
CRITICAL: >10%

# 接続数
WARNING: >100 active connections
CRITICAL: >200 active connections
```

### **監視スクリプト実行**
```bash
# 包括的監視実行
/tmp/kong_alerts.sh

# ヘルスチェックのみ
curl -s http://localhost:8001/status | jq .

# レスポンス時間測定
time curl -H "X-API-Key: ai-dev-key-2025" http://localhost:8080/api/v1/gateway/
```

---

## 🚨 **トラブルシューティング**

### **よくある問題と解決方法**

#### **Kong起動失敗**
```bash
# 症状: Kong containerが起動しない
# 原因: PostgreSQLが起動していない

# 解決方法:
docker compose up -d ai-postgres
sleep 10
docker compose up -d ai-kong
```

#### **API Key認証エラー**
```bash
# 症状: "No API key found in request"
# 原因: API Keyが正しく送信されていない

# 確認方法:
curl -H "X-API-Key: ai-dev-key-2025" http://localhost:8080/api/v1/gateway/

# API Key確認:
curl http://localhost:8001/consumers/ai-dev-user/key-auth
```

#### **Rate Limit到達**
```bash
# 症状: "API rate limit exceeded"
# 原因: 100req/min制限に到達

# 制限設定確認:
curl http://localhost:8001/plugins | jq '.data[] | select(.name=="rate-limiting")'

# 制限解除（一時的）:
curl -X PATCH http://localhost:8001/plugins/{plugin-id} -d "config.minute=200"
```

#### **プロキシ接続エラー**
```bash
# 症状: "name resolution failed"
# 原因: upstreamサービスが起動していない

# upstreamサービス確認:
docker ps | grep api-gateway
curl http://localhost:8000/  # API Gateway直接確認

# Kong Service設定確認:
curl http://localhost:8001/services/api-gateway
```

---

## 🔒 **セキュリティ**

### **実装済みセキュリティ機能**

#### **1. API Key認証**
```bash
# Consumer: ai-dev-user
# API Key: ai-dev-key-2025
# 設定: X-API-Key ヘッダー または apikey パラメータ
```

#### **2. Rate Limiting**
```bash
# 制限: 100 requests/minute, 1000 requests/hour
# 適用範囲: API Gateway Service
```

#### **3. IP制限**
```bash
# 許可IP範囲:
# - 127.0.0.1 (localhost)
# - ::1 (IPv6 localhost)
# - 10.0.0.0/8 (プライベートネットワーク)
# - 172.16.0.0/12 (Dockerネットワーク)
# - 192.168.0.0/16 (ローカルネットワーク)
```

#### **4. Bot Detection**
```bash
# 許可User-Agent:
# - chrome, firefox, curl
# 拒否: 悪意のあるbot・クローラー
```

#### **5. リクエストサイズ制限**
```bash
# 最大ペイロードサイズ: 10MB
# DDoS攻撃対策
```

### **セキュリティ設定確認**
```bash
# 全セキュリティプラグイン確認
curl http://localhost:8001/plugins | jq '.data[] | {name: .name, service: .service.id}'

# API Key一覧
curl http://localhost:8001/consumers/ai-dev-user/key-auth

# Rate Limiting設定
curl http://localhost:8001/plugins | jq '.data[] | select(.name=="rate-limiting").config'
```

---

## ⚡ **パフォーマンス調整**

### **現在の性能指標**
- **レスポンス時間**: 14-20ms (目標<100ms: ✅ 5-7倍性能)
- **並列処理**: 5並列同時処理成功
- **スループット**: 安定した高速処理
- **メモリ使用量**: 平均54MB/worker

### **パフォーマンス最適化設定**

#### **Kong Worker設定**
```bash
# 現在: 10 workers (自動設定)
# メモリ使用量: 平均54MB/worker
# 推奨: CPU core数 x 2
```

#### **PostgreSQL接続プール**
```bash
# データベース接続: 正常
# 接続プール: Kong内部管理
# 監視: reachable=true
```

#### **Redis キャッシュ**
```bash
# 用途: セッション・Rate Limitingカウンター
# 接続状況: 正常
# パフォーマンス: 高速アクセス
```

### **負荷テスト結果**
```bash
# 連続リクエスト (10回): 14-20ms 安定
# 並列リクエスト (5並列): 同時処理成功
# Rate Limiting: 100req/min 正常動作
```

---

## 🗄️ **バックアップ・復旧**

### **バックアップ対象**
- Kong設定データ (Services, Routes, Consumers, Plugins)
- PostgreSQLデータベース
- Redis データ（オプション）
- 設定ファイル・スクリプト

### **バックアップ実行**
```bash
# Kong設定バックアップ
mkdir -p /tmp/kong_backup
curl -s http://localhost:8001/services > /tmp/kong_backup/services.json
curl -s http://localhost:8001/routes > /tmp/kong_backup/routes.json
curl -s http://localhost:8001/consumers > /tmp/kong_backup/consumers.json
curl -s http://localhost:8001/plugins > /tmp/kong_backup/plugins.json

# PostgreSQLバックアップ
docker exec ai-postgres pg_dump -U ai_user ai_development > /tmp/kong_backup/postgres_backup.sql
```

### **復旧手順**
```bash
# 1. Kong停止
docker compose stop ai-kong

# 2. PostgreSQL復旧
docker exec -i ai-postgres psql -U ai_user ai_development < /tmp/kong_backup/postgres_backup.sql

# 3. Kong再起動
docker compose up -d ai-kong

# 4. 設定確認
curl http://localhost:8001/status
```

### **災害復旧**
```bash
# 完全復旧手順:
# 1. Docker環境再構築
# 2. PostgreSQL・Redis復旧
# 3. Kong設定復旧
# 4. API Key・プラグイン復旧
# 5. 動作確認・テスト実行
```

---

## 📞 **緊急連絡先・エスカレーション**

### **レベル1: 自動復旧**
- Kong自動再起動
- ヘルスチェック自動実行
- アラート自動生成

### **レベル2: 運用チーム対応**
- 監視アラート対応
- 基本トラブルシューティング
- 設定調整・ログ分析

### **レベル3: 開発チーム・専門家**
- 複雑な設定問題
- セキュリティインシデント
- 大規模障害対応

### **連絡先**
- **プライマリ**: AI開発チーム
- **エスカレーション**: システム管理者
- **緊急**: ai-emergency@development.local

---

## 📚 **参考資料**

### **公式ドキュメント**
- [Kong Gateway Documentation](https://docs.konghq.com/gateway/)
- [Kong Admin API Reference](https://docs.konghq.com/gateway/api/)
- [Kong Plugin Hub](https://docs.konghq.com/hub/)

### **設定ファイル場所**
- Kong設定: `/etc/kong/kong.conf`
- Docker Compose: `_core_config/docker/docker-compose.yml`
- スクリプト: `_core_config/docker/kong/scripts/`

### **ログファイル場所**
- Kong: `docker logs ai-kong`
- PostgreSQL: `docker logs ai-postgres`
- 監視ログ: `/tmp/kong_alerts.log`
- メトリクス: `/tmp/kong_metrics.log`

---

**🎯 Kong Gateway 本格運用開始: 2025年6月10日**  
**📋 最終更新: 2025年6月10日 19:30**  
**✅ 運用レディ状態: 100%完了** 