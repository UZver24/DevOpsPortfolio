#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TFVARS_FILE="$ROOT_DIR/terraform/serverless/terraform.tfvars"
BOOTSTRAP_DIR="$ROOT_DIR/terraform/serverless/bootstrap"
DEPLOY_DIR="$ROOT_DIR/terraform/serverless/deploy"

"$ROOT_DIR/scripts/serverless-prepare-tfvars.sh"

terraform -chdir="$BOOTSTRAP_DIR" init
"$ROOT_DIR/scripts/serverless-bootstrap-import.sh" "$TFVARS_FILE"
terraform -chdir="$BOOTSTRAP_DIR" apply -auto-approve -var-file="$TFVARS_FILE"

"$ROOT_DIR/scripts/serverless-build-push-backend.sh"

terraform -chdir="$DEPLOY_DIR" init
"$ROOT_DIR/scripts/serverless-deploy-import.sh" "$TFVARS_FILE"
terraform -chdir="$DEPLOY_DIR" apply -auto-approve -var-file="$TFVARS_FILE"

"$ROOT_DIR/scripts/serverless-build-frontend.sh"
"$ROOT_DIR/scripts/serverless-upload-frontend.sh"

echo
echo "Bootstrap outputs:"
terraform -chdir="$BOOTSTRAP_DIR" output

echo
echo "Deploy outputs:"
terraform -chdir="$DEPLOY_DIR" output
