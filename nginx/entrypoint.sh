#!/bin/sh

DOMAIN=${DOMAIN:-todo-app.theabhipatel.com}
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
CONF_PATH="/etc/nginx/conf.d/default.conf"
TEMPLATE_PATH="/etc/nginx/conf.d/default.conf.template"

# Generate HTTP-only config
echo "⚙️ Generating HTTP-only config for Nginx..."
sed "s|{{SSL_BLOCK}}||g" $TEMPLATE_PATH > $CONF_PATH

echo "🚀 Starting temporary Nginx (HTTP only)..."
nginx &

# Wait for cert
echo "🕒 Waiting for SSL certificate for $DOMAIN..."
while [ ! -f "$CERT_PATH" ]; do
  sleep 2
done

# Once cert exists, add SSL block dynamically
echo "🔐 SSL certificate found — enabling HTTPS..."
SSL_BLOCK=$(cat <<EOF
server {
  listen 443 ssl;
  server_name $DOMAIN;

  ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

  location / {
    proxy_pass http://app:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF
)

# Inject SSL block into final Nginx config
sed "s|{{SSL_BLOCK}}|$SSL_BLOCK|g" $TEMPLATE_PATH > $CONF_PATH

echo "♻️ Restarting Nginx with SSL..."
nginx -s quit
nginx -g "daemon off;"
