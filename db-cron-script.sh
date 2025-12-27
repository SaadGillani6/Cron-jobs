#!/bin/bash

# ================== CONFIG ==================
DEFAULT_USER_ID="6925a24381e2cda6690e0bcf"
DEFAULT_USER_EMAIL="machine_user@issm.ai"
DEFAULT_ORGANIZATION_ID="69259acf81e2cda6690e0b9a"

LOG_FILE="/home/it/databases/db-healthcheck.log"
# ===========================================

check_port () {
  local PORT=$1
  local SERVICE_NAME=$2
  local COMPOSE_FILE=$3

  if ! timeout 5 bash -c "</dev/tcp/127.0.0.1/$PORT" 2>/dev/null; then

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    MESSAGE_ID=$(date +%s%N)

    {
      echo "$TIMESTAMP - $SERVICE_NAME health check FAILED on port $PORT"
      echo "Restarting services using $COMPOSE_FILE"
      echo "======================="
    } >> "$LOG_FILE"

    # Restart service
    /usr/bin/docker compose -f "$COMPOSE_FILE" down
    /usr/bin/docker compose -f "$COMPOSE_FILE" up -d

    # Send alert
    curl -s -X POST "https://testde.fbr.gov.pk/poly-x/poly-alert/v1/push" \
      -H "Content-Type: application/json" \
      -d "{
        \"organization_id\": \"$DEFAULT_ORGANIZATION_ID\",
        \"user\": {
          \"_id\": \"$DEFAULT_USER_ID\",
          \"email\": \"$DEFAULT_USER_EMAIL\"
        },
        \"title\": \"Service Down: $SERVICE_NAME\",
        \"tokens\": \"\",
        \"body\": \"Health check failed for $SERVICE_NAME on port $PORT. Service restarted.\",
        \"data\": {
          \"notificationType\": \"system\",
          \"messageId\": \"$MESSAGE_ID\",
          \"extra_key\": \"auto-restart\"
        },
        \"messageId\": \"$MESSAGE_ID\",
        \"type\": \"system\",
        \"audience\": {
          \"user_id\": \"$DEFAULT_USER_ID\",
          \"role\": \"\",
          \"organization_id\": \"$DEFAULT_ORGANIZATION_ID\"
        },
        \"severity\": \"error\"
      }"
  fi
}

# ------------------ SERVICES ------------------

check_port 6380 "Redis" "/home/it/databases/redis/docker-compose.yml"
check_port 27017 "MongoDB" "/home/it/databases/mongo/docker-compose.yml"
