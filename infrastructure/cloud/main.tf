# main.tf — настройка подключения к облаку Yandex Cloud через Terraform

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
}

provider "yandex" {
  token     = var.yc_token      # IAM-токен сервисного аккаунта
  cloud_id  = var.yc_cloud_id   # b1g5h4qcn4qvf54hber1
  folder_id = var.yc_folder_id  # b1g5h63h4jh5ju7f4ecs
  zone      = var.yc_zone       # Зона размещения ресурсов (например, ru-central1-a)
}

# -------------------------------------
# Создаём VPC (виртуальную облачную сеть)
# -------------------------------------
resource "yandex_vpc_network" "main" {
  name = "${var.project_name}-vpc"
}

# -----------------------------------------------------------
# Создаём публичную подсеть в выбранной зоне (например, ru-central1-a)
# CIDR блок 10.10.0.0/24 — пример, можешь изменить под себя
# -----------------------------------------------------------
resource "yandex_vpc_subnet" "public" {
  name           = "${var.project_name}-subnet-public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

# -----------------------------------------------------------
# Security group: разрешим SSH (22), HTTP (80), HTTPS (443) для всех
# -----------------------------------------------------------
resource "yandex_vpc_security_group" "main" {
  name       = "${var.project_name}-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol            = "TCP"
    description         = "Allow SSH from anywhere"
    port                = 22
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol            = "TCP"
    description         = "Allow HTTP from anywhere"
    port                = 80
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol            = "TCP"
    description         = "Allow HTTPS from anywhere"
    port                = 443
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  # Разрешить все исходящие соединения (иначе поды не выйдут в интернет)
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------
# Автоматическое создание сервисного аккаунта для управления кластером
# -----------------------------------------------------------
resource "yandex_iam_service_account" "k8s" {
  name        = "${var.project_name}-k8s-sa"
  description = "Service Account для управления Managed Kubernetes Cluster и worker-нодами"
}

# Назначение ролей сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "k8s_admin" {
  folder_id = var.yc_folder_id
  role      = "k8s.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "container_registry_editor" {
  folder_id = var.yc_folder_id
  role      = "container-registry.editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}

# -----------------------------------------------------------
# Создаём Managed Kubernetes Cluster используя новый сервисный аккаунт
# -----------------------------------------------------------
resource "yandex_kubernetes_cluster" "main" {
  name        = "${var.project_name}-yk8s"
  network_id  = yandex_vpc_network.main.id
  master {
    public_ip = true
    subnet_ids = [yandex_vpc_subnet.public.id]
    security_group_ids = [yandex_vpc_security_group.main.id]
  }
  service_account_id      = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s.id
  release_channel         = "STABLE"
}

# -----------------------------------------------------------
# Worker node group как раньше (использует тот же SA)
# -----------------------------------------------------------
resource "yandex_kubernetes_node_group" "ng1" {
  cluster_id = yandex_kubernetes_cluster.main.id
  name       = "${var.project_name}-nodes"
  instance_template {
    platform_id = var.worker_platform_id
    resources {
      memory = var.worker_memory_gb
      cores  = var.worker_cores
    }
    boot_disk {
      size = var.worker_disk_gb
      type = "network-ssd"
    }
    network_interface {
      nat = true
      subnet_ids = [yandex_vpc_subnet.public.id]
      security_group_ids = [yandex_vpc_security_group.main.id]
    }
    scheduling_policy {
      preemptible = true
    }
  }
  scale_policy {
    fixed_scale {
      size = var.worker_node_count
    }
  }
  allocation_policy {
    location {
      zone = var.yc_zone
    }
  }
  version = "1.29"
}
