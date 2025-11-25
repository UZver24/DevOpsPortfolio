"""
Роутер для проектов
"""
from fastapi import APIRouter
from app.models import ProjectsResponse

router = APIRouter()


@router.get("/projects", response_model=ProjectsResponse)
async def get_projects():
    """Получить список проектов"""
    return ProjectsResponse(
        projects=[
            {
                "id": 1,
                "name": "DevOps Portfolio",
                "description": "Сайт-визитка с демонстрацией DevOps навыков. Включает полный стек: Kubernetes, CI/CD, мониторинг, GitOps и многое другое.",
                "technologies": ["Python", "FastAPI", "React", "Kubernetes", "Terraform", "Helm", "ArgoCD"],
                "github_url": "https://github.com/UZver24/DevOpsPortfolio",
                "status": "В разработке"
            }
        ]
    )

