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

data "terraform_remote_state" "bootstrap" {
  backend = "local"
  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

locals {
  backend_cores           = var.backend_cpu >= 1 ? floor(var.backend_cpu) : 1
  backend_core_fraction   = var.backend_cpu >= 1 ? 100 : floor(var.backend_cpu * 100 + 0.5)
  frontend_cores          = var.frontend_cpu >= 1 ? floor(var.frontend_cpu) : 1
  frontend_core_fraction  = var.frontend_cpu >= 1 ? 100 : floor(var.frontend_cpu * 100 + 0.5)
  backend_image_from_boot = data.terraform_remote_state.bootstrap.outputs.backend_image
  default_labels = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.extra_labels,
  )
}

resource "yandex_serverless_container" "backend" {
  name              = "${var.project_name}-backend"
  description       = "Backend FastAPI server (deployed as Serverless Container)"
  memory            = var.backend_memory_mb
  cores             = local.backend_cores
  core_fraction     = local.backend_core_fraction
  concurrency       = var.backend_concurrency
  execution_timeout = "30s"

  image {
    url         = local.backend_image_from_boot
    environment = var.backend_env
  }

  runtime {
    type = "http"
  }

  service_account_id = data.terraform_remote_state.bootstrap.outputs.serverless_service_account_id
}

resource "yandex_serverless_container" "frontend" {
  count = var.enable_frontend_container ? 1 : 0

  name              = "${var.project_name}-frontend"
  description       = "Frontend React server (optional, alternative to Object Storage)"
  memory            = var.frontend_memory_mb
  cores             = local.frontend_cores
  core_fraction     = local.frontend_core_fraction
  concurrency       = var.frontend_concurrency
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

  service_account_id = data.terraform_remote_state.bootstrap.outputs.serverless_service_account_id
}

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

resource "yandex_api_gateway" "backend" {
  count = var.create_api_gateway ? 1 : 0

  name        = "${var.project_name}-api"
  description = "HTTP calls to backend serverless container"
  folder_id   = var.yc_folder_id
  labels      = local.default_labels

  spec = templatefile("${path.module}/templates/api-gateway.yaml.tmpl", {
    backend_base_url = trimsuffix(yandex_serverless_container.backend.url, "/")
    allowed_origins  = var.api_allowed_origins
  })
}
