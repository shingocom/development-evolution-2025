# ⚡ 迅速セットアップリファレンス

**用途**: 新環境での素早いセットアップ  
**所要時間**: 15-30分  
**優先度**: 🔴 最高（セキュリティ対応必須）

---

## 🚨 緊急対応チェックリスト

### **1. セキュリティ確認（5分）**
```bash
# APIキー暴露チェック
cat ~/.cursor/mcp.json | grep -E "(API|token|key)" | head -5

# バックアップファイル確認
find ~/Development -name "mcp.json" -exec ls -la {} \;
```

**⚠️ 平文APIキーが見つかった場合は即座にセキュリティ対応実行**

### **2. MCP動作確認（3分）**
```bash
# MCP設定ファイル存在確認
ls -la ~/.cursor/mcp.json

# 権限確認
ls -la ~/.cursor/mcp.json | awk '{print $1}'
```

**期待結果**: `-rw-------` (600) または `-rw-r--r--` (644)

### **3. プロジェクト稼働確認（5分）**
```bash
# AIプロジェクト確認
ls -la ~/flux-lab ~/llama-lab ~/sd-lab 2>/dev/null | grep "^d"

# Python環境確認  
ls ~/flux-lab/venv/ ~/llama-lab/.venv/ ~/sd-lab/.venv/ 2>/dev/null
```

---

## 🔑 重要なコマンド・設定

### **MCP設定場所**
```bash
# メイン設定ファイル
~/.cursor/mcp.json

# バックアップ場所
~/Development/backup_20250607_111906/.cursor/mcp.json
```

### **環境変数設定（セキュリティ対応）**
```bash
# セキュア環境変数ファイル作成
touch ~/.env.secure
chmod 600 ~/.env.secure

# 設定例
cat >> ~/.env.secure << 'EOF'
export N8N_API_KEY="NEW_KEY_HERE"
export NOTION_API_KEY="NEW_KEY_HERE"  
export AIRTABLE_API_KEY="NEW_KEY_HERE"
EOF

# 読み込み
source ~/.env.secure
```

### **MCP接続テスト**
```bash
# Airtable接続確認（MCPが利用可能な場合）
# → Cursor内でAirtableベース一覧を確認

# Filesystem監視確認
ls ~/Desktop ~/Documents ~/Downloads | head -3
```

---

## 📁 ディレクトリ構造の作成

### **基本構造作成（2分）**
```bash
cd ~/Development

# AI Agent専用領域
mkdir -p _ai_workspace/{context,rules,knowledge/{solutions,patterns,resources},templates/{project_init,documentation,workflow}}

# 核となる設定
mkdir -p _core_config/{mcp/{backup_configs,templates},environments,git,docker}

# プロジェクト管理
mkdir -p _project_management/{status,planning,completed,metrics}

# その他
mkdir -p active_projects archive/{old_configs,deprecated_projects,migration_logs} maintenance/{cleanup_scripts,backup_scripts,health_check}
```

### **権限設定**
```bash
# セキュリティ強化
chmod 700 ~/Development/_core_config/
chmod 600 ~/.cursor/mcp.json
find ~/Development -name "*.json" -exec chmod 600 {} \;
```

---

## 🎯 動作確認テスト

### **1. MCP機能テスト（Cursor内で実行）**
```
# Airtableベース一覧取得
→ 5つのベースが表示されることを確認

# ファイルシステムアクセス
→ Desktop, Documents, Downloadsにアクセス可能であることを確認

# Puppeteer動作
→ Webページ操作が可能であることを確認
```

### **2. AIプロジェクト動作確認**
```bash
# FLUX-lab
cd ~/flux-lab && source venv/bin/activate && python flux_webui.py --help

# LLaMA-lab  
cd ~/llama-lab && source .venv/bin/activate && python webui_pro_advanced.py --help

# SD-lab
cd ~/sd-lab && source .venv/bin/activate && ls scripts/
```

---

## ⚠️ 既知の課題と対処法

### **課題1: APIキー平文保存**
```bash
# 対処法: 環境変数化
# 1. 新しいAPIキー生成（各サービス）
# 2. ~/.env.secure に保存
# 3. MCP設定を ${環境変数} に変更
```

### **課題2: MCP環境変数未対応**
```bash
# 対処法: 設定ファイル修正
# ~/.cursor/mcp.json の "API_KEY": "文字列" を
# "API_KEY": "${環境変数名}" に変更
```

### **課題3: バックアップファイルの暴露**
```bash
# 対処法: セキュアバックアップ作成
gpg --cipher-algo AES256 --symmetric important_file.json
rm important_file.json  # 平文削除
```

---

## 🚀 作業開始の手順

### **最優先（セキュリティ）**
1. APIキー暴露状況確認
2. 各サービスでAPIキー再生成
3. セキュア環境変数ファイル作成
4. MCP設定の環境変数化

### **基盤構築**
1. ディレクトリ構造作成
2. 権限設定・セキュリティ強化
3. 既存プロジェクトの整理開始

### **動作確認**
1. MCP機能テスト
2. AIプロジェクト稼働確認
3. 全体システム統合テスト

---

## 📞 緊急時の対応

### **MCP接続不可の場合**
```bash
# 設定ファイル復元
cp ~/Development/backup_20250607_111906/.cursor/mcp.json ~/.cursor/mcp.json

# Cursor再起動
# （アプリケーション再起動）
```

### **プロジェクト動作不可の場合**
```bash
# Python環境確認・再構築
cd ~/プロジェクト名
python -m venv venv  # または .venv
source venv/bin/activate  # または .venv/bin/activate
pip install -r requirements.txt  # 存在する場合
```

### **データ損失の場合**
```bash
# バックアップから復元
cp -r ~/Development/backup_20250607_111906/* 復元先/
```

---

## 🔍 参照ドキュメント

- **詳細状況**: `PROJECT_HANDOVER_SUMMARY.md`
- **セキュリティ対応**: `SECURITY_IMPROVEMENT_PLAN.md`
- **現状詳細**: `CURRENT_STATE_INVENTORY.md`
- **セッション継続**: `CURRENT_SESSION.md`
- **全体計画**: `AI_AGENT_OPTIMIZATION_PLAN.md`

---

**💡 Tips**: 新しいAI Agentは必ず **`README.md`** を最初に読み、このリファレンスで緊急時対応を確認してください。

## 🚀 新規AI Agent向けクイックスタート

### **📋 推奨読了順序**
1. **README.md** - 実践的手順書（必読・最優先）
2. **このファイル** - 緊急時対応・セキュリティ
3. **CURRENT_STATE_INVENTORY.md** - 詳細状況
4. **AI_AGENT_OPTIMIZATION_PLAN.md** - 全体像理解

### **⚡ 5分で作業開始**
```bash
# README.mdの10分スタートガイド実行
cat README.md | grep -A 20 "10分でスタート"
``` 