# outputs.tf — выходные параметры инфраструктуры Yandex Cloud

output "k8s_cluster_id" {
  value       = yandex_kubernetes_cluster.main.id
  description = "ID созданного Kubernetes-кластера (используется в yc managed-kubernetes cluster get-credentials)"
}

output "k8s_cluster_name" {
  value       = yandex_kubernetes_cluster.main.name
  description = "Имя созданного Kubernetes-кластера (альтернатива для выгрузки kubeconfig)"
}
