-- MySQL initialization script for MyWay LLM Router
-- This script creates the necessary tables for storing LLM requests and responses

CREATE DATABASE IF NOT EXISTS myway;
USE myway;

-- Create schema for LLM data
CREATE SCHEMA IF NOT EXISTS llm;

-- LLM Requests table
CREATE TABLE IF NOT EXISTS llm.llm_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(255) UNIQUE NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    provider VARCHAR(100) NOT NULL,
    model VARCHAR(255) NOT NULL,
    request_type ENUM('chat_completion', 'embedding', 'completion') NOT NULL,
    endpoint VARCHAR(255),
    
    -- Request metadata
    user_id VARCHAR(255),
    session_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- Request content
    messages JSON,
    system_message TEXT,
    prompt TEXT,
    max_tokens INT,
    temperature DECIMAL(3,2),
    top_p DECIMAL(3,2),
    frequency_penalty DECIMAL(3,2),
    presence_penalty DECIMAL(3,2),
    stream BOOLEAN DEFAULT FALSE,
    
    -- Additional request parameters
    extra_params JSON,
    
    -- Indexing
    INDEX idx_timestamp (timestamp),
    INDEX idx_provider (provider),
    INDEX idx_model (model),
    INDEX idx_request_type (request_type),
    INDEX idx_user_id (user_id),
    INDEX idx_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- LLM Responses table
CREATE TABLE IF NOT EXISTS llm.llm_responses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Response metadata
    status_code INT,
    success BOOLEAN DEFAULT TRUE,
    error_type VARCHAR(100),
    error_message TEXT,
    
    -- Timing
    duration_ms INT,
    
    -- Usage metrics
    prompt_tokens INT DEFAULT 0,
    completion_tokens INT DEFAULT 0,
    total_tokens INT DEFAULT 0,
    
    -- Response content
    response_text TEXT,
    finish_reason VARCHAR(50),
    response_data JSON,
    
    -- Streaming information
    is_streaming BOOLEAN DEFAULT FALSE,
    chunk_count INT DEFAULT 0,
    
    -- Indexing
    FOREIGN KEY (request_id) REFERENCES llm.llm_requests(request_id) ON DELETE CASCADE,
    INDEX idx_timestamp (timestamp),
    INDEX idx_request_id (request_id),
    INDEX idx_success (success),
    INDEX idx_total_tokens (total_tokens),
    INDEX idx_duration (duration_ms)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- LLM Entries table (for combined request/response storage)
CREATE TABLE IF NOT EXISTS llm.llm_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(255) UNIQUE NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Request info
    provider VARCHAR(100) NOT NULL,
    model VARCHAR(255) NOT NULL,
    request_type ENUM('chat_completion', 'embedding', 'completion') NOT NULL,
    
    -- Combined data
    request_data JSON NOT NULL,
    response_data JSON,
    
    -- Metrics
    prompt_tokens INT DEFAULT 0,
    completion_tokens INT DEFAULT 0,
    total_tokens INT DEFAULT 0,
    duration_ms INT,
    success BOOLEAN DEFAULT TRUE,
    
    -- Indexing
    INDEX idx_timestamp (timestamp),
    INDEX idx_provider (provider),
    INDEX idx_model (model),
    INDEX idx_request_type (request_type),
    INDEX idx_total_tokens (total_tokens),
    INDEX idx_success (success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Token usage summary view
CREATE VIEW llm.token_usage_summary AS
SELECT 
    DATE(timestamp) as date,
    provider,
    model,
    COUNT(*) as request_count,
    SUM(prompt_tokens) as total_prompt_tokens,
    SUM(completion_tokens) as total_completion_tokens,
    SUM(total_tokens) as total_tokens,
    AVG(duration_ms) as avg_duration_ms
FROM llm.llm_responses 
WHERE success = TRUE
GROUP BY DATE(timestamp), provider, model
ORDER BY date DESC, total_tokens DESC;