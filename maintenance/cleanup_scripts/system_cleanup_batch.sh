#!/bin/bash

# システムクリーニングバッチ処理
# 作成日: 2025年6月10日
# 目的: Kong Gateway環境の包括的クリーニング

set -euo pipefail

# ログファイル設定
LOG_FILE="/tmp/system_cleanup_$(date +%Y%m%d_%H%M%S).log"
echo "🧹 システムクリーニング開始: $(date)" | tee "$LOG_FILE"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ステップ関数
step() {
    echo -e "\n${BLUE}📋 Step $1: $2${NC}" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

# Step 1: Kong Gateway統計情報収集
step "1" "Kong Gateway統計情報収集"
if curl -s http://localhost:8001/status >/dev/null 2>&1; then
    echo "Kong Services:" | tee -a "$LOG_FILE"
    curl -s http://localhost:8001/services | jq '.data | length' | tee -a "$LOG_FILE"
    
    echo "Kong Routes:" | tee -a "$LOG_FILE"
    curl -s http://localhost:8001/routes | jq '.data | length' | tee -a "$LOG_FILE"
    
    echo "Kong Consumers:" | tee -a "$LOG_FILE"
    curl -s http://localhost:8001/consumers | jq '.data | length' | tee -a "$LOG_FILE"
    
    success "Kong統計情報収集完了"
else
    error "Kong Gateway接続失敗"
fi

# Step 2: 一時ファイルクリーニング
step "2" "一時ファイルクリーニング"

# 古い一時ファイル削除
if [ -d "/tmp/youtubeshort_generation" ]; then
    OLD_FILES=$(find /tmp/youtubeshort_generation -type f -mtime +7 | wc -l)
    find /tmp/youtubeshort_generation -type f -mtime +7 -delete 2>/dev/null || true
    success "古い一時ファイル削除: ${OLD_FILES}個"
else
    warning "youtubeshort_generation ディレクトリなし"
fi

# Kong バックアップディレクトリ整理
if [ -d "/tmp/kong_backup" ]; then
    BACKUP_SIZE=$(du -sh /tmp/kong_backup | cut -f1)
    success "Kong バックアップサイズ: $BACKUP_SIZE"
else
    warning "Kong バックアップディレクトリなし"
fi

# Step 3: ログファイル整理
step "3" "ログファイル整理"

# システムログ確認
LOG_COUNT=0
for log_pattern in "kong" "docker" "postgres" "redis"; do
    if find /var/log -name "*${log_pattern}*" 2>/dev/null | head -1 >/dev/null; then
        ((LOG_COUNT++))
    fi
done
success "システムログファイル確認: ${LOG_COUNT}種類"

# Step 4: Docker状況確認
step "4" "Docker状況確認"

if command -v docker >/dev/null 2>&1; then
    RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | wc -l)
    success "稼働中Dockerコンテナ: ${RUNNING_CONTAINERS}個"
    
    # メモリ使用量確認
    if docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}" >/dev/null 2>&1; then
        success "Docker メモリ使用量確認完了"
    else
        warning "Docker メモリ情報取得失敗"
    fi
else
    warning "Docker コマンド利用不可"
fi

# Step 5: プロジェクトファイル整理
step "5" "プロジェクトファイル整理"

# Archive ディレクトリ確認
if [ -d "archive" ]; then
    ARCHIVE_COUNT=$(find archive -type f | wc -l)
    success "Archiveファイル数: ${ARCHIVE_COUNT}個"
else
    warning "Archive ディレクトリなし"
fi

# 完了したプロジェクト確認
if [ -d "_project_management/completed" ]; then
    COMPLETED_COUNT=$(find _project_management/completed -name "*.md" | wc -l)
    success "完了プロジェクト: ${COMPLETED_COUNT}個"
else
    warning "完了プロジェクトディレクトリなし"
fi

# Step 6: 権限とアクセス確認
step "6" "権限とアクセス確認"

# 重要ディレクトリの権限確認
for dir in "_core_config" "_project_management" "maintenance"; do
    if [ -d "$dir" ]; then
        PERMS=$(ls -ld "$dir" | cut -d' ' -f1)
        success "$dir 権限: $PERMS"
    else
        warning "$dir ディレクトリなし"
    fi
done

# 最終レポート
step "7" "クリーニング完了レポート"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "🎯 システムクリーニング完了: $(date)" | tee -a "$LOG_FILE"
echo "📄 詳細ログ: $LOG_FILE" | tee -a "$LOG_FILE"
echo "🔍 次のステップ: 個別項目チェック" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

success "システムクリーニングバッチ処理完了" 