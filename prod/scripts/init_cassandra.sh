#!/bin/bash
# scripts/init_cassandra.sh
# Wait for Cassandra cluster to be ready, then run CQL init script

set -e

CASSANDRA_HOST=${CASSANDRA_HOST:-"cassandra1"}
CQL_FILE="/db/cassandra/init.cql"

echo "⏳ Waiting for Cassandra to be ready..."

# Keep trying until cqlsh connects successfully
until docker exec $CASSANDRA_HOST cqlsh -e "DESCRIBE KEYSPACES" &>/dev/null; do
    echo "   Cassandra not ready yet, retrying in 5s..."
    sleep 5
done

echo "✅ Cassandra is ready. Running init CQL..."
docker exec -i $CASSANDRA_HOST cqlsh < $CQL_FILE

echo "✅ Cassandra keyspace and tables initialized."
