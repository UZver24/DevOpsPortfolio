# Настройка секретов для CI/CD

Эта инструкция описывает, как настроить переменные окружения (секреты) в GitHub Actions для автоматического развёртывания.

## Необходимые переменные

Для работы CI/CD пайплайна нужно настроить следующие секреты в GitHub:

| Переменная | Описание | Тип | Где получить |
|------------|----------|-----|-------------|
| `YC_IAM_TOKEN` | IAM-токен для Docker login в Container Registry | **Secret** | `yc iam create-token` (действителен 12 часов) |
| `REGISTRY_ID` | ID Container Registry в Yandex Cloud | **Variable** или **Secret** | Из `terraform.tfvars` или `yc container registry list` |

> **⚠️ Важно**: Для Docker login в Yandex Container Registry **необходим IAM-токен** (получается через `yc iam create-token`). IAM-токен действителен только 12 часов, поэтому его нужно периодически обновлять в секретах GitHub.

## Пошаговая инструкция

### 1. Получение IAM-токена для Docker login

Для Docker login в Yandex Container Registry нужен IAM-токен:

```bash
# Создайте IAM-токен
yc iam create-token
```

**Скопируйте весь токен** (он начинается с `t1.` и заканчивается точкой).

> **⚠️ ВАЖНО**: IAM-токен действителен только **12 часов**! После истечения нужно создать новый токен и обновить секрет в GitHub.

### 2. Получение REGISTRY_ID

```bash
# Посмотреть список реестров
yc container registry list

# Или взять из terraform.tfvars
# container_registry_id = "crp50gpc30l3tbd4rtj0"
```

#### REGISTRY_ID

```bash
# Посмотреть список реестров
yc container registry list

# Или взять из terraform.tfvars
# container_registry_id = "crp50gpc30l3tbd4rtj0"
```

### 3. Добавление секретов в GitHub

1. Откройте ваш репозиторий в GitHub
2. Перейдите в **Settings** (в верхнем меню репозитория)
3. В левом меню выберите **Secrets and variables** → **Actions**
4. Нажмите **New repository secret** (для секретов) или **New repository variable** (для обычных переменных)

#### Для YC_IAM_TOKEN (Secret):

1. Нажмите **New repository secret**
2. **Name**: `YC_IAM_TOKEN`
3. **Secret**: вставьте IAM-токен, полученный через `yc iam create-token`
4. Нажмите **Add secret**

> **Примечание**: 
> - В GitHub секреты автоматически скрыты в логах и не могут быть просмотрены после сохранения
> - IAM-токен действителен только 12 часов, после истечения нужно обновить секрет
> - Для автоматизации можно использовать сервисный аккаунт (см. раздел "Автоматизация обновления токена" ниже)

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

### 4. Проверка настроек

После добавления секретов они будут доступны в GitHub Actions workflows. Проверьте, что секреты правильно используются:

- `YC_IAM_TOKEN` используется в:
  - `build-backend` job (для `docker login` в Yandex Container Registry)
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

### Ошибка: "YC_IAM_TOKEN is not set"

Проверьте:
1. Секрет добавлен в Settings → Secrets and variables → Actions → Secrets
2. Правильное имя секрета (чувствительно к регистру): `YC_IAM_TOKEN`
3. В workflow файле секрет правильно используется: `${{ secrets.YC_IAM_TOKEN }}`

### Ошибка: "unauthorized: Password is invalid - must be IAM token" при docker push

Эта ошибка означает, что:
1. Токен истёк (IAM-токен действителен только 12 часов)
2. Токен вставлен неправильно (возможно, есть лишние пробелы)

Решение:
1. Создайте новый IAM-токен: `yc iam create-token`
2. Обновите секрет `YC_IAM_TOKEN` в GitHub
3. Перезапустите workflow

### Ошибка: "REGISTRY_ID is not set"

Проверьте:
1. Переменная или секрет `REGISTRY_ID` добавлен в Settings → Secrets and variables → Actions
2. В workflow файле правильно используется: `${{ vars.REGISTRY_ID }}` (если переменная) или `${{ secrets.REGISTRY_ID }}` (если секрет)

### Как просмотреть секреты в GitHub?

**Важно**: После сохранения секрета в GitHub его нельзя просмотреть. Можно только обновить или удалить. Это сделано для безопасности.

