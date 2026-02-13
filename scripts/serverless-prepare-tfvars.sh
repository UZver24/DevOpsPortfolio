#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TFVARS_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars"
TFVARS_EXAMPLE_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars.example"

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if [[ ! -f "$TFVARS_FILE" ]]; then
  if [[ -f "$TFVARS_EXAMPLE_FILE" ]]; then
    cp "$TFVARS_EXAMPLE_FILE" "$TFVARS_FILE"
    echo "Created $TFVARS_FILE from terraform.tfvars.example"
  else
    echo "terraform.tfvars not found and example is missing: $TFVARS_FILE" >&2
    exit 1
  fi
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

ensure_var_with_prompt() {
  local key="$1"
  local prompt_text="$2"
  local suggested_value="${3:-}"
  local current_value
  current_value="$(get_hcl_string_var "$key")"

  if [[ -n "$current_value" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    echo "Variable '$key' is empty in $TFVARS_FILE and interactive input is unavailable." >&2
    echo "Fill '$key' manually and rerun." >&2
    exit 1
  fi

  local user_value=""
  while [[ -z "$user_value" ]]; do
    if [[ -n "$suggested_value" ]]; then
      read -r -p "$prompt_text [$suggested_value]: " user_value
      if [[ -z "$user_value" ]]; then
        user_value="$suggested_value"
      fi
    else
      read -r -p "$prompt_text: " user_value
    fi
  done

  set_hcl_string_var "$key" "$user_value"
}

TOKEN="$(yc iam create-token | tr -d '\r\n')"
if [[ -z "$TOKEN" ]]; then
  echo "Failed to get yc IAM token. Check 'yc init' and active profile." >&2
  exit 1
fi
set_hcl_string_var "yc_token" "$TOKEN"

CLOUD_ID="$(get_hcl_string_var "yc_cloud_id")"
SUGGESTED_CLOUD_ID="$(yc config get cloud-id 2>/dev/null || true)"
ensure_var_with_prompt "yc_cloud_id" "Enter yc_cloud_id" "$SUGGESTED_CLOUD_ID"
CLOUD_ID="$(get_hcl_string_var "yc_cloud_id")"

FOLDER_ID="$(get_hcl_string_var "yc_folder_id")"
SUGGESTED_FOLDER_ID="$(yc config get folder-id 2>/dev/null || true)"
ensure_var_with_prompt "yc_folder_id" "Enter yc_folder_id" "$SUGGESTED_FOLDER_ID"
FOLDER_ID="$(get_hcl_string_var "yc_folder_id")"

ensure_var_with_prompt "static_bucket_name" "Enter static_bucket_name" "kulibin-devops-portfolio"

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
