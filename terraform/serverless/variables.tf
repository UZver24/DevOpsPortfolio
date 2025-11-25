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

variable "environment" {
  description = "Окружение (dev/stage/prod) для тегов."
  type        = string
  default     = "dev"
}

variable "extra_labels" {
  description = "Дополнительные теги для ресурсов."
  type        = map(string)
  default     = {}
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

variable "enable_frontend_container" {
  description = "Включить ли развёртывание frontend как serverless контейнера (по умолчанию используем Object Storage)."
  type        = bool
  default     = false
}

variable "container_registry_id" {
  description = "ID реестра образов (например crp50gpc30l3tbd4rtj0)."
  type        = string
}

variable "static_bucket_name" {
  description = "Имя бакета для статического фронтенда (должно быть уникальным)."
  type        = string
}

variable "static_default_storage_class" {
  description = "Класс хранения (standard / cold / ice)."
  type        = string
  default     = "standard"
}

variable "static_max_size" {
  description = "Максимальный размер бакета в байтах (0 = без ограничений)."
  type        = number
  default     = 0
}

variable "static_index_document" {
  description = "Главная страница статического сайта."
  type        = string
  default     = "index.html"
}

variable "static_error_document" {
  description = "Страница ошибки (для SPA можно оставить index.html)."
  type        = string
  default     = "index.html"
}

variable "static_allowed_origins" {
  description = "Разрешённые домены (CORS) для доступа к статике."
  type        = list(string)
  default     = ["*"]
}

variable "api_allowed_origins" {
  description = "Origin'ы, которым API Gateway разрешает доступ."
  type        = list(string)
  default     = ["https://example.website.yandexcloud.net", "http://localhost:3000", "http://localhost:5173"]
}

variable "create_api_gateway" {
  description = "Создавать ли API Gateway (false если уже существует и не поддерживает импорт). TODO: ТРЕБУЕТСЯ ПРАВКА - автоматическое обнаружение существующего API Gateway."
  type        = bool
  default     = true
}


