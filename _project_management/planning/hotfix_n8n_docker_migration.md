# 🚨 HOTFIX: N8N Docker移行プロジェクト

**プロジェクト名**: N8N ローカル→Docker完全移行  
**優先度**: 🔴 CRITICAL  
**開始日**: 2025-06-13 17:10  
**予定完了**: 2025-06-13 18:30  
**担当**: AI Development Team  

---

## 🎯 **プロジェクト目標**

### **現状問題**
- N8Nがローカルインストール版で稼働中
- Dockerコンテナ化されていない
- バックアップ・復旧が困難
- 環境の再現性が低い

### **目標状態**
- N8NがDockerで完全稼働
- 既存データ・ワークフロー完全保持
- GitHubバックアップ完了
- README準拠の構成

---

## 📋 **Phase 1: 現状分析・データ保護**

### **Task 1.1: 現在のN8N環境完全調査**
- [ ] **実行コマンド**: `ps aux | grep n8n`
- [ ] **データ場所確認**: `ls -la ~/.n8n/`
- [ ] **設定ファイル確認**: `cat ~/.n8n/config`
- [ ] **ワークフロー数確認**: N8N UI でワークフロー一覧
- [ ] **APIキー確認**: N8N Settings → API Keys

**成果物**: `workspace/temp/n8n_current_analysis.md`

### **Task 1.2: 完全バックアップ作成**
- [ ] **データベースバックアップ**: `cp ~/.n8n/database.sqlite workspace/temp/n8n_production_backup_$(date +%Y%m%d_%H%M%S).sqlite`
- [ ] **設定バックアップ**: `cp ~/.n8n/config workspace/temp/n8n_config_backup.txt`
- [ ] **全ディレクトリバックアップ**: `tar -czf workspace/temp/n8n_full_backup_$(date +%Y%m%d_%H%M%S).tar.gz ~/.n8n/`
- [ ] **ワークフロー手動エクスポート**: N8N UI → Export All Workflows

**成果物**: `workspace/temp/` 内に完全バックアップセット

---

## 📋 **Phase 2: Docker環境構築**

### **Task 2.1: docker-compose.yml にN8N追加**
- [ ] **ファイル編集**: `docker/docker-compose.yml`
- [ ] **N8Nサービス定義**:
```yaml
  # ==========================================
  # N8N ワークフロー自動化
  # ==========================================
  n8n:
    image: n8nio/n8n:latest
    container_name: ai-n8n
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
      - ./n8n/backup:/backup
    environment:
      - N8N_BASIC_AUTH_ACTIVE=false
      - N8N_USER_MANAGEMENT_DISABLED=true
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
    networks:
      - ai-network
    restart: unless-stopped
```

### **Task 2.2: バックアップディレクトリ作成**
- [ ] **ディレクトリ作成**: `mkdir -p docker/n8n/backup`
- [ ] **権限設定**: `chmod 755 docker/n8n/backup`

**成果物**: 更新された `docker/docker-compose.yml`

---

## 📋 **Phase 3: データ移行・動作確認**

### **Task 3.1: Dockerコンテナ起動**
- [ ] **ディレクトリ移動**: `cd docker`
- [ ] **コンテナ起動**: `docker-compose up -d n8n`
- [ ] **ログ確認**: `docker-compose logs n8n`
- [ ] **起動確認**: `curl http://localhost:5679` (ポート変更)

### **Task 3.2: データ移行実行**
- [ ] **コンテナ停止**: `docker-compose stop n8n`
- [ ] **データコピー**: `docker cp workspace/temp/n8n_production_backup_*.sqlite ai-n8n:/home/node/.n8n/database.sqlite`
- [ ] **権限修正**: `docker exec ai-n8n chown -R node:node /home/node/.n8n/`
- [ ] **コンテナ再起動**: `docker-compose start n8n`

### **Task 3.3: 動作確認**
- [ ] **Web UI確認**: `http://localhost:5679` アクセス
- [ ] **ワークフロー確認**: 既存ワークフロー表示確認
- [ ] **API確認**: `curl http://localhost:5679/rest/workflows`
- [ ] **MCP接続テスト**: MCPからN8N接続確認

**成果物**: 動作するDockerベースN8N

---

## 📋 **Phase 4: README準拠・コード修正**

### **Task 4.1: ファイル配置修正**
- [ ] **一時ファイル整理**: `workspace/temp/` 内のファイル整理
- [ ] **設定ファイル移動**: 適切なディレクトリに配置
- [ ] **不要ファイル削除**: Development直下の不要ファイル削除

### **Task 4.2: 設定ファイル更新**
- [ ] **MCP設定更新**: `~/.cursor/mcp.json` のN8N接続先をDocker版に変更
- [ ] **環境変数更新**: `~/.env.secure` のN8N関連設定
- [ ] **ポート設定**: ローカル版(5678) → Docker版(5679) 切り替え

### **Task 4.3: ローカル版停止**
- [ ] **プロセス確認**: `ps aux | grep n8n`
- [ ] **ローカルN8N停止**: `pkill -f "n8n start"`
- [ ] **ポート確認**: `lsof -i :5678` (空になることを確認)
- [ ] **Docker版ポート変更**: 5679 → 5678 に変更

**成果物**: README準拠の構成

---

## 📋 **Phase 5: GitHubバックアップ・完了**

### **Task 5.1: Git管理**
- [ ] **変更確認**: `git status`
- [ ] **差分確認**: `git diff`
- [ ] **ステージング**: `git add .`
- [ ] **コミット**: `git commit -m "🚨 HOTFIX: N8N Docker移行完了 - ローカル版からDocker版に完全移行・データ保持・README準拠"`

### **Task 5.2: GitHubプッシュ**
- [ ] **プッシュ**: `git push origin main`
- [ ] **GitHub確認**: リポジトリでファイル更新確認
- [ ] **バックアップ確認**: docker-compose.yml, バックアップファイル等の保存確認

### **Task 5.3: 最終動作確認**
- [ ] **Docker環境**: `docker-compose ps` 全サービス稼働確認
- [ ] **N8N動作**: `http://localhost:5678` アクセス確認
- [ ] **MCP接続**: MCPからN8N, Airtable接続確認
- [ ] **ワークフロー**: 既存ワークフロー動作確認

**成果物**: 完全にDockerized されたN8N環境

---

## 🚨 **リスク管理・ロールバック計画**

### **Critical Risks**
1. **データ損失**: 既存ワークフロー・設定の消失
2. **ダウンタイム**: N8N停止による業務影響
3. **MCP接続断**: 他システムとの連携停止

### **ロールバック手順**
```bash
# 緊急時：ローカル版に即座復帰
pkill -f docker  # Docker停止
cd ~/.nvm/versions/node/v20.19.2/bin/
./n8n start &    # ローカル版再起動

# データ復旧
cp workspace/temp/n8n_production_backup_*.sqlite ~/.n8n/database.sqlite
```

### **検証チェックリスト**
- [ ] ワークフロー数が移行前後で一致
- [ ] APIキーが正常動作
- [ ] MCP接続が正常
- [ ] 設定が保持されている

---

## 📊 **進捗管理**

### **Phase 1: 現状分析・データ保護** ⏳
- Task 1.1: ⬜ 未開始
- Task 1.2: ⬜ 未開始

### **Phase 2: Docker環境構築** ⏳
- Task 2.1: ⬜ 未開始
- Task 2.2: ⬜ 未開始

### **Phase 3: データ移行・動作確認** ⏳
- Task 3.1: ⬜ 未開始
- Task 3.2: ⬜ 未開始
- Task 3.3: ⬜ 未開始

### **Phase 4: README準拠・コード修正** ✅
- Task 4.1: ✅ 完了（一時ファイル整理）
- Task 4.2: ✅ 完了（MCP設定・Docker設定更新）
- Task 4.3: ⚠️ スキップ（レプリケーション方式のため）

### **Phase 5: GitHubバックアップ・完了** ⏳
- Task 5.1: ⬜ 未開始
- Task 5.2: ⬜ 未開始
- Task 5.3: ⬜ 未開始

---

## 🎯 **成功定義**

### **完了条件**
1. ✅ N8NがDockerで完全稼働
2. ✅ 既存データ・ワークフロー100%保持
3. ✅ MCP接続正常動作
4. ✅ README準拠の構成
5. ✅ GitHubバックアップ完了

### **品質基準**
- **データ整合性**: 移行前後でワークフロー・設定が完全一致
- **可用性**: ダウンタイム最小化（5分以内）
- **再現性**: docker-compose up で即座に環境構築可能

---

## 📞 **次のアクション**

**即座実行可能**:
```bash
# Phase 1 開始
ps aux | grep n8n
ls -la ~/.n8n/
```

**実行順序**:
1. Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
2. 各Phase完了後に進捗更新
3. 問題発生時は即座にロールバック

---

*作成日: 2025-06-13 17:10*  
*最終更新: 2025-06-13 17:10*  
*次回更新: Phase 1完了時* 