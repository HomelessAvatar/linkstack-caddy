#!/bin/bash
set -e

export TZ="${TZ:-Europe/Istanbul}"
export PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-128M}"
export UPLOAD_MAX_FILESIZE="${UPLOAD_MAX_FILESIZE:-8M}"

echo "========================================================"
echo "    🔗 LinkStack Caddy (PHP 8.4-FPM + Caddy v2)        "
echo "========================================================"
echo "Timezone: $TZ"
echo "PHP Memory Limit: $PHP_MEMORY_LIMIT"

# Populate /htdocs if empty or missing index.php
if [ ! -f /htdocs/index.php ]; then
    echo "Initializing LinkStack files in /htdocs from template..."
    cp -rn /htdocs-template/* /htdocs/ 2>/dev/null || true
    cp -rn /htdocs-template/.* /htdocs/ 2>/dev/null || true
fi

# Ensure essential directories exist
mkdir -p /htdocs/database \
         /htdocs/storage/logs \
         /htdocs/storage/framework/sessions \
         /htdocs/storage/framework/views \
         /htdocs/storage/framework/cache \
         /htdocs/bootstrap/cache

# Create SQLite database file if it does not exist
if [ ! -f /htdocs/database/database.sqlite ]; then
    echo "Creating empty SQLite database..."
    touch /htdocs/database/database.sqlite
fi

# Set permissions
chown -R www-data:www-data /htdocs /var/log/caddy
chmod -R 775 /htdocs/storage /htdocs/bootstrap/cache /htdocs/database

# Start PHP-FPM in background
echo "Starting PHP 8.4-FPM..."
php-fpm -D

# Start Caddy in foreground
echo "Starting Caddy v2 (HTTP/3)..."
exec caddy run --config /etc/caddy/Caddyfile
