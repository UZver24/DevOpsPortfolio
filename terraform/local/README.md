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

## Развертывание приложения через Helm

После создания minikube кластера можно развернуть приложение DevOps Portfolio через Helm chart.

### Предварительные требования

- Установленный [Helm](https://helm.sh/docs/intro/install/)
- Собранные Docker образы приложения (backend и frontend)

### Шаг 1: Подготовка образов

Перед развертыванием необходимо собрать Docker образы и загрузить их в minikube:

```bash
# Вернуться в корень проекта
cd /home/user/yandex/DevOpsPortfolio

# Собрать образы через docker-compose (или вручную)
docker-compose build

# Настроить Docker окружение minikube
eval $(minikube -p devops-portfolio docker-env)

# Загрузить образы в minikube
minikube -p devops-portfolio image load devops-portfolio-backend:latest
minikube -p devops-portfolio image load devops-portfolio-frontend:latest

# Проверить, что образы загружены
eval $(minikube -p devops-portfolio docker-env) && docker images | grep devops-portfolio
```

**Альтернативный способ:** Собрать образы напрямую в контексте minikube Docker:

```bash
# Настроить Docker окружение minikube
eval $(minikube -p devops-portfolio docker-env)

# Собрать образы в контексте minikube
cd src/backend && docker build -t devops-portfolio-backend:latest .
cd ../frontend && docker build -t devops-portfolio-frontend:latest .
```

### Шаг 2: Проверка контекста Kubernetes

Убедитесь, что kubectl настроен на правильный кластер:

```bash
# Проверить текущий контекст
kubectl config current-context

# Должен быть: devops-portfolio

# Если контекст другой, переключиться:
kubectl config use-context devops-portfolio

# Проверить доступность кластера
kubectl get nodes
```

### Шаг 3: Развертывание через Helm

```bash
# Перейти в каталог Helm chart
cd /home/user/yandex/DevOpsPortfolio/helm

# (Опционально) Просмотреть шаблоны перед установкой
helm template devops-portfolio . --debug

# Установить приложение
helm install devops-portfolio . --namespace default --create-namespace

# Проверить статус установки
helm list
kubectl get pods
```

### Шаг 4: Проверка развертывания

```bash
# Проверить статус подов (должны быть в статусе Running и Ready)
kubectl get pods

# Проверить сервисы
kubectl get services

# Проверить логи backend
kubectl logs -l app=backend --tail=10

# Проверить логи frontend
kubectl logs -l app=frontend --tail=10
```

### Шаг 5: Доступ к приложению

```bash
# Получить URL для доступа к frontend
minikube -p devops-portfolio service frontend --url

# Или использовать port-forward для backend API
kubectl port-forward service/backend 8000:8000
# Затем открыть http://localhost:8000/docs для API документации

# Или использовать port-forward для frontend
kubectl port-forward service/frontend 8080:80
# Затем открыть http://localhost:8080
```

### Обновление приложения

Если вы изменили код и пересобрали образы:

```bash
# Загрузить обновленные образы в minikube
eval $(minikube -p devops-portfolio docker-env)
minikube -p devops-portfolio image load devops-portfolio-backend:latest
minikube -p devops-portfolio image load devops-portfolio-frontend:latest

# Перезапустить поды для применения новых образов
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend

# Или обновить Helm release
cd /home/user/yandex/DevOpsPortfolio/helm
helm upgrade devops-portfolio .
```

### Удаление приложения

```bash
# Удалить Helm release
helm uninstall devops-portfolio

# Проверить, что все ресурсы удалены
kubectl get all
```

### Важные замечания

1. **Helm использует контекст kubectl**: Helm автоматически использует текущий активный контекст kubectl. Убедитесь, что выбран правильный кластер перед развертыванием.

2. **Образы должны быть в minikube**: Поскольку в `values.yaml` указано `pullPolicy: Never`, образы должны быть доступны локально в minikube Docker daemon, а не в удаленном registry.

3. **Порты приложения**:
   - Backend слушает на порту 8000 (настраивается через переменную окружения `PORT`)
   - Frontend слушает на порту 80 (настраивается через переменную окружения `PORT`)
   - Frontend доступен извне через NodePort 30080

4. **Переключение между кластерами**:
   ```bash
   # Посмотреть все контексты
   kubectl config get-contexts
   
   # Переключиться на другой кластер
   kubectl config use-context minikube
   
   # Или использовать другой контекст только для Helm команды
   helm install my-app . --kube-context=minikube
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
