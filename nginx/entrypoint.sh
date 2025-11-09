#!/bin/sh

DOMAIN=${DOMAIN:-todo-app.theabhipatel.com}
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

echo "🕒 Waiting for SSL certificate for $DOMAIN..."

# Wait until cert exists
while [ ! -f "$CERT_PATH" ]; do
  sleep 2
done

echo "✅ Certificate found, starting Nginx..."
nginx -g "daemon off;"
