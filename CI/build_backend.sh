#!/usr/bin/env bash
# Скрипт для сборки backend-образа и публикации его в Yandex Container Registry.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

main() {
  : "${REGISTRY_ID:?Нужно указать REGISTRY_ID (например, crp50gpc30l3tbd4rtj0)}"
  : "${IMAGE_TAG:?Нужно указать IMAGE_TAG (например, latest или \$CI_COMMIT_SHORT_SHA)}"
  : "${YC_OAUTH_TOKEN:?Нужно указать YC_OAUTH_TOKEN (yc iam create-token)}"

  local image="cr.yandex/${REGISTRY_ID}/backend:${IMAGE_TAG}"

  echo "==> Авторизация в YCR"
  echo "${YC_OAUTH_TOKEN}" | docker login --username oauth --password-stdin cr.yandex

  echo "==> Сборка backend-образа: ${image}"
  docker build -t "${image}" "${REPO_ROOT}/backend"

  echo "==> Публикация образа"
  docker push "${image}"

  echo "Готово: ${image}"
}

main "$@"

