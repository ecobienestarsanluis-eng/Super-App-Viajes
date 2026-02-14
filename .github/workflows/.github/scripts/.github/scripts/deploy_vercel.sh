#!/usr/bin/env bash
# Deploy to Vercel using the Vercel CLI and token
set -e

if [ -z "$VERCEL_TOKEN" ] || [ -z "$VERCEL_PROJECT_ID" ] || [ -z "$VERCEL_ORG_ID" ]; then
  echo "VERCEL_TOKEN or VERCEL_PROJECT_ID or VERCEL_ORG_ID not set. Skipping Vercel deploy."
  exit 0
fi

npm i -g vercel@33.0.0
vercel deploy --prod --token "$VERCEL_TOKEN" --confirm --project "$VERCEL_PROJECT_ID" --org "$VERCEL_ORG_ID"
