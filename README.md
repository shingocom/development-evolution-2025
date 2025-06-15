# 🚀 AI開発環境進化プロジェクト 2025

**プロジェクト**: AI Agent最適化環境を次世代開発プラットフォームに進化  
**リポジトリ**: https://github.com/shingocom/development-evolution-2025  
**ステータス**: Phase 1 完了 → Phase 2 開始準備  
**最終更新**: 2025-06-10 16:00

---

## ⚡ **10分でスタート：新規AI Agent向け**

### **1. 必須事前確認 (2分)**
```bash
# 現在の位置・状況確認
pwd  # ~/Development にいることを確認
git status  # Gitリポジトリの状況確認
git log --oneline | head -3  # 最新のコミット履歴確認

# セキュリティ状況確認
ls -la ~/.env.secure  # セキュア環境変数ファイル確認
ls -la ~/.cursor/mcp.json  # MCP設定確認
```

### **2. GitHub連携確認 (2分)**
```bash
# GitHub認証状況確認
gh auth status

# リモートリポジトリ確認
git remote -v

# 最新状況取得
git pull origin main
```

### **3. プロジェクト状況把握 (3分)**
```bash
# 現在のフェーズ確認
cat DEVELOPMENT_EVOLUTION_PROJECT_2025.md | head -20

# 進捗状況確認
cat _project_management/status/overall_progress.md | tail -20

# 現在のセッション情報
cat _ai_workspace/context/current_session.md
```

### **4. 作業環境準備 (3分)**
```bash
# 自動クリーニング実行
bash maintenance/scripts/auto_cleanup.sh

# 構造検証
bash maintenance/scripts/structure_validator.sh

# セッション開始記録
echo "## $(date +%Y-%m-%d\ %H:%M:%S) セッション開始" >> _ai_workspace/context/current_session.md
echo "- AI Agent: [あなたのID]" >> _ai_workspace/context/current_session.md
echo "- 作業目標: [今回の目標]" >> _ai_workspace/context/current_session.md
```

---

## 📊 **現在のプロジェクト状況（2025-06-10）**

### **✅ Phase 1 完了済み: Git統合基盤構築**
- **期間**: 2025-06-10 完了
- **成果**: 100%達成

#### **完了項目:**
1. **Git統合基盤構築** ✅
   - セキュリティ重視の包括的.gitignore作成
   - Mac/Linux クロスプラットフォーム対応
   - 4つの段階的コミット（意味のある履歴）
   
2. **GitHub統合** ✅
   - SSH認証設定完了
   - リポジトリ: https://github.com/shingocom/development-evolution-2025
   - 83ファイル、112.39 KiB正常同期
   - ブランチトラッキング設定済み
   
3. **セキュリティ対応** ✅
   - API暴露問題解決
   - 環境変数管理システム構築
   - セキュア起動プロセス確立

4. **運用システム** ✅
   - 自動クリーニングシステム
   - 構造検証システム
   - セッション管理システム

### **🔄 Phase 2: AI/ML本格導入（次のステップ）**
- **予定期間**: 2025-06-10 開始
- **目標**: Docker + AI統合環境

#### **実行予定:**
1. **Docker基盤構築**
   - AI開発用コンテナ環境
   - GPU対応設定
   - 開発環境統一

2. **Flux.1本格統合**
   - Docker環境構築
   - API化実装
   - バッチ処理パイプライン

3. **Ollama本格運用**
   - マルチモデル管理
   - LangChain統合
   - 推論最適化

---

## 🔧 **運用ルール：日常作業フロー**

### **📝 ファイル編集の必須プロセス**

#### **1. 編集前チェック（必須）**
```bash
# 重複ファイル確認
find ~/Development -name "*[ファイルキーワード]*" | head -5

# Git状況確認
git status

# 既存ファイル確認
ls -la [対象ディレクトリ]/[ファイル名]

# 重要ファイルのバックアップ（必要時）
cp [ファイルパス] [ファイルパス].backup_$(date +%Y%m%d_%H%M%S)
```

#### **2. 編集実行**
```bash
# 推奨ツール使い分け:
# - edit_file: 新規作成・大幅変更
# - search_replace: 部分変更・既存ファイル修正
# - read_file: 内容確認

# 例: 設定ファイル部分更新
read_file _core_config/mcp/active_config.json 1 50  # 現状確認
search_replace _core_config/mcp/active_config.json "OLD_VALUE" "NEW_VALUE"
```

#### **3. 編集後確認・コミット（必須）**
```bash
# ファイル内容確認
cat [編集したファイル] | head -10

# Git変更確認
git diff [編集したファイル]

# ステージング・コミット
git add [編集したファイル]
git commit -m "📝 [変更内容の説明]"

# GitHubプッシュ
git push origin main

# セッション記録
echo "- $(date +%H:%M): [ファイル名] 更新完了" >> _ai_workspace/context/current_session.md
```

### **🚨 N8N作業時の重要注意事項**

#### **⚠️ CRITICAL: N8Nローカル環境の制限**
```
🔴 【データ破壊防止】重要事項:

1. N8Nローカルホスト環境は1アカウントのみサポート
2. 新規アカウント作成 = 既存データ完全削除
3. 既存ワークフロー・設定が全て失われる
4. 復旧不可能なデータ損失のリスク

⚠️ 既存N8N環境での作業手順:
- ❌ 新規アカウント作成は絶対に禁止
- ✅ 既存ログイン情報のみ使用
- ✅ MCP接続は既存APIキーで認証
- ✅ データベース初期化は厳禁
```

#### **🚨 CRITICAL: Docker N8N ボリューム管理**
```
🔴 【ボリューム消失防止】重要事項:

1. Docker Composeプロジェクト名でボリューム名が決定される
2. 実行ディレクトリ変更 = 異なるボリューム作成
3. `docker rm -f` でコンテナ削除時もボリューム残存
4. しかし異なるプロジェクト名では別ボリューム参照

⚠️ Docker N8N作業時の必須手順:
- ✅ 必ず同じディレクトリから docker-compose 実行
- ✅ プロジェクト名固定: `cd _core_config/docker && docker-compose`
- ❌ ルートディレクトリからの実行禁止
- ✅ ボリューム確認: `docker volume ls | grep n8n`
- ✅ データ復旧手順: 正しいボリューム間でデータコピー

🔧 緊急復旧コマンド:
docker run --rm -v ai-development-2025_n8n_data:/source -v docker_n8n_data:/target alpine sh -c "cp -a /source/. /target/"
```

#### **🔧 N8N-MCP統合の正しい手順**
```bash
# 1. 既存N8N環境確認（破壊前チェック）
curl http://localhost:5678/healthz  # サービス稼働確認
docker ps | grep n8n               # コンテナ状況確認

# 2. 既存認証情報確認
# 注意: 新規ログインページが表示されても新規作成しない
# 既存のユーザー名・パスワードでログイン試行

# 3. APIキー取得（既存アカウントで）
# N8N画面: Settings > API Keys > Create API Key

# 4. MCP設定更新（データ破壊なし）
# ~/.cursor/mcp.json の N8N_API_KEY のみ更新
# 新規インスタンス作成は禁止

# 5. 接続テスト
# MCPでワークフロー一覧取得テスト
```

### **🔄 作業パターン別フロー**

#### **パターンA: MCP設定変更（N8N含む）**
```bash
# 例: MCP設定更新 - データ破壊防止重視

# 1. 現状確認（既存環境保護）
cat ~/.cursor/mcp.json | jq .
docker ps | grep n8n  # N8N稼働状況

# 2. 環境変数確認
source ~/.env.secure
echo "N8N_API_KEY前10文字: ${N8N_API_KEY:0:10}"

# 3. バックアップ作成
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup_$(date +%Y%m%d_%H%M%S)

# 4. テンプレート適用（慎重に）
cp _core_config/mcp/templates/secure_template.json ~/.cursor/mcp.json

# 5. 動作確認（既存データ確認）
# 例: Airtableベース一覧取得テスト
# 例: N8Nワークフロー一覧取得（既存データ保持確認）

# 6. Git記録
git add _core_config/mcp/
git commit -m "🔧 MCP設定更新: $(date +%Y-%m-%d) - データ保護確認済み"
git push origin main
```

#### **パターンB: プロジェクト文書更新**
```bash
# 例: 進捗報告・計画更新

# 1. 対象ファイル特定
find _project_management -name "*.md" | grep progress

# 2. 現状確認
read_file _project_management/status/overall_progress.md 1 50

# 3. 更新実行
search_replace _project_management/status/overall_progress.md "**進捗**: 75%" "**進捗**: 85%"

# 4. 関連ファイル更新
echo "- $(date): Phase 1 完了" >> _project_management/status/overall_progress.md

# 5. Git管理
git add _project_management/
git commit -m "📊 進捗報告更新: Phase 1 完了記録"
git push origin main
```

#### **パターンC: 新機能・スクリプト開発**
```bash
# 例: 新しい自動化スクリプト作成

# 1. 開発ブランチ作成
git checkout -b feature/new-automation-script

# 2. スクリプト作成
edit_file maintenance/scripts/new_feature.sh

# 3. 権限設定
chmod +x maintenance/scripts/new_feature.sh

# 4. テスト実行
bash maintenance/scripts/new_feature.sh

# 5. ドキュメント更新
echo "## new_feature.sh" >> maintenance/scripts/README.md

# 6. プルリクエスト準備
git add maintenance/scripts/
git commit -m "✨ 新機能追加: 自動化スクリプト new_feature.sh"
git push origin feature/new-automation-script

# 7. GitHub上でプルリクエスト作成
gh pr create --title "✨ 新機能: 自動化スクリプト" --body "詳細説明..."
```

---

## 🚨 **緊急時対応・トラブルシューティング**

### **Git関連問題**
```bash
# コンフリクト発生時
git status  # 問題ファイル確認
git diff    # 差分確認
# 手動でコンフリクト解決後
git add .
git commit -m "🔥 コンフリクト解決"

# 間違ったコミットの修正
git reset --soft HEAD~1  # 最新コミットを取り消し（変更は保持）
git reset --hard HEAD~1  # 最新コミットを完全削除（注意）

# プッシュ済みコミットの修正
git revert [コミットハッシュ]  # 安全なリバート
```

### **APIキー漏洩対応**
```bash
# 1. 緊急停止
echo "🚨 API KEY EXPOSURE - $(date)" >> security_incident.log

# 2. 漏洩箇所確認
grep -r "eyJhbGci\|patn_\|ntn_" . --exclude-dir=.git

# 3. 緊急修正
sed -i 's/eyJhbGci[a-zA-Z0-9]*/${SECURE_TOKEN}/g' [対象ファイル]

# 4. API再生成
# N8N: http://localhost:5678 → Settings → API Keys
# Airtable: https://airtable.com/create/tokens

# 5. 環境変数更新
echo 'export NEW_API_KEY="新しいキー"' >> ~/.env.secure

# 6. 緊急コミット
git add .
git commit -m "🚨 セキュリティ修正: APIキー環境変数化"
git push origin main
```

### **ファイル重複・散在対応**
```bash
# 1. 重複検出
find ~/Development -name "*config*" -o -name "*session*" | sort

# 2. 安全バックアップ
mkdir emergency_backup_$(date +%Y%m%d_%H%M%S)
cp [重複ファイル群] emergency_backup_$(date +%Y%m%d_%H%M%S)/

# 3. 自動整理実行
bash maintenance/scripts/auto_cleanup.sh

# 4. 手動統合（必要時）
# 各ファイル内容確認・適切に統合

# 5. Git整理
git add .
git commit -m "🧹 ファイル重複解決・整理完了"
git push origin main
```

---

## 📋 **重要ファイル・ディレクトリ早見表**

### **📁 プロジェクト管理**
| ファイル | 用途 | 更新頻度 |
|----------|------|----------|
| `DEVELOPMENT_EVOLUTION_PROJECT_2025.md` | 全体計画 | 週次 |
| `_project_management/status/overall_progress.md` | 進捗状況 | 日次 |
| `_ai_workspace/context/current_session.md` | セッション記録 | 毎回 |

### **⚙️ 設定・テンプレート**
| ディレクトリ | 用途 | 管理方法 |
|--------------|------|----------|
| `_core_config/` | 核となる設定 | Git管理 |
| `_ai_workspace/rules/` | 運用ルール | Git管理 |
| `maintenance/scripts/` | 自動化スクリプト | Git管理 |

### **🔒 セキュリティ**
| ファイル | 場所 | Git管理 |
|----------|------|---------|
| `~/.env.secure` | ホーム | ❌除外 |
| `~/.cursor/mcp.json` | MCP設定 | ❌除外 |
| `.gitignore` | リポジトリ | ✅管理 |

---

## 🎯 **次のアクション：Phase 2開始**

### **今すぐ実行可能**
1. **Docker導入**: Mac用Docker Desktop インストール
2. **AI開発コンテナ**: Python + PyTorch + CUDA環境
3. **Flux.1統合**: Docker環境での動作確認

### **今週の目標**
- Docker基盤環境構築 80%
- AI/MLコンテナ統合 60%
- 次フェーズ計画策定 100%

### **実行コマンド例**
```bash
# Docker導入開始
brew install --cask docker

# プロジェクト次フェーズ準備
git checkout -b feature/phase2-docker-integration
mkdir -p docker/ai-dev
touch docker/docker-compose.yml
```

---

## 💡 **AI Agent作業指針**

### **基本原則**
1. **Git First**: 全ての変更はGitで管理
2. **Security First**: 機密情報は環境変数
3. **Documentation First**: 変更は必ず記録
4. **Test First**: 実行前に安全確認

### **判断基準**
- 迷ったら**安全な方法**を選択
- 重複を**絶対に作らない**
- 変更前に**必ず確認**
- エラー時は**即座に記録**

### **コミュニケーション**
- 作業内容は具体的に記述
- 問題発生時は詳細を報告
- 成功・完了も必ず記録
- 次の作業者への引き継ぎを明記

---

## 🔗 **外部リンク・参考資料**

- **GitHub Repository**: https://github.com/shingocom/development-evolution-2025
- **N8N管理画面**: http://localhost:5678
- **Airtable**: https://airtable.com/create/tokens
- **Docker Hub**: https://hub.docker.com

---

**🚀 プロジェクト成功の定義**: Phase 5完了時に、企業レベルのAI/ML開発環境が構築され、チーム開発・CI/CD・監視システムが完全稼働している状態

**📞 サポート**: 各作業で詳細な実装プランを即座提供可能

---

*最終更新: 2025-06-10 16:00 | 次回更新予定: Phase 2進捗に応じて* 