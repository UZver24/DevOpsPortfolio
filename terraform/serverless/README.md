# Serverless Containers (Yandex Cloud) — деплой приложения через Terraform

В этом разделе описан альтернативный, экономичный вариант деплоя приложения с помощью Yandex Serverless Containers (YSC). Такой подход отлично подходит для MVP, тестовых и учебных задач, когда запуск полноценного кластера Kubernetes не нужен (или слишком дорог).

## Преимущества Serverless Containers:
- Платишь только за реально потраченные ресурсы (CPU, RAM, время работы), нет постоянных VM или node pool
- Нет необходимости управлять Kubernetes, ingress, VM и прочей инфраструктурой
- Всё работает “из коробки”, доступ по HTTP(S), логирование, переменные окружения, автошкалирование
- Простая интеграция с Yandex Container Registry и Object Storage

## Минусы (по сравнению с K8s):
- Меньше гибкости и меньше “тонких” возможностей для сложных и Stateful-сервисов
- Нет постоянного pod’а (только обработка http-запросов/триггеров)

---

## Сравнение с вариантом “Managed Service for Kubernetes”
- K8s-подход требует целого кластера, что стоит больше 1000 ₽/мес (даже минимум), и требует отдельной настройки ingress/CI/CD
- Вариант serverless не требует VM, оплачивается по-микросекундам, идеально для development, прототипирования, портфолио
- K8s-манифесты и инфраструктура тут НЕ реализованы (разрабатывается отдельно; подробнее см. папку `cloudK8/` и README там)

---

## Предварительные требования
- Установлены `yc`, `terraform`, `docker`
- В облаке создан отдельный каталог/проект, в котором есть доступ на запись в Container Registry
- Есть IAM-токен сервисного аккаунта или пользователя для Terraform (`yc iam create-token`)

## Пошаговая инструкция

1. **Соберите Docker-образ backend**
   ```bash
   docker build -t backend:latest ../../backend
   ```
2. **Создайте (или возьмите существующий) реестр YCR и запушьте образ**
   ```bash
   yc container registry create --name devops-portfolio   # при отсутствии
   yc iam create-token | docker login --username oauth --password-stdin cr.yandex
   docker tag backend:latest  cr.yandex/<registry_id>/backend:latest
   docker push cr.yandex/<registry_id>/backend:latest
   ```
3. **Заполните `terraform/serverless/terraform.tfvars`**
   ```hcl
   yc_token      = "..."         # yc iam create-token
   yc_cloud_id   = "..."         # yc config list
   yc_folder_id  = "..."
   yc_zone       = "ru-central1-a"
   environment   = "dev"

   backend_image         = "cr.yandex/<registry_id>/backend:latest"
   container_registry_id = "<registry_id>"

   static_bucket_name = "kulibin-devops-portfolio"
   static_allowed_origins = ["https://kulibin-devops-portfolio.website.yandexcloud.net"]
   api_allowed_origins    = ["https://kulibin-devops-portfolio.website.yandexcloud.net"]
   ```
   `enable_frontend_container = false` — фронтенд отдаём из Object Storage. В дальнейшем можно включить контейнер, если потребуется.
4. **Примените Terraform**
   ```bash
   cd terraform/serverless
   terraform init
   terraform apply
   ```
   Конфигурация создаст:
   - serverless container для backend;
   - Object Storage + ключи для выкладки статики;
   - API Gateway, который проксирует запросы на backend.
5. **Соберите и загрузите фронтенд**
   ```bash
   export API_URL=$(terraform output -raw api_gateway_endpoint)
   cd ../../src/frontend
   VITE_API_BASE_URL=$API_URL npm run build

   cd ../..
   export AWS_ACCESS_KEY_ID=$(terraform -chdir=terraform/serverless output -raw static_site_access_key)
   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=terraform/serverless output -raw static_site_secret_key)
   yc storage s3 cp --recursive src/frontend/dist/ s3://$(terraform -chdir=terraform/serverless output -raw static_bucket_name)
   ```
6. **Проверьте URLs**
   - `terraform output backend_url` — прямой доступ к контейнеру (для отладки).
   - `terraform output api_gateway_endpoint` — адрес API, на который ходит фронт.
   - `terraform output static_site_endpoint` — адрес статического сайта (`https://<bucket>.website.yandexcloud.net`).

> Сборка и публикация сейчас выполняются вручную. Позже можно автоматизировать их в CI/CD, чтобы push образа/статического билда автоматически триггерил Terraform или `yc` скрипты.

---

## Документация и полезные ссылки
- [Yandex Serverless Containers, документация](https://cloud.yandex.ru/docs/containers)
- [Тарифы Serverless Containers](https://cloud.yandex.ru/prices/serverless-containers)
- [Terraform Yandex Provider, ресурс yandex_serverless_container](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/serverless_container)

---

> Это самый экономичный, простой и “cloud native” способ деплоя небольших сервисов с оплатой именно за полезную нагрузку.


