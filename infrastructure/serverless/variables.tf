variable "yc_token" {
  description = "IAM-токен для доступа к Yandex Cloud. Получить через 'yc iam create-token'."
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "ID облака (cloud_id). См. 'yc config list'."
  type        = string
}

variable "yc_folder_id" {
  description = "ID каталога (folder_id). См. 'yc config list'."
  type        = string
}

variable "yc_zone" {
  description = "Зона размещения ресурсов, например ru-central1-a."
  type        = string
}

variable "project_name" {
  description = "Идентификатор проекта для тегов/имен."
  type        = string
  default     = "devops-portfolio-serverless"
}

variable "backend_image" {
  description = "Публичный URL docker-образа backend-API (например, из Yandex Container Registry)"
  type        = string
}

variable "backend_memory_mb" {
  description = "ОЗУ backend, МБ (минимум 128, практично 256-512)"
  type        = number
  default     = 256
}

variable "backend_cpu" {
  description = "CPU backend, в ядрах (например 0.05, 0.1, 0.25, 1)"
  type        = number
  default     = 0.1
}

variable "backend_concurrency" {
  description = "Максимум одновременных запросов (чем выше — тем выше instant потребление ресурсов)"
  type        = number
  default     = 8
}

variable "backend_env" {
  description = "Переменные окружения для backend (map, можно пустой)"
  type        = map(string)
  default     = {}
}

variable "frontend_image" {
  description = "Публичный URL docker-образа фронтенда (например, из Yandex Container Registry)"
  type        = string
}

variable "frontend_memory_mb" {
  description = "ОЗУ frontend, МБ (128-512 обычно достаточно)"
  type        = number
  default     = 128
}

variable "frontend_cpu" {
  description = "CPU frontend, в ядрах (например 0.05, 0.1, 0.25, 1)"
  type        = number
  default     = 0.05
}

variable "frontend_concurrency" {
  description = "Максимум одновременных запросов (для фронта обычно хватает 4-16)"
  type        = number
  default     = 8
}

variable "frontend_env" {
  description = "Переменные окружения для frontend (map, можно пустой)"
  type        = map(string)
  default     = {}
}

variable "container_registry_id" {
  description = "ID реестра образов (например crp50gpc30l3tbd4rtj0)."
  type        = string
}


