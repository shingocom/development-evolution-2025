# 📋 ファイル整理・組織化ルール

**作成日**: 2024年1月  
**最終更新**: 2024年1月  
**優先度**: 🔴 最高（基盤ルール）  
**適用範囲**: 全プロジェクト・全AI Agentセッション

---

## 🎯 基本原則

### **🏗️ 構造優先の原則**
1. **ファイル作成前に配置場所を決定** - 作業中のファイルも適切な場所に配置
2. **機能別ディレクトリ配置** - 目的に応じたディレクトリ使用
3. **単一責任原則** - 1ファイル1目的、重複ファイル禁止
4. **命名規則統一** - 明確で一貫性のあるファイル名

### **🔄 継続的整理の原則**  
1. **セッション開始時チェック** - 毎回構造確認
2. **作業中整理** - リアルタイムでの適切配置
3. **セッション終了時クリーンアップ** - 散在ファイル整理
4. **定期メンテナンス** - 週次での構造最適化

---

## 📁 標準ディレクトリ構造と配置ルール

### **🤖 _ai_workspace/** - AI Agent専用領域
```
context/           → セッション情報、AI向けコンテキスト
├── current_session.md    ← 現在のセッション情報（単一正規版）
├── session_history/      ← 過去セッション履歴
└── work_context/         ← 作業コンテキスト

rules/             → AI動作ルール、ガイドライン
├── coding_standards.md   ← 開発標準
├── workflow_patterns.md  ← ワークフローパターン
└── file_organization_rules.md ← このファイル

knowledge/         → ナレッジベース
├── solutions/            ← 解決策集
├── patterns/            ← パターン集
└── resources/           ← リソース集

templates/         → テンプレート集
└── project_init/        ← プロジェクト初期化テンプレート
```

### **🔧 _core_config/** - 核となる設定
```
mcp/               → MCP設定管理
├── templates/           ← 設定テンプレート
├── backup_configs/      ← バックアップ設定
└── active_config.json   ← 現在の設定

environments/      → 環境設定
git/              → Git設定
docker/           → Docker設定
```

### **📊 _project_management/** - プロジェクト管理
```
planning/          → 計画・設計文書
├── PROJECT_HANDOVER_SUMMARY.md  ← プロジェクト引き継ぎ
├── QUICK_SETUP_REFERENCE.md     ← クイックセットアップ
└── AI_AGENT_OPTIMIZATION_PLAN.md ← メイン計画書

security/          → セキュリティ関連
├── SECURITY_IMPROVEMENT_PLAN.md ← セキュリティ計画
└── api_key_regeneration_guide.md ← API管理ガイド

status/           → 状況・進捗管理
├── cleanup_analysis.md          ← 整理分析
├── overall_progress.md          ← 全体進捗
└── current_inventory.md         ← 現状調査

metrics/          → メトリクス・測定
completed/        → 完了プロジェクト
```

### **🧹 maintenance/** - メンテナンス
```
scripts/          → 実行スクリプト
├── cleanup_scripts/     ← 整理スクリプト
├── backup_scripts/      ← バックアップスクリプト
└── health_check/        ← ヘルスチェック

backup_scripts/   → バックアップシステム
cleanup_scripts/  → クリーンアップシステム
health_check/     → ヘルスチェックシステム
```

---

## 🚨 重複ファイル防止ルール

### **❌ 禁止事項**
1. **同一目的ファイルの複数作成** 
   - ✗ `current_session.md` + `session_context.md`
   - ✗ `secure_template.json` + `secure_config_template.json`

2. **Development直下への散在**
   - ✗ ドキュメントファイル直置き
   - ✗ 設定ファイル直置き
   - ✗ スクリプトファイル直置き

3. **曖昧な命名**
   - ✗ `temp.md`, `test.py`, `backup.json`
   - ✗ 日付なしバックアップファイル

### **✅ 必須事項**
1. **ファイル作成時の配置場所決定**
2. **重複チェックの実施**  
3. **明確な命名規則適用**
4. **適切なディレクトリ使用**

---

## 🧹 定期クリーニング手順

### **⚡ セッション開始時 (2分)**
```bash
# 1. 散在ファイルチェック
ls -la ~/Development/*.{md,json,sh,py} 2>/dev/null | wc -l

# 2. 重複ファイル確認  
find ~/Development -name "*session*" -o -name "*current*"

# 3. .DS_Store削除
find ~/Development -name ".DS_Store" -delete
```

### **🔄 セッション中 (リアルタイム)**
```bash
# ファイル作成時のチェック
echo "作成前確認: 配置場所は適切か？重複はないか？"

# 即座整理
mv [新規ファイル] [適切なディレクトリ]/
```

### **✅ セッション終了時 (3分)**
```bash
# 1. 散在ファイル整理
find ~/Development -maxdepth 1 -name "*.md" -exec mv {} _project_management/status/ \;

# 2. 設定ファイル整理
find ~/Development -maxdepth 1 -name "*.json" -exec mv {} _core_config/mcp/templates/ \;

# 3. スクリプト整理
find ~/Development -maxdepth 1 -name "*.sh" -exec mv {} maintenance/scripts/ \;

# 4. 最終クリーンアップ
find ~/Development -name ".DS_Store" -delete
find ~/Development -name "*.tmp" -delete
```

### **📅 週次メンテナンス (10分)**
```bash
# 1. 構造最適化
bash ~/Development/maintenance/scripts/structure_optimization.sh

# 2. 重複ファイル検索・統合
bash ~/Development/maintenance/scripts/duplicate_finder.sh

# 3. 不要ファイル削除
bash ~/Development/maintenance/scripts/cleanup_unused_files.sh

# 4. 整理レポート生成
bash ~/Development/maintenance/scripts/generate_cleanup_report.sh
```

---

## 🤖 AI Agent向け自動化ルール

### **📋 セッション開始時の自動チェック**
```markdown
1. [ ] Development直下に散在ファイルがないか確認
2. [ ] 重複するセッションファイルがないか確認  
3. [ ] .DS_Storeなど不要ファイルの削除
4. [ ] 前回セッションの未整理ファイル処理
```

### **🔄 作業中の自動実施**
```markdown
1. [ ] 新規ファイル作成時の適切配置
2. [ ] 既存ファイル編集時の重複チェック
3. [ ] 一時ファイルの即座削除
4. [ ] 設定変更時のバックアップ作成
```

### **📊 品質保証チェック**
```markdown
1. [ ] ファイル構造の論理性確認
2. [ ] 命名規則の一貫性確認
3. [ ] 機能別配置の適切性確認
4. [ ] 重複排除の完全性確認
```

---

## 🚀 自動化スクリプト

### **structure_validator.sh** - 構造検証
```bash
#!/bin/bash
# Development ディレクトリ構造の検証と警告

echo "🔍 ディレクトリ構造検証開始..."

# 散在ファイルチェック
SCATTERED_FILES=$(ls -la ~/Development/*.{md,json,sh,py} 2>/dev/null | wc -l)
if [ $SCATTERED_FILES -gt 0 ]; then
    echo "⚠️  散在ファイル発見: $SCATTERED_FILES 個"
    ls -la ~/Development/*.{md,json,sh,py} 2>/dev/null
fi

# 重複ファイルチェック  
echo "🔍 重複ファイルチェック..."
find ~/Development -name "*session*" -o -name "*current*" | sort

echo "✅ 構造検証完了"
```

### **auto_cleanup.sh** - 自動整理
```bash
#!/bin/bash
# 自動整理スクリプト

echo "🧹 自動整理開始..."

# .DS_Store削除
find ~/Development -name ".DS_Store" -delete

# 散在ファイル整理
find ~/Development -maxdepth 1 -name "*.md" -exec mv {} _project_management/status/ \; 2>/dev/null
find ~/Development -maxdepth 1 -name "*.json" -exec mv {} _core_config/mcp/templates/ \; 2>/dev/null  
find ~/Development -maxdepth 1 -name "*.sh" -exec mv {} maintenance/scripts/ \; 2>/dev/null

echo "✅ 自動整理完了"
```

---

## 📋 セッション終了チェックリスト

### **🎯 必須確認項目（ファイル複製防止重点）**
- [ ] Development直下に散在ファイルが残っていないか
- [ ] 重複ファイルが作成されていないか（最重要 🔴）
- [ ] 同一目的ファイルの複数バージョンがないか
- [ ] 一時ファイルや古いコピーが残っていないか
- [ ] すべてのファイルが適切なディレクトリに配置されているか
- [ ] .DS_Storeなど不要ファイルが削除されているか
- [ ] current_session.mdが最新状態に更新されているか

### **📊 品質確認項目**
- [ ] ファイル命名規則が守られているか
- [ ] ディレクトリ構造が論理的に保たれているか
- [ ] AI Agentが次回迅速に状況把握できる状態か
- [ ] セキュリティファイルが適切に保護されているか

---

## 💡 継続改善

### **📈 効果測定**
- **整理時間**: セッション開始時の準備時間測定
- **発見速度**: 必要ファイルの発見速度測定  
- **重複発生率**: 重複ファイル発生頻度の追跡
- **構造遵守率**: ルール遵守度の測定

### **🔄 ルール更新**
- **月次レビュー**: ルールの有効性確認・改善
- **パターン分析**: 散在パターンの分析・対策
- **自動化拡張**: 手動作業の自動化推進
- **ベストプラクティス**: 効果的手法の文書化

---

**⚠️ 重要**: このルールはAI Agent開発環境の基盤となるため、必ず遵守してください。ルール違反は開発効率の大幅な低下を招きます。

**🎯 目標**: ゼロ散在・ゼロ重複・最高効率のAI Agent開発環境を維持 