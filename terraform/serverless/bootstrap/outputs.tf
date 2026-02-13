output "container_registry_id" {
  value       = yandex_container_registry.main.id
  description = "Yandex Container Registry ID"
}

output "backend_image" {
  value       = "cr.yandex/${yandex_container_registry.main.id}/backend:${var.backend_image_tag}"
  description = "Canonical backend image URL"
}

output "serverless_service_account_id" {
  value       = yandex_iam_service_account.serverless.id
  description = "Service account id for serverless containers"
}

output "static_bucket_name" {
  value       = yandex_storage_bucket.static_site.bucket
  description = "Bucket for frontend static files"
}

output "static_site_endpoint" {
  value       = "https://${yandex_storage_bucket.static_site.bucket}.website.yandexcloud.net"
  description = "Static site endpoint"
}

output "static_site_access_key" {
  value       = yandex_iam_service_account_static_access_key.static_site.access_key
  description = "S3 access key for frontend upload"
  sensitive   = true
}

output "static_site_secret_key" {
  value       = yandex_iam_service_account_static_access_key.static_site.secret_key
  description = "S3 secret key for frontend upload"
  sensitive   = true
}
