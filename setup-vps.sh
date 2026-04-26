#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: ./setup-vps.sh <domain>"
  echo "Example: ./setup-vps.sh proxy.example.com"
  exit 1
fi

DOMAIN="$1"
APP_DIR="/opt/unstable-backend"

sudo apt update
sudo apt install -y curl nginx certbot python3-certbot-nginx

if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
fi

if ! command -v pm2 >/dev/null 2>&1; then
  sudo npm i -g pm2
fi

sudo mkdir -p "$APP_DIR"
sudo cp server.mjs package.json package-lock.json ecosystem.config.cjs nginx-proxy.conf "$APP_DIR/"
cd "$APP_DIR"
sudo npm ci --omit=dev

sudo pm2 delete unstable-backend >/dev/null 2>&1 || true
sudo pm2 start ecosystem.config.cjs
sudo pm2 save

sudo cp nginx-proxy.conf /etc/nginx/sites-available/unstable-backend
sudo sed -i "s/proxy.yourdomain.com/$DOMAIN/g" /etc/nginx/sites-available/unstable-backend
sudo ln -sf /etc/nginx/sites-available/unstable-backend /etc/nginx/sites-enabled/unstable-backend
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@$DOMAIN" || true

echo
echo "Done."
echo "Health URL: https://$DOMAIN/health"
echo "Wisp URL:   wss://$DOMAIN/wisp/"
