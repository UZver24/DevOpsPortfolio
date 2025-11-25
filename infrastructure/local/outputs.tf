# outputs.tf — выходные значения

output "info_file_path" {
  description = "Путь к файлу info.txt, сгенерированному Terraform."
  value       = local_file.info.filename
}

output "project_name" {
  description = "Название локального проекта из переменной."
  value       = var.project_name
}
