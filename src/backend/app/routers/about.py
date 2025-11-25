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
        name="Карташов Михаил Владимирович",
        title=None,
        description="Инженер с 19+ годами опыта на стыке аппаратного и программного обеспечения",
        bio="Работаю над решением инженерных задач на стыке аппаратного и программного обеспечения. Провожу исследования, разрабатываю и внедряю решения «под ключ» — от концепции до работающего прототипа. Работаю с DevOps практиками, автоматизацией инфраструктуры, контейнеризацией, облачными технологиями и системным администрированием.",
        location=None,
        email=None,
        github="https://github.com/UZver24"
    )

