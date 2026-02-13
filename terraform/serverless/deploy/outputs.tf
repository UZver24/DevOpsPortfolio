output "backend_url" {
  value       = yandex_serverless_container.backend.url
  description = "Public endpoint of backend serverless container"
}

output "frontend_url" {
  value       = var.enable_frontend_container ? yandex_serverless_container.frontend[0].url : null
  description = "Public endpoint of frontend serverless container"
}

output "api_gateway_endpoint" {
  value       = var.create_api_gateway ? "https://${yandex_api_gateway.backend[0].domain}" : null
  description = "Public API Gateway endpoint"
}
