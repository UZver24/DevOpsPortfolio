#!/usr/bin/env bash
# Собирает фронтенд (React/Vite) и выгружает dist/ в Object Storage.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

main() {
  : "${STATIC_BUCKET_NAME:?Нужно указать STATIC_BUCKET_NAME (например, kulibin-devops-portfolio)}"
  : "${API_GATEWAY_ENDPOINT:?Нужно указать API_GATEWAY_ENDPOINT (например, https://....apigw.yandexcloud.net)}"
  : "${AWS_ACCESS_KEY_ID:?Нужно указать access key (из Terraform output)}"
  : "${AWS_SECRET_ACCESS_KEY:?Нужно указать secret key (из Terraform output)}"

  cd "${REPO_ROOT}/frontend"

  echo "==> Устанавливаем зависимости"
  npm ci

  echo "==> Собираем фронтенд (VITE_API_BASE_URL=${API_GATEWAY_ENDPOINT})"
  VITE_API_BASE_URL="${API_GATEWAY_ENDPOINT}" npm run build

  echo "==> Загружаем dist/ в Object Storage (s3://${STATIC_BUCKET_NAME})"
  yc storage s3 sync dist/ "s3://${STATIC_BUCKET_NAME}"

  echo "Готово: фронтенд обновлён"
}

main "$@"

