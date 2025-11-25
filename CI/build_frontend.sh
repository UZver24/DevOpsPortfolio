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

  echo "==> Настраиваем авторизацию yc для Object Storage"
  if [ -n "${YC_IAM_TOKEN:-}" ]; then
    export YC_TOKEN="${YC_IAM_TOKEN}"
    yc config set token "${YC_IAM_TOKEN}" || true
    yc config set folder-id "${YC_FOLDER_ID:-}" || true
    yc config set cloud-id "${YC_CLOUD_ID:-}" || true
  else
    echo "⚠️  YC_IAM_TOKEN не установлен, пробуем использовать существующую конфигурацию yc"
  fi

  echo "==> Загружаем dist/ в Object Storage (s3://${STATIC_BUCKET_NAME})"
  yc storage s3 cp --recursive dist/ "s3://${STATIC_BUCKET_NAME}"

  echo "Готово: фронтенд обновлён"
}

main "$@"

