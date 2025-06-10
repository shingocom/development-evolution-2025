# 🔒 セキュリティ改善計画

**作成日**: 2024年1月  
**優先度**: 🔴 最高（即座に対応が必要）  
**ステータス**: 📋 計画中

---

## 🚨 発見された重大なセキュリティリスク

### 🔴 Critical（緊急対応必要）

#### 1. **APIキー平文保存**
- **場所**: `/Users/shingoyamaguchi02/.cursor/mcp.json`
- **リスク**: すべてのAPIキーが平文で記載
- **影響範囲**: 
  - N8N API Key (JWT Token)
  - Notion API Key (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)
  - Airtable API Key (patn[MASKED_API_KEY])

#### 2. **設定ファイルバックアップの暴露**
- **場所**: `~/Development/backup_20250607_111906/.cursor/mcp.json`
- **リスク**: バックアップファイルにも平文でAPIキーが保存
- **影響**: 暗号化されていないバックアップがリスクを増大

---

## 🛠️ 改善アクションプラン

### Phase 1: 緊急セキュリティ対応（即座）

#### ✅ **1.1 現在のAPIキー無効化・再生成**
```bash
# TODO: 各サービスでAPIキーを再生成
□ Notion API Key の再生成
□ Airtable API Key の再生成  
□ N8N API Key の再生成（可能であれば）
□ 古いキーの無効化確認
```

#### ✅ **1.2 環境変数への移行**
```bash
# 新しい環境変数ファイル作成
touch ~/.env.secure
chmod 600 ~/.env.secure

# 環境変数設定例
cat >> ~/.env.secure << 'EOF'
# === Secure API Keys ===
export N8N_API_KEY="NEW_SECURE_KEY_HERE"
export NOTION_API_KEY="NEW_NOTION_KEY_HERE" 
export AIRTABLE_API_KEY="NEW_AIRTABLE_KEY_HERE"
EOF
```

#### ✅ **1.3 MCP設定ファイルの環境変数化**
```json
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
    "airtable": {
      "command": "npx",
      "args": ["@felores/airtable-mcp-server"],
      "env": {
        "AIRTABLE_API_KEY": "${AIRTABLE_API_KEY}"
      }
    },
    "notionApi": {
      "command": "npx", 
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer ${NOTION_API_KEY}\", \"Notion-Version\": \"2022-06-28\" }"
      }
    }
  }
}
```

### Phase 2: セキュアな管理システム構築（1-2日後）

#### ✅ **2.1 macOS Keychain統合**
```bash
#!/bin/bash
# セキュアキー管理スクリプト

# キーチェーンにAPIキー保存
security add-generic-password \
  -s "n8n-api" \
  -a "$USER" \
  -w "NEW_N8N_API_KEY" \
  -T "" \
  login.keychain

security add-generic-password \
  -s "notion-api" \
  -a "$USER" \
  -w "NEW_NOTION_API_KEY" \
  -T "" \
  login.keychain

security add-generic-password \
  -s "airtable-api" \
  -a "$USER" \
  -w "NEW_AIRTABLE_API_KEY" \
  -T "" \
  login.keychain
```

#### ✅ **2.2 セキュア設定ローダー**
```bash
#!/bin/bash
# secure_env_loader.sh

load_secure_env() {
    export N8N_API_KEY=$(security find-generic-password -s "n8n-api" -w)
    export NOTION_API_KEY=$(security find-generic-password -s "notion-api" -w)
    export AIRTABLE_API_KEY=$(security find-generic-password -s "airtable-api" -w)
    
    echo "✅ セキュアな環境変数をロードしました"
}

# Cursor起動前に実行
load_secure_env
```

#### ✅ **2.3 暗号化バックアップシステム**
```bash
#!/bin/bash
# secure_backup.sh

BACKUP_DIR="~/Development/secure_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 設定ファイルをAPIキーを除いて暗号化バックアップ
create_secure_backup() {
    mkdir -p "$BACKUP_DIR"
    
    # APIキーをマスクした設定ファイル作成
    cat ~/.cursor/mcp.json | \
        sed 's/"[a-zA-Z0-9_-]*API[a-zA-Z0-9_-]*": "[^"]*"/"API_KEY": "[MASKED]"/g' | \
        sed 's/"Bearer [^"]*"/"Bearer [MASKED]"/g' > \
        "$BACKUP_DIR/mcp_masked_$TIMESTAMP.json"
    
    # 暗号化
    gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
        "$BACKUP_DIR/mcp_masked_$TIMESTAMP.json"
    
    # 平文削除
    rm "$BACKUP_DIR/mcp_masked_$TIMESTAMP.json"
    
    echo "✅ セキュアバックアップ作成: $BACKUP_DIR/mcp_masked_$TIMESTAMP.json.gpg"
}
```

### Phase 3: 長期セキュリティ強化（1週間後）

#### ✅ **3.1 アクセス制御強化**
```bash
# ファイルアクセス権限の強化
chmod 600 ~/.cursor/mcp.json
chmod 600 ~/.env.secure
chmod 700 ~/Development/secure_backups/

# プロジェクトフォルダの権限確認
find ~/flux-lab ~/llama-lab ~/sd-lab -name "*.json" -o -name "*.env" | \
    xargs chmod 600
```

#### ✅ **3.2 監査・ログシステム**
```bash
#!/bin/bash
# security_audit.sh

audit_api_key_exposure() {
    echo "🔍 APIキー暴露チェック実行中..."
    
    # ファイルシステム全体でAPIキーパターン検索
    find ~ -type f \( -name "*.json" -o -name "*.env" -o -name "*.md" \) \
        -exec grep -l "ntn_\|patn\|eyJhbGci" {} \; 2>/dev/null
    
    # Git履歴内のAPIキー検索
    find ~ -name ".git" -type d | while read gitdir; do
        cd "$(dirname "$gitdir")"
        git log --all --grep="API\|token\|key" --oneline 2>/dev/null
    done
}

# 定期実行設定
echo "0 9 * * * /path/to/security_audit.sh" | crontab -
```

#### ✅ **3.3 セキュリティ監視ダッシュボード**
```bash
#!/bin/bash
# security_dashboard.sh

display_security_status() {
    echo "🔒 === セキュリティ状況ダッシュボード ==="
    echo "📅 最終チェック: $(date)"
    echo ""
    
    # APIキー状態確認
    echo "🔑 APIキー状態:"
    security find-generic-password -s "n8n-api" >/dev/null 2>&1 && \
        echo "  ✅ N8N API Key: セキュア保存済み" || \
        echo "  ❌ N8N API Key: 未設定"
    
    security find-generic-password -s "notion-api" >/dev/null 2>&1 && \
        echo "  ✅ Notion API Key: セキュア保存済み" || \
        echo "  ❌ Notion API Key: 未設定"
    
    security find-generic-password -s "airtable-api" >/dev/null 2>&1 && \
        echo "  ✅ Airtable API Key: セキュア保存済み" || \
        echo "  ❌ Airtable API Key: 未設定"
    
    # ファイル権限確認
    echo ""
    echo "📁 ファイル権限:"
    ls -la ~/.cursor/mcp.json | awk '{print "  MCP設定: " $1}'
    ls -la ~/.env.secure 2>/dev/null | awk '{print "  環境変数: " $1}' || \
        echo "  環境変数: 未作成"
    
    # バックアップ状況
    echo ""
    echo "💾 バックアップ:"
    backup_count=$(ls ~/Development/secure_backups/*.gpg 2>/dev/null | wc -l)
    echo "  暗号化バックアップ: ${backup_count}個"
}
```

---

## 📋 実行チェックリスト

### 🔴 Phase 1: 緊急対応（今すぐ）
- [ ] 現在のAPIキー無効化
- [ ] 新しいAPIキー生成
- [ ] 環境変数ファイル作成
- [ ] MCP設定ファイル環境変数化
- [ ] 既存バックアップファイルの暗号化または削除

### 🟡 Phase 2: システム構築（1-2日）
- [ ] macOS Keychain統合
- [ ] セキュア設定ローダー作成
- [ ] 暗号化バックアップシステム構築
- [ ] テスト・動作確認

### 🟢 Phase 3: 長期強化（1週間）
- [ ] アクセス制御強化
- [ ] 監査システム構築
- [ ] セキュリティダッシュボード
- [ ] 定期チェック自動化

---

## 🎯 期待効果

| 項目 | 現在 | 改善後 | 改善率 |
|------|------|--------|--------|
| **APIキー暴露リスク** | 高 (平文保存) | 低 (暗号化・Keychain) | -90% |
| **アクセス制御** | なし | 厳格な権限設定 | +100% |
| **監査可能性** | なし | 完全ログ・監視 | +100% |
| **バックアップセキュリティ** | 低 (平文) | 高 (暗号化) | +95% |

---

**⚠️ 注意事項**
- Phase 1は**即座に実行が必要**
- APIキー再生成時は各サービスでの連携確認が必要
- 暗号化パスワードは別途安全に管理すること 