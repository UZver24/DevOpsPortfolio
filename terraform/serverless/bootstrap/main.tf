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

resource "yandex_container_registry" "main" {
  name = var.container_registry_name
}

resource "yandex_iam_service_account" "serverless" {
  name        = "${var.project_name}-serverless-sa"
  description = "Used by serverless containers"
}

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
  registry_id = yandex_container_registry.main.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.serverless.id}"
  ]
}

resource "yandex_iam_service_account" "static_site" {
  name        = "${var.project_name}-static-site"
  description = "Used to publish frontend to Object Storage"
}

resource "yandex_resourcemanager_folder_iam_member" "static_site_storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.static_site.id}"
}

resource "yandex_iam_service_account_static_access_key" "static_site" {
  service_account_id = yandex_iam_service_account.static_site.id
  description        = "Static key for frontend upload"
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
