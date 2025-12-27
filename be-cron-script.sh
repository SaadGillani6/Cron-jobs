#!/bin/bash

# ================== CONFIG ==================
URL="http://localhost:8000"
COMPOSE_FILE="/home/it/digital_eye/docker-compose.yml"
LOG_FILE="/home/it/healthcheck.log"

DEFAULT_USER_ID="6925a24381e2cda6690e0bcf"
DEFAULT_USER_EMAIL="machine_user@issm.ai"
DEFAULT_ORGANIZATION_ID="69259acf81e2cda6690e0b9a"
# ===========================================

# Check if service is responding
if ! curl -sf "$URL" > /dev/null; then

  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  MESSAGE_ID=$(date +%s%N)

  {
    echo "$TIMESTAMP - Health check FAILED for $URL"
    echo "Restarting services using docker-compose"
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
      \"title\": \"Service Down: Application Health Check\",
      \"tokens\": \"\",
      \"body\": \"Health check failed for $URL. Service was restarted automatically.\",
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
