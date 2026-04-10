#!/bin/bash
# Vera Trade — PostgreSQL daily backup with 7-day retention
BACKUP_DIR="/home/debian/vera_trade/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="vera_trade_${TIMESTAMP}.sql.gz"

# Dump + compress
docker exec vera-trade-db pg_dump -U vera_trade_real vera_trade_real | gzip > "${BACKUP_DIR}/${FILENAME}"

if [ $? -eq 0 ] && [ -s "${BACKUP_DIR}/${FILENAME}" ]; then
  echo "[$(date)] Backup OK: ${FILENAME} ($(du -h "${BACKUP_DIR}/${FILENAME}" | cut -f1))"
else
  echo "[$(date)] BACKUP FAILED" >&2
  exit 1
fi

# Retention: keep last 7 days
find "${BACKUP_DIR}" -name "vera_trade_*.sql.gz" -mtime +7 -delete
