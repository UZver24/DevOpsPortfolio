#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$ROOT_DIR/terraform/serverless/bootstrap"
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

state_has() {
  local addr="$1"
  terraform -chdir="$BOOTSTRAP_DIR" state list 2>/dev/null | grep -Fx "$addr" >/dev/null 2>&1
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
  terraform -chdir="$BOOTSTRAP_DIR" import -var-file=../terraform.tfvars "$addr" "$id" >/dev/null
}

FOLDER_ID="$(get_hcl_string_var "yc_folder_id")"
PROJECT_NAME="$(get_hcl_string_var "project_name")"
REGISTRY_NAME="$(get_hcl_string_var "container_registry_name")"
BUCKET_NAME="$(get_hcl_string_var "static_bucket_name")"

if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="devops-portfolio-serverless"
fi

SERVERLESS_SA_NAME="${PROJECT_NAME}-serverless-sa"
STATIC_SA_NAME="${PROJECT_NAME}-static-site"

SERVERLESS_SA_ID="$({ yc iam service-account list --format json | jq -r --arg name "$SERVERLESS_SA_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .id // empty'; } || true)"
STATIC_SA_ID="$({ yc iam service-account list --format json | jq -r --arg name "$STATIC_SA_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder)) | first | .id // empty'; } || true)"
REGISTRY_ID="$({ yc container registry list --format json | jq -r --arg name "$REGISTRY_NAME" --arg folder "$FOLDER_ID" 'map(select(.name == $name and .folder_id == $folder and .status != "DELETING")) | first | .id // empty'; } || true)"
EXISTING_BUCKET="$({ yc storage bucket list --format json | jq -r --arg name "$BUCKET_NAME" 'map(select(.name == $name)) | first | .name // empty'; } || true)"

import_if_missing "yandex_iam_service_account.serverless" "$SERVERLESS_SA_ID"
import_if_missing "yandex_iam_service_account.static_site" "$STATIC_SA_ID"
import_if_missing "yandex_container_registry.main" "$REGISTRY_ID"
import_if_missing "yandex_storage_bucket.static_site" "$EXISTING_BUCKET"

echo "Bootstrap import precheck completed."
