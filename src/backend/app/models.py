"""
Pydantic модели для API
"""
from typing import List, Optional
from pydantic import BaseModel, EmailStr


class AboutResponse(BaseModel):
    """Модель информации о себе"""
    name: str
    title: str
    description: str
    bio: str
    location: str
    email: EmailStr
    github: str

    class Config:
        json_schema_extra = {
            "example": {
                "name": "UZver24",
                "title": "DevOps Engineer",
                "description": "Опытный DevOps инженер",
                "bio": "Специализируюсь на...",
                "location": "Россия",
                "email": "m-kar@inbox.ru",
                "github": "https://github.com/UZver24"
            }
        }


class SkillCategory(BaseModel):
    """Модель категории навыков"""
    name: str
    items: List[str]


class SkillsResponse(BaseModel):
    """Модель списка навыков"""
    categories: List[SkillCategory]


class Project(BaseModel):
    """Модель проекта"""
    id: int
    name: str
    description: str
    technologies: List[str]
    github_url: Optional[str] = None
    status: str


class ProjectsResponse(BaseModel):
    """Модель списка проектов"""
    projects: List[Project]


class ContactResponse(BaseModel):
    """Модель контактов"""
    email: EmailStr
    github: str
    linkedin: Optional[str] = None
    telegram: Optional[str] = None

