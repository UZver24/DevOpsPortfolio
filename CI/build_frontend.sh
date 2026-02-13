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

  cd "${REPO_ROOT}/src/frontend"

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
  
  # Функция для определения Content-Type по расширению
  get_content_type() {
    local file="$1"
    case "${file##*.}" in
      html) echo "text/html; charset=utf-8" ;;
      css)  echo "text/css; charset=utf-8" ;;
      js)   echo "application/javascript; charset=utf-8" ;;
      json) echo "application/json; charset=utf-8" ;;
      png)  echo "image/png" ;;
      jpg|jpeg) echo "image/jpeg" ;;
      svg)  echo "image/svg+xml" ;;
      ico)  echo "image/x-icon" ;;
      woff) echo "font/woff" ;;
      woff2) echo "font/woff2" ;;
      ttf)  echo "font/ttf" ;;
      eot)  echo "application/vnd.ms-fontobject" ;;
      map)  echo "application/json" ;;
      *)    echo "text/plain" ;;
    esac
  }

  # Загружаем все файлы из dist/ с правильными Content-Type
  cd dist
  find . -type f | while read -r file; do
    # Убираем ведущую точку и слэш
    key="${file#./}"
    content_type=$(get_content_type "$file")
    
    echo "Загружаем: $key (Content-Type: $content_type)"
    yc storage s3api put-object \
      --bucket "${STATIC_BUCKET_NAME}" \
      --key "$key" \
      --body "$file" \
      --content-type "$content_type" \
      --acl public-read
  done

  echo "Готово: фронтенд обновлён"
}

main "$@"

