variable "yc_token" {
  description = "IAM token for Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Yandex availability zone"
  type        = string
}

variable "project_name" {
  description = "Project prefix for resource names"
  type        = string
  default     = "devops-portfolio-serverless"
}

variable "container_registry_name" {
  description = "Name of Yandex Container Registry"
  type        = string
  default     = "kulibin-devops-portfolio"
}

variable "backend_image_tag" {
  description = "Backend image tag used for build/push/deploy"
  type        = string
  default     = "latest"
}

variable "static_bucket_name" {
  description = "Object Storage bucket for static frontend"
  type        = string
}

variable "static_default_storage_class" {
  description = "Storage class (standard/cold/ice)"
  type        = string
  default     = "standard"
}

variable "static_max_size" {
  description = "Bucket max size in bytes"
  type        = number
  default     = 0
}

variable "static_index_document" {
  description = "Index page"
  type        = string
  default     = "index.html"
}

variable "static_error_document" {
  description = "Error page"
  type        = string
  default     = "index.html"
}

variable "static_allowed_origins" {
  description = "Allowed CORS origins for static bucket"
  type        = list(string)
  default     = ["*"]
}
