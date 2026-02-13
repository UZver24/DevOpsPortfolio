#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"
TFVARS_FILE="${1:-$ROOT_DIR/terraform/serverless/terraform.tfvars}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed" >&2
  exit 1
fi

if [[ ! -f "$TFVARS_FILE" ]]; then
  echo "tfvars file not found: $TFVARS_FILE" >&2
  exit 1
fi

get_hcl_string_var() {
  local key="$1"
  sed -nE "s|^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\".*$|\1|p" "$TFVARS_FILE" | head -n1
}

get_hcl_bool_var() {
  local key="$1"
  sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\\(true\\|false\\)[[:space:]]*$/\\1/p" "$TFVARS_FILE" | head -n1
}

state_has() {
  local addr="$1"
  terraform -chdir="$DEPLOY_DIR" state list 2>/dev/null | grep -Fx "$addr" >/dev/null 2>&1
}

import_if_missing() {
  local addr="$1"
  local id="$2"
  if [[ -z "$id" ]]; then
    return 0
  fi
  if state_has "$addr"; then
    return 0
  fi
  echo "Importing $addr <= $id"
  if ! timeout 180s terraform -chdir="$DEPLOY_DIR" import -var-file="$TFVARS_FILE" "$addr" "$id"; then
    echo "Import failed or timed out for $addr" >&2
    exit 1
  fi
}

FOLDER_ID="$(get_hcl_string_var "yc_folder_id")"
PROJECT_NAME="$(get_hcl_string_var "project_name")"
CREATE_API_GATEWAY="$(get_hcl_bool_var "create_api_gateway")"
ENABLE_FRONTEND_CONTAINER="$(get_hcl_bool_var "enable_frontend_container")"

if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="devops-portfolio-serverless"
fi
if [[ -z "$CREATE_API_GATEWAY" ]]; then
  CREATE_API_GATEWAY="true"
fi
if [[ -z "$ENABLE_FRONTEND_CONTAINER" ]]; then
  ENABLE_FRONTEND_CONTAINER="false"
fi

if [[ -z "$FOLDER_ID" ]]; then
  echo "yc_folder_id is empty in $TFVARS_FILE" >&2
  exit 1
fi

BACKEND_CONTAINER_NAME="${PROJECT_NAME}-backend"
FRONTEND_CONTAINER_NAME="${PROJECT_NAME}-frontend"
API_GATEWAY_NAME="${PROJECT_NAME}-api"
MARKER_FILE="$DEPLOY_DIR/.api_gateway_exists_without_state"

YC_CONTAINERS_JSON="$(yc serverless container list --format json)"
YC_API_GWS_JSON="$(yc serverless api-gateway list --format json)"

BACKEND_CONTAINER_ID="$(jq -r --arg name "$BACKEND_CONTAINER_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .id // empty' <<<"$YC_CONTAINERS_JSON")"
FRONTEND_CONTAINER_ID="$(jq -r --arg name "$FRONTEND_CONTAINER_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .id // empty' <<<"$YC_CONTAINERS_JSON")"
API_GATEWAY_ID="$(jq -r --arg name "$API_GATEWAY_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .id // empty' <<<"$YC_API_GWS_JSON")"

import_if_missing "yandex_serverless_container.backend" "$BACKEND_CONTAINER_ID"
if [[ -n "$BACKEND_CONTAINER_ID" ]]; then
  import_if_missing "yandex_serverless_container_iam_binding.backend_public" "${BACKEND_CONTAINER_ID},serverless.containers.invoker"
fi

if [[ "$ENABLE_FRONTEND_CONTAINER" == "true" ]]; then
  import_if_missing "yandex_serverless_container.frontend[0]" "$FRONTEND_CONTAINER_ID"
  if [[ -n "$FRONTEND_CONTAINER_ID" ]]; then
    import_if_missing "yandex_serverless_container_iam_binding.frontend_public[0]" "${FRONTEND_CONTAINER_ID},serverless.containers.invoker"
  fi
fi

rm -f "$MARKER_FILE"
if [[ "$CREATE_API_GATEWAY" == "true" ]] && [[ -n "$API_GATEWAY_ID" ]] && ! state_has "yandex_api_gateway.backend[0]"; then
  # yandex_api_gateway import is not implemented in the provider.
  printf '%s\n' "$API_GATEWAY_ID" > "$MARKER_FILE"
  echo "Found existing API Gateway ($API_GATEWAY_ID) without Terraform state."
  echo "Will skip API Gateway creation in apply step for this run."
fi

echo "Deploy import precheck completed."
