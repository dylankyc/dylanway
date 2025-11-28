#!/bin/sh

# Create OpenSearch Dashboard Index Pattern for MyWay LLM Logs
# This script creates the index pattern to visualize LLM request/response data

set -e

OPENSEARCH_DASHBOARDS_URL="http://opensearch-dashboards:5601"
INDEX_PATTERN="llm-logs"
TIME_FIELD="timestamp"

echo "🔧 Setting up OpenSearch Dashboard index pattern for MyWay LLM logs..."

# Wait for OpenSearch Dashboards to be ready
echo "⏳ Waiting for OpenSearch Dashboards to be ready..."
until curl -s "${OPENSEARCH_DASHBOARDS_URL}/api/status" > /dev/null; do
    echo "Waiting for OpenSearch Dashboards..."
    sleep 5
done
echo "✅ OpenSearch Dashboards is ready"

# Create the index pattern
echo "📝 Creating index pattern: ${INDEX_PATTERN}"

# First, let's check if the index pattern already exists
echo "📝 Checking for existing index pattern: ${INDEX_PATTERN}"

# Simple check without jq
EXISTING_CHECK=$(curl -s "${OPENSEARCH_DASHBOARDS_URL}/api/saved_objects/_find?type=index-pattern&search=${INDEX_PATTERN}")

if echo "$EXISTING_CHECK" | grep -q "\"title\":\"${INDEX_PATTERN}\""; then
    echo "⚠️  Index pattern '${INDEX_PATTERN}' already exists"
    echo "✅ Index pattern setup complete (already exists)"
else
    echo "📝 Creating new index pattern..."
    
    # Create new index pattern
    RESPONSE=$(curl -s -X POST "${OPENSEARCH_DASHBOARDS_URL}/api/saved_objects/index-pattern" \
        -H "Content-Type: application/json" \
        -H "osd-xsrf: true" \
        -d '{
            "attributes": {
                "title": "'${INDEX_PATTERN}'",
                "timeFieldName": "'${TIME_FIELD}'"
            }
        }')
    
    if echo "$RESPONSE" | grep -q "\"id\":"; then
        echo "✅ Created index pattern successfully"
    else
        echo "❌ Failed to create index pattern"
        echo "Response: $RESPONSE"
    fi
fi

echo ""
echo "🎉 Index pattern setup complete!"
echo ""
echo "📊 You can now:"
echo "   🔸 Visit OpenSearch Dashboards: http://localhost:5601"
echo "   🔸 Go to Discover to explore LLM logs"
echo "   🔸 Create visualizations and dashboards"
echo ""
echo "🔍 Useful filters:"
echo "   • doc_type: \"request\" or \"response\""
echo "   • data.provider: \"openai\", \"anthropic\", etc."
echo "   • data.model: \"gpt-4o\", \"claude-3\", etc."
echo "   • data.success: true or false"
echo ""
echo "📈 Sample queries:"
echo "   • Requests in last hour: timestamp:[now-1h TO now]"
echo "   • Failed requests: data.success:false"
echo "   • Specific provider: data.provider:\"openai\""