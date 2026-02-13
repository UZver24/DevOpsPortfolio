#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TFVARS_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars"
BOOTSTRAP_DIR="$ROOT_DIR/terraform/serverless/bootstrap"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"

"$ROOT_DIR/scripts/serverless-prepare-tfvars.sh"

terraform -chdir="$DEPLOY_DIR" init
terraform -chdir="$DEPLOY_DIR" destroy -auto-approve -var-file="$TFVARS_FILE" || true

terraform -chdir="$BOOTSTRAP_DIR" init

# Container Registry cannot be deleted while it contains images.
REGISTRY_ID="$(terraform -chdir="$BOOTSTRAP_DIR" output -raw container_registry_id 2>/dev/null || true)"
REGISTRY_ID="$(printf '%s' "$REGISTRY_ID" | tr -d '\r' | head -n1)"
if [[ ! "$REGISTRY_ID" =~ ^crp[[:alnum:]]+$ ]]; then
  REGISTRY_ID="$(
    (terraform -chdir="$BOOTSTRAP_DIR" state show yandex_container_registry.main 2>/dev/null || true) \
      | sed -nE 's|^[[:space:]]*id[[:space:]]*=[[:space:]]*\"([^\"]+)\"$|\1|p' \
      | head -n1
  )"
fi
if [[ "$REGISTRY_ID" =~ ^crp[[:alnum:]]+$ ]]; then
  echo "Cleaning images in registry: $REGISTRY_ID"
  IMAGE_IDS="$(yc container image list --registry-id "$REGISTRY_ID" --format json | jq -r '.[].id')"
  if [[ -n "$IMAGE_IDS" ]]; then
    while IFS= read -r image_id; do
      [[ -z "$image_id" ]] && continue
      echo "Deleting image: $image_id"
      yc container image delete --id "$image_id" >/dev/null
    done <<< "$IMAGE_IDS"
  fi

  REMAINING="$(yc container image list --registry-id "$REGISTRY_ID" --format json | jq -r 'length')"
  if [[ "$REMAINING" != "0" ]]; then
    echo "Registry $REGISTRY_ID still has images after cleanup." >&2
    exit 1
  fi
fi

terraform -chdir="$BOOTSTRAP_DIR" destroy -auto-approve -var-file="$TFVARS_FILE"

echo "All serverless Terraform-managed resources were destroyed (deploy + bootstrap)."
