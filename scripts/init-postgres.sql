-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS myway;

-- Table for LLM requests
CREATE TABLE IF NOT EXISTS myway.llm_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    model VARCHAR(100) NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    prompt TEXT NOT NULL,
    system_prompt TEXT,
    temperature FLOAT,
    max_tokens INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster querying
CREATE INDEX IF NOT EXISTS idx_requests_provider ON myway.llm_requests (provider);
CREATE INDEX IF NOT EXISTS idx_requests_model ON myway.llm_requests (model);
CREATE INDEX IF NOT EXISTS idx_requests_created_at ON myway.llm_requests (created_at);

-- Table for LLM responses
CREATE TABLE IF NOT EXISTS myway.llm_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES myway.llm_requests(id),
    content TEXT NOT NULL,
    finish_reason VARCHAR(50),
    prompt_tokens INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    latency_ms INTEGER,
    error TEXT,
    success BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster querying
CREATE INDEX IF NOT EXISTS idx_responses_request_id ON myway.llm_responses (request_id);
CREATE INDEX IF NOT EXISTS idx_responses_created_at ON myway.llm_responses (created_at);

-- Table for combined entries (for combined storage approach)
CREATE TABLE IF NOT EXISTS myway.llm_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    model VARCHAR(100) NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    request_data JSONB NOT NULL,
    response_data JSONB,
    prompt_tokens INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    latency_ms INTEGER,
    success BOOLEAN DEFAULT TRUE,
    error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create view for combined request/response data
CREATE OR REPLACE VIEW myway.llm_events AS
SELECT
    r.id AS request_id,
    r.provider,
    r.model,
    r.request_type,
    r.prompt,
    r.system_prompt,
    r.created_at AS request_time,
    resp.id AS response_id,
    resp.content AS response_content,
    resp.total_tokens,
    resp.latency_ms,
    resp.created_at AS response_time
FROM
    myway.llm_requests r
LEFT JOIN
    myway.llm_responses resp ON r.id = resp.request_id;

-- Grant appropriate permissions
GRANT ALL PRIVILEGES ON SCHEMA myway TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA myway TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA myway TO postgres;
