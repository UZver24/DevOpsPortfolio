#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$ROOT_DIR/terraform/serverless/bootstrap"
DIST_DIR="$ROOT_DIR/src/frontend/dist"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if [[ ! -d "$DIST_DIR" ]]; then
  echo "Frontend dist not found: $DIST_DIR. Build frontend first." >&2
  exit 1
fi

AWS_ACCESS_KEY_ID="$(terraform -chdir="$BOOTSTRAP_DIR" output -raw static_site_access_key)"
AWS_SECRET_ACCESS_KEY="$(terraform -chdir="$BOOTSTRAP_DIR" output -raw static_site_secret_key)"
BUCKET_NAME="$(terraform -chdir="$BOOTSTRAP_DIR" output -raw static_bucket_name)"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

content_type_for_file() {
  local file_path="$1"
  case "${file_path##*.}" in
    html) echo "text/html; charset=utf-8" ;;
    css) echo "text/css; charset=utf-8" ;;
    js|mjs) echo "application/javascript; charset=utf-8" ;;
    json) echo "application/json; charset=utf-8" ;;
    svg) echo "image/svg+xml" ;;
    png) echo "image/png" ;;
    jpg|jpeg) echo "image/jpeg" ;;
    webp) echo "image/webp" ;;
    ico) echo "image/x-icon" ;;
    txt) echo "text/plain; charset=utf-8" ;;
    map) echo "application/json; charset=utf-8" ;;
    *) echo "application/octet-stream" ;;
  esac
}

echo "Uploading dist to s3://$BUCKET_NAME with explicit Content-Type"
while IFS= read -r -d '' file; do
  relative_path="${file#"$DIST_DIR"/}"
  content_type="$(content_type_for_file "$file")"
  yc storage s3 cp "$file" "s3://$BUCKET_NAME/$relative_path" --content-type "$content_type"
done < <(find "$DIST_DIR" -type f -print0)

echo "Upload completed: https://$BUCKET_NAME.website.yandexcloud.net"
