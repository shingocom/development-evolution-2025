# 🚨 N8N作業安全ガイドライン

**作成日**: 2025-06-10  
**重要度**: 🔴 **CRITICAL**  
**目的**: データ破壊事故防止

---

## ⚠️ **重要な制限事項**

### **N8Nローカル環境の制限**
```
🔴 絶対に守るべきルール:

✅ N8Nローカルホスト = 1アカウントのみ
❌ 新規アカウント作成 = 既存データ完全削除
❌ 管理者アカウント追加 = データベース初期化
❌ ユーザー管理画面での操作 = 危険
```

### **データ損失リスク**
- **既存ワークフロー**: 完全削除
- **既存設定**: 完全削除  
- **作業履歴**: 完全削除
- **復旧可能性**: **不可能**

---

## 🔧 **正しい作業手順**

### **Phase 1: 事前確認（必須）**
```bash
# 1. N8Nサービス状況確認
curl http://localhost:5678/healthz
docker ps | grep n8n

# 2. 既存データの存在確認
curl http://localhost:5678/rest/workflows | jq '.count'

# 3. バックアップ作成
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/n8n_backup_$(date +%Y%m%d_%H%M%S).tar.gz /data
```

### **Phase 2: MCP接続（データ破壊なし）**
```bash
# 1. 既存ログイン情報で認証
# 注意: 新規ログイン画面でも既存情報を使用

# 2. APIキー取得（既存アカウントで）
# N8N UI: Settings > API Keys > Create New

# 3. MCP設定更新（慎重に）
# ~/.cursor/mcp.json の N8N_API_KEY のみ変更
```

### **Phase 3: 動作確認**
```bash
# 1. 既存データ保持確認
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:5678/api/v1/workflows | jq '.count'

# 2. MCP接続テスト
# Cursorで N8N MCP ツール使用テスト

# 3. 既存ワークフロー確認
# 既存IDでワークフローアクセス可能か確認
```

---

## 🚨 **緊急時対応**

### **データ損失発生時**
```bash
# 1. 即座にコンテナ停止
docker stop $(docker ps -q --filter "name=n8n")

# 2. データボリューム確認
docker volume ls | grep n8n

# 3. バックアップから復旧試行
# 注意: 完全復旧は困難な場合が多い
```

### **予防策**
- 作業前バックアップ必須
- 新規アカウント作成絶対禁止
- 管理画面操作時は慎重に
- データベース初期化コマンド実行禁止

---

## 📋 **チェックリスト**

### **作業開始前（必須確認）**
- [ ] N8Nサービス稼働確認
- [ ] 既存データ存在確認
- [ ] バックアップ作成完了
- [ ] 既存ログイン情報準備

### **MCP接続時**
- [ ] 既存アカウントでログイン
- [ ] 新規アカウント作成回避
- [ ] APIキー取得（既存アカウント）
- [ ] MCP設定更新のみ

### **作業完了後**
- [ ] 既存データ保持確認
- [ ] ワークフロー数確認
- [ ] MCP接続動作確認
- [ ] 作業記録・コミット

---

## 📞 **緊急連絡・参考情報**

### **重要ファイル**
- N8N設定: `~/.cursor/mcp.json`
- Docker Compose: `_core_config/docker/docker-compose.yml`
- バックアップ: `n8n_backup_*.tar.gz`

### **安全コマンド**
```bash
# N8N状況確認のみ（安全）
docker ps | grep n8n
curl http://localhost:5678/healthz

# データ確認のみ（安全）
curl http://localhost:5678/rest/workflows | jq '.count'

# 危険コマンド（実行禁止）
docker volume rm n8n_data  # ❌ データ完全削除
docker run ... --rm-database  # ❌ DB初期化
```

---

**🎯 目標**: データを守りながらMCP統合を実現  
**🔴 絶対NG**: 新規アカウント作成・データベース初期化  
**✅ 推奨**: 既存環境の慎重な活用

---

*このガイドラインを遵守し、データ損失事故を防止してください。* 