terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

locals {
  backend_cores          = var.backend_cpu >= 1 ? floor(var.backend_cpu) : 1
  backend_core_fraction  = var.backend_cpu >= 1 ? 100 : var.backend_cpu * 100
  frontend_cores         = var.frontend_cpu >= 1 ? floor(var.frontend_cpu) : 1
  frontend_core_fraction = var.frontend_cpu >= 1 ? 100 : var.frontend_cpu * 100
  default_labels = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.extra_labels,
  )
}

# Сервисный аккаунт для обоих контейнеров
resource "yandex_iam_service_account" "serverless" {
  name        = "${var.project_name}-serverless-sa"
  description = "Используется контейнерами backend/frontend"
}

# Необходимые роли для запуска контейнеров и скачивания образов
resource "yandex_resourcemanager_folder_iam_member" "serverless_admin" {
  folder_id = var.yc_folder_id
  role      = "serverless.containers.admin"
  member    = "serviceAccount:${yandex_iam_service_account.serverless.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "cr_puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.serverless.id}"
}

resource "yandex_container_registry_iam_binding" "registry_puller" {
  registry_id = var.container_registry_id
  role        = "container-registry.images.puller"
  members     = [
    "serviceAccount:${yandex_iam_service_account.serverless.id}"
  ]
}

# Сервисный аккаунт и бакет для статического фронтенда
resource "yandex_iam_service_account" "static_site" {
  name        = "${var.project_name}-static-site"
  description = "Обслуживает Object Storage для статического фронтенда"
}

resource "yandex_resourcemanager_folder_iam_member" "static_site_storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.static_site.id}"
}

resource "yandex_iam_service_account_static_access_key" "static_site" {
  service_account_id = yandex_iam_service_account.static_site.id
  description        = "Статический ключ для загрузки билда фронтенда"
}

resource "yandex_storage_bucket" "static_site" {
  bucket = var.static_bucket_name

  access_key = yandex_iam_service_account_static_access_key.static_site.access_key
  secret_key = yandex_iam_service_account_static_access_key.static_site.secret_key

  default_storage_class = var.static_default_storage_class
  max_size              = var.static_max_size

  website {
    index_document = var.static_index_document
    error_document = var.static_error_document
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.static_allowed_origins
    allowed_headers = ["*"]
    expose_headers  = []
    max_age_seconds = 3600
  }

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = true
  }

  force_destroy = true
}

# --- Backend Serverless Container ---
resource "yandex_serverless_container" "backend" {
  name      = "${var.project_name}-backend"
  description = "Backend FastAPI server (deployed as Serverless Container)"
  memory    = var.backend_memory_mb
  cores         = local.backend_cores
  core_fraction = local.backend_core_fraction
  concurrency = var.backend_concurrency
  execution_timeout = "30s"

  image {
    url         = var.backend_image
    environment = var.backend_env
  }

  runtime {
    type = "http"
  }

  service_account_id = yandex_iam_service_account.serverless.id
}

# --- Frontend Serverless Container ---
resource "yandex_serverless_container" "frontend" {
  count = var.enable_frontend_container ? 1 : 0

  name        = "${var.project_name}-frontend"
  description = "Frontend React-server (опционально, используется вместо Object Storage)"
  memory      = var.frontend_memory_mb
  cores         = local.frontend_cores
  core_fraction = local.frontend_core_fraction
  concurrency   = var.frontend_concurrency
  execution_timeout = "30s"

  image {
    url = var.frontend_image
    environment = merge(
      var.frontend_env,
      {
        API_BASE_URL = trimsuffix(yandex_serverless_container.backend.url, "/")
      }
    )
  }

  runtime {
    type = "http"
  }

  service_account_id = yandex_iam_service_account.serverless.id
}

# Публикуем контейнеры для публичного доступа
resource "yandex_serverless_container_iam_binding" "backend_public" {
  container_id = yandex_serverless_container.backend.id
  role         = "serverless.containers.invoker"
  members      = ["system:allUsers"]
}

resource "yandex_serverless_container_iam_binding" "frontend_public" {
  count = var.enable_frontend_container ? 1 : 0

  container_id = yandex_serverless_container.frontend[0].id
  role         = "serverless.containers.invoker"
  members      = ["system:allUsers"]
}

# API Gateway для backend (используется фронтендом из Object Storage)
resource "yandex_api_gateway" "backend" {
  name        = "${var.project_name}-api"
  description = "HTTP вызовы к backend serverless контейнеру"
  folder_id   = var.yc_folder_id
  labels      = local.default_labels

  spec = templatefile("${path.module}/templates/api-gateway.yaml.tmpl", {
    backend_base_url = trimsuffix(yandex_serverless_container.backend.url, "/")
    allowed_origins  = var.api_allowed_origins
  })
}


