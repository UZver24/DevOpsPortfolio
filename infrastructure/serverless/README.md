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
- K8s-манифесты и инфраструктура тут НЕ реализованы (разрабатывается отдельно; подробнее см. папку cloud/ и README там)

---

## Предварительные требования
- Установлены `yc`, `terraform`, `docker`
- В облаке создан отдельный каталог/проект, в котором есть доступ на запись в Container Registry
- Есть IAM-токен сервисного аккаунта или пользователя для Terraform (`yc iam create-token`)

## Пошаговая инструкция

1. **Соберите Docker-образы**
   ```bash
   docker build -t backend:latest ../../backend
   docker build -t frontend:latest ../../frontend
   ```
2. **Создайте (или возьмите существующий) реестр YCR**
   ```bash
   yc container registry create --name devops-portfolio
   yc container registry list  # чтобы узнать <registry_id>
   ```
3. **Залогиньтесь в реестр и запушьте образы**
   ```bash
   yc iam create-token | docker login --username oauth --password-stdin cr.yandex
   docker tag backend:latest  cr.yandex/<registry_id>/backend:latest
   docker tag frontend:latest cr.yandex/<registry_id>/frontend:latest
   docker push cr.yandex/<registry_id>/backend:latest
   docker push cr.yandex/<registry_id>/frontend:latest
   ```
4. **Заполните `infrastructure/serverless/terraform.tfvars`**
   ```hcl
   yc_token              = "..."            # результат yc iam create-token
   yc_cloud_id           = "..."            # yc config list
   yc_folder_id          = "..."
   yc_zone               = "ru-central1-a"
   backend_image         = "cr.yandex/<registry_id>/backend:latest"
   frontend_image        = "cr.yandex/<registry_id>/frontend:latest"
   container_registry_id = "<registry_id>"  # нужен для выдачи роли puller
   ```
   При необходимости добавьте карты `backend_env` / `frontend_env` в `terraform.tfvars`.
5. **Примените Terraform**
   ```bash
   cd infrastructure/serverless
   terraform init
   terraform apply
   ```
   Скрипт создаст сервисный аккаунт, выдаст нужные IAM-ролли и опубликует два Serverless Container.
6. **Получите публичные URL** — Terraform выведет `backend_url` и `frontend_url`. Проверьте их вручную, чтобы убедиться, что приложение отвечает.

> Сборка и публикация образов сейчас выполняются вручную (см. шаги 1‑3). Позже можно автоматизировать их через CI/CD (GitHub Actions, GitLab, Yandex Cloud Builder и т.д.), но для MVP это не обязательно.

---

## Документация и полезные ссылки
- [Yandex Serverless Containers, документация](https://cloud.yandex.ru/docs/containers)
- [Тарифы Serverless Containers](https://cloud.yandex.ru/prices/serverless-containers)
- [Terraform Yandex Provider, ресурс yandex_serverless_container](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/serverless_container)

---

> Это самый экономичный, простой и “cloud native” способ деплоя небольших сервисов с оплатой именно за полезную нагрузку.


