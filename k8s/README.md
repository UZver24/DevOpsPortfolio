# Kubernetes манифесты для DevOps Portfolio

Этот каталог содержит Kubernetes манифесты для развертывания приложения в кластере.

## Что такое minikube и kubectl?

**minikube** — инструмент для запуска локального Kubernetes кластера на одной машине. Он создает виртуальную машину (или использует Docker) с полноценным Kubernetes кластером для разработки и тестирования.

**kubectl** — командная утилита для управления Kubernetes кластерами. Позволяет развертывать приложения, управлять ресурсами, просматривать логи и т.д.

## Структура

- `backend-deployment.yaml` - Deployment для backend сервиса
- `backend-service.yaml` - Service для backend (ClusterIP)
- `frontend-deployment.yaml` - Deployment для frontend сервиса
- `frontend-service.yaml` - Service для frontend (NodePort)

## Установка

**На Arch Linux:**
```bash
sudo pacman -S kubectl minikube
```

## Запуск minikube

```bash
# Запуск minikube с драйвером docker
minikube start --driver=docker

# Проверка статуса
minikube status

# Проверка подключения к кластеру
kubectl get nodes
```

## Работа с Docker образами в minikube

**Важно:** Minikube использует свой собственный Docker daemon, отдельный от локального Docker. Поэтому образы, собранные локально, не видны в minikube.

**Рекомендуемый подход (приближенный к CI/CD):**

Этот подход имитирует реальный процесс CI/CD, где образы собираются локально, а затем загружаются/публикуются в registry (в нашем случае - в minikube):

```bash
# 1. Собираем образы локально (как будет в CI/CD)
cd backend
docker build -t devops-portfolio-backend:latest .
cd ../frontend
docker build -t devops-portfolio-frontend:latest .

# 2. Загружаем образы в minikube (имитация публикации в registry)
minikube image load devops-portfolio-backend:latest
minikube image load devops-portfolio-frontend:latest

# 3. Проверяем, что образы загружены
minikube image ls | grep devops-portfolio
```

**Альтернативный подход (для разработки):**

Если нужно собирать образы напрямую в minikube (быстрее для разработки, но не соответствует CI/CD процессу):

```bash
# Настраиваем окружение для использования Docker daemon minikube
eval $(minikube -p minikube docker-env)

# Теперь docker команды работают с minikube
cd backend && docker build -t devops-portfolio-backend:latest .
cd ../frontend && docker build -t devops-portfolio-frontend:latest .

# Возвращаемся к локальному Docker
eval $(minikube -p minikube docker-env -u)
```

**Почему первый подход лучше:**
- Имитирует реальный CI/CD процесс (сборка → публикация → развертывание)
- Образы можно переиспользовать
- Проще отлаживать проблемы с образами

## Полезные команды minikube

```bash
# Просмотр логов
minikube logs

# Открытие dashboard
minikube dashboard

# Остановка кластера
minikube stop

# Удаление кластера
minikube delete

# Получение IP адреса кластера
minikube ip
```

## Развертывание в minikube

### 1. Подготовка образов

```bash
# Собираем образы локально
cd backend
docker build -t devops-portfolio-backend:latest .
cd ../frontend
docker build -t devops-portfolio-frontend:latest .

# Загружаем образы в minikube
minikube image load devops-portfolio-backend:latest
minikube image load devops-portfolio-frontend:latest

# Проверяем загрузку
minikube image ls | grep devops-portfolio
```

### 2. Развертывание

```bash
# Применяем манифесты
kubectl apply -f k8s/

# Проверяем статус
kubectl get deployments
kubectl get services
kubectl get pods

# Просмотр логов
kubectl logs -f deployment/backend
kubectl logs -f deployment/frontend
```

### 3. Доступ к приложению

```bash
# Получаем URL для frontend
minikube service frontend --url

# Или используем NodePort напрямую
minikube ip
# Затем откройте http://<minikube-ip>:30080
```

### 4. Проверка работы

```bash
# Проверяем статус подов
kubectl get pods

# Проверяем логи
kubectl logs -f deployment/backend
kubectl logs -f deployment/frontend

# Проверяем доступность через curl
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30080
curl http://$MINIKUBE_IP:30080/api/about
```

### 5. Удаление

```bash
kubectl delete -f k8s/
```

## Особенности конфигурации

- **Backend**: 2 реплики, ClusterIP сервис (внутренний доступ)
- **Frontend**: 2 реплики, NodePort сервис (внешний доступ на порту 30080)
- **Health checks**: Настроены liveness и readiness пробы
- **Resources**: Ограничения по памяти и CPU для каждого контейнера
- **ImagePullPolicy: Never**: Используем локальные образы в minikube
- **Универсальный nginx.conf**: Использует `backend:8000` - работает в Docker Compose, Kubernetes и Helm

## Результаты тестирования

✅ Все поды успешно запускаются (4/4 Running)
✅ Backend health check работает
✅ Frontend доступен через NodePort (http://<minikube-ip>:30080)
✅ API запросы через frontend работают корректно
✅ Health checks (liveness/readiness) функционируют
✅ Логи показывают нормальную работу сервисов

