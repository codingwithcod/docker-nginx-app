#!/bin/sh

DOMAINS=${DOMAINS:-example.com}
EMAIL=${EMAIL:-admin@example.com}

CERT_PATH="/etc/letsencrypt/live/$(echo $DOMAINS | cut -d',' -f1)/fullchain.pem"

# 1. If certificate does not exist, issue it
if [ ! -f "$CERT_PATH" ]; then
  echo "🔐 No certificate found for $DOMAINS — issuing a new one..."
  certbot certonly --webroot -w /var/www/certbot \
    -d $(echo $DOMAINS | sed 's/,/ -d /g') \
    --email "$EMAIL" --agree-tos --no-eff-email --non-interactive
else
  echo "✅ Certificate already exists for $DOMAINS"
fi

# 2. Renewal loop (every 12 hours)
while true; do
  certbot renew --webroot -w /var/www/certbot
  sleep 12h
done
