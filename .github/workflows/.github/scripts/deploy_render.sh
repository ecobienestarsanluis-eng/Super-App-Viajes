#!/usr/bin/env bash
# trigger deploy for Render service
set -e
if [ -z "$RENDER_SERVICE_ID" ] || [ -z "$RENDER_API_KEY" ]; then
  echo "RENDER_SERVICE_ID or RENDER_API_KEY not set. Skipping Render deploy."
  exit 0
fi

echo "Triggering Render deploy for service id: $RENDER_SERVICE_ID"
curl -X POST "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"clearCache": true }'
echo "Render deploy triggered."
