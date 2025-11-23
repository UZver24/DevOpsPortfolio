# Helm Chart для DevOps Portfolio

## Что такое Helm и зачем он нужен?

**Helm** — это менеджер пакетов для Kubernetes, который упрощает развертывание и управление приложениями.

### Зачем использовать Helm:

1. **Шаблонизация конфигураций** — позволяет создавать переиспользуемые шаблоны Kubernetes манифестов
2. **Управление версиями** — можно версионировать конфигурации и легко откатываться к предыдущим версиям
3. **Упрощение развертывания** — одна команда `helm install` вместо множества `kubectl apply`
4. **Гибкая конфигурация** — легко менять параметры через `values.yaml` без редактирования манифестов
5. **Управление зависимостями** — можно определять зависимости между чартами
6. **Переиспользование** — один чарт можно использовать для разных окружений (dev, staging, production)

### Преимущества для нашего проекта:

- Легко менять количество реплик, ресурсы, образы через `values.yaml`
- Можно создавать разные конфигурации для разных окружений
- Упрощает CI/CD — одна команда для развертывания
- Легко обновлять приложение через `helm upgrade`

## Структура Chart

```
devops-portfolio/
├── Chart.yaml          # Метаданные чарта
├── values.yaml         # Значения по умолчанию
└── templates/          # Шаблоны Kubernetes манифестов
    ├── backend-deployment.yaml
    ├── backend-service.yaml
    ├── frontend-deployment.yaml
    ├── frontend-service.yaml
    └── _helpers.tpl    # Вспомогательные шаблоны
```

## Использование

### Установка

```bash
# Загружаем образы в minikube (если еще не загружены)
minikube image load devops-portfolio-backend:latest
minikube image load devops-portfolio-frontend:latest

# Устанавливаем chart
cd devops-portfolio
helm install devops-portfolio .

# Или с кастомными значениями
helm install devops-portfolio . -f my-values.yaml
```

### Обновление

```bash
# Обновляем развертывание
helm upgrade devops-portfolio .

# С кастомными значениями
helm upgrade devops-portfolio . -f my-values.yaml
```

### Просмотр статуса

```bash
# Список установленных релизов
helm list

# Статус конкретного релиза
helm status devops-portfolio

# Просмотр сгенерированных манифестов
helm template devops-portfolio .
```

### Удаление

```bash
helm uninstall devops-portfolio
```

## Кастомизация через values.yaml

Все параметры можно изменить в `values.yaml`:

```yaml
backend:
  replicaCount: 3  # Изменить количество реплик
  resources:
    limits:
      memory: "512Mi"  # Увеличить лимиты памяти
```

## Сравнение с обычными манифестами

**Без Helm:**
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

**С Helm:**
```bash
helm install devops-portfolio .
```

Одна команда вместо четырех, плюс возможность легко менять конфигурацию!

## Результаты тестирования

✅ Helm chart успешно создан и прошел линтинг
✅ Развертывание через Helm работает корректно
✅ Все поды запускаются (4/4 Running)
✅ Frontend доступен через NodePort
✅ API запросы через frontend работают
✅ Обновление через `helm upgrade` работает
✅ Удаление через `helm uninstall` работает

