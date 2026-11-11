#!/bin/bash

set -Eeuo pipefail

# Configuration

CONTAINER_NAME="hotel-postgres"
DB_USER="hotel_admin"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BACKUP_DIR="${PROJECT_ROOT}/backups"

# Accept backup file as first argument

BACKUP_FILE="${1:-}"

# Default restore database name

RESTORE_DB="${2:-hotel_db_restore}"

echo "======================================"
echo " PostgreSQL Database Restore"
echo "======================================"

# Check Docker container

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
    echo "ERROR: PostgreSQL container is not running."
    exit 1
fi

# Select latest backup if no file is provided

if [[ -z "$BACKUP_FILE" ]]; then
    BACKUP_FILE=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "hotel_db_*.dump" -printf '%T@ %p\n' |
        sort -nr | head -n 1 | cut -d' ' -f2-)
fi

# Check backup file

if [[ -z "$BACKUP_FILE" || ! -s "$BACKUP_FILE" ]]; then
    echo "ERROR: Backup file not found or empty."
    exit 1
fi

# Convert relative path to absolute path

if [[ "$BACKUP_FILE" != /* ]]; then
    BACKUP_FILE="${PROJECT_ROOT}/${BACKUP_FILE}"
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "ERROR: Backup file does not exist: $BACKUP_FILE"
    exit 1
fi

# Validate backup archive

if ! docker exec -i "$CONTAINER_NAME" \
    pg_restore --list < "$BACKUP_FILE" >/dev/null; then
    echo "ERROR: Invalid PostgreSQL backup."
    exit 1
fi

# Check target database name

if [[ "$RESTORE_DB" == "hotel_db" || "$RESTORE_DB" == "postgres" ]]; then
    echo "ERROR: Choose a separate restore database name."
    exit 1
fi

# Ensure target database does not already exist

EXISTS=$(docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d postgres -tAc \
    "SELECT 1 FROM pg_database WHERE datname = '${RESTORE_DB}'")

if [[ "$EXISTS" == "1" ]]; then
    echo "ERROR: Database ${RESTORE_DB} already exists."
    echo "Choose another database name."
    exit 1
fi

# Create fresh database

echo "Creating fresh database: $RESTORE_DB"

docker exec "$CONTAINER_NAME" \
    createdb -U "$DB_USER" "$RESTORE_DB"

# Restore backup

echo "Restoring database backup..."

if ! docker exec -i "$CONTAINER_NAME" \
    pg_restore -U "$DB_USER" -d "$RESTORE_DB" \
    --exit-on-error < "$BACKUP_FILE"; then

    echo "ERROR: Restore failed."

    docker exec "$CONTAINER_NAME" \
        dropdb -U "$DB_USER" "$RESTORE_DB" || true

    exit 1
fi

echo ""
echo "Database restored successfully!"

# Verify restored tables

echo ""
echo "Checking restored tables..."

docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d "$RESTORE_DB" -c "\dt"

# Verify booking records

echo ""
echo "Verifying booking records..."

docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d "$RESTORE_DB" -c \
    "SELECT COUNT(*) AS total_bookings FROM hotel_bookings;"

# Verify booking events

echo ""
echo "Verifying booking events..."

docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d "$RESTORE_DB" -c \
    "SELECT COUNT(*) AS total_events FROM booking_events;"

echo ""
echo "======================================"
echo " Restore completed successfully!"
echo "Database: $RESTORE_DB"
echo "======================================"