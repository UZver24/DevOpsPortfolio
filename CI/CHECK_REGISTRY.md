# Проверка Container Registry

## Быстрая проверка

### 1. Список реестров

```bash
yc container registry list
```

Вывод должен показать ваш реестр с ID (например, `crp50gpc30l3tbd4rtj0`).

### 2. Список образов в реестре

```bash
# Замените REGISTRY_ID на ваш ID реестра
yc container image list --registry-id crp50gpc30l3tbd4rtj0
```

Или по имени реестра:

```bash
yc container image list --registry-name devops-portfolio
```

### 3. Детальная информация об образе

```bash
# По ID образа
yc container image get --id crpjf10o8ke35dcsh20k

# Или по имени и тегу
yc container image get --name crp50gpc30l3tbd4rtj0/backend:latest
```

### 4. Проверка доступа через Docker

**Важно**: Если у вас настроен credential helper для `yc`, нужно либо отключить его, либо использовать другой профиль.

#### Вариант 1: Отключить credential helper для cr.yandex

```bash
# Проверить текущую конфигурацию
cat ~/.docker/config.json

# Если есть credential helper для cr.yandex, можно временно отключить его
# или использовать другой профиль
```

#### Вариант 2: Использовать IAM токен напрямую

```bash
# Создать IAM токен
TOKEN=$(yc iam create-token)

# Логин (может не работать, если включен credential helper)
echo "$TOKEN" | docker login --username iam --password-stdin cr.yandex
```

#### Вариант 3: Настроить credential helper правильно

```bash
# Настроить Docker для работы с Yandex Container Registry
yc container registry configure-docker
```

### 5. Проверка pull образа

```bash
# Попробовать скачать образ
docker pull cr.yandex/crp50gpc30l3tbd4rtj0/backend:latest
```

### 6. Проверка push образа

```bash
# Создать тестовый образ
docker tag <local-image> cr.yandex/crp50gpc30l3tbd4rtj0/test:latest

# Попробовать загрузить
docker push cr.yandex/crp50gpc30l3tbd4rtj0/test:latest
```

## Текущее состояние вашего реестра

- **Registry ID**: `crp50gpc30l3tbd4rtj0`
- **Registry Name**: `devops-portfolio`
- **Образы**:
  - `backend:latest` (59.0 MB)
  - `frontend:latest` (23.0 MB)

## Проверка прав доступа

```bash
# Проверить, какие роли назначены вашему аккаунту
yc container registry list-access-bindings --id crp50gpc30l3tbd4rtj0
```

## Устранение проблем

### Ошибка: "unauthorized"

1. Проверьте, что IAM токен действителен (не истёк)
2. Проверьте права доступа к реестру
3. Убедитесь, что используете правильный Registry ID

### Ошибка: "credential helper"

Если Docker использует credential helper от `yc`, можно:
1. Временно отключить его в `~/.docker/config.json`
2. Использовать другой профиль: `yc container registry configure-docker --profile <PROFILE>`
3. Использовать переменные окружения вместо credential helper

### Проверка токена

```bash
# Создать новый токен
yc iam create-token

# Проверить, что токен работает
yc config set token $(yc iam create-token)
yc container registry list
```

