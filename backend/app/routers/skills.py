"""
Роутер для навыков
"""
from fastapi import APIRouter
from app.models import SkillsResponse

router = APIRouter()


@router.get("/skills", response_model=SkillsResponse)
async def get_skills():
    """Получить список навыков"""
    return SkillsResponse(
        categories=[
            {
                "name": "Контейнеризация",
                "items": ["Docker", "Docker Compose", "Kubernetes", "Helm"]
            },
            {
                "name": "CI/CD",
                "items": ["GitHub Actions", "GitLab CI", "Jenkins"]
            },
            {
                "name": "Infrastructure as Code",
                "items": ["Terraform", "Ansible"]
            },
            {
                "name": "Мониторинг",
                "items": ["Prometheus", "Grafana", "ELK Stack", "Loki"]
            },
            {
                "name": "GitOps",
                "items": ["ArgoCD", "Flux"]
            },
            {
                "name": "Облачные платформы",
                "items": ["Yandex Cloud", "AWS", "GCP"]
            },
            {
                "name": "Языки программирования",
                "items": ["Python", "Bash", "Go"]
            },
            {
                "name": "Базы данных",
                "items": ["PostgreSQL", "MongoDB", "Redis"]
            }
        ]
    )

