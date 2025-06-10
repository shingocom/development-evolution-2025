# 🔧 環境構築トラブル解決策

**対象**: 開発環境構築・管理  
**重点**: **ファイル複製防止・環境統一・効率化**  
**最終更新**: 2024年12月7日

---

## 🎯 基本方針

### **🚨 ファイル複製防止原則**
1. **設定ファイルの統一管理** - `_core_config/`配下で一元管理
2. **テンプレート活用** - 個別作成ではなくテンプレート使用
3. **環境変数統一** - `.env.secure`による一元管理
4. **重複設定の統合** - 同一機能設定の重複排除

---

## 🔧 Python環境問題

### **問題1: 仮想環境の重複作成**
```bash
# ❌ 問題のパターン
cd project1 && python -m venv venv
cd project2 && python -m venv venv  # 重複作成
cd project3 && python -m venv env   # 命名不統一
```

#### **✅ 解決策：統一テンプレート使用**
```bash
# 1. プロジェクトテンプレート確認
ls _ai_workspace/templates/project_init/

# 2. 統一スクリプト使用
source _ai_workspace/templates/project_init/setup_python_env.sh [project_name]

# 3. 設定統一確認
find ~/Development/active_projects -name "venv" | head -5
```

### **問題2: requirements.txtの散在**
```bash
# ❌ 問題状況
find ~/Development -name "requirements*.txt" | wc -l  # 複数存在
```

#### **✅ 解決策：統一管理**
```bash
# 1. マスターrequirements.txt使用
cp _ai_workspace/templates/project_init/requirements.txt ./

# 2. プロジェクト固有依存関係のみ追加
echo "project-specific-package==1.0.0" >> requirements.txt

# 3. 統一フォーマット確認
pip freeze | grep -E "^[a-zA-Z]" | sort
```

---

## 🗂️ MCP設定問題

### **問題1: MCP設定ファイルの複製**
```bash
# ❌ 問題のパターン  
~/.cursor/mcp.json           # オリジナル
~/mcp_backup.json           # 手動バックアップ
~/mcp_secure.json          # セキュア版
~/Development/mcp_test.json # テスト版
```

#### **✅ 解決策：一元管理システム**
```bash
# 1. 設定統一
mv ~/.cursor/mcp.json _core_config/mcp/backup_configs/original_$(date +%Y%m%d).json

# 2. テンプレート使用
cp _core_config/mcp/templates/secure_mcp_template.json ~/.cursor/mcp.json

# 3. 環境変数設定
source ~/.env.secure

# 4. 動作確認
cursor --version && echo "MCP設定適用済み"
```

### **問題2: 環境変数の散在**
```bash
# ❌ 問題状況
find ~/Development -name ".env*" | head -10  # 複数の.envファイル
```

#### **✅ 解決策：統一環境変数システム**
```bash
# 1. マスター環境変数確認
ls -la ~/.env.secure

# 2. プロジェクト固有設定の統合
echo "PROJECT_SPECIFIC_VAR=value" >> ~/.env.secure

# 3. 重複削除
find ~/Development -name ".env.local" -delete
find ~/Development -name ".env.backup" -delete

# 4. シンボリックリンク作成（必要に応じて）
ln -sf ~/.env.secure ~/Development/active_projects/project_name/.env
```

---

## 📦 依存関係管理問題

### **問題1: パッケージマネージャーの混在**
```bash
# ❌ 問題のパターン
pip install package1        # pip使用
conda install package2      # conda併用
poetry add package3         # poetry併用
```

#### **✅ 解決策：統一ガイドライン**
```bash
# 1. プロジェクト標準確認
cat _ai_workspace/rules/coding_standards.md | grep -A 5 "Python開発"

# 2. pip統一使用
pip list | head -10

# 3. 統一フォーマットでの管理
pip freeze > requirements.txt

# 4. 定期依存関係チェック
pip check
```

### **問題2: バージョン管理の不統一**
```bash
# ❌ 問題のパターン
torch                    # バージョン未指定
numpy==1.21.0           # 固定バージョン  
scikit-learn>=0.24      # 最小バージョン
```

#### **✅ 解決策：バージョン管理統一**
```bash
# 1. 現在の依存関係確認
pip freeze | grep -E "(torch|numpy|scikit-learn)"

# 2. 統一フォーマット適用
pip freeze | sed 's/==.*$/==\*/' > requirements_template.txt

# 3. 安定バージョンでの固定
pip install torch==2.0.0 numpy==1.24.0 scikit-learn==1.3.0
```

---

## 🔧 Git設定問題

### **問題1: .gitignoreの重複作成**
```bash
# ❌ 問題状況
find ~/Development -name ".gitignore" | wc -l  # 多数存在
```

#### **✅ 解決策：マスター.gitignore使用**
```bash
# 1. マスター.gitignore確認
cat _core_config/git/.gitignore_master

# 2. プロジェクトへのコピー
cp _core_config/git/.gitignore_master ~/Development/active_projects/project_name/.gitignore

# 3. プロジェクト固有設定追加（最小限）
echo "project_specific_file.log" >> .gitignore

# 4. 統一性確認
diff _core_config/git/.gitignore_master .gitignore
```

### **問題2: Git設定の不統一**
```bash
# ❌ 問題状況
git config --list | grep user.name  # プロジェクトごとに異なる設定
```

#### **✅ 解決策：グローバル設定統一**
```bash
# 1. マスター設定適用
cat _core_config/git/.gitconfig_shared >> ~/.gitconfig

# 2. 設定確認
git config --global --list | grep -E "(user|core)"

# 3. プロジェクト設定のリセット
cd ~/Development/active_projects/project_name
git config --unset user.name
git config --unset user.email
```

---

## 🚀 自動化スクリプト解決策

### **環境診断スクリプト**
```bash
#!/bin/bash
# ~/Development/maintenance/scripts/environment_diagnosis.sh

echo "🔍 環境診断開始..."

# 1. Python環境チェック
echo "## Python環境"
find ~/Development/active_projects -name "venv" | wc -l | xargs echo "仮想環境数:"

# 2. 設定ファイル重複チェック
echo "## 設定ファイル重複"
find ~/Development -name "requirements*.txt" | wc -l | xargs echo "requirements.txt数:"
find ~/Development -name ".gitignore" | wc -l | xargs echo ".gitignore数:"
find ~/Development -name ".env*" | wc -l | xargs echo ".env*数:"

# 3. 推奨アクション
echo "## 推奨アクション"
if [ $(find ~/Development -name "requirements*.txt" | wc -l) -gt 5 ]; then
    echo "⚠️ requirements.txtが多すぎます。統合を推奨"
fi

echo "✅ 環境診断完了"
```

### **環境統一スクリプト**
```bash
#!/bin/bash
# ~/Development/maintenance/scripts/unify_environment.sh

echo "🔧 環境統一開始..."

# 1. 設定ファイル統一
cp _core_config/git/.gitignore_master ~/Development/active_projects/*/

# 2. 環境変数統一
for project in ~/Development/active_projects/*/; do
    if [ -f "$project/.env" ]; then
        echo "⚠️ $project に個別.envファイル発見"
        mv "$project/.env" "$project/.env.backup"
        ln -sf ~/.env.secure "$project/.env"
    fi
done

# 3. 重複ファイル整理
find ~/Development -name "requirements_backup*.txt" -delete
find ~/Development -name ".gitignore_old" -delete

echo "✅ 環境統一完了"
```

---

## 📋 チェックリスト

### **🎯 環境構築完了チェック**
- [ ] Python仮想環境が統一された場所に作成されている
- [ ] requirements.txtがプロジェクトテンプレートベース
- [ ] .gitignoreがマスターファイルベース
- [ ] 環境変数が~/.env.secureで一元管理
- [ ] 重複設定ファイルが存在しない

### **📊 定期メンテナンス項目**
- [ ] 週次での重複ファイルチェック
- [ ] 月次での依存関係更新
- [ ] 四半期での環境設定最適化
- [ ] 年次での環境構成見直し

---

**🎯 最重要**: 環境構築時は必ず既存設定を確認し、重複作成を避けて統一テンプレートを使用する

**📞 問題発生時**: `environment_diagnosis.sh`を実行して状況確認後、`unify_environment.sh`で統一化を実施 