# variables.tf — переменные для провайдера Yandex Cloud

variable "project_name" {
  description = "Имя проекта для ресурсов VPC и других тегов"
  type        = string
  default     = "devops-portfolio-cloud"
}

variable "yc_token" {
  description = "IAM-токен сервисного аккаунта Яндекс.Облака. Получить командой 'yc iam create-token'."
  type        = string
  sensitive   = true
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

variable "yc_sa_id" {
  description = "ID сервисного аккаунта с необходимыми правами для кластера и узлов."
  type        = string
}

variable "worker_platform_id" {
  description = "Тип VM для нод k8s (например, 'standard-v3')."
  type        = string
  default     = "standard-v2"
}

variable "worker_memory_gb" {
  description = "Оперативная память VM-воркера, в GB (минимум 2, лучше 4+)"
  type        = number
  default     = 2
}

variable "worker_cores" {
  description = "Кол-во vCPU на VM-воркере (минимум 2 для нормального старта)"
  type        = number
  default     = 2
}

variable "worker_disk_gb" {
  description = "Размер boot-диска воркера, GB (лучше минимум 20)"
  type        = number
  default     = 20
}

variable "worker_node_count" {
  description = "Кол-во рабочих нод в пуле (для MVP достаточно 1-2; можно масштабировать позже)"
  type        = number
  default     = 1
}
