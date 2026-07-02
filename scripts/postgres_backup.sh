#!/bin/bash
# scripts/postgres_backup.sh
# Backup PostgreSQL database using pg_dump

set -e  # Exit on any error

# Configuration
POSTGRES_HOST=${POSTGRES_HOST:-"postgres-primary"}
POSTGRES_DB=${POSTGRES_DB:-"ecommerce"}
POSTGRES_USER=${POSTGRES_USER:-"admin"}
BACKUP_DIR="./backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/ecommerce_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "📦 Starting PostgreSQL backup..."
PGPASSWORD=$POSTGRES_PASSWORD pg_dump \
    -h $POSTGRES_HOST \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    -F p \               # Plain text format
    -f $BACKUP_FILE

echo "✅ Backup saved to: $BACKUP_FILE"

# ─────────────────────────────
# RESTORE INSTRUCTIONS (manual)
# ─────────────────────────────
# To restore from backup, run:
#
# PGPASSWORD=admin123 psql \
#   -h postgres-primary \
#   -U admin \
#   -d ecommerce \
#   -f ./backups/postgres/ecommerce_TIMESTAMP.sql
#
# ─────────────────────────────
