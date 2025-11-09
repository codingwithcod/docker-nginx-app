#!/bin/sh

DOMAIN=${DOMAIN:-todo-app.theabhipatel.com}
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

# Always start HTTP (port 80) immediately
echo "🚀 Starting temporary HTTP server on port 80..."
nginx &

# Wait for cert
echo "🕒 Waiting for SSL certificate for $DOMAIN..."
while [ ! -f "$CERT_PATH" ]; do
  sleep 2
done

echo "✅ Certificate found. Restarting Nginx with SSL..."
nginx -s quit
nginx -g "daemon off;"
