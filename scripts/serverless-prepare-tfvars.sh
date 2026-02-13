#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TFVARS_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars"

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if [[ ! -f "$TFVARS_FILE" ]]; then
  echo "terraform.tfvars not found: $TFVARS_FILE" >&2
  exit 1
fi

escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

set_hcl_string_var() {
  local key="$1"
  local value="$2"
  local escaped_value
  escaped_value="$(escape_sed_repl "$value")"

  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$TFVARS_FILE"; then
    sed -i -E "s|^[[:space:]]*${key}[[:space:]]*=.*$|${key} = \"${escaped_value}\"|" "$TFVARS_FILE"
  else
    printf '%s = "%s"\n' "$key" "$value" >> "$TFVARS_FILE"
  fi
}

get_hcl_string_var() {
  local key="$1"
  sed -nE "s|^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\".*$|\1|p" "$TFVARS_FILE" | head -n1
}

TOKEN="$(yc iam create-token | tr -d '\r\n')"
if [[ -z "$TOKEN" ]]; then
  echo "Failed to get yc IAM token. Check 'yc init' and active profile." >&2
  exit 1
fi
set_hcl_string_var "yc_token" "$TOKEN"

CLOUD_ID="$(get_hcl_string_var "yc_cloud_id")"
if [[ -z "$CLOUD_ID" ]]; then
  CLOUD_ID="$(yc config get cloud-id 2>/dev/null || true)"
  if [[ -n "$CLOUD_ID" ]]; then
    set_hcl_string_var "yc_cloud_id" "$CLOUD_ID"
  fi
fi

FOLDER_ID="$(get_hcl_string_var "yc_folder_id")"
if [[ -z "$FOLDER_ID" ]]; then
  FOLDER_ID="$(yc config get folder-id 2>/dev/null || true)"
  if [[ -n "$FOLDER_ID" ]]; then
    set_hcl_string_var "yc_folder_id" "$FOLDER_ID"
  fi
fi

ZONE="$(get_hcl_string_var "yc_zone")"
if [[ -z "$ZONE" ]]; then
  set_hcl_string_var "yc_zone" "ru-central1-a"
fi

REGISTRY_NAME="$(get_hcl_string_var "container_registry_name")"
if [[ -z "$REGISTRY_NAME" ]]; then
  set_hcl_string_var "container_registry_name" "kulibin-devops-portfolio"
fi

BACKEND_TAG="$(get_hcl_string_var "backend_image_tag")"
if [[ -z "$BACKEND_TAG" ]]; then
  set_hcl_string_var "backend_image_tag" "latest"
fi

MISSING=()
for key in yc_token yc_cloud_id yc_folder_id yc_zone static_bucket_name; do
  value="$(get_hcl_string_var "$key")"
  if [[ -z "$value" ]]; then
    MISSING+=("$key")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Updated token, but terraform.tfvars still has empty required values:" >&2
  printf '  - %s\n' "${MISSING[@]}" >&2
  exit 1
fi

echo "terraform/serverless/terraform.tfvars updated (token refreshed)."
