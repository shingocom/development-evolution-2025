# 🤖 AI Agent コーディング規約

**対象**: AI Agent開発作業  
**適用範囲**: 全プロジェクト  
**最終更新**: 2024年1月

---

## 📋 基本原則

### **1. セキュリティファースト**
- APIキーや機密情報は絶対に平文で記載しない
- 環境変数（`${変数名}`）を使用する
- ファイル権限を適切に設定する（600, 700）

### **2. 日本語対応**
- ドキュメントは日本語で作成
- コメントも日本語で記載
- エラーメッセージは日本語で説明

### **3. 絵文字活用**
- 視覚的分類のため絵文字を積極的に使用
- ステータス表記の統一（✅ ⏳ ❌ ⚠️ 💡）
- 優先度表記（🔴 🟡 🟢）

---

## 🔧 技術標準

### **Python開発**
```python
# 仮想環境の使用必須
python -m venv venv  # または .venv
source venv/bin/activate

# 依存関係管理
pip freeze > requirements.txt

# セキュア設定例
import os
API_KEY = os.getenv('API_KEY')  # 環境変数から取得
```

### **JSON設定ファイル**
```json
{
  "api_key": "${API_KEY}",  // 環境変数使用
  "debug": false,
  "paths": [
    "/secure/path"
  ]
}
```

### **Bash/Shell スクリプト**
```bash
#!/bin/bash
# セキュア環境変数読み込み
source ~/.env.secure

# エラーハンドリング
set -e  # エラー時に停止

# 権限設定
chmod 600 sensitive_file
```

---

## 📁 ファイル組織ルール

### **ディレクトリ構造**
```
project/
├── README.md              # プロジェクト概要（日本語）
├── requirements.txt       # Python依存関係
├── .env.example          # 環境変数テンプレート
├── scripts/              # 実行スクリプト
├── docs/                 # ドキュメント
├── tests/                # テスト
└── output/               # 生成ファイル
```

### **命名規則**
- **ファイル**: `snake_case.py`, `kebab-case.md`
- **ディレクトリ**: `snake_case/`, `kebab-case/`
- **変数**: `UPPER_CASE` (環境変数), `snake_case` (Python)

---

## 🚀 開発ワークフロー

### **1. プロジェクト開始**
```bash
# 1. ディレクトリ作成
mkdir new_project && cd new_project

# 2. 基本構造作成
mkdir {scripts,docs,tests,output}

# 3. Python環境構築
python -m venv venv
source venv/bin/activate

# 4. 基本ファイル作成
touch README.md requirements.txt .env.example
```

### **2. セキュリティチェック**
```bash
# APIキー暴露チェック
grep -r "api.*key\|token\|secret" . --exclude-dir=venv

# 権限確認
find . -name "*.json" -o -name "*.env" | xargs ls -la
```

### **3. ドキュメント更新**
- README.md: プロジェクト概要更新
- CHANGELOG.md: 変更履歴記録
- STATUS.md: 現在の状況記録

---

## ⚠️ 禁止事項

### **絶対にやってはいけないこと**
1. **平文でAPIキー記載**
   ```json
   // ❌ 禁止
   {"api_key": "sk-1234567890abcdef"}
   
   // ✅ 正しい
   {"api_key": "${API_KEY}"}
   ```

2. **機密情報のコミット**
   ```bash
   # .gitignoreに必ず追加
   .env
   *.key
   secrets/
   ```

3. **権限設定の無視**
   ```bash
   # ❌ 危険
   chmod 777 config.json
   
   # ✅ 安全
   chmod 600 config.json
   ```

---

## 🔍 品質チェックリスト

### **コード品質**
- [ ] セキュリティチェック実施
- [ ] エラーハンドリング実装
- [ ] ログ出力適切に設定
- [ ] テストケース作成

### **ドキュメント品質**
- [ ] README.md更新
- [ ] コメント日本語で記載
- [ ] 使用方法明記
- [ ] 既知の問題記載

### **セキュリティ品質**
- [ ] APIキー環境変数化
- [ ] ファイル権限適切に設定
- [ ] 機密情報除外確認
- [ ] バックアップ暗号化

---

## 📞 緊急時対応

### **セキュリティインシデント**
1. 即座に作業停止
2. 暴露されたAPIキー無効化
3. 新しいキー生成・設定
4. 影響範囲調査・報告

### **システム障害**
1. エラーログ確認
2. バックアップから復旧
3. 原因調査・対策実施
4. 再発防止策策定

---

**重要**: このルールは全てのAI Agent作業で遵守すること 