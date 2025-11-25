#!/bin/sh
set -euo pipefail

PORT="${PORT:-8080}"
API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"

export PORT API_BASE_URL

envsubst '${PORT} ${API_BASE_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'


