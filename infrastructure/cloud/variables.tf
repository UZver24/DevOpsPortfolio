# variables.tf — переменные для провайдера Yandex Cloud

variable "yc_token" {
  description = "IAM-токен сервисного аккаунта Яндекс.Облака. Получить командой 'yc iam create-token'."
  type        = string
}

variable "yc_cloud_id" {
  description = "ID облака (cloud_id). Получить командой 'yc config list'."
  type        = string
}

variable "yc_folder_id" {
  description = "ID каталога (folder_id) в Яндекс.Облаке. Получить командой 'yc config list'."
  type        = string
}

variable "yc_zone" {
  description = "Зона размещения ресурсов (например, ru-central1-a)."
  type        = string
}
