#!/bin/bash
# scripts/mongo_backup.sh
# Backup MongoDB using mongodump

set -e

MONGO_URI=${MONGO_URI:-"mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0"}
BACKUP_DIR="./backups/mongo"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/mongo_${TIMESTAMP}"

mkdir -p $BACKUP_DIR

echo "📦 Starting MongoDB backup..."
mongodump \
    --uri="$MONGO_URI" \
    --db=ecommerce \
    --out=$BACKUP_PATH

echo "✅ MongoDB backup saved to: $BACKUP_PATH"

# ─────────────────────────────
# RESTORE INSTRUCTIONS (manual)
# ─────────────────────────────
# To restore from backup, run:
#
# mongorestore \
#   --uri="mongodb://mongo1:27017/?replicaSet=rs0" \
#   --db=ecommerce \
#   ./backups/mongo/mongo_TIMESTAMP/ecommerce/
#
# ─────────────────────────────
