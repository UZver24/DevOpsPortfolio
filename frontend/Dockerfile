# Multi-stage build для React Frontend

# Stage 1: Сборка приложения
FROM node:20-alpine AS builder

WORKDIR /app

# Копируем файлы зависимостей
COPY package.json package-lock.json* ./

# Устанавливаем зависимости
RUN npm ci

# Копируем исходный код
COPY . .

# Собираем приложение для production
RUN npm run build

# Stage 2: Production образ с nginx
FROM nginx:alpine

RUN apk add --no-cache gettext

# Копируем собранное приложение из builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Открываем порт
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD sh -c "wget --quiet --tries=1 --spider http://localhost:${PORT:-8080}/ || exit 1"

# Запускаем nginx через entrypoint (шаблонизация конфига)
ENTRYPOINT ["/docker-entrypoint.sh"]

