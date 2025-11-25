# Устранение проблем CI/CD

## Проблема: "unauthorized: Password is invalid - must be OAuth token"

Эта ошибка означает, что токен `YC_OAUTH_TOKEN` неверный или истёк.

### Причины:

1. **Токен истёк** — IAM-токены действительны только **12 часов**
2. **Токен вставлен неправильно** — возможно, есть лишние пробелы или символы
3. **Секрет не сохранён** — секрет не был правильно добавлен в GitHub

### Решение:

#### 1. Проверьте секрет в GitHub:

1. Откройте репозиторий в GitHub
2. Перейдите в **Settings** → **Secrets and variables** → **Actions**
3. Найдите секрет `YC_OAUTH_TOKEN`
4. Проверьте, что он существует и правильно назван (чувствительно к регистру!)

#### 2. Обновите токен:

```bash
# Создайте новый IAM-токен
yc iam create-token
```

Скопируйте **весь** токен (он начинается с `t1.` и заканчивается точкой).

#### 3. Обновите секрет в GitHub:

1. В GitHub: **Settings** → **Secrets and variables** → **Actions**
2. Найдите `YC_OAUTH_TOKEN`
3. Нажмите **Update** (или удалите и создайте заново)
4. Вставьте **новый** токен (без пробелов в начале/конце)
5. Нажмите **Update secret**

#### 4. Перезапустите workflow:

1. Перейдите в **Actions** вкладку
2. Найдите упавший workflow
3. Нажмите **Re-run all jobs**

### Альтернатива: Использование сервисного аккаунта

Для production рекомендуется использовать сервисный аккаунт со статическим ключом (не истекает):

```bash
# Создать сервисный аккаунт
yc iam service-account create --name github-actions

# Создать статический ключ
yc iam access-key create --service-account-name github-actions

# Выдаст:
# access_key_id: <ID>
# secret: <SECRET>  # Сохраните это!
```

Затем в GitHub добавьте секреты:
- `YC_ACCESS_KEY_ID` = `<ID>`
- `YC_SECRET_ACCESS_KEY` = `<SECRET>`

И обновите workflow для использования этих переменных (потребуется изменить скрипты).

---

## Как поделиться логами для диагностики

### Вариант 1: Скопировать полный лог

1. В GitHub перейдите в **Actions**
2. Откройте упавший workflow run
3. Откройте упавший job (например, "Build and Push Backend")
4. Нажмите на любой step, чтобы развернуть лог
5. Нажмите кнопку **...** (три точки) в правом верхнем углу лога
6. Выберите **Download log** или **Copy log**
7. Вставьте в сообщение (можно сократить, оставив только ошибки)

### Вариант 2: Скопировать только ошибки

1. В логе найдите строки, начинающиеся с `##[error]`
2. Скопируйте их вместе с несколькими строками контекста до и после
3. Вставьте в сообщение

### Вариант 3: Скриншот

Сделайте скриншот секции с ошибкой в логе.

---

## Другие частые проблемы

### Ошибка: "REGISTRY_ID is not set"

**Решение**: Проверьте, что секрет `REGISTRY_ID` добавлен в GitHub:
- Settings → Secrets and variables → Actions → Secrets (или Variables)

### Ошибка: "terraform: command not found"

**Решение**: Это не должно происходить, так как мы используем `hashicorp/setup-terraform@v3`. Если возникает, проверьте версию workflow файла.

### Ошибка: "yc: command not found"

**Решение**: Проверьте, что шаг "Install Yandex Cloud CLI" выполнился успешно. Если нет, проверьте логи этого шага.

### Ошибка при terraform apply

**Решение**: 
1. Проверьте, что `YC_TOKEN` (секрет `YC_OAUTH_TOKEN`) действителен
2. Проверьте, что terraform state не повреждён
3. Попробуйте выполнить `terraform init` и `terraform apply` локально для диагностики

---

## Отладка локально

Вы можете запустить скрипты локально для проверки:

```bash
# Проверка backend скрипта
export REGISTRY_ID=crp50gpc30l3tbd4rtj0
export IMAGE_TAG=test
export YC_OAUTH_TOKEN=$(yc iam create-token)
./CI/build_backend.sh

# Проверка frontend скрипта (после terraform apply)
cd infrastructure/serverless
export API_GATEWAY_ENDPOINT=$(terraform output -raw api_gateway_endpoint)
export STATIC_BUCKET_NAME=$(terraform output -raw static_bucket_name)
export AWS_ACCESS_KEY_ID=$(terraform output -raw static_site_access_key)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw static_site_secret_key)
cd ../..
./CI/build_frontend.sh
```

---

## Проверка токена

Чтобы проверить, действителен ли токен:

```bash
# Используйте токен для запроса к Yandex Cloud API
export YC_TOKEN="ваш_токен"
yc config set token $YC_TOKEN
yc container registry list
```

Если команда выполняется успешно, токен действителен. Если нет — создайте новый.

