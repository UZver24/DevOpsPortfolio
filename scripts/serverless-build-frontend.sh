#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"
FRONTEND_DIR="$ROOT_DIR/src/frontend"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed" >&2
  exit 1
fi

API_URL="$(terraform -chdir="$DEPLOY_DIR" output -raw api_gateway_endpoint 2>/dev/null || true)"

if [[ -z "$API_URL" || "$API_URL" == "null" ]]; then
  echo "api_gateway_endpoint is empty. Run deploy apply first." >&2
  exit 1
fi

echo "Using API URL: $API_URL"
cd "$FRONTEND_DIR"

if [[ ! -d node_modules ]]; then
  npm ci
fi

VITE_API_BASE_URL="$API_URL" npm run build

echo "Frontend build completed: $FRONTEND_DIR/dist"
