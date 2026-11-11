#!/bin/bash

set -Eeuo pipefail

# Configuration

CONTAINER_NAME="hotel-postgres"
DB_NAME="hotel_db"
DB_USER="hotel_admin"

# Project directory

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BACKUP_DIR="${PROJECT_ROOT}/backups"

# Timestamp

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

# Create backup directory

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo " PostgreSQL Database Backup"
echo "======================================"

# Check Docker container

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
    echo "ERROR: PostgreSQL container is not running."
    exit 1
fi

# Check database connectivity

if ! docker exec "$CONTAINER_NAME" \
    pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null; then
    echo "ERROR: Database is not ready."
    exit 1
fi

# Create timestamped backup

echo "Creating database backup..."

if docker exec "$CONTAINER_NAME" \
    pg_dump -U "$DB_USER" -d "$DB_NAME" -Fc > "$BACKUP_FILE"; then

    echo "Backup completed successfully."

else
    rm -f "$BACKUP_FILE"
    echo "ERROR: Backup failed."
    exit 1
fi

# Verify backup file

if [[ ! -s "$BACKUP_FILE" ]]; then
    echo "ERROR: Backup file is empty."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo ""
echo "Backup location: $BACKUP_FILE"
echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"

echo "======================================"
echo " Backup completed successfully!"
echo "======================================"