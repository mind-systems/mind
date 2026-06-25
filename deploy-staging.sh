#!/bin/bash
set -e

SERVER="user@185.138.186.243"
SSH="ssh -i ~/.ssh/compmaster_host -p 2222"
SCP="scp -i ~/.ssh/compmaster_host -P 2222"
REMOTE_DIR="/srv/mind"

SERVICE="${1:-mind_api}"

echo "==> Building $SERVICE..."
docker compose --env-file .env.staging -f docker-compose.staging.yml build "$SERVICE"

PROJECT_NAME=$(docker compose --env-file .env.staging -f docker-compose.staging.yml config --format json | python3 -c "import sys,json; print(json.load(sys.stdin)['name'])")
IMAGE_NAME="${PROJECT_NAME}-${SERVICE}"

echo "==> Pushing image $IMAGE_NAME to server..."
docker save "$IMAGE_NAME" | gzip | $SSH "$SERVER" "docker load"

echo "==> Syncing compose files..."
$SSH "$SERVER" "mkdir -p $REMOTE_DIR/mind_api"
$SCP docker-compose.staging.yml .env.staging "$SERVER:$REMOTE_DIR/"
$SCP mind_api/.env.staging "$SERVER:$REMOTE_DIR/mind_api/.env.staging"

echo "==> Restarting $SERVICE on server..."
$SSH "$SERVER" "cd $REMOTE_DIR && docker compose --env-file .env.staging -f docker-compose.staging.yml up -d $SERVICE"

echo "==> Done."
