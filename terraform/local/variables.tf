# variables.tf — определение переменных

variable "project_name" {
  description = "Название проекта для теста локального Terraform."
  type        = string
  default     = "devops-portfolio-local"
}

variable "minikube_cluster_name" {
  description = "Имя minikube кластера"
  type        = string
  default     = "devops-portfolio"
}

variable "minikube_driver" {
  description = "Драйвер для minikube (docker, virtualbox, kvm2 и т.д.)"
  type        = string
  default     = "docker"
}

variable "minikube_cpus" {
  description = "Количество CPU для minikube"
  type        = number
  default     = 2
}

variable "minikube_memory" {
  description = "Количество памяти для minikube (например, '2048mb')"
  type        = string
  default     = "2048mb"
}

variable "minikube_disk_size" {
  description = "Размер диска для minikube (например, '20g')"
  type        = string
  default     = "20g"
}

variable "minikube_kubernetes_version" {
  description = "Версия Kubernetes для minikube"
  type        = string
  default     = "stable"
}
