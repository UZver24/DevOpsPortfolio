# Настройка секретов для CI/CD

Эта инструкция описывает, как настроить переменные окружения (секреты) в GitHub Actions для автоматического развёртывания.

## Необходимые переменные

Для работы CI/CD пайплайна нужно настроить следующие секреты в GitHub:

| Переменная | Описание | Тип | Где получить |
|------------|----------|-----|-------------|
| `YC_OAUTH_TOKEN` | IAM-токен для доступа к Yandex Cloud | **Secret** | `yc iam create-token` |
| `REGISTRY_ID` | ID Container Registry в Yandex Cloud | **Variable** или **Secret** | Из `terraform.tfvars` или `yc container registry list` |

## Пошаговая инструкция

### 1. Получение значений

#### YC_OAUTH_TOKEN (IAM-токен)

```bash
# Создайте IAM-токен (действителен 12 часов)
yc iam create-token

# Или для сервисного аккаунта (если используете)
yc iam create-token --service-account-id <service-account-id>
```

**Важно**: IAM-токен действителен только 12 часов. Для production рекомендуется использовать сервисный аккаунт с постоянным ключом или настроить автоматическое обновление токена.

#### REGISTRY_ID

```bash
# Посмотреть список реестров
yc container registry list

# Или взять из terraform.tfvars
# container_registry_id = "crp50gpc30l3tbd4rtj0"
```

### 2. Добавление секретов в GitHub

1. Откройте ваш репозиторий в GitHub
2. Перейдите в **Settings** (в верхнем меню репозитория)
3. В левом меню выберите **Secrets and variables** → **Actions**
4. Нажмите **New repository secret** (для секретов) или **New repository variable** (для обычных переменных)

#### Для YC_OAUTH_TOKEN (Secret):

1. Нажмите **New repository secret**
2. **Name**: `YC_OAUTH_TOKEN`
3. **Secret**: вставьте токен, полученный через `yc iam create-token`
4. Нажмите **Add secret**

> **Примечание**: В GitHub секреты автоматически скрыты в логах и не могут быть просмотрены после сохранения.

#### Для REGISTRY_ID (Variable или Secret):

**Вариант 1: Как переменная (рекомендуется, если это не секрет)**
1. Нажмите **New repository variable**
2. **Name**: `REGISTRY_ID`
3. **Value**: `crp50gpc30l3tbd4rtj0` (ваш Registry ID)
4. Нажмите **Add variable**

**Вариант 2: Как секрет (если хотите скрыть)**
1. Нажмите **New repository secret**
2. **Name**: `REGISTRY_ID`
3. **Secret**: `crp50gpc30l3tbd4rtj0`
4. Нажмите **Add secret**

### 3. Проверка настроек

После добавления секретов они будут доступны в GitHub Actions workflows. Проверьте, что секреты правильно используются:

- `YC_OAUTH_TOKEN` используется в:
  - `build-backend` job (для `docker login`)
  - `deploy-infra` job (для terraform provider)
- `REGISTRY_ID` используется в:
  - `build-backend` job (для формирования пути к образу)

## Автоматические переменные

Следующие переменные настраивать не нужно — они автоматически доступны в GitHub Actions:

- `GITHUB_SHA` — полный хеш коммита (можно использовать `${{ github.sha }}` или `${{ github.sha }}` с обрезкой)
- `GITHUB_REF_NAME` — имя ветки или тега
- `GITHUB_REPOSITORY` — имя репозитория

Для получения короткого хеша коммита (аналог `CI_COMMIT_SHORT_SHA`) используйте:
```yaml
IMAGE_TAG: ${{ github.sha }}
# или для короткого хеша (первые 7 символов):
IMAGE_TAG: ${{ github.sha }}
```

## Безопасность

### Рекомендации:

1. **YC_OAUTH_TOKEN**:
   - Используйте сервисный аккаунт для production
   - Настройте автоматическое обновление токена (через cron или внешний сервис)
   - Или используйте статический ключ сервисного аккаунта (но это менее безопасно)

2. **Защита секретов**:
   - В GitHub секреты автоматически скрыты в логах
   - Можно использовать **Environment secrets** для разделения секретов по окружениям (dev, staging, production)
   - Для ограничения доступа используйте **Environment protection rules** в настройках окружения

3. **Ограничение доступа**:
   - Используйте **Environments** (Settings → Environments) для разделения секретов по окружениям
   - Настройте **Environment protection rules** для ограничения доступа к секретам по веткам

## Альтернатива: использование сервисного аккаунта

Вместо IAM-токена можно использовать статический ключ сервисного аккаунта:

```bash
# Создать сервисный аккаунт
yc iam service-account create --name github-actions

# Создать статический ключ
yc iam access-key create --service-account-name github-actions

# Выдаст access_key_id и secret (secret нужно сохранить!)
```

Затем в GitHub добавьте секреты:
- `YC_ACCESS_KEY_ID` — access key ID
- `YC_SECRET_ACCESS_KEY` — secret

И обновите GitHub Actions workflow для использования этих переменных вместо `YC_OAUTH_TOKEN`.

## Устранение проблем

### Ошибка: "YC_OAUTH_TOKEN is not set"

Проверьте:
1. Секрет добавлен в Settings → Secrets and variables → Actions → Secrets
2. Правильное имя секрета (чувствительно к регистру)
3. В workflow файле секрет правильно используется: `${{ secrets.YC_OAUTH_TOKEN }}`

### Ошибка: "unauthorized" при docker push

Токен мог истечь (действителен 12 часов). Обновите `YC_OAUTH_TOKEN` в настройках GitHub:
1. Settings → Secrets and variables → Actions
2. Найдите `YC_OAUTH_TOKEN`
3. Нажмите **Update** и вставьте новый токен

### Ошибка: "REGISTRY_ID is not set"

Проверьте:
1. Переменная или секрет `REGISTRY_ID` добавлен в Settings → Secrets and variables → Actions
2. В workflow файле правильно используется: `${{ vars.REGISTRY_ID }}` (если переменная) или `${{ secrets.REGISTRY_ID }}` (если секрет)

### Как просмотреть секреты в GitHub?

**Важно**: После сохранения секрета в GitHub его нельзя просмотреть. Можно только обновить или удалить. Это сделано для безопасности.

