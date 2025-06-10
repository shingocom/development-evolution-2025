# 🔑 APIキー再生成ガイド

**緊急度**: 🔴 最高  
**対象**: 暴露されたAPIキーの安全な再生成・適用  
**最終更新**: 2024年1月

---

## 🚨 現在の暴露状況

### **特定されたAPIキー**
1. **N8N_API_KEY**: JWT Token (eyJhbGciOiJIUzI1NiIs...)
2. **AIRTABLE_API_KEY**: Personal Access Token (patn[MASKED_API_KEY]..)

### **リスクレベル**
- **影響度**: 🔴 高（ワークフロー自動化・データベースアクセス）
- **緊急度**: 🔴 最高（即座に対応必要）

---

## 🔄 再生成手順

### **1. N8N APIキー再生成**

#### **アクセス方法**
```
1. N8Nインスタンスにアクセス
   URL: http://localhost:5678
   
2. 設定画面へ移動
   Settings > Personal > API Keys
   
3. 既存キーの無効化
   - 現在のキーを削除または無効化
   
4. 新しいキー生成
   - "Create API Key" をクリック
   - 適切な名前を設定（例: "cursor-mcp-2024"）
   - 必要な権限を設定
```

#### **権限設定**
```
推奨権限:
- workflow:read
- workflow:write  
- workflow:execute
- credential:read (必要に応じて)
```

#### **セキュリティ注意事項**
- キー生成時のみ表示されるため、即座に安全な場所に保存
- 古いキーは即座に削除
- 定期的なローテーション（推奨：3ヶ月毎）

### **2. Airtable APIキー再生成**

#### **アクセス方法**
```
1. Airtableアカウントにログイン
   URL: https://airtable.com/
   
2. Account設定に移動
   アカウント > Developer > Personal access tokens
   または直接: https://airtable.com/create/tokens
   
3. 既存トークンの確認・削除
   - 現在のトークンを特定
   - "Delete" で安全に削除
   
4. 新しいトークン生成
   - "Create new token" をクリック
   - 名前設定（例: "cursor-mcp-token-2024"）
   - 必要なスコープ・ベースを選択
```

#### **権限設定（スコープ）**
```
必須スコープ:
- data.records:read    # レコード読み取り
- data.records:write   # レコード書き込み
- schema.bases:read    # ベース情報読み取り

対象ベース:
- News
- video_generation  
- video_dose&remedy
- youtube_generation
- youtubeshort_generation
```

#### **セキュリティ注意事項**
- 最小権限の原則に従う
- 不要なベースへのアクセス権限は付与しない
- 定期的なアクセスログ確認

---

## 🔧 環境変数への適用

### **手順1: セキュア環境変数ファイル更新**
```bash
# 1. セキュア環境変数ファイルを編集
nano ~/.env.secure

# 2. 新しいAPIキーを設定
# 以下のように更新:
export N8N_API_KEY="新しいN8NのAPIキー"
export AIRTABLE_API_KEY="新しいAirtableのAPIキー"

# 3. ファイル保存・終了
```

### **手順2: 権限確認**
```bash
# セキュア権限設定
chmod 600 ~/.env.secure

# 権限確認
ls -la ~/.env.secure
# 期待結果: -rw------- 1 user user ... ~/.env.secure
```

### **手順3: 環境変数読み込みテスト**
```bash
# 環境変数読み込み
source ~/.env.secure

# 設定確認（値はマスク表示）
echo "N8N_API_KEY: ${N8N_API_KEY:0:10}..."
echo "AIRTABLE_API_KEY: ${AIRTABLE_API_KEY:0:10}..."
```

---

## 🎯 MCP設定への適用

### **現在の設定確認**
```bash
# 現在のMCP設定確認
cat ~/.cursor/mcp.json | grep -A2 -B2 "API_KEY"
```

### **既にセキュアテンプレート準備済み**
```bash
# セキュアテンプレートの確認
cat _core_config/mcp/templates/secure_template.json

# 環境変数を使用した設定例:
# "N8N_API_KEY": "${N8N_API_KEY}"
# "AIRTABLE_API_KEY": "${AIRTABLE_API_KEY}"
```

### **⚠️ 重要**: 現在のMCP設定は既に環境変数対応済み
現在の`~/.cursor/mcp.json`の該当部分：
```json
{
  "env": {
    "N8N_API_KEY": "${N8N_API_KEY}",
    "AIRTABLE_API_KEY": "${AIRTABLE_API_KEY}"
  }
}
```

**ただし、MCPは環境変数の動的解決に制限があるため、以下のいずれかの対応が必要**:

#### **オプション1: 直接設定（セキュリティリスクあり）**
```bash
# 新しいAPIキーを直接MCP設定に記載
# ⚠️ セキュリティリスクがあるため推奨しない
```

#### **オプション2: 起動時環境変数設定（推奨）**
```bash
# Cursor起動前に環境変数設定
source ~/.env.secure
/Applications/Cursor.app/Contents/MacOS/Cursor

# または.zshrc/.bashrcに追加:
echo 'source ~/.env.secure' >> ~/.zshrc
```

#### **オプション3: セキュア起動スクリプト作成（最推奨）**
```bash
# セキュア起動スクリプト作成
cat > ~/start_cursor_secure.sh << 'EOF'
#!/bin/bash
echo "🔒 セキュア環境でCursorを起動中..."
source ~/.env.secure
echo "✅ 環境変数読み込み完了"
/Applications/Cursor.app/Contents/MacOS/Cursor
EOF

chmod +x ~/start_cursor_secure.sh
```

---

## ✅ 動作確認手順

### **1. 環境変数確認**
```bash
# 設定確認
source ~/.env.secure
env | grep -E "(N8N|AIRTABLE)_API_KEY" | sed 's/=.*/=***MASKED***/'
```

### **2. MCP接続テスト**
```
Cursor内で以下を実行:

1. Airtableベース一覧取得
   → 5つのベースが表示されることを確認

2. N8Nワークフロー確認
   → 接続エラーが解消されることを確認
```

### **3. セキュリティ確認**
```bash
# APIキー暴露チェック
find ~ -name "*.json" -o -name "*.md" | xargs grep -l "patn\|eyJhbGci" 2>/dev/null
# 期待結果: 何も表示されない（暴露なし）
```

---

## 📋 完了チェックリスト

### **APIキー再生成**
- [ ] N8N: 既存キー削除
- [ ] N8N: 新しいキー生成
- [ ] Airtable: 既存トークン削除  
- [ ] Airtable: 新しいトークン生成
- [ ] 旧キーの完全削除確認

### **環境変数設定**
- [ ] ~/.env.secure更新
- [ ] 権限設定確認（600）
- [ ] 環境変数読み込みテスト
- [ ] セキュア起動スクリプト作成

### **動作確認**
- [ ] Airtable MCP接続テスト
- [ ] N8N MCP接続テスト
- [ ] セキュリティスキャン実行
- [ ] 暴露なし確認

### **文書化**
- [ ] 新しいキー情報の安全な記録
- [ ] 変更履歴の記録
- [ ] 次回更新予定の設定

---

## 📞 緊急時の対応

### **キー生成に失敗した場合**
1. サービス管理画面で権限確認
2. ネットワーク接続確認
3. ブラウザキャッシュクリア
4. 別ブラウザでの試行

### **MCP接続に失敗した場合**
1. 環境変数読み込み確認
2. Cursor完全再起動
3. バックアップ設定からの復元
4. 手動での直接設定（一時的）

---

**重要**: APIキー再生成後は、必ず旧キーを完全削除し、新しいキーの動作確認を実施してください。 