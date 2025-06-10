-- AI Development Database 初期化スクリプト
-- 作成日: 2025-01-25

-- データベース基本設定
SET timezone = 'Asia/Tokyo';
SET client_encoding = 'UTF8';

-- ========================================
-- AI プロジェクト管理テーブル
-- ========================================

-- プロジェクトテーブル
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    project_type VARCHAR(50) NOT NULL, -- 'flux', 'llama', 'sd', 'custom'
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'paused', 'completed', 'archived'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- 実験テーブル
CREATE TABLE IF NOT EXISTS experiments (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    config JSONB NOT NULL DEFAULT '{}',
    results JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'running', -- 'running', 'completed', 'failed', 'cancelled'
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    metadata JSONB DEFAULT '{}'
);

-- モデルテーブル
CREATE TABLE IF NOT EXISTS models (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL DEFAULT '1.0.0',
    model_type VARCHAR(100) NOT NULL, -- 'llm', 'diffusion', 'custom'
    file_path TEXT,
    config JSONB DEFAULT '{}',
    performance_metrics JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(project_id, name, version)
);

-- ========================================
-- AI サービス使用統計テーブル
-- ========================================

-- API使用統計
CREATE TABLE IF NOT EXISTS api_usage (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL, -- 'ollama', 'gradio', 'n8n'
    endpoint VARCHAR(255) NOT NULL,
    model_name VARCHAR(100),
    request_count INTEGER DEFAULT 0,
    tokens_used INTEGER DEFAULT 0,
    processing_time_ms INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_hour TIMESTAMP WITH TIME ZONE NOT NULL, -- 時間別集計用
    UNIQUE(service_name, endpoint, model_name, date_hour)
);

-- セッション管理
CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    user_agent TEXT,
    ip_address INET,
    project_id INTEGER REFERENCES projects(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'
);

-- ========================================
-- ログ・監査テーブル
-- ========================================

-- アクションログ
CREATE TABLE IF NOT EXISTS action_logs (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50), -- 'project', 'experiment', 'model'
    resource_id INTEGER,
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- エラーログ
CREATE TABLE IF NOT EXISTS error_logs (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    error_type VARCHAR(100),
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    context JSONB DEFAULT '{}',
    severity VARCHAR(20) DEFAULT 'error', -- 'debug', 'info', 'warning', 'error', 'critical'
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- インデックス作成
-- ========================================

-- パフォーマンス向上用インデックス
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_type ON projects(project_type);
CREATE INDEX IF NOT EXISTS idx_experiments_project_status ON experiments(project_id, status);
CREATE INDEX IF NOT EXISTS idx_experiments_started_at ON experiments(started_at);
CREATE INDEX IF NOT EXISTS idx_models_project_active ON models(project_id, is_active);
CREATE INDEX IF NOT EXISTS idx_api_usage_service_date ON api_usage(service_name, date_hour);
CREATE INDEX IF NOT EXISTS idx_sessions_active ON sessions(is_active, last_activity);
CREATE INDEX IF NOT EXISTS idx_action_logs_timestamp ON action_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_error_logs_timestamp_severity ON error_logs(timestamp, severity);

-- ========================================
-- 初期データ挿入
-- ========================================

-- サンプルプロジェクト
INSERT INTO projects (name, description, project_type, metadata) VALUES
('flux-lab', 'FLUX.1 画像生成実験環境', 'flux', '{"location": "~/flux-lab/", "framework": "FLUX.1"}'),
('llama-lab', 'LLaMA大規模言語モデル実験', 'llama', '{"location": "~/llama-lab/", "framework": "LLaMA"}'),
('sd-lab', 'Stable Diffusion画像生成研究', 'sd', '{"location": "~/sd-lab/", "framework": "Stable Diffusion"}'),
('ai-integration', 'AI統合開発環境', 'custom', '{"location": "~/Development/", "framework": "Docker+FastAPI"}')
ON CONFLICT (name) DO NOTHING;

-- ========================================
-- 関数・トリガー作成
-- ========================================

-- updated_at自動更新関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_atトリガー
DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_models_updated_at ON models;
CREATE TRIGGER update_models_updated_at
    BEFORE UPDATE ON models
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 使用統計集計関数
CREATE OR REPLACE FUNCTION aggregate_api_usage()
RETURNS void AS $$
BEGIN
    -- 1時間前のデータを集計
    INSERT INTO api_usage (service_name, endpoint, model_name, request_count, tokens_used, processing_time_ms, success_count, error_count, date_hour)
    SELECT 
        service_name,
        endpoint,
        model_name,
        COUNT(*) as request_count,
        SUM(COALESCE((metadata->>'tokens_used')::integer, 0)) as tokens_used,
        AVG(COALESCE((metadata->>'processing_time_ms')::integer, 0))::integer as processing_time_ms,
        COUNT(CASE WHEN details->>'status' = 'success' THEN 1 END) as success_count,
        COUNT(CASE WHEN details->>'status' = 'error' THEN 1 END) as error_count,
        DATE_TRUNC('hour', timestamp) as date_hour
    FROM action_logs 
    WHERE timestamp >= NOW() - INTERVAL '1 hour'
      AND timestamp < DATE_TRUNC('hour', NOW())
      AND action LIKE 'api_%'
    GROUP BY service_name, endpoint, model_name, DATE_TRUNC('hour', timestamp)
    ON CONFLICT (service_name, endpoint, model_name, date_hour) 
    DO UPDATE SET
        request_count = EXCLUDED.request_count,
        tokens_used = EXCLUDED.tokens_used,
        processing_time_ms = EXCLUDED.processing_time_ms,
        success_count = EXCLUDED.success_count,
        error_count = EXCLUDED.error_count,
        recorded_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ビュー作成
-- ========================================

-- プロジェクト統計ビュー
CREATE OR REPLACE VIEW project_stats AS
SELECT 
    p.id,
    p.name,
    p.project_type,
    p.status,
    COUNT(e.id) as experiment_count,
    COUNT(CASE WHEN e.status = 'completed' THEN 1 END) as completed_experiments,
    COUNT(m.id) as model_count,
    COUNT(CASE WHEN m.is_active THEN 1 END) as active_models,
    p.created_at,
    p.updated_at
FROM projects p
LEFT JOIN experiments e ON p.id = e.project_id
LEFT JOIN models m ON p.id = m.project_id
GROUP BY p.id, p.name, p.project_type, p.status, p.created_at, p.updated_at;

-- API使用統計ビュー（直近24時間）
CREATE OR REPLACE VIEW recent_api_usage AS
SELECT 
    service_name,
    endpoint,
    model_name,
    SUM(request_count) as total_requests,
    SUM(tokens_used) as total_tokens,
    AVG(processing_time_ms) as avg_processing_time,
    SUM(success_count) as total_success,
    SUM(error_count) as total_errors,
    ROUND(100.0 * SUM(success_count) / NULLIF(SUM(request_count), 0), 2) as success_rate
FROM api_usage 
WHERE date_hour >= NOW() - INTERVAL '24 hours'
GROUP BY service_name, endpoint, model_name
ORDER BY total_requests DESC;

-- ========================================
-- 権限設定
-- ========================================

-- ai_userに適切な権限を付与
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ai_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ai_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ai_user;

-- 完了メッセージ
SELECT 'AI Development Database initialized successfully!' as status; 