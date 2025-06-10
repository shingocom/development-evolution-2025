# 🔗 Website API Kong Gateway統合ガイド

**作成日**: 2025年6月10日  
**対象**: 外部Website APIのKong Gateway経由アクセス統合  
**前提**: Kong Gateway Hotfix完了環境

---

## 🚀 **クイックスタート: 3ステップ統合**

### **Step 1: API情報準備**
```bash
# 統合したいAPIの情報を整理
API_NAME="your-api-name"        # 例: twitter-api, github-api
API_URL="https://api.xxx.com"   # 実際のAPI URL
KONG_PATH="/api/v1/xxx"         # Kong経由でアクセスするパス
```

### **Step 2: 統合実行**
```bash
# 基本統合 (認証なし)
./add_website_api.sh your-api-name https://api.xxx.com /api/v1/xxx

# セキュア統合 (推奨)
./add_website_api.sh your-api-name https://api.xxx.com /api/v1/xxx --auth --rate-limit --monitoring
```

### **Step 3: テスト実行**
```bash
# Kong経由でAPIアクセステスト
curl -H "X-API-Key: ai-dev-key-2025" "http://localhost:8080/api/v1/xxx"
```

---

## 📋 **統合パターン別設定例**

### **🔓 パターン1: 公開API (認証なし)**
```bash
# 例: JSONPlaceholder API
./add_website_api.sh jsonplaceholder-api https://jsonplaceholder.typicode.com /api/v1/jsonplaceholder --monitoring

# テスト
curl "http://localhost:8080/api/v1/jsonplaceholder/posts/1"
```

### **🔐 パターン2: セキュアAPI (認証あり)**
```bash
# 例: GitHub API
./add_website_api.sh github-api https://api.github.com /api/v1/github --auth --rate-limit --cors --monitoring

# テスト
curl -H "X-API-Key: ai-dev-key-2025" "http://localhost:8080/api/v1/github/user"
```

### **⚡ パターン3: 高負荷API (Rate Limiting調整)**
```bash
# 例: 高負荷対応API
./add_website_api.sh high-traffic-api https://api.example.com /api/v1/hightraffic \
  --auth --rate-limit --rate-minute 500 --rate-hour 10000 --monitoring

# テスト
curl -H "X-API-Key: ai-dev-key-2025" "http://localhost:8080/api/v1/hightraffic/data"
```

### **🌐 パターン4: Web Frontend用API (CORS対応)**
```bash
# 例: フロントエンド用API
./add_website_api.sh frontend-api https://api.frontend.com /api/v1/frontend --cors --monitoring

# テスト (ブラウザから)
fetch('http://localhost:8080/api/v1/frontend/data')
```

---

## 🛠️ **手動統合手順 (詳細)**

### **Service作成**
```bash
curl -X POST http://localhost:8001/services \
  -d "name=example-api" \
  -d "url=https://api.example.com"
```

### **Route作成**
```bash
curl -X POST http://localhost:8001/services/example-api/routes \
  -d "paths[]=/api/v1/example" \
  -d "methods[]=GET" \
  -d "methods[]=POST"
```

### **プラグイン追加**
```bash
# API Key認証
curl -X POST http://localhost:8001/services/example-api/plugins \
  -d "name=key-auth"

# Rate Limiting
curl -X POST http://localhost:8001/services/example-api/plugins \
  -d "name=rate-limiting" \
  -d "config.minute=100" \
  -d "config.hour=1000"

# CORS
curl -X POST http://localhost:8001/services/example-api/plugins \
  -d "name=cors" \
  -d "config.origins[]=http://localhost:3000"

# Prometheus監視
curl -X POST http://localhost:8001/services/example-api/plugins \
  -d "name=prometheus"
```

---

## 🔑 **認証・API Key管理**

### **既存API Key使用 (推奨)**
```bash
# 現在のai-dev-key-2025を使用
curl -H "X-API-Key: ai-dev-key-2025" "http://localhost:8080/api/v1/your-api"
```

### **新しいAPI Key作成**
```bash
# 新しいConsumer作成
curl -X POST http://localhost:8001/consumers \
  -d "username=your-api-user"

# API Key生成
curl -X POST http://localhost:8001/consumers/your-api-user/key-auth \
  -d "key=your-custom-api-key-2025"

# 使用
curl -H "X-API-Key: your-custom-api-key-2025" "http://localhost:8080/api/v1/your-api"
```

### **API Key確認**
```bash
# 全Consumerリスト
curl http://localhost:8001/consumers

# 特定ConsumerのAPI Key
curl http://localhost:8001/consumers/ai-dev-user/key-auth
```

---

## 📊 **統合済みAPI管理**

### **統合API一覧確認**
```bash
# 全Services確認
curl http://localhost:8001/services | jq '.data[] | {name: .name, host: .host, port: .port}'

# 全Routes確認
curl http://localhost:8001/routes | jq '.data[] | {paths: .paths, methods: .methods}'
```

### **特定API設定確認**
```bash
# Service詳細
curl http://localhost:8001/services/your-api-name

# Route詳細
curl http://localhost:8001/services/your-api-name/routes

# Plugin設定
curl http://localhost:8001/services/your-api-name/plugins
```

### **統計・監視確認**
```bash
# Kong統計
curl http://localhost:8001/status

# Prometheusメトリクス
curl http://localhost:8001/metrics

# 特定APIの統計
curl http://localhost:8001/services/your-api-name | jq '.name, .created_at'
```

---

## 🚨 **トラブルシューティング**

### **よくある問題と解決**

#### **1. API接続エラー**
```bash
# 症状: 502 Bad Gateway
# 原因: 元APIが利用不可・URL間違い

# 確認方法
curl -v https://api.example.com  # 元API直接確認
curl http://localhost:8001/services/your-api-name  # Kong設定確認
```

#### **2. 認証エラー**
```bash
# 症状: 401 Unauthorized
# 原因: API Key未設定・間違い

# 確認方法
curl http://localhost:8001/consumers/ai-dev-user/key-auth  # API Key確認
curl -H "X-API-Key: ai-dev-key-2025" http://localhost:8080/api/v1/your-api  # 正しいKey使用
```

#### **3. CORS エラー**
```bash
# 症状: ブラウザでCORSエラー
# 原因: CORS Plugin未設定

# 解決方法
curl -X POST http://localhost:8001/services/your-api-name/plugins \
  -d "name=cors" \
  -d "config.origins[]=http://localhost:3000"
```

#### **4. Rate Limit到達**
```bash
# 症状: 429 Too Many Requests
# 原因: Rate Limit制限到達

# 確認・調整
curl http://localhost:8001/services/your-api-name/plugins | jq '.data[] | select(.name=="rate-limiting")'
# Rate Limit調整
curl -X PATCH http://localhost:8001/plugins/{plugin-id} \
  -d "config.minute=200"
```

---

## 📈 **パフォーマンス最適化**

### **推奨設定**

#### **高負荷API向け**
```bash
# Rate Limiting調整
--rate-minute 500 --rate-hour 10000

# Kong Upstream設定
curl -X PATCH http://localhost:8001/services/your-api-name \
  -d "connect_timeout=60000" \
  -d "write_timeout=60000" \
  -d "read_timeout=60000"
```

#### **低遅延API向け**
```bash
# Kong設定最適化
curl -X PATCH http://localhost:8001/services/your-api-name \
  -d "connect_timeout=5000" \
  -d "write_timeout=5000" \
  -d "read_timeout=5000"
```

### **監視・アラート**
```bash
# Prometheus監視必須
--monitoring

# アラート確認
tail -f /tmp/kong_alerts.log | grep your-api-name
```

---

## 🔄 **API統合ワークフロー**

### **統合チェックリスト**
- [ ] API URL・仕様確認
- [ ] Kong Path設計 (/api/v1/xxx)
- [ ] セキュリティ要件確認 (認証・CORS等)
- [ ] Rate Limiting設定
- [ ] 統合スクリプト実行
- [ ] テスト・動作確認
- [ ] 監視・アラート設定確認
- [ ] ドキュメント更新

### **統合後の確認**
```bash
# 1. Kong設定確認
curl http://localhost:8001/services/your-api-name

# 2. アクセステスト
curl -H "X-API-Key: ai-dev-key-2025" "http://localhost:8080/api/v1/your-api"

# 3. 監視確認
curl http://localhost:8001/metrics | grep your_api_name

# 4. ログ確認
docker logs ai-kong --tail 20 | grep your-api-name
```

---

## 📚 **参考情報**

### **Kong Admin API**
- **Base URL**: http://localhost:8001
- **Services**: /services
- **Routes**: /routes  
- **Plugins**: /plugins
- **Consumers**: /consumers

### **Kong Proxy URL**
- **Base URL**: http://localhost:8080
- **統合API**: http://localhost:8080/api/v1/{your-api-path}

### **利用可能Plugin**
- **key-auth**: API Key認証
- **rate-limiting**: Rate Limiting
- **cors**: CORS設定
- **prometheus**: 監視
- **ip-restriction**: IP制限
- **request-size-limiting**: リクエストサイズ制限
- **bot-detection**: Bot検出

---

**🎯 Website API Kong統合: ワンコマンドで簡単統合！**  
**🔧 統合スクリプト**: `./add_website_api.sh`  
**📊 監視**: Prometheus・Grafana自動対応  
**🛡️ セキュリティ**: API Key・Rate Limiting・CORS完備** 