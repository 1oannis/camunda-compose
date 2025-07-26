#!/bin/bash
set -e

# Start Elasticsearch in the background
/usr/local/bin/docker-entrypoint.sh "$@" &

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
until curl -f -u elastic:${ELASTIC_PASSWORD} http://localhost:9200/_cluster/health; do
  echo "Waiting for Elasticsearch to be ready..."
  sleep 5
done

echo "Elasticsearch is ready. Configuring replica count to 0 for all indices..."

# Set replica count to 0 for all indices
curl -X PUT -u elastic:${ELASTIC_PASSWORD} \
  "http://localhost:9200/_all/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 0}}'

echo "Replica configuration applied successfully."

# Wait for the background process
wait 