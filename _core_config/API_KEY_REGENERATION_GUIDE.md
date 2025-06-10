# 🔑 **APIキー再生成ガイド**

**緊急度**: 🔥 **最高優先度** - 即座に実行が必要  
**理由**: 現在のAPIキーが平文で公開されているため

---

## ⚠️ **重要な注意事項**

### 🚨 **セキュリティリスク**
現在のAPIキーは以下の理由で**即座に無効化**する必要があります：
- チャットログやドキュメントに平文で記録
- バックアップファイルに含まれている可能性
- セキュリティベストプラクティスに反する状態

### 🎯 **対応の流れ**
1. **新しいAPIキーを生成**
2. **古いAPIキーを無効化**  
3. **環境変数ファイルを更新**
4. **MCP設定を再適用**
5. **Cursor再起動で確認**

---

## 🔑 **サービス別再生成手順**

### 1️⃣ **N8N (JWT Token)**

#### 📍 **現在のキー**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhNjFiMjgyNy1mNTMyLTQ3MGUtYWY3YS0zYjY4NDIxNTJmM2QiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzQ4MjE3NTI5fQ.xD08ybuEDKyLPG7oy-Vqwv3yTwNK-XAUlCAfA0G3lgU
```

#### 🔄 **再生成手順**
1. **N8Nにアクセス**: `http://localhost:5678`
2. **設定 > Users & Permissions > API Keys**
3. **現在のキーを削除**
4. **新しいAPI Keyを生成**
5. **生成されたJWTトークンをコピー**

---

### 2️⃣ **Notion API (🚫 使用停止)**

#### 📍 **現在のキー（削除対象）**
```
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
```

#### 🗑️ **完全削除手順**
1. **Notion Developers**: `https://www.notion.so/my-integrations`
2. **既存のIntegrationを選択**
3. **Integration削除**: "Delete integration"で完全削除
4. **確認**: "I understand this action cannot be undone"
5. **APIキー無効化完了**

#### ⚠️ **削除理由**
- **使用停止決定**: Notion MCPサーバーの完全除去
- **セキュリティ向上**: 使用しないAPIキーの排除
- **管理簡素化**: 必要なサービスのみに集約

---

### 3️⃣ **Airtable API**

#### 📍 **現在のキー**
```
patn[MASKED_API_KEY]
```

#### 🔄 **再生成手順**
1. **Airtable Account**: `https://airtable.com/account`
2. **Developer Hub > Personal Access Tokens**
3. **既存のトークンを削除**
4. **"Create new token"**
5. **必要なスコープを設定**:
   - `data.records:read`
   - `data.records:write`
   - `schema.bases:read`
6. **新しいトークンをコピー**

---

## 🔄 **環境変数更新手順**

### 1️⃣ **セキュア環境ファイルを編集**
```bash
# セキュアファイルを編集
nano ~/.env.secure
```

### 2️⃣ **新しいAPIキーに置換**
```bash
# === セキュア環境変数 ===
# 更新日: 2024年1月

# N8N API Key (新しいJWT Token)
export N8N_API_KEY="新しいN8N_JWT_トークンをここに"

# Notion API Key (削除 - 使用停止)
# export NOTION_API_KEY="REMOVED_SERVICE"

# Airtable API Key (新しいトークン)
export AIRTABLE_API_KEY="新しいAirtable_トークンをここに"
```

### 3️⃣ **MCP設定を再適用**
```bash
# 環境変数を読み込んでMCP設定更新
cd ~/development
./fix_mcp_environment.sh
```

### 4️⃣ **Cursorを再起動**
- Cursorを完全に終了
- 再起動してMCP接続を確認

---

## ✅ **確認チェックリスト**

### 🔐 **セキュリティ確認**
- [ ] 古いAPIキーがすべて無効化されている
- [ ] 新しいAPIキーが正しく環境変数に設定されている
- [ ] MCP設定ファイルに平文のAPIキーが残っていない
- [ ] 環境変数ファイルの権限が600になっている

### 🔌 **動作確認**
- [ ] N8NとのMCP接続が正常
- [ ] ~~NotionとのMCP接続が正常~~ → **削除済み**
- [ ] AirtableとのMCP接続が正常
- [ ] 使用中サービスでのCRUD操作が可能

### 📝 **ドキュメント更新**
- [ ] 新しいAPIキー情報の記録（マスク形式）
- [ ] セキュリティ対応完了の記録
- [ ] 次回メンテナンス予定の設定

---

## 🚨 **緊急時の対応**

### 📞 **問題が発生した場合**
1. **バックアップ復元**: `~/Development/secure_backups/`から復元
2. **手動設定**: MCPサーバーを一時的に無効化
3. **段階的復旧**: 1つずつサービスを有効化

### 🔙 **ロールバック手順**
```bash
# 元の設定に戻す（緊急時のみ）
cp ~/Development/secure_backups/original_mcp_TIMESTAMP.json ~/.cursor/mcp.json
```

---

## 📋 **完了後のアクション**

### ✅ **セキュリティ対応完了**
1. **進捗ダッシュボード更新**
2. **セキュリティステータス更新** 
3. **次回メンテナンス計画策定**

### 🎯 **次のフェーズ準備**
- Day 3: プロジェクト移行準備
- 自動化スクリプト拡張
- 監視システム導入

---

**🎯 実行優先度**: **最高** - 他の作業よりも先に実行してください 