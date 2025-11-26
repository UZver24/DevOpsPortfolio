# Terraform (локальная инфраструктура)

> **Важно!**
> Из-за санкций, официальный реестр плагинов Terraform ([registry.terraform.io](https://registry.terraform.io/)) недоступен. Рабочее решение — использовать зеркала, как описано в статье: [Разворачиваем без боли Terraform в Яндекс облаке (Habr)](https://habr.com/ru/companies/otus/articles/957982/)
>
> **Для этого настройте файл `~/.terraformrc` (в домашней папке):**
>
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
>
> Это позволит Terraform скачивать плагины через российское зеркало и обойти блокировки.

Данный каталог содержит инфраструктурный код Terraform для автоматизации локального развёртывания учебного проекта с minikube.

## Зачем это нужно
- Автоматизация создания minikube кластера для локальной разработки
- Автоматическое удаление существующего кластера перед созданием нового
- Возможность воспроизвести инфраструктуру проекта на новой локальной машине

## Что делает Terraform
- **Проверяет и удаляет** существующий minikube кластер (если он уже запущен)
- **Создаёт новый minikube кластер** с Docker драйвером
- **Настраивает** необходимые ресурсы (CPU, память, диск)
- **Генерирует** информационный файл с инструкциями по использованию

## Основные файлы
- `main.tf` — основной инфраструктурный код
- `variables.tf` — описание переменных
- `outputs.tf` — выходные параметры (например, IP-адреса, пути к kubeconfig)

## Требования
- Установленный [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Установленный [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Установленный Docker (для драйвера docker)
- Настроенный файл `~/.terraformrc` (см. выше), если вы видите ошибку про registry.terraform.io!

## Как использовать
1. Зайти в каталог `terraform/local`
2. Инициализировать проект:
   ```bash
   terraform init
   ```
3. (Опционально) Настроить переменные в `terraform.tfvars` или через флаги:
   ```bash
   terraform apply -var="minikube_cpus=4" -var="minikube_memory=4096mb"
   ```
4. Просмотреть план изменений:
   ```bash
   terraform plan
   ```
5. Применить инфраструктуру (создаст/пересоздаст minikube):
   ```bash
   terraform apply
   ```
6. После успешного создания используйте выводы Terraform:
   ```bash
   # Проверка статуса
   minikube status -p devops-portfolio
   
   # Использование kubectl
   minikube kubectl -- -p devops-portfolio get nodes
   
   # Настройка Docker окружения для сборки образов
   eval $(minikube -p devops-portfolio docker-env)
   ```

## Переменные
- `minikube_cluster_name` (по умолчанию: `devops-portfolio`) — имя кластера
- `minikube_driver` (по умолчанию: `docker`) — драйвер minikube
- `minikube_cpus` (по умолчанию: `2`) — количество CPU
- `minikube_memory` (по умолчанию: `2048mb`) — объем памяти
- `minikube_disk_size` (по умолчанию: `20g`) — размер диска
- `minikube_kubernetes_version` (по умолчанию: `stable`) — версия Kubernetes

## Удаление инфраструктуры
```bash
terraform destroy
```
Это удалит minikube кластер и все связанные ресурсы.

---

> **Внимание!** Данный каталог и все его файлы относятся только к локальному варианту. Для облачных сценариев будет отдельная структура.
