# 🔄 AI Agent ワークフローパターン

**対象**: AI Agent開発ワークフロー  
**適用範囲**: 全開発作業  
**最終更新**: 2024年1月

---

## 🎯 基本ワークフローパターン

### **パターン1: 新規プロジェクト開始**

#### **1. プロジェクト初期化 (5分)**
```bash
# ディレクトリ作成
cd ~/Development/active_projects
mkdir new_project && cd new_project

# 基本構造作成
mkdir {scripts,docs,tests,output,config}

# Python環境構築
python -m venv venv
source venv/bin/activate

# 基本ファイル作成
touch README.md requirements.txt .env.example .gitignore
```

#### **2. セキュリティ設定 (3分)**
```bash
# .gitignore設定
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "venv/" >> .gitignore

# 権限設定
chmod 600 .env.example
find config/ -name "*.json" -exec chmod 600 {} \;
```

#### **3. ドキュメント作成 (10分)**
```markdown
# README.md テンプレート
# 🚀 プロジェクト名

## 概要
[プロジェクトの概要を記載]

## セットアップ
```bash
# 仮想環境有効化
source venv/bin/activate

# 依存関係インストール
pip install -r requirements.txt
```

## 使用方法
[使用方法を記載]

## セキュリティ注意事項
- APIキーは.envファイルに設定
- 機密情報をコミットしない
```

### **パターン2: 既存プロジェクト作業再開**

#### **1. 環境確認 (2分)**
```bash
# プロジェクトディレクトリ移動
cd ~/Development/active_projects/project_name

# 仮想環境確認・有効化
ls venv/ && source venv/bin/activate

# 依存関係確認
pip list | head -10
```

#### **2. 状況把握 (5分)**
```bash
# 最近の変更確認
git log --oneline -10

# 現在のブランチ確認
git branch

# 未コミット変更確認
git status
```

#### **3. セキュリティチェック (3分)**
```bash
# APIキー暴露チェック
grep -r "api.*key\|token\|secret" . --exclude-dir=venv --exclude-dir=.git

# 権限確認
find . -name "*.env" -o -name "*.key" | xargs ls -la 2>/dev/null
```

---

## 🔧 技術作業パターン

### **パターン3: MCP統合開発**

#### **1. MCP設定確認 (3分)**
```bash
# MCP接続テスト
# Cursor内でAirtableベース一覧取得を実行

# 環境変数確認
source ~/.env.secure
env | grep -E "(API_KEY|TOKEN)" | sed 's/=.*/=***MASKED***/'
```

#### **2. データベース操作 (10分)**
```python
# Airtable操作例
# 1. ベース一覧取得（MCP経由）
# 2. レコード検索・取得
# 3. データ処理・変換
# 4. 結果記録・保存
```

#### **3. ワークフロー自動化 (15分)**
```python
# N8N連携例
# 1. ワークフロー実行
# 2. 結果確認
# 3. エラーハンドリング
# 4. ログ記録
```

### **パターン4: AI/ML開発**

#### **1. モデル準備 (10分)**
```bash
# モデルディレクトリ確認
ls models/

# 必要なモデルダウンロード（必要に応じて）
python scripts/download_model.py

# GPU確認（利用可能な場合）
python -c "import torch; print(torch.cuda.is_available())"
```

#### **2. 実験実行 (20分)**
```bash
# WebUI起動
python webui.py --port 7860

# スクリプト実行
python scripts/generate.py --input "test prompt"

# 結果確認
ls output/ | tail -5
```

#### **3. 結果整理 (10分)**
```bash
# 結果をoutputディレクトリに整理
mv *.jpg *.png output/ 2>/dev/null

# ログ保存
cp server.log logs/$(date +%Y%m%d_%H%M%S).log

# 進捗更新
echo "## $(date)" >> STATUS.md
echo "- 実験完了: [内容]" >> STATUS.md
```

---

## 📋 品質保証パターン

### **パターン5: セキュリティ監査**

#### **定期実行 (週1回推奨)**
```bash
#!/bin/bash
echo "🔒 セキュリティ監査開始"

# 1. APIキー暴露チェック
find ~/Development -name "*.json" -o -name "*.md" -o -name "*.py" | \
    xargs grep -l "patn\|ntn_\|eyJhbGci\|sk-" 2>/dev/null && \
    echo "⚠️ APIキー暴露発見" || echo "✅ 暴露なし"

# 2. 権限チェック
find ~/Development -name "*.env" -o -name "*.key" | while read file; do
    perm=$(ls -la "$file" | awk '{print $1}')
    if [[ "$perm" != "-rw-------" ]]; then
        echo "⚠️ 不適切な権限: $file ($perm)"
    fi
done

# 3. バックアップ確認
ls -la ~/Development/_core_config/mcp/backup_configs/ | tail -3

echo "🔒 セキュリティ監査完了"
```

### **パターン6: 品質チェック**

#### **コミット前実行**
```bash
#!/bin/bash
echo "🔍 品質チェック開始"

# 1. Python構文チェック
find . -name "*.py" -exec python -m py_compile {} \; 2>/dev/null && \
    echo "✅ Python構文OK" || echo "❌ Python構文エラー"

# 2. 必須ファイル確認
required_files=("README.md" "requirements.txt" ".gitignore")
for file in "${required_files[@]}"; do
    [ -f "$file" ] && echo "✅ $file" || echo "❌ $file 不足"
done

# 3. 大容量ファイルチェック
find . -size +10M -not -path "./venv/*" -not -path "./.git/*" | \
    head -5 | while read file; do
        echo "⚠️ 大容量ファイル: $file"
    done

echo "🔍 品質チェック完了"
```

---

## 🚀 効率化パターン

### **パターン7: 自動化スクリプト活用**

#### **⚠️ ファイル複製防止チェック (必須)**
```bash
# ファイル作成前の重複チェック
check_duplicates() {
    local filename="$1"
    find ~/Development -name "*${filename}*" -type f 2>/dev/null | \
    grep -v "backup" | head -5
    echo "⚠️ 上記ファイルが既存です。本当に新規作成しますか？"
}

# 使用例
check_duplicates "session.md"
check_duplicates "config.json"
```

#### **Makefileパターン**
```makefile
# 共通タスクの自動化
.PHONY: setup start test clean security duplicate-check

# ファイル重複チェック追加
duplicate-check:
	@echo "🔍 重複ファイルチェック実行中..."
	@find ~/Development -name "*session*" -o -name "*config*" -o -name "*template*" | sort
	@echo "✅ 重複チェック完了"

setup: duplicate-check
	python -m venv venv
	source venv/bin/activate && pip install -r requirements.txt
	chmod 600 .env.example

start:
	source venv/bin/activate && python main.py

test:
	source venv/bin/activate && python -m pytest tests/

clean:
	find . -name "__pycache__" -exec rm -rf {} +
	find . -name "*.pyc" -delete

security:
	grep -r "api.*key\|token\|secret" . --exclude-dir=venv || echo "✅ セキュアOK"
```

#### **定期メンテナンス**
```bash
#!/bin/bash
# 週次メンテナンス

# 1. 依存関係更新
source venv/bin/activate
pip list --outdated

# 2. ログローテーション
find logs/ -name "*.log" -mtime +7 -delete

# 3. 一時ファイル削除
find output/ -name "temp_*" -mtime +1 -delete

# 4. バックアップ作成
cp -r config/ backup/config_$(date +%Y%m%d)/
```

---

## 💡 トラブルシューティングパターン

### **パターン8: 一般的な問題解決**

#### **仮想環境問題**
```bash
# 問題: 仮想環境が壊れた
# 解決: 再作成
rm -rf venv/
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### **依存関係問題**
```bash
# 問題: パッケージ競合
# 解決: クリーンインストール
pip freeze > old_requirements.txt
pip uninstall -r old_requirements.txt -y
pip install -r requirements.txt
```

#### **権限問題**
```bash
# 問題: ファイルアクセス拒否
# 解決: 権限修正
chmod 755 scripts/
chmod +x scripts/*.sh
chmod 600 config/*.json
```

---

## 📊 成果測定パターン

### **パターン9: 進捗追跡**

#### **日次レポート**
```bash
echo "## $(date +%Y-%m-%d) 進捗レポート" >> daily_report.md
echo "- 作業時間: [記録]" >> daily_report.md
echo "- 完了タスク: [リスト]" >> daily_report.md
echo "- 課題・問題: [リスト]" >> daily_report.md
echo "- 明日の予定: [リスト]" >> daily_report.md
echo "" >> daily_report.md
```

#### **週次振り返り**
```bash
echo "## Week $(date +%V) - $(date +%Y) 振り返り" >> weekly_review.md
echo "### 成果" >> weekly_review.md
echo "- [主要な成果を記載]" >> weekly_review.md
echo "### 学び" >> weekly_review.md
echo "- [学んだことを記載]" >> weekly_review.md
echo "### 改善点" >> weekly_review.md
echo "- [次週への改善点を記載]" >> weekly_review.md
```

---

**重要**: これらのパターンを組み合わせて、効率的な開発ワークフローを構築してください。 