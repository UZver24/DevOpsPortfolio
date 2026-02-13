#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"
FRONTEND_DIR="$ROOT_DIR/src/frontend"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed" >&2
  exit 1
fi

API_URL="$(terraform -chdir="$DEPLOY_DIR" output -raw api_gateway_endpoint 2>/dev/null || true)"
API_URL="$(printf '%s' "$API_URL" | tr -d '\r' | head -n1)"
if [[ ! "$API_URL" =~ ^https?:// ]]; then
  API_URL=""
fi

if [[ -z "$API_URL" || "$API_URL" == "null" ]]; then
  TFVARS_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars"
  FOLDER_ID="$(sed -nE 's|^[[:space:]]*yc_folder_id[[:space:]]*=[[:space:]]*"([^"]*)".*$|\1|p' "$TFVARS_FILE" | head -n1)"
  PROJECT_NAME="$(sed -nE 's|^[[:space:]]*project_name[[:space:]]*=[[:space:]]*"([^"]*)".*$|\1|p' "$TFVARS_FILE" | head -n1)"
  if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="devops-portfolio-serverless"
  fi
  API_GATEWAY_NAME="${PROJECT_NAME}-api"
  API_DOMAIN="$(yc serverless api-gateway list --format json | jq -r --arg name "$API_GATEWAY_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .domain // empty')"
  if [[ -n "$API_DOMAIN" ]]; then
    API_URL="https://${API_DOMAIN}"
    echo "api_gateway_endpoint output is empty, fallback to existing gateway: $API_URL"
  else
    echo "api_gateway_endpoint is empty and existing API Gateway was not found." >&2
    exit 1
  fi
fi

echo "Using API URL: $API_URL"
cd "$FRONTEND_DIR"

if [[ ! -d node_modules ]]; then
  npm ci
fi

VITE_API_BASE_URL="$API_URL" npm run build

echo "Frontend build completed: $FRONTEND_DIR/dist"
