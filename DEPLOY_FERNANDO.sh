#!/bin/bash
set -euo pipefail

SERVER_IP="192.168.1.8"
SERVER_USER="rootify"
DB_PASSWORD=$(openssl rand -base64 32)

# Secrets are loaded from an untracked local file (see .env.deploy.local.example)
source "$(dirname "$0")/.env.deploy.local"

cat > .env.prod << EOF
DB_PASSWORD=$DB_PASSWORD
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_ADMIN_ID=$TELEGRAM_ADMIN_ID
GROQ_API_KEY=$GROQ_API_KEY
OLLAMA_API_URL=$OLLAMA_API_URL
OLLAMA_MODEL=llama3.1:latest
DATABASE_URL=postgresql://tutor:$DB_PASSWORD@postgres:5432/serbian_tutor
REDIS_URL=redis://redis:6379/0
EOF

echo "✅ .env.prod created"

ssh -p 22 $SERVER_USER@$SERVER_IP << 'REMOTE'
cd /opt
git clone https://github.com/redstock369/serbian-tutor-v2.git 2>/dev/null || (cd serbian-tutor-v2 && git pull)
cd serbian-tutor-v2
curl -fsSL https://get.docker.com | bash 2>/dev/null || true
which docker-compose || sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
docker-compose -f docker-compose.prod.yml up -d
REMOTE

echo "🎉 Deploy complete! Bot is live on Telegram: @Serbian_Tutor_Bot"
echo "Logs: ssh $SERVER_USER@$SERVER_IP 'cd /opt/serbian-tutor-v2 && docker-compose -f docker-compose.prod.yml logs bot'"
