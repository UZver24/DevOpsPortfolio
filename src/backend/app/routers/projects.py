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
                "description": "Сайт-визитка с демонстрацией DevOps навыков. Включает полный стек: Kubernetes, CI/CD, мониторинг, Terraform, Helm. Развёрнут в Yandex Cloud с использованием serverless технологий.",
                "technologies": ["Python", "FastAPI", "React", "Vite", "Docker", "Kubernetes", "Helm", "Terraform", "GitHub Actions", "Yandex Cloud", "Serverless Containers", "Object Storage", "API Gateway"],
                "github_url": "https://github.com/UZver24/DevOpsPortfolio",
                "status": "В разработке"
            },
            {
                "id": 2,
                "name": "Разработка устройств полного цикла",
                "description": "Проектирование электроники в KiCAD, 3D-моделирование корпусов в Компас-3D, FreeCAD и Blender, организация производства и управление изготовлением прототипов, формирование комплекта технической документации.",
                "technologies": ["KiCAD", "Компас-3D", "FreeCAD", "Blender", "Python", "OpenCV"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 3,
                "name": "Разработка прототипов компьютерного зрения",
                "description": "Разработка прототипов компьютерного зрения на Python с использованием OpenCV. Создание и доработка веб-интерфейсов для управления устройствами.",
                "technologies": ["Python", "OpenCV", "Web-интерфейсы"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 4,
                "name": "Кастомизированные образы ОС для встраиваемых систем",
                "description": "Разработка и поддержка кастомизированных образов ОС для встраиваемых систем. Автоматизация процесса сборки образов с помощью Ansible. Проведение миграции парка оборудования на актуальные LTS-версии Ubuntu. Расширение функциональности образов, интеграция сервисов Avahi (Zeroconf), SSDP.",
                "technologies": ["Ansible", "Ubuntu", "Linux", "systemd", "Avahi", "SSDP", "ZFS", "PINN"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 5,
                "name": "Автоматизация инфраструктуры с Terraform и Ansible",
                "description": "Автоматизация развертывания и управления инфраструктурой: PostgreSQL, Docker, ClickHouse, Nginx, ElasticMQ, Minio. Оркестрация сервисов с помощью Kubernetes и управление пакетами через Helm.",
                "technologies": ["Terraform", "Ansible", "Kubernetes", "Helm", "PostgreSQL", "Docker", "ClickHouse", "Nginx"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 6,
                "name": "CI/CD автоматизация",
                "description": "Автоматизация сборки и CI/CD: интеграция Jenkins с GitLab, добавление и настройка специализированных сборщиков. Автоматизация развертывания Jenkins в Kubernetes.",
                "technologies": ["Jenkins", "GitLab", "Kubernetes", "Helm", "CI/CD"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 7,
                "name": "Автоматизация обработки данных в облаке",
                "description": "Автоматизация обработки данных и очередей сообщений с использованием Go и Python в облачной среде.",
                "technologies": ["Go", "Python", "Yandex Cloud"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 8,
                "name": "Реализация низкоуровневых функций безопасности",
                "description": "Реализация полного шифрования ОС с использованием ZFS, механизм восстановления/обновления прошивок с использованием PINN.",
                "technologies": ["ZFS", "PINN", "Linux", "Безопасность"],
                "github_url": None,
                "status": "Завершён"
            },
            {
                "id": 9,
                "name": "Развёртывание удаленных стендов для тестирования",
                "description": "Настройка удаленных стендов для тестирования на базе Pi-KVM (KVM over IP), а также серверов для развертывания обновлений и личных Git-репозиториев.",
                "technologies": ["Pi-KVM", "KVM", "Git", "DevOps"],
                "github_url": None,
                "status": "Завершён"
            }
        ]
    )

