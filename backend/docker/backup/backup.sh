#!/bin/bash

set -e

# Variables
DB_HOST=${MYSQL_HOST}
DB_USER=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}
DB_NAME=${MYSQL_DATABASE}
BACKUP_DIR="/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/showme_backup_${DATE}.sql"
RETENTION_DAYS=7

echo "🔄 Démarrage du backup de la base de données..."

until mysqladmin ping -h"$DB_HOST" --silent; do
    echo "⏳ Attente de MySQL..."
    sleep 2
done

mkdir -p "$BACKUP_DIR"

echo "💾 Création du backup: $BACKUP_FILE"
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    --no-tablespaces \
    "$DB_NAME" > "$BACKUP_FILE"

if [ ! -s "$BACKUP_FILE" ]; then
    echo "❌ Le backup est vide, tentative avec des options réduites..."
    mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        --single-transaction \
        --no-tablespaces \
        "$DB_NAME" > "$BACKUP_FILE"
fi

echo "🗜️ Compression du backup..."
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

if [ -f "$BACKUP_FILE" ]; then
    echo "✅ Backup créé avec succès: $BACKUP_FILE"
    echo "📊 Taille: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "❌ Erreur lors de la création du backup"
    exit 1
fi

echo "🧹 Nettoyage des anciens backups (> $RETENTION_DAYS jours)..."
find "$BACKUP_DIR" -name "showme_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete

echo "📋 Backups disponibles:"
ls -lah "$BACKUP_DIR"/showme_backup_*.sql.gz 2>/dev/null || echo "Aucun backup trouvé"

echo "✅ Processus de backup terminé"