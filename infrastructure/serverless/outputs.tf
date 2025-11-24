output "backend_url" {
  value = yandex_serverless_container.backend.url
  description = "Публичный endpoint backend serverless container"
}

output "frontend_url" {
  value = yandex_serverless_container.frontend.url
  description = "Публичный endpoint frontend (React) serverless container"
}


