# variables.tf — определение переменных

variable "project_name" {
  description = "Название проекта для теста локального Terraform."
  type        = string
  default     = "devops-portfolio-local"
}
