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

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "extra_labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}

variable "backend_memory_mb" {
  description = "Backend memory (MB)"
  type        = number
  default     = 256
}

variable "backend_cpu" {
  description = "Backend CPU cores"
  type        = number
  default     = 0.1

  validation {
    condition     = var.backend_cpu > 0 && var.backend_cpu <= 1
    error_message = "backend_cpu must be in range (0; 1]."
  }
}

variable "backend_concurrency" {
  description = "Backend max concurrent requests"
  type        = number
  default     = 8
}

variable "backend_env" {
  description = "Backend env vars"
  type        = map(string)
  default     = {}
}

variable "frontend_image" {
  description = "Frontend image URL (used only if enable_frontend_container=true)"
  type        = string
  default     = ""
}

variable "frontend_memory_mb" {
  description = "Frontend memory (MB)"
  type        = number
  default     = 128
}

variable "frontend_cpu" {
  description = "Frontend CPU cores"
  type        = number
  default     = 0.05

  validation {
    condition     = var.frontend_cpu > 0 && var.frontend_cpu <= 1
    error_message = "frontend_cpu must be in range (0; 1]."
  }
}

variable "frontend_concurrency" {
  description = "Frontend max concurrent requests"
  type        = number
  default     = 8
}

variable "frontend_env" {
  description = "Frontend env vars"
  type        = map(string)
  default     = {}
}

variable "enable_frontend_container" {
  description = "Deploy frontend as serverless container"
  type        = bool
  default     = false
}

variable "api_allowed_origins" {
  description = "CORS origins for API Gateway"
  type        = list(string)
  default     = ["https://example.website.yandexcloud.net", "http://localhost:3000", "http://localhost:5173"]
}

variable "create_api_gateway" {
  description = "Whether to create API Gateway"
  type        = bool
  default     = true
}
