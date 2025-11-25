"""
Роутер для контактов
"""
from fastapi import APIRouter
from app.models import ContactResponse

router = APIRouter()


@router.get("/contacts", response_model=ContactResponse)
async def get_contacts():
    """Получить контактную информацию"""
    return ContactResponse(
        email=None,
        github="https://github.com/UZver24",
        linkedin=None,
        telegram="@Kulibin2024"
    )

