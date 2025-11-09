#!/bin/sh

DOMAIN=${DOMAIN:-todo-app.theabhipatel.com}
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
CONF_PATH="/etc/nginx/conf.d/default.conf"

echo "⚙️ Generating HTTP-only config for Nginx..."
# Step 1: temporary HTTP-only config (for Certbot initial issuance)
cat > "$CONF_PATH" <<EOF
server {
  listen 80;
  server_name $DOMAIN;

  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
  }

  location / {
    proxy_pass http://app:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF

echo "🚀 Starting temporary Nginx (HTTP only)..."
nginx &

# Step 2: wait until SSL certificate exists
echo "🕒 Waiting for SSL certificate for $DOMAIN..."
while [ ! -f "$CERT_PATH" ]; do
  sleep 2
done

echo "🔐 SSL certificate found — enabling HTTPS with redirect..."

# Step 3: overwrite Nginx config with HTTPS + redirect
cat > "$CONF_PATH" <<EOF
# HTTP server (for renewal + redirect)
server {
  listen 80;
  server_name $DOMAIN;

  # Certbot renewals
  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
  }

  # Redirect all other traffic to HTTPS
  location / {
    return 301 https://\$host\$request_uri;
  }
}

# HTTPS server
server {
  listen 443 ssl;
  server_name $DOMAIN;

  ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

  # Your app
  location / {
    proxy_pass http://app:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF

echo "♻️ Restarting Nginx with SSL + Redirect..."
nginx -s quit || true
nginx -g "daemon off;"



# ###########################################################
# ################     Working configuration    #############
# ###########################################################

# #!/bin/sh

# DOMAIN=${DOMAIN:-todo-app.theabhipatel.com}
# CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
# CONF_PATH="/etc/nginx/conf.d/default.conf"
# TEMPLATE_PATH="/etc/nginx/conf.d/default.conf.template"

# echo "⚙️ Generating HTTP-only config for Nginx..."
# # Write HTTP-only config first
# cat > "$CONF_PATH" <<EOF
# server {
#   listen 80;
#   server_name $DOMAIN;

#   location /.well-known/acme-challenge/ {
#     root /var/www/certbot;
#   }

#   location / {
#     proxy_pass http://app:3000;
#     proxy_set_header Host \$host;
#     proxy_set_header X-Real-IP \$remote_addr;
#   }
# }
# EOF

# echo "🚀 Starting temporary Nginx (HTTP only)..."
# nginx &

# # Wait for cert
# echo "🕒 Waiting for SSL certificate for $DOMAIN..."
# while [ ! -f "$CERT_PATH" ]; do
#   sleep 2
# done

# echo "🔐 SSL certificate found — enabling HTTPS..."

# # Overwrite full config with HTTP + HTTPS blocks
# cat > "$CONF_PATH" <<EOF
# server {
#   listen 80;
#   server_name $DOMAIN;

#   location /.well-known/acme-challenge/ {
#     root /var/www/certbot;
#   }

#   location / {
#     proxy_pass http://app:3000;
#     proxy_set_header Host \$host;
#     proxy_set_header X-Real-IP \$remote_addr;
#   }
# }

# server {
#   listen 443 ssl;
#   server_name $DOMAIN;

#   ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
#   ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

#   location / {
#     proxy_pass http://app:3000;
#     proxy_set_header Host \$host;
#     proxy_set_header X-Real-IP \$remote_addr;
#   }
# }
# EOF

# echo "♻️ Restarting Nginx with SSL..."
# nginx -s quit
# nginx -g "daemon off;"
