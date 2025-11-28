# DylanWay - Universal LLM Platform

A unified Rust-based platform for interacting with multiple Large Language Model (LLM) providers through a single, extensible interface. DylanWay is more than just a library—it is a flexible foundation for building, routing, monitoring, and scaling LLM-powered applications and services.

## Table of Contents

- [Features](#features)
- [Supported Providers](#supported-providers)
- [Quick Start](#quick-start)
- [Sink Support](#sink-support)
- [Configuration](#configuration)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Features

- 🚀 **Unified API** - Single interface for all providers
- 🔄 **Auto-routing** - Automatic provider detection based on model names
- 📡 **Streaming support** - Real-time response streaming for all providers
- 🧮 **Embeddings** - Text embedding support where available
- ⚡ **Async/await** - Full async support with tokio
- 🛡️ **Error handling** - Comprehensive error types and handling
- 📊 **Observability** - Precise CPU and memory tracking, OpenTelemetry integration
- 🚰 **Multi-Sink Support** - Stream to S3, Kafka, ClickHouse, OpenSearch, Loki, and more
- 🔒 **Rate Limiting** - Global and per-provider rate limiting with Redis or in-memory backends

## Supported Providers

DylanWay provides seamless integration with multiple LLM providers through a unified interface.

### Core Providers

|                                                                                                                         | Provider          | Support | Models                                           |
| ----------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- | ------------------------------------------------ |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/openai.svg" alt="OpenAI" width="35" />            | **OpenAI**        | ✅      | GPT-4/5, GPT-3.5-turbo, text-embedding-ada-002   |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/anthropic.svg" alt="Anthropic" width="35" />      | **Anthropic**     | ✅      | Claude 3 (Sonnet, Opus, Haiku)                   |
| <img src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Google-favicon-2015.png" width="35">                      | **Google Gemini** | ✅      | Gemini 1.5 Pro, Gemini 1.5 Flash, Gemini Pro     |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/amazonaws.svg" alt="AWS" width="35" />            | **AWS Bedrock**   | ✅      | Amazon Nova, Amazon Titan, Claude, Llama         |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/microsoftazure.svg" alt="Azure" width="35" />     | **Azure OpenAI**  | ✅      | GPT-4, GPT-3.5-turbo (Azure-hosted)              |
| <img src="https://docs.mistral.ai/img/favicon.ico" width="35">                                                          | **Mistral AI**    | ✅      | Mistral Small, Mistral Large, Mixtral, Codestral |
| <img src="https://avatars.githubusercontent.com/u/54850923?s=200&v=4" alt="Cohere" width="35" />                        | **Cohere**        | ✅      | Command R, Command R+, Embed models              |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/huggingface.svg" alt="Hugging Face" width="35" /> | **Hugging Face**  | ✅      | HuggingFace                                      |
| <img src="https://www.gstatic.com/lamda/images/favicon_v1_150160cddff7f294ce30.svg" width="35">                         | **X.AI Grok**     | 🚌      | Grok models                                      |
| <img src="https://img.alicdn.com/imgextra/i4/O1CN01a6pmNi24dfWQwmMp3_!!6000000007414-2-tps-270-90.png" width="35">      | **Alibaba Qwen**  | 🚌      | Qwen models                                      |
| <img src="https://avatars.githubusercontent.com/u/148330874?s=200&v=4" width="35">                                      | **DeepSeek**      | 🚌      | DeepSeek Chat, DeepSeek Coder                    |
| <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/meta.svg" alt="Meta" width="35" />                | **Meta Llama**    | 🚌      | Llama 2, Llama 3, Code Llama series              |

## Quick Start

### 1. Set Environment Variables

Set these environment variables for the providers you want to use:

```bash
# OpenAI
export OPENAI_API_KEY="your_openai_api_key"

# Anthropic
export ANTHROPIC_API_KEY="your_anthropic_api_key"

# Google Gemini
export GEMINI_API_KEY="your_gemini_api_key"

# AWS (Bedrock)
export AWS_ACCESS_KEY_ID="your_aws_access_key"
export AWS_SECRET_ACCESS_KEY="your_aws_secret_key"

# Azure OpenAI
export AZURE_OPENAI_API_KEY="your_azure_api_key"
export AZURE_OPENAI_INSTANCE_NAME="your-instance-name"

# Mistral AI
export MISTRAL_API_KEY="your_mistral_api_key"

# Cohere
export COHERE_API_KEY="your_cohere_api_key"

# Huggingface
export HUGGINGFACE_API_KEY="your_huggingface_api_key"
```

### 2. Start Services

```bash
git clone https://github.com/dylankyc/dylanway
cd dylanway
make up
```

### 3. Test the Platform

```bash
curl http://localhost:9999/v1/chat/completions \
   -H "Content-Type: application/json" \
   -d '{
   "model": "openai/gpt-4o",
   "messages": [{
     "role": "user",
     "content": "Tell me a long love story about love between father and daughter and ends in a heartbreaking, tragic way and translate to chinese in the end"
   }],
   "stream": true,
   "stream_options": {
     "include_usage": true
   }
}'
```
## Usage

This repository includes short guides showing how to use MyWay with several editors and AI coding assistants. The full walkthroughs live in the `story/` directory — open the matching file for step-by-step instructions and examples.

- [**VS Code:**](https://code.visualstudio.com/) Use the instructions in [`story/0001.using-myway-in-vscode.md`](story/0001.using-myway-in-vscode.md) to open the project, install recommended extensions, and configure the workspace for local development and observability.
- [**Codex (OpenAI Codex / editor plugins):**](https://openai.com/codex/) See [`story/0002.using-myway-in-codex.md`](story/0002.using-myway-in-codex.md) for tips on integrating Codex-style assistants or editor plugins to navigate the project and generate code snippets safely.
- [**Claude Code:**](https://www.claude.com/product/claude-code) See [`story/0003.using-myway-in-claude-code.md`](story/0003.using-myway-in-claude-code.md) for guidance on using Anthropic Claude-assisted coding workflows with MyWay, including example prompts and safety suggestions.
- [**Zed Editor:**](https://zed.dev/) See [`story/0004.using-myway-in-zed.md`](story/0004.using-myway-in-zed.md) for notes on using the Zed editor with this repository, plus quick tips for working with the UI and observability dashboards.

## Sink Support

DylanWay supports integration with a wide variety of sinks for both streaming and batch data. You can enable multiple sinks simultaneously, allowing flexible routing and observability for your data pipelines.
### Supported Sinks

- [**AWS S3**](https://aws.amazon.com/s3/) - Object storage for logs and events
- [**ClickHouse**](https://clickhouse.com/) - High-performance analytics database
- [**Apache Kafka**](https://kafka.apache.org/) - Distributed event streaming
- [**Grafana Loki**](https://grafana.com/oss/loki/) - Log aggregation system
- [**MinIO**](https://min.io/) - S3-compatible object storage
- [**OpenSearch**](https://opensearch.org/) - Search and analytics engine
- [**Jaeger**](https://www.jaegertracing.io/) - Distributed tracing
- [**OpenTelemetry (OTEL)**](https://opentelemetry.io/) - OpenTelemetry integration

### Configuration Example

Sinks are configured in your YAML config under the `sinks` section:

```yaml
sinks:
  sinks:
    opensearch:
      sink_type: "elasticsearch"
      config:
        url: "http://opensearch:9200"
        index: "llm-logs"
        opensearch: true
    loki:
      sink_type: "loki"
      storage_approach: "combined"
      config:
        endpoint: "http://loki:3100"
        labels:
          environment: "development"
          service: "myway-llm"
          source: "llm-gateway"
        label_template: "provider={provider},model={model},status={status}"
        include_request_labels: true
        include_response_labels: true
        max_retries: 2 # reduced from 3
        retry_delay_ms: 100
        tls_verify: true
    kafka:
      sink_type: "kafka"
      config:
        brokers: ["kafka:9092"]
        topic: "llm-events"
```

For more examples, see the `docker-compose.*.yml` files in the repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
