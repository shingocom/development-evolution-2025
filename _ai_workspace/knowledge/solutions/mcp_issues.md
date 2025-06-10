# 🔧 MCP関連トラブルシューティング

**対象**: Model Context Protocol (MCP) 関連問題  
**最終更新**: 2024年1月  
**経験レベル**: 実際のトラブル対応経験に基づく

---

## 🚨 よくある問題と解決法

### **1. APIキー関連エラー**

#### **問題**: `Authentication failed` / `Invalid API key`
```
Error: Request failed with status 401
Authentication failed
```

**原因**:
- APIキーが無効または期限切れ
- 環境変数が正しく読み込まれていない
- APIキーの権限不足

**解決法**:
```bash
# 1. 環境変数確認
echo $AIRTABLE_API_KEY
echo $N8N_API_KEY

# 2. 環境変数読み込み
source ~/.env.secure

# 3. APIキー再生成（各サービス）
# Airtable: https://airtable.com/create/tokens
# N8N: Settings > API Keys
```

#### **問題**: `Environment variable not found`
```
Error: ${AIRTABLE_API_KEY} not resolved
```

**原因**:
- 環境変数ファイルが読み込まれていない
- 変数名の誤記

**解決法**:
```bash
# 1. 環境変数ファイル確認
cat ~/.env.secure

# 2. 手動読み込み
export AIRTABLE_API_KEY="your_key_here"

# 3. MCP設定確認
cat ~/.cursor/mcp.json | grep -A2 -B2 "API_KEY"
```

---

### **2. 接続エラー**

#### **問題**: `Connection refused` / `ECONNREFUSED`
```
Error: connect ECONNREFUSED 127.0.0.1:5678
```

**原因**:
- N8Nサーバーが起動していない
- ポート番号の間違い
- ファイアウォールによるブロック

**解決法**:
```bash
# 1. N8Nサーバー起動確認
curl http://localhost:5678/healthz

# 2. プロセス確認
ps aux | grep n8n

# 3. N8N起動
npx n8n start

# 4. ポート確認
netstat -an | grep 5678
```

#### **問題**: `Module not found` / `Package not installed`
```
Error: Cannot find module '@felores/airtable-mcp-server'
```

**原因**:
- NPXパッケージのインストール失敗
- ネットワーク接続問題
- パッケージ名の変更

**解決法**:
```bash
# 1. 手動インストール
npm install -g @felores/airtable-mcp-server

# 2. キャッシュクリア
npm cache clean --force

# 3. 代替パッケージ確認
npm search airtable-mcp

# 4. NPX強制再インストール
npx --yes @felores/airtable-mcp-server
```

---

### **3. 権限エラー**

#### **問題**: `Permission denied` / `Access forbidden`
```
Error: EACCES: permission denied, open '/Users/.../mcp.json'
```

**原因**:
- ファイル権限の問題
- ディレクトリアクセス権限不足

**解決法**:
```bash
# 1. 権限確認
ls -la ~/.cursor/mcp.json

# 2. 権限修正
chmod 600 ~/.cursor/mcp.json
chmod 700 ~/.cursor/

# 3. 所有者確認
chown $USER ~/.cursor/mcp.json
```

#### **問題**: Airtable `Insufficient permissions`
```
Error: You don't have permission to access this base
```

**原因**:
- APIキーの権限不足
- ベースへのアクセス権限なし

**解決法**:
```bash
# 1. ベース一覧確認（MCPで実行）
# → Airtableベース一覧取得

# 2. APIキー権限確認
# Airtable > Account > API > Personal access tokens
# 必要な権限: data.records:read, data.records:write

# 3. ベース共有設定確認
# Airtable > Base > Share > API access
```

---

### **4. 設定ファイルエラー**

#### **問題**: `Invalid JSON format`
```
Error: Unexpected token } in JSON at position 123
```

**原因**:
- JSON構文エラー
- コメントの混入
- 文字エンコーディング問題

**解決法**:
```bash
# 1. JSON構文チェック
cat ~/.cursor/mcp.json | python -m json.tool

# 2. バックアップから復元
cp _core_config/mcp/backup_configs/mcp_original_*.json ~/.cursor/mcp.json

# 3. テンプレートから再作成
cp _core_config/mcp/templates/secure_template.json ~/.cursor/mcp.json
```

#### **問題**: `Configuration not loaded`
```
Error: MCP configuration not found or invalid
```

**原因**:
- 設定ファイルの場所間違い
- Cursor再起動が必要

**解決法**:
```bash
# 1. 設定ファイル場所確認
ls -la ~/.cursor/mcp.json

# 2. Cursor再起動
# アプリケーション完全終了 → 再起動

# 3. 設定ファイル再作成
cp _core_config/mcp/templates/secure_template.json ~/.cursor/mcp.json
```

---

## 🔍 診断コマンド集

### **総合診断**
```bash
#!/bin/bash
echo "=== MCP診断スクリプト ==="

# 1. 設定ファイル確認
echo "📁 設定ファイル:"
ls -la ~/.cursor/mcp.json 2>/dev/null || echo "❌ mcp.json not found"

# 2. 環境変数確認
echo "🔑 環境変数:"
env | grep -E "(API_KEY|TOKEN)" | sed 's/=.*/=***MASKED***/'

# 3. ネットワーク確認
echo "🌐 ネットワーク:"
curl -s http://localhost:5678/healthz >/dev/null && echo "✅ N8N接続OK" || echo "❌ N8N接続NG"

# 4. NPXパッケージ確認
echo "📦 パッケージ:"
npx @felores/airtable-mcp-server --version 2>/dev/null && echo "✅ Airtable MCP OK" || echo "❌ Airtable MCP NG"

echo "=== 診断完了 ==="
```

### **セキュリティチェック**
```bash
#!/bin/bash
echo "🔒 セキュリティチェック"

# APIキー暴露チェック
echo "APIキー暴露確認:"
find ~ -name "*.json" -o -name "*.md" | xargs grep -l "patn\|ntn_\|eyJhbGci" 2>/dev/null || echo "✅ 暴露なし"

# 権限チェック
echo "ファイル権限確認:"
ls -la ~/.cursor/mcp.json ~/.env.secure 2>/dev/null | awk '{print $1, $9}'
```

---

## 📋 予防策・ベストプラクティス

### **定期メンテナンス**
```bash
# 週次実行推奨
#!/bin/bash

# 1. バックアップ作成
cp ~/.cursor/mcp.json _core_config/mcp/backup_configs/mcp_$(date +%Y%m%d).json

# 2. 権限確認・修正
chmod 600 ~/.cursor/mcp.json ~/.env.secure

# 3. 不要ファイル削除
find _core_config/mcp/backup_configs/ -name "*.json" -mtime +30 -delete

# 4. セキュリティスキャン
grep -r "api.*key\|token" . --exclude-dir=.git --exclude-dir=venv 2>/dev/null || echo "✅ セキュリティOK"
```

### **緊急時対応手順**
1. **即座に実行**:
   ```bash
   # MCP停止
   pkill -f "mcp"
   
   # 設定バックアップ
   cp ~/.cursor/mcp.json ~/.cursor/mcp.json.emergency.$(date +%s)
   ```

2. **原因調査**:
   - ログファイル確認
   - 最近の変更履歴確認
   - 環境変数状態確認

3. **復旧作業**:
   - バックアップから復元
   - 設定ファイル再作成
   - Cursor再起動

---

## 📞 エスカレーション基準

### **即座にエスカレーション**
- セキュリティインシデント（APIキー暴露等）
- データ損失の可能性
- 複数システムへの影響

### **調査継続**
- 単発の接続エラー
- 設定ファイルの軽微な問題
- パフォーマンス低下

---

**重要**: 問題解決後は必ずこのドキュメントを更新し、ナレッジを蓄積すること 