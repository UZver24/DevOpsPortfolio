# main.tf — Локальная инфраструктура с minikube

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Провайдер для локальных файлов
provider "local" {}

# Проверка и удаление существующего minikube кластера
resource "null_resource" "minikube_delete" {
  triggers = {
    cluster_name = var.minikube_cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      if minikube status -p ${var.minikube_cluster_name} >/dev/null 2>&1; then
        echo "Удаление существующего minikube кластера: ${var.minikube_cluster_name}"
        minikube delete -p ${var.minikube_cluster_name} || true
      else
        echo "Minikube кластер ${var.minikube_cluster_name} не найден, пропускаем удаление"
      fi
    EOT
  }
}

# Создание minikube кластера с Docker драйвером
resource "null_resource" "minikube_start" {
  depends_on = [null_resource.minikube_delete]

  triggers = {
    cluster_name     = var.minikube_cluster_name
    driver           = var.minikube_driver
    cpus             = var.minikube_cpus
    memory           = var.minikube_memory
    disk_size        = var.minikube_disk_size
    kubernetes_version = var.minikube_kubernetes_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Создание minikube кластера: ${var.minikube_cluster_name}"
      minikube start \
        -p ${var.minikube_cluster_name} \
        --driver=${var.minikube_driver} \
        --cpus=${var.minikube_cpus} \
        --memory=${var.minikube_memory} \
        --disk-size=${var.minikube_disk_size} \
        --kubernetes-version=${var.minikube_kubernetes_version} \
        --wait=all \
        --wait-timeout=10m
      
      echo "Настройка Docker окружения для minikube"
      minikube -p ${var.minikube_cluster_name} docker-env > /dev/null 2>&1 || true
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Удаление minikube кластера: ${self.triggers.cluster_name}"
      minikube delete -p ${self.triggers.cluster_name} || true
    EOT
  }
}

# Создание инфофайла с информацией о minikube
resource "local_file" "info" {
  depends_on = [null_resource.minikube_start]

  filename = "${path.module}/info.txt"
  content  = <<-EOT
Учебный проект: локальная инфраструктура с minikube.

Minikube кластер:
  Имя: ${var.minikube_cluster_name}
  Драйвер: ${var.minikube_driver}
  CPU: ${var.minikube_cpus}
  Память: ${var.minikube_memory}
  Диск: ${var.minikube_disk_size}
  Kubernetes версия: ${var.minikube_kubernetes_version}

Для использования kubectl:
  minikube kubectl -- -p ${var.minikube_cluster_name} get nodes

Для доступа к Docker образам minikube:
  eval $(minikube -p ${var.minikube_cluster_name} docker-env)
  EOT
}
