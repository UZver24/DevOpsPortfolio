#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$ROOT_DIR/terraform/serverless/bootstrap"
BACKEND_DIR="$ROOT_DIR/src/backend"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed" >&2
  exit 1
fi

if ! command -v yc >/dev/null 2>&1; then
  echo "yc is not installed" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed" >&2
  exit 1
fi

IMAGE_URL="$(terraform -chdir="$BOOTSTRAP_DIR" output -raw backend_image)"

if [[ -z "$IMAGE_URL" || "$IMAGE_URL" == "null" ]]; then
  echo "backend_image output is empty. Run bootstrap apply first." >&2
  exit 1
fi

echo "Configuring Docker auth for Yandex Container Registry"
yc container registry configure-docker >/dev/null

echo "Building backend image: $IMAGE_URL"
docker build -t "$IMAGE_URL" "$BACKEND_DIR"

echo "Pushing backend image: $IMAGE_URL"
docker push "$IMAGE_URL"

echo "Backend image pushed successfully."
