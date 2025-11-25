Есть вот-такой сайт-визитка: https://tosinonikute.com/
Надо сделать его аналог и развернуть его в облаке, но при этом продемонстрировать навыки DevOps. То есть итог: сайт-визитка + его проект на GitHub, по которому можно оценить мой уровень.

Cтек технологий, которые должен демонстрировать проект:

## Критически важные (Must Have):
* Kubernetes - k8s (Pod, Deployment, Service, Ingress, ConfigMap, Secret, StatefulSet, DaemonSet)
* CI/CD пайплайны (GitHub Actions, GitLab CI, или Jenkins)
* образы, контейнеры, Dockerfile, Docker Compose
* Terraform (Infrastructure as Code)
* Мониторинг и метрики (Prometheus, Grafana)
* GitOps (ArgoCD, Flux)
* Helm (управление приложениями в k8s)
* Code style, принципы чистого кода (SOLID, DRY, KISS)

## Очень важные (Should Have):
* Централизованное логирование (ELK Stack, Loki, Fluentd)
* DevSecOps ("Сдвиг влево", Управление секретами (HashiCorp Vault, AWS Secrets Manager), сканирование образов на уязвимости (Trivy, Grype), анализ кода (SAST))
* стратегии деплоя (Blue-Green, Canary, Rolling Update)
* Multi-environment подход (dev, staging, production)
* Управление сертификатами (cert-manager, Let's Encrypt)
* OWASP Top 10 (безопасность приложений)
* Автоматизация тестирования в CI/CD (unit, integration, e2e тесты)
* minikube (для локального тестирования развёртывания)

## Важные (Nice to Have):
* Ansible (конфигурационное управление)
* Облачные сервисы (AWS EKS/GKE/AKS, S3, CloudFront, Route53 или аналоги в GCP/Azure, Yandex Cloud)
* Контейнерные реестры (Harbor, AWS ECR, Google Container Registry, Yandex Container Registry)
* Базы данных и их управление (PostgreSQL, MongoDB, Redis) с backup стратегиями
* Disaster Recovery и backup стратегии
* Трейсинг (Jaeger или Zipkin)
* Service Mesh (Istio, Linkerd) - для продвинутого управления трафиком в k8s
* API Gateway (Kong, Ambassador, Traefik)

## Дополнительные компетенции (Advanced):
* Platform Engineering и Internal Developer Platforms (IDP)
* FinOps (управление затратами на облачную инфраструктуру)
* Serverless и Container-as-a-Service (AWS Lambda, Yandex Cloud Functions)