# CI Scripts

В каталоге собраны вспомогательные скрипты, которые использует ручной запуск или GitLab CI для подготовки артефактов перед Terraform.

## `build_backend.sh`

Собирает backend-образ и публикует его в Yandex Container Registry.

Переменные окружения (обязательные):

| Переменная        | Описание |
|-------------------|----------|
| `REGISTRY_ID`     | ID Container Registry (например, `crp50gpc30l3tbd4rtj0`). |
| `IMAGE_TAG`       | Тег образа (`latest`, `dev`, `$CI_COMMIT_SHORT_SHA`). |
| `YC_OAUTH_TOKEN`  | OAuth/IAM токен, полученный через `yc iam create-token`. |

Пример локального запуска:

```bash
export REGISTRY_ID=crp50gpc30l3tbd4rtj0
export IMAGE_TAG=dev
export YC_OAUTH_TOKEN=$(yc iam create-token)
./CI/build_backend.sh
```

В GitLab CI добавьте переменные `REGISTRY_ID`, `YC_OAUTH_TOKEN`, при необходимости `IMAGE_TAG` (по умолчанию можно использовать `CI_COMMIT_SHORT_SHA`).

## `build_frontend.sh`

Собирает React/Vite фронтенд и выгружает готовый `dist/` в Object Storage (Yandex S3).

Переменные окружения (обязательные):

| Переменная              | Описание |
|-------------------------|----------|
| `STATIC_BUCKET_NAME`    | Имя бакета (например, `kulibin-devops-portfolio`). |
| `API_GATEWAY_ENDPOINT`  | URL API Gateway, который будет подставлен в `VITE_API_BASE_URL`. |
| `AWS_ACCESS_KEY_ID`     | Access key для Object Storage (из Terraform output). |
| `AWS_SECRET_ACCESS_KEY` | Secret key для Object Storage (из Terraform output). |

Пример запуска:

```bash
export STATIC_BUCKET_NAME=kulibin-devops-portfolio
export API_GATEWAY_ENDPOINT=https://d5dm4d9170q82do7f5m8.lievo6ut.apigw.yandexcloud.net
export AWS_ACCESS_KEY_ID=$(terraform -chdir=infrastructure/serverless output -raw static_site_access_key)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=infrastructure/serverless output -raw static_site_secret_key)
./CI/build_frontend.sh
```

В CI добавьте соответствующие переменные в настройках проекта (секреты). Скрипт выполняет `npm ci`, `npm run build` и `yc storage s3 sync dist/ ...`.

