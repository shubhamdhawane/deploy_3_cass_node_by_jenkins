#!/bin/bash
# scripts/cassandra_backup.sh
# Backup Cassandra using nodetool snapshot

set -e

CASSANDRA_HOST=${CASSANDRA_HOST:-"cassandra1"}
KEYSPACE="ecommerce"
SNAPSHOT_NAME="backup_$(date +%Y%m%d_%H%M%S)"

echo "📦 Creating Cassandra snapshot: $SNAPSHOT_NAME"

# Create snapshot on all nodes via the first node
docker exec $CASSANDRA_HOST nodetool snapshot \
    --tag $SNAPSHOT_NAME \
    $KEYSPACE

echo "✅ Snapshot '$SNAPSHOT_NAME' created on keyspace: $KEYSPACE"
echo ""
echo "📁 Snapshot files are located at:"
echo "   /var/lib/cassandra/data/$KEYSPACE/*/snapshots/$SNAPSHOT_NAME/"
echo ""

# ─────────────────────────────
# RESTORE INSTRUCTIONS (manual)
# ─────────────────────────────
# 1. Stop Cassandra on the node
# 2. Copy snapshot files back to the data directory:
#    cp -r /var/lib/cassandra/data/ecommerce/TABLE/snapshots/SNAPSHOT_NAME/* \
#          /var/lib/cassandra/data/ecommerce/TABLE/
# 3. Run: nodetool refresh ecommerce TABLE_NAME
# 4. Restart Cassandra
# ─────────────────────────────
