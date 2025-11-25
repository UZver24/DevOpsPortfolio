output "backend_url" {
  value = yandex_serverless_container.backend.url
  description = "Публичный endpoint backend serverless container"
}

output "frontend_url" {
  value       = var.enable_frontend_container ? yandex_serverless_container.frontend[0].url : null
  description = "Публичный endpoint frontend-контейнера (если включён)"
}

output "static_bucket_name" {
  value       = yandex_storage_bucket.static_site.bucket
  description = "Имя бакета со статическим фронтом"
}

output "static_site_endpoint" {
  value       = "https://${yandex_storage_bucket.static_site.bucket}.website.yandexcloud.net"
  description = "URL статического сайта"
}

output "static_site_access_key" {
  value       = yandex_iam_service_account_static_access_key.static_site.access_key
  description = "Access key для загрузки файлов в бакет"
}

output "static_site_secret_key" {
  value       = yandex_iam_service_account_static_access_key.static_site.secret_key
  description = "Secret key для загрузки файлов (храните в секрете)"
  sensitive   = true
}

output "api_gateway_endpoint" {
  value       = var.create_api_gateway ? "https://${yandex_api_gateway.backend[0].domain}" : null
  description = "Публичный endpoint API Gateway (null если не создан, так как уже существует)"
}


