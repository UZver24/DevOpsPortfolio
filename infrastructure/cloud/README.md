# Terraform (облачная инфраструктура, Yandex Cloud)

Этот каталог предназначен для ресурсов, автоматизирующих развёртывание облачной инфраструктуры проекта в Яндекс.Облаке с помощью Terraform.

## Важно о секретных переменных
- Все чувствительные данные (токены, cloud_id, folder_id, zone) хранятся только в отдельном файле `terraform.tfvars`.
- Рабочий файл `terraform.tfvars` ВСЕГДА должен быть в .gitignore (не попадёт в git, см. правила в проекте).
- В репозитории публикуется только шаблон: `terraform.tfvars.example`. Перед работой скопируйте его и заполните:
  ```bash
  cp terraform.tfvars.example terraform.tfvars
  # Далее отредактируйте terraform.tfvars под свои значения
  ```

## Общие цели
- Создание облачного окружения «инфраструктура как код» (IaC)
- Развёртывание сетей, кластеров, машин и сервисов в облаке повторяемым способом

## Используемые источники
- [Разворачиваем без боли Terraform в Яндекс облаке (Habr)](https://habr.com/ru/companies/otus/articles/957982/)

---

## Первый этап — подключение облачного провайдера Terraform (Yandex Cloud)

1. Установите Terraform
2. Добавьте в файл `~/.terraformrc` mirror Яндекс (см. README локального варианта):
   ```
   provider_installation {
     network_mirror {
       url = "https://terraform-mirror.yandexcloud.net/"
       include = ["registry.terraform.io/*/*"]
     }
     direct {
       exclude = ["registry.terraform.io/*/*"]
     }
   }
   ```
3. Пропишите провайдер в `main.tf` (пример ниже)

---

## Пример provider блока для Yandex Cloud
```hcl
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89"  # актуальная версия на момент добавления
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}
```

---

> **Важно:** Не забудьте задокументировать переменные (`variables.tf`) и сохранить `README.md` всегда в актуальном виде!
