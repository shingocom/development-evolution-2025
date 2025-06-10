# 🧹 **ファイル整理・清掃ルール**

**目的**: AI Agent最適化環境を清潔に保ち、効率的な作業環境を維持する

---

## 📋 **基本原則**

### ✅ **保持すべきファイル**
- **メインドキュメント**: 企画書、現状調査、セキュリティ関連
- **アクティブな設定ファイル**: 現在使用中の設定
- **バックアップファイル**: セキュアバックアップディレクトリ内
- **プロジェクトファイル**: active_projects内の稼働中プロジェクト

### 🗑️ **削除対象ファイル**
- **実行完了スクリプト**: 一度実行して完了したsetup系スクリプト
- **一時ファイル**: .DS_Store、.tmp、cache系
- **重複ファイル**: 古いバージョンや不要なコピー
- **テストファイル**: 動作確認のみの一時ファイル

---

## 🎯 **現在の削除対象ファイル**

### 🔧 **実行完了スクリプト群**
以下のスクリプトは役目を終えたため、`archive/executed_scripts/`に移動：

```bash
# セキュリティ設定完了済み
execute_api_management_setup.sh       # APIキー管理設定（完了）
execute_notion_mcp_removal.sh         # Notion MCP除去（完了）
setup_secure_environment.sh           # セキュア環境構築（完了）

# 構造作成は継続使用の可能性があるため保持
# create_new_directory_structure.sh   # 構造作成（保持）
# fix_mcp_environment.sh              # MCP修正（継続使用）
```

### 🗂️ **整理アクション**
```bash
# 実行完了スクリプトをアーカイブに移動
mkdir -p archive/executed_scripts/
mv execute_api_management_setup.sh archive/executed_scripts/
mv execute_notion_mcp_removal.sh archive/executed_scripts/
mv setup_secure_environment.sh archive/executed_scripts/

# 不要ファイル削除
rm -f .DS_Store
```

---

## 🔄 **継続的清掃ルール**

### 📅 **定期清掃スケジュール**
- **デイリー**: 一時ファイル、キャッシュの確認
- **ウィークリー**: 完了スクリプトのアーカイブ移動
- **月次**: バックアップの世代管理、不要ファイル削除

### 🚫 **作成を避けるべきファイル**
- **ルートディレクトリの一時ファイル**: `/tmp_*`, `/test_*`
- **重複した設定ファイル**: 同じ設定の複数コピー
- **長期間未使用のスクリプト**: 3週間以上実行されていないもの

### ✅ **推奨ファイル配置**
- **設定ファイル**: `_core_config/`
- **スクリプト**: `maintenance/scripts/`または`_ai_workspace/tools/`
- **ドキュメント**: 各機能別ディレクトリ
- **アーカイブ**: `archive/`サブディレクトリ

---

## 🛠️ **自動清掃スクリプト**

### 📁 **ファイル移動・削除コマンド**
```bash
#!/bin/bash
# ファイル整理スクリプト

echo "🧹 ファイル整理を開始..."

# 1. 実行完了スクリプトのアーカイブ
if [ ! -d "archive/executed_scripts" ]; then
    mkdir -p archive/executed_scripts/
fi

# 完了済みスクリプトを移動
for script in execute_*.sh setup_secure_environment.sh; do
    if [ -f "$script" ]; then
        mv "$script" archive/executed_scripts/
        echo "✅ $script をアーカイブに移動"
    fi
done

# 2. 一時ファイル削除
rm -f .DS_Store
find . -name "*.tmp" -delete
find . -name "*.cache" -delete

# 3. 空ディレクトリの清掃
find . -type d -empty -not -path "./.*" -delete

echo "🎉 ファイル整理完了！"
```

---

## 📊 **ファイル管理ダッシュボード**

### 📈 **現在の状況**
- **総ファイル数**: 動的カウント
- **削除対象**: 3個のスクリプトファイル
- **アーカイブ済み**: 0個
- **清掃ステータス**: 🟡 要整理

### 🎯 **目標状態**
- **ルートディレクトリ**: メインドキュメント + アクティブスクリプトのみ
- **アーカイブ率**: 実行完了スクリプト100%移動
- **清掃ステータス**: 🟢 清潔維持

---

## 🔄 **次回整理予定**

### 📋 **整理チェックリスト**
- [ ] 実行完了スクリプトのアーカイブ移動
- [ ] 一時ファイルの削除
- [ ] プロジェクト構造の最適化確認
- [ ] バックアップの世代管理

### 📅 **スケジュール**
- **即座実行**: 現在の削除対象ファイル整理
- **Day 3**: プロジェクト移行時の再整理
- **Day 7**: 最終整理とルール確定

---

**更新日**: 2024年1月  
**次回見直し**: Day 3 プロジェクト移行完了後 