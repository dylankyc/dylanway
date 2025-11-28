-- ClickHouse initialization script for MyWay LLM Router
-- This script creates the necessary tables for analytics and time-series data

CREATE DATABASE IF NOT EXISTS myway;

-- LLM Requests table (optimized for analytics)
CREATE TABLE IF NOT EXISTS myway.llm_requests (
    id UInt64,
    request_id String,
    timestamp DateTime DEFAULT now(),
    provider LowCardinality(String),
    model String,
    request_type LowCardinality(String),
    endpoint String,
    
    -- Request metadata
    user_id String,
    session_id String,
    ip_address String,
    
    -- Request content (JSON strings for flexibility)
    messages String,
    prompt String,
    max_tokens UInt32,
    temperature Float32,
    top_p Float32,
    stream UInt8 DEFAULT 0,
    
    -- Additional request parameters as JSON
    extra_params String
) ENGINE = MergeTree()
ORDER BY (timestamp, provider, model)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 1 YEAR;

-- LLM Responses table (optimized for metrics)
CREATE TABLE IF NOT EXISTS myway.llm_responses (
    id UInt64,
    request_id String,
    timestamp DateTime DEFAULT now(),
    
    -- Response metadata
    status_code UInt16,
    success UInt8 DEFAULT 1,
    error_type String,
    
    -- Timing metrics
    duration_ms UInt32,
    
    -- Token usage metrics
    prompt_tokens UInt32 DEFAULT 0,
    completion_tokens UInt32 DEFAULT 0,
    total_tokens UInt32 DEFAULT 0,
    
    -- Response content
    finish_reason LowCardinality(String),
    response_data String,
    
    -- Streaming information
    is_streaming UInt8 DEFAULT 0,
    chunk_count UInt32 DEFAULT 0
) ENGINE = MergeTree()
ORDER BY (timestamp, request_id)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 1 YEAR;

-- Token usage aggregation table (materialized view)
CREATE MATERIALIZED VIEW IF NOT EXISTS myway.token_usage_hourly
ENGINE = SummingMergeTree()
ORDER BY (date_hour, provider, model)
AS SELECT
    toStartOfHour(resp.timestamp) as date_hour,
    req.provider,
    req.model,
    count() as request_count,
    sum(resp.prompt_tokens) as total_prompt_tokens,
    sum(resp.completion_tokens) as total_completion_tokens,
    sum(resp.total_tokens) as total_tokens,
    avg(resp.duration_ms) as avg_duration_ms
FROM myway.llm_responses resp
JOIN myway.llm_requests req ON resp.request_id = req.request_id
WHERE resp.success = 1
GROUP BY date_hour, req.provider, req.model;

-- LLM Entries table (for combined request/response storage)
CREATE TABLE IF NOT EXISTS myway.llm_entries (
    id UInt64,
    request_id String,
    timestamp DateTime DEFAULT now(),
    
    -- Request info
    provider LowCardinality(String),
    model String,
    request_type LowCardinality(String),
    
    -- Combined data as JSON strings
    request_data String,
    response_data String,
    
    -- Token usage metrics
    prompt_tokens UInt32 DEFAULT 0,
    completion_tokens UInt32 DEFAULT 0,
    total_tokens UInt32 DEFAULT 0,
    
    -- Performance metrics
    duration_ms UInt32,
    success UInt8 DEFAULT 1,
    error_message String
) ENGINE = MergeTree()
ORDER BY (timestamp, provider, model)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 1 YEAR;

-- Error tracking table
CREATE TABLE IF NOT EXISTS myway.error_events (
    timestamp DateTime DEFAULT now(),
    provider LowCardinality(String),
    model String,
    error_type LowCardinality(String),
    error_message String,
    request_id String,
    duration_ms UInt32
) ENGINE = MergeTree()
ORDER BY (timestamp, provider, error_type)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 6 MONTH;