# outputs.tf — выходные значения

output "info_file_path" {
  description = "Путь к файлу info.txt, сгенерированному Terraform."
  value       = local_file.info.filename
}

output "project_name" {
  description = "Название локального проекта из переменной."
  value       = var.project_name
}

output "minikube_cluster_name" {
  description = "Имя созданного minikube кластера"
  value       = var.minikube_cluster_name
}

output "minikube_status_command" {
  description = "Команда для проверки статуса minikube"
  value       = "minikube status -p ${var.minikube_cluster_name}"
}

output "kubectl_command" {
  description = "Команда для использования kubectl с minikube"
  value       = "minikube kubectl -- -p ${var.minikube_cluster_name}"
}

output "docker_env_command" {
  description = "Команда для настройки Docker окружения minikube"
  value       = "eval $(minikube -p ${var.minikube_cluster_name} docker-env)"
}
