# Настройка секретов для CI/CD

Эта инструкция описывает, как настроить переменные окружения (секреты) в GitHub Actions для автоматического развёртывания.

## Необходимые переменные

Для работы CI/CD пайплайна нужно настроить следующие секреты в GitHub:

| Переменная | Описание | Тип | Где получить |
|------------|----------|-----|-------------|
| `YC_ACCESS_KEY_ID` | Access key ID сервисного аккаунта | **Secret** | См. инструкцию ниже |
| `YC_SECRET_ACCESS_KEY` | Secret access key сервисного аккаунта | **Secret** | См. инструкцию ниже |
| `REGISTRY_ID` | ID Container Registry в Yandex Cloud | **Variable** или **Secret** | Из `terraform.tfvars` или `yc container registry list` |

> **⚠️ Важно**: Для Docker login в Yandex Container Registry **необходим** сервисный аккаунт со статическим ключом доступа. OAuth-токен или IAM-токен не работают для Docker login!

## Пошаговая инструкция

### 1. Создание сервисного аккаунта и ключа доступа

#### Шаг 1: Создайте сервисный аккаунт

```bash
yc iam service-account create --name github-actions
```

Сохраните **ID сервисного аккаунта** из вывода (например, `aje...`).

#### Шаг 2: Назначьте необходимые роли

```bash
# Получите folder ID
FOLDER_ID=$(yc config get folder-id)

# Назначьте роли для работы с Container Registry
yc resource-manager folder add-access-binding $FOLDER_ID \
  --role container-registry.images.pusher \
  --service-account-name github-actions

# Назначьте роль для работы с Serverless Containers (если нужно)
yc resource-manager folder add-access-binding $FOLDER_ID \
  --role serverless.containers.admin \
  --service-account-name github-actions

# Назначьте роль для работы с Terraform
yc resource-manager folder add-access-binding $FOLDER_ID \
  --role editor \
  --service-account-name github-actions
```

#### Шаг 3: Создайте статический ключ доступа

```bash
yc iam access-key create --service-account-name github-actions
```

**Сохраните оба значения:**
- `access_key_id` — это будет `YC_ACCESS_KEY_ID`
- `secret` — это будет `YC_SECRET_ACCESS_KEY`

> **⚠️ ВАЖНО**: `secret` показывается только один раз! Сохраните его сразу.

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

#### Для YC_ACCESS_KEY_ID (Secret):

1. Нажмите **New repository secret**
2. **Name**: `YC_ACCESS_KEY_ID`
3. **Secret**: вставьте `access_key_id` из шага 3
4. Нажмите **Add secret**

#### Для YC_SECRET_ACCESS_KEY (Secret):

1. Нажмите **New repository secret**
2. **Name**: `YC_SECRET_ACCESS_KEY`
3. **Secret**: вставьте `secret` из шага 3
4. Нажмите **Add secret**

> **Примечание**: В GitHub секреты автоматически скрыты в логах и не могут быть просмотрены после сохранения. `secret` показывается только один раз при создании ключа!

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

- `YC_ACCESS_KEY_ID` и `YC_SECRET_ACCESS_KEY` используются в:
  - `build-backend` job (для `docker login` в Yandex Container Registry)
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

## Альтернатива: использование IAM-токена (только для Terraform)

> **⚠️ Внимание**: IAM-токен **не работает** для Docker login в Yandex Container Registry! Используйте только access key.

Если вы хотите использовать IAM-токен только для Terraform (не для Docker), можно добавить дополнительный секрет:

1. Создайте IAM-токен:
```bash
yc iam create-token
```

2. Добавьте секрет `YC_TOKEN` в GitHub (опционально, если хотите использовать токен для terraform)

3. Обновите workflow, чтобы использовать `YC_TOKEN` для terraform вместо access key.

Но для Docker login **обязательно** нужен access key!

## Устранение проблем

### Ошибка: "YC_ACCESS_KEY_ID is not set" или "YC_SECRET_ACCESS_KEY is not set"

Проверьте:
1. Оба секрета добавлены в Settings → Secrets and variables → Actions → Secrets
2. Правильные имена секретов (чувствительно к регистру)
3. В workflow файле секреты правильно используются: `${{ secrets.YC_ACCESS_KEY_ID }}` и `${{ secrets.YC_SECRET_ACCESS_KEY }}`

### Ошибка: "unauthorized: Password is invalid - must be OAuth token" при docker push

Эта ошибка означает, что вы пытаетесь использовать IAM-токен или OAuth-токен для Docker login. **Для Docker login нужен access key!**

Решение:
1. Создайте сервисный аккаунт и access key (см. инструкцию выше)
2. Добавьте `YC_ACCESS_KEY_ID` и `YC_SECRET_ACCESS_KEY` в секреты GitHub
3. Убедитесь, что workflow использует access key для docker login

### Ошибка: "REGISTRY_ID is not set"

Проверьте:
1. Переменная или секрет `REGISTRY_ID` добавлен в Settings → Secrets and variables → Actions
2. В workflow файле правильно используется: `${{ vars.REGISTRY_ID }}` (если переменная) или `${{ secrets.REGISTRY_ID }}` (если секрет)

### Как просмотреть секреты в GitHub?

**Важно**: После сохранения секрета в GitHub его нельзя просмотреть. Можно только обновить или удалить. Это сделано для безопасности.

