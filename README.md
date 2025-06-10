# 🤖 AI Agent開発環境 - 実践ガイド

**対象**: 新しいAI Agent・継続作業・引き継ぎ作業  
**目的**: **即座に実践的な作業を開始**できる具体的手順書  
**重要**: このREADMEを**最初に必ず読む**こと

---

## 🚀 **10分でスタート：必須アクション**

### **1. 最優先確認事項（2分）**
```bash
# 現在の位置確認
pwd  # ~/Development にいることを確認

# 重複ファイル緊急チェック
ls -la *.{md,json,sh} 2>/dev/null | wc -l  # 0であることを確認

# セキュリティ状況確認
ls -la ~/.env.secure  # ファイル存在確認
ls -la ~/.cursor/mcp.json  # MCP設定確認
```

### **2. プロジェクト状況把握（3分）**
```bash
# 進捗確認
cat AI_AGENT_OPTIMIZATION_PLAN.md | grep "進捗"

# 現在のセッション情報確認
cat _ai_workspace/context/current_session.md

# 重要ドキュメント確認
ls -la QUICK_SETUP_REFERENCE.md CURRENT_STATE_INVENTORY.md
```

### **3. 安全チェック（3分）**
```bash
# 自動整理スクリプト実行
bash maintenance/scripts/auto_cleanup.sh

# 構造検証
bash maintenance/scripts/structure_validator.sh

# APIキー暴露チェック
grep -r "patn\|ntn_\|eyJhbGci\|sk-" . --exclude-dir=backup_* | head -3
```

### **4. 作業準備完了（2分）**
```bash
# セッション開始記録
echo "## $(date +%Y-%m-%d\ %H:%M:%S) セッション開始" >> _ai_workspace/context/current_session.md
echo "- AI Agent: [あなたのID]" >> _ai_workspace/context/current_session.md
echo "- 作業目標: [今回の目標]" >> _ai_workspace/context/current_session.md
```

---

## 📋 **ファイル更新：具体的手順**

### **🔧 手順1: ファイル編集時の必須プロセス**

#### **編集前チェック（必須）**
```bash
# 1. 重複ファイル確認
find ~/Development -name "*[ファイル名のキーワード]*" | head -5

# 2. 既存ファイル確認
ls -la [対象ディレクトリ]/[ファイル名]

# 3. バックアップ作成（重要ファイルの場合）
cp [ファイルパス] [ファイルパス].backup_$(date +%Y%m%d_%H%M%S)
```

#### **編集実行**
```bash
# ツール使用例：
# - edit_file: 新規作成・大幅変更
# - search_replace: 部分変更・既存ファイル修正
# - read_file: 内容確認

# 例：workflow_patterns.mdに新しいパターン追加
read_file _ai_workspace/rules/workflow_patterns.md 200 250  # 現状確認
search_replace _ai_workspace/rules/workflow_patterns.md "OLD_TEXT" "NEW_TEXT"
```

#### **編集後確認（必須）**
```bash
# 1. ファイル内容確認
cat [編集したファイル] | head -10 | tail -5

# 2. 権限確認（設定ファイルの場合）
ls -la [編集したファイル]

# 3. 構文チェック（JSON・bashの場合）
python -m json.tool [ファイル.json] > /dev/null  # JSON
bash -n [ファイル.sh]  # bash
```

---

## 🔄 **ワークフロー：具体的作業手順**

### **パターンA: 設定ファイル変更**
```bash
# 例：MCP設定更新

# 1. 事前確認
cat _core_config/mcp/templates/secure_mcp_template.json

# 2. 環境変数確認
source ~/.env.secure
echo $AIRTABLE_API_KEY | head -c 10  # 最初の10文字のみ表示

# 3. 設定適用
cp _core_config/mcp/templates/secure_mcp_template.json ~/.cursor/mcp.json

# 4. 動作確認
# Cursor内でAirtableベース一覧取得テスト実行

# 5. 記録
echo "- MCP設定更新完了: $(date)" >> _ai_workspace/context/current_session.md
```

### **パターンB: ドキュメント更新**
```bash
# 例：運用ルール追加

# 1. 対象ファイル特定
find _ai_workspace/rules -name "*.md" | grep [キーワード]

# 2. 重複チェック
grep -r "[追加したい内容のキーワード]" _ai_workspace/rules/

# 3. 編集実行
search_replace _ai_workspace/rules/[ファイル名].md "[既存テキスト]" "[新しいテキスト]"

# 4. 一貫性チェック
grep -A 5 -B 5 "[変更した部分]" _ai_workspace/rules/[ファイル名].md
```

### **パターンC: スクリプト実行**
```bash
# 例：自動化スクリプト実行

# 1. 実行権限確認
ls -la maintenance/scripts/auto_cleanup.sh

# 2. 安全実行
cd ~/Development
bash maintenance/scripts/auto_cleanup.sh

# 3. 結果確認
ls -la _project_management/status/auto_cleanup_*.log | tail -1
cat [最新ログファイル]
```

---

## 🚨 **緊急時対応：具体的手順**

### **ファイル重複を発見した場合**
```bash
# 1. 即座に作業停止
echo "STOP: 重複ファイル発見 - $(date)" >> emergency.log

# 2. 重複ファイル確認
find ~/Development -name "*session*" -o -name "*config*" | sort

# 3. 安全バックアップ
mkdir -p emergency_backup_$(date +%Y%m%d_%H%M%S)
cp [重複ファイル群] emergency_backup_$(date +%Y%m%d_%H%M%S)/

# 4. 専用スクリプト実行
bash maintenance/scripts/auto_cleanup.sh

# 5. 手動確認・統合
# 各ファイルの内容を比較して適切に統合
```

### **APIキー暴露を発見した場合**
```bash
# 1. 緊急停止
echo "🚨 API KEY EXPOSURE DETECTED - $(date)" >> security_incident.log

# 2. 暴露箇所特定
grep -r "patn\|ntn_\|eyJhbGci\|sk-" . --exclude-dir=backup_* | tee exposure_report.txt

# 3. 即座削除・修正
sed -i 's/patn_[a-zA-Z0-9]*/${AIRTABLE_API_KEY}/g' [対象ファイル]

# 4. API再生成（QUICK_SETUP_REFERENCE.md参照）
cat QUICK_SETUP_REFERENCE.md | grep -A 10 "API再生成"
```

---

## 📊 **現在のプロジェクト状況**

### **✅ 完了済み（75%）**
- ディレクトリ構造構築
- セキュリティ基盤整備（部分）
- AI Workspace構築
- 運用ルール策定
- 自動化スクリプト作成

### **🔄 進行中**
- APIキー環境変数化（緊急）
- Day 7最終検証

### **⏳ 未着手**
- 本格運用開始
- プロジェクト統合

### **🎯 即座にやるべきこと**
1. **APIキー再生成**（セキュリティ強化）
2. **MCP動作確認**
3. **Day 7検証完了**

---

## 💡 **新しいAI Agent向けガイド**

### **初回作業時の必須ステップ**
1. **このREADMEを最後まで読む**
2. **`QUICK_SETUP_REFERENCE.md`を確認**
3. **セキュリティ状況確認**
4. **auto_cleanup.sh実行**
5. **current_session.md更新**

### **毎回の作業フロー**
1. **重複チェック** → **作業** → **確認** → **記録**
2. **編集前確認** → **編集実行** → **動作検証** → **ログ更新**

### **判断に迷った時の対処**
1. **一時停止**
2. **`_ai_workspace/rules/communication.md`参照**
3. **安全な方法を選択**
4. **重複・散在を絶対に避ける**

---

## 🔗 **重要ファイル早見表**

| 目的 | ファイル | 用途 |
|------|---------|------|
| 全体理解 | `AI_AGENT_OPTIMIZATION_PLAN.md` | プロジェクト全体像 |
| 現状把握 | `CURRENT_STATE_INVENTORY.md` | 現在の詳細状況 |
| 緊急対応 | `QUICK_SETUP_REFERENCE.md` | 緊急時手順書 |
| セキュリティ | `SECURITY_IMPROVEMENT_PLAN.md` | セキュリティ対応 |
| 作業ルール | `_ai_workspace/rules/` | 日常作業ルール |
| 実行手順 | `_ai_workspace/rules/workflow_patterns.md` | 具体的作業手順 |
| コミュニケーション | `_ai_workspace/rules/communication.md` | 指示・対話方法 |

---

## 📞 **困った時の対処法**

### **作業に迷った場合**
```bash
# 1. 状況整理
echo "迷った内容: [詳細]" >> confusion_log.md
echo "現在の状況: [状況]" >> confusion_log.md

# 2. ルール確認
grep -r "[関連キーワード]" _ai_workspace/rules/

# 3. 類似事例確認  
grep -r "[関連キーワード]" _ai_workspace/knowledge/solutions/
```

### **エラーが発生した場合**
```bash
# 1. エラー記録
echo "ERROR: $(date) - [エラー内容]" >> error_log.md

# 2. 現状バックアップ
cp -r . backup_error_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null

# 3. 安全復旧
bash maintenance/scripts/auto_cleanup.sh
```

---

**🎯 最重要原則**: **迷ったら安全な方法を選ぶ・重複を絶対に作らない・必ず確認してから実行する**

**📋 このREADMEの更新**: 新しい手順や解決策を発見したら、このREADMEに追記して共有する

**🎉 成功の定義**: 新しいAI AgentがこのREADMEだけで、迷わず安全に作業を開始・継続できる状態 