# 📋 包括的自動クリーニング運用ガイド

## 🎯 **目的**
2025-06-10の手動チェックで発見された多くの改善点を自動化し、継続的に品質維持を行う。

---

## ⚡ **クイックスタート**

### **基本実行**
```bash
cd Development
bash maintenance/scripts/comprehensive_cleanup.sh
```

### **事前確認（推奨）**
```bash
# 現在の状況確認
ls -la | grep -E '\.(md|json|sh|py)$'

# 実行前バックアップ確認
ls -la archive/
```

---

## 🔄 **実行タイミング**

| タイミング | 優先度 | 実行方法 |
|-----------|-------|---------|
| **日次作業開始前** | 🔴 必須 | 手動実行 |
| **Git作業前** | 🟡 推奨 | 手動実行 |
| **新AI Agent引き継ぎ時** | 🔴 必須 | 手動実行 |
| **週次メンテナンス** | 🟡 推奨 | 定期実行 |

---

## 📊 **処理フェーズ詳細**

### **フェーズ1: 古いファイル処理**
- **対象**: ルートディレクトリの古いスクリプト
- **パターン**: `create_*.sh`, `fix_*.sh`, `setup_*.sh`, `day[0-9]*.sh`
- **処理**: `archive/executed_scripts/` へ移動

### **フェーズ2: 重複設定削除**
- **MCP設定**: 正規版 `_core_config/mcp/templates/secure_template.json` 以外削除
- **Docker設定**: `docker/` 内の設定を優先、ルート版削除
- **環境変数**: `docker/` 内以外のテンプレート削除

### **フェーズ3: 一時・テストファイル**
- **パターン**: `*test_*.md`, `*_temp_*`, `*.tmp`, `*.bak`
- **処理**: バックアップ後削除

### **フェーズ4: システム生成ファイル**
- **Mac**: `.DS_Store`, `._*` (リソースフォーク)
- **Windows**: `Thumbs.db`
- **処理**: 即座削除

### **フェーズ5: 散在ファイル配置**
- **重要文書**: ルート維持 (README.md, 開発文書等)
- **一般文書**: `_project_management/status/` へ移動

### **フェーズ6: 詳細重複チェック**
- **セッションファイル**: 正規版 `_ai_workspace/context/current_session.md` 以外削除
- **散在設定**: `_core_config/misc/` へ集約

### **フェーズ7: セキュリティ**
- **権限設定**: `~/.env.secure` (600), `docker/.env` (600)
- **実行権限**: 全スクリプトに適用

### **フェーズ8: 構造検証**
- **必須ディレクトリ**: 存在確認・自動作成

### **フェーズ9: Git対応**
- **削除ファイル**: Gitインデックスから除去
- **新規・移動**: 自動追加

---

## 🔍 **手動チェック項目（参考）**

実行後に以下を確認：

### **ルートディレクトリ状態**
```bash
# 重要文書のみであることを確認
ls -la *.md
# 期待値: README.md, DEVELOPMENT_*.md, CURRENT_*.md, QUICK_*.md, SECURITY_*.md のみ
```

### **設定ファイル統合状況**
```bash
# MCP設定の正規化確認
find . -name "*mcp*" | grep -v "_core_config/mcp"
# 期待値: 出力なし

# Docker設定統合確認  
ls -la docker*
# 期待値: docker/ ディレクトリのみ
```

### **一時ファイル清掃状況**
```bash
# 一時ファイル残存確認
find . -name "*.tmp" -o -name "*test_*" -o -name "temp*"
# 期待値: 出力なし
```

---

## 📈 **実行結果の読み方**

### **正常パターン**
```
✅ 移動ファイル数: 3
✅ 削除ファイル数: 8  
✅ 重複解消数: 2
✅ エラー: なし
```

### **要注意パターン**
```
⚠️  セッション関連重複: 5 個
🚨 緊急要確認: old_mcp_config.json
❌ エラー発生数: 1
```

### **ログ確認**
```bash
# 最新実行ログ
ls -t _project_management/status/comprehensive_cleanup_*.log | head -1
cat $(ls -t _project_management/status/comprehensive_cleanup_*.log | head -1)
```

---

## 🚨 **トラブルシューティング**

### **実行権限エラー**
```bash
chmod +x maintenance/scripts/comprehensive_cleanup.sh
```

### **Git競合回避**
```bash
# 実行前にクリーンな状態に
git add -A
git commit -m "クリーニング前コミット"
bash maintenance/scripts/comprehensive_cleanup.sh
```

### **バックアップから復元**
```bash
# 最新バックアップ確認
ls -t archive/auto_cleanup_backup_* | head -1

# 特定ファイル復元
cp archive/auto_cleanup_backup_20250610_155553/重要ファイル.md ./
```

### **手動介入が必要な場合**
```bash
# 重複チェック詳細実行
find . \( -name "*mcp*" -o -name "*config*" -o -name "*template*" \) | sort
```

---

## 🔧 **カスタマイズ**

### **除外パターン追加**
`comprehensive_cleanup.sh` の該当セクションを編集：

```bash
# 重要文書リスト拡張
IMPORTANT_MD=(
    "README.md"
    "DEVELOPMENT_EVOLUTION_PROJECT_2025.md"
    "MY_CUSTOM_DOC.md"  # 追加
)
```

### **新しい重複パターン追加**
```bash
# 新しい重複パターン
NEW_DUPLICATE_PATTERNS=(
    "*duplicate_pattern*"
    "old_*_backup*"
)
```

---

## 📅 **メンテナンススケジュール**

### **日次** (作業開始前)
```bash
bash maintenance/scripts/comprehensive_cleanup.sh
```

### **週次** (日曜日)
```bash
# 詳細レポート付き実行
bash maintenance/scripts/comprehensive_cleanup.sh 2>&1 | tee weekly_cleanup.log
```

### **月次** (月初)
```bash
# アーカイブ整理
find archive -name "auto_cleanup_backup_*" -mtime +30 -exec rm -rf {} \;
```

---

## 🎯 **成功指標**

### **品質指標**
- ルートディレクトリファイル数: ≤ 5個
- 重複設定ファイル: 0個
- 一時ファイル: 0個
- Git未追跡ファイル: 計画的なもののみ

### **効率指標**  
- 手動介入回数: 週1回以下
- エラー発生率: 5%以下
- 実行時間: 30秒以内

---

## 🔄 **継続的改善**

### **新しい問題パターン発見時**
1. 手動処理を記録
2. スクリプトに自動化ロジック追加
3. テスト実行
4. ドキュメント更新

### **フィードバックループ**
- 実行ログ分析 (週次)
- パターン更新 (月次)  
- 運用改善 (四半期) 