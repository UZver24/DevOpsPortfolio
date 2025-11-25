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
                "name": "Контейнеризация и оркестрация",
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
                "name": "Мониторинг и логирование",
                "items": ["Yandex Monitoring", "Yandex Logging", "Prometheus", "Grafana", "ELK Stack", "Loki"]
            },
            {
                "name": "Облачные платформы",
                "items": ["Yandex Cloud", "Yandex Serverless Containers", "Yandex Container Registry", "Yandex Object Storage", "Yandex API Gateway"]
            },
            {
                "name": "Языки программирования",
                "items": ["Python", "Go", "C/C++", "C#", "Bash", "RegExp"]
            },
            {
                "name": "Системное администрирование",
                "items": ["Linux", "Windows Server 2003/2008 R2", "DHCP", "NTP", "Администрирование серверов"]
            },
            {
                "name": "Базы данных",
                "items": ["MS SQL Server", "PostgreSQL", "MongoDB", "Redis"]
            },
            {
                "name": "Инструменты разработки",
                "items": ["MS Visual Studio", "Visual Studio C#", "Git", "GitLab"]
            },
            {
                "name": "CAD/CAM системы",
                "items": ["Компас-3D", "KiCAD", "FreeCAD", "Blender", "P-CAD", "Altium Designer", "MATLAB", "HFSS"]
            },
            {
                "name": "Дополнительные навыки",
                "items": ["FinOps", "DevSecOps практики", "Проектирование электроники", "3D-моделирование", "Разработка прошивок для микроконтроллеров"]
            }
        ]
    )

