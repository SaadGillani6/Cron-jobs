curl -X POST "https://de-admin-sugar.fintra.ai/poly-x/poly-alert/v1/push" \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "69259acf81e2cda6690e0b9a",
    "user": {
      "_id": "6925a24381e2cda6690e0bcf",
      "email": "machine_user@issm.ai"
    },
    "title": "Service Down: UI",
    "tokens": "",
    "body": "Health check failed for http://localhost:3000. Service restarted.",
    "data": {
      "notificationType": "system",
      "messageId": "1234567890123456",
      "extra_key": "auto-restart"
    },
    "messageId": "1234567890123456",
    "type": "system",
    "audience": {
      "user_id": "6925a24381e2cda6690e0bcf",
      "role": "",
      "organization_id": "69259acf81e2cda6690e0b9a"
    },
    "severity": "error"
  }'
