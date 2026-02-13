#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"
TFVARS_FILE="${1:-$ROOT_DIR/terraform/serverless/terraform.tfvars}"
MARKER_FILE="$DEPLOY_DIR/.api_gateway_exists_without_state"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

terraform -chdir="$DEPLOY_DIR" init
"$ROOT_DIR/scripts/serverless-deploy-import.sh" "$TFVARS_FILE"

APPLY_ARGS=("-auto-approve" "-var-file=$TFVARS_FILE")
if [[ -f "$MARKER_FILE" ]]; then
  API_GATEWAY_ID="$(head -n1 "$MARKER_FILE" | tr -d '\r\n')"
  echo "Applying deploy with create_api_gateway=false (existing gateway id: $API_GATEWAY_ID)"
  APPLY_ARGS+=("-var=create_api_gateway=false")
fi

terraform -chdir="$DEPLOY_DIR" apply "${APPLY_ARGS[@]}"
