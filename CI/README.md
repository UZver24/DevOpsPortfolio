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

