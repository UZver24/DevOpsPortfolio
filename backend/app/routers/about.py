"""
Роутер для информации о себе
"""
from fastapi import APIRouter
from app.models import AboutResponse

router = APIRouter()


@router.get("/about", response_model=AboutResponse)
async def get_about():
    """Получить информацию о себе"""
    return AboutResponse(
        name="UZver24",
        title="DevOps Engineer",
        description="Опытный DevOps инженер с фокусом на автоматизацию, контейнеризацию и облачные технологии",
        bio="Специализируюсь на настройке CI/CD пайплайнов, работе с Kubernetes, инфраструктуре как коде (Terraform), мониторинге и обеспечении безопасности приложений.",
        location="Россия",
        email="m-kar@inbox.ru",
        github="https://github.com/UZver24"
    )

