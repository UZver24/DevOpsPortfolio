#!/usr/bin/env bash
# Скрипт для сборки backend-образа и публикации его в Yandex Container Registry.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

main() {
  : "${REGISTRY_ID:?Нужно указать REGISTRY_ID (например, crp50gpc30l3tbd4rtj0)}"
  : "${IMAGE_TAG:?Нужно указать IMAGE_TAG (например, latest или \$CI_COMMIT_SHORT_SHA)}"
  
  # Поддержка обоих способов: access key (рекомендуется) или OAuth token
  if [ -n "${YC_ACCESS_KEY_ID:-}" ] && [ -n "${YC_SECRET_ACCESS_KEY:-}" ]; then
    echo "==> Авторизация в YCR через access key"
    echo "${YC_ACCESS_KEY_ID}:${YC_SECRET_ACCESS_KEY}" | docker login --username iam --password-stdin cr.yandex
  elif [ -n "${YC_OAUTH_TOKEN:-}" ]; then
    echo "==> Авторизация в YCR через OAuth token (устаревший способ)"
    echo "${YC_OAUTH_TOKEN}" | docker login --username oauth --password-stdin cr.yandex
  else
    echo "❌ Ошибка: нужно указать либо YC_ACCESS_KEY_ID и YC_SECRET_ACCESS_KEY, либо YC_OAUTH_TOKEN"
    exit 1
  fi

  local image="cr.yandex/${REGISTRY_ID}/backend:${IMAGE_TAG}"

  echo "==> Сборка backend-образа: ${image}"
  docker build -t "${image}" "${REPO_ROOT}/backend"

  echo "==> Публикация образа"
  docker push "${image}"

  echo "Готово: ${image}"
}

main "$@"

