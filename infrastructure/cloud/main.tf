# main.tf — настройка подключения к облаку Yandex Cloud через Terraform

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
}

provider "yandex" {
  token     = var.yc_token      # IAM-токен сервисного аккаунта
  cloud_id  = var.yc_cloud_id   # ID облака
  folder_id = var.yc_folder_id  # ID каталога
  zone      = var.yc_zone       # Зона размещения ресурсов (например, ru-central1-a)
}
