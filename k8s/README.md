# Kubernetes манифесты для DevOps Portfolio

Этот каталог содержит Kubernetes манифесты для развертывания приложения в кластере.

## Структура

- `backend-deployment.yaml` - Deployment для backend сервиса
- `backend-service.yaml` - Service для backend (ClusterIP)
- `frontend-deployment.yaml` - Deployment для frontend сервиса
- `frontend-service.yaml` - Service для frontend (NodePort)

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

### 4. Удаление

```bash
kubectl delete -f k8s/
```

## Особенности конфигурации

- **Backend**: 2 реплики, ClusterIP сервис (внутренний доступ)
- **Frontend**: 2 реплики, NodePort сервис (внешний доступ на порту 30080)
- **Health checks**: Настроены liveness и readiness пробы
- **Resources**: Ограничения по памяти и CPU для каждого контейнера
- **ImagePullPolicy: Never**: Используем локальные образы в minikube

