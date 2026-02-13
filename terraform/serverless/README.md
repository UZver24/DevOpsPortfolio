# Serverless Containers (Yandex Cloud) — деплой через Terraform в 2 этапа

Этот вариант развёртывания разделён на два Terraform-этапа:
- `bootstrap/` — базовая инфраструктура (Container Registry, IAM, Object Storage)
- `deploy/` — приложение (backend container, API Gateway, опционально frontend container)

Такой split нужен, чтобы сначала создать реестр и права, затем собрать/запушить образ backend и только потом деплоить контейнер.

## Что где лежит
- `terraform/serverless/bootstrap` — Terraform этап 1
- `terraform/serverless/deploy` — Terraform этап 2
- `terraform/serverless/terraform.tfvars` — общий var-file для обоих этапов
- `scripts/serverless-*.sh` — автоматизация шагов
- `.vscode/tasks.json` — задачи для запуска по шагам и end-to-end

## Предварительные требования
- Установлены: `yc`, `terraform`, `docker`, `npm`
- Выполнен `yc init`
- В `terraform/serverless/terraform.tfvars` заполнены минимум:
  - `yc_cloud_id`, `yc_folder_id`, `static_bucket_name`

Токен `yc_token` обновляется скриптом автоматически.

## Шаги вручную (CLI)
1. Подготовить tfvars (токен/дефолты):
```bash
./scripts/serverless-prepare-tfvars.sh
```

2. Bootstrap apply:
```bash
terraform -chdir=terraform/serverless/bootstrap init
terraform -chdir=terraform/serverless/bootstrap apply -var-file=../terraform.tfvars
```

3. Сборка и push backend image в созданный registry:
```bash
./scripts/serverless-build-push-backend.sh
```

4. Deploy apply:
```bash
terraform -chdir=terraform/serverless/deploy init
terraform -chdir=terraform/serverless/deploy apply -var-file=../terraform.tfvars
```

5. Сборка фронтенда с API Gateway URL:
```bash
./scripts/serverless-build-frontend.sh
```

6. Загрузка `dist` в Object Storage:
```bash
./scripts/serverless-upload-frontend.sh
```

## Один запуск всего пайплайна
```bash
./scripts/serverless-full-deploy.sh
```

## Полное удаление ресурсов (для проверки с нуля)
```bash
./scripts/serverless-destroy-all.sh
```

Destroy идёт в правильном порядке: сначала `deploy`, потом `bootstrap`.

## Проверка outputs
```bash
terraform -chdir=terraform/serverless/bootstrap output
terraform -chdir=terraform/serverless/deploy output
```
