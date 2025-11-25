"""
Pydantic модели для API
"""
from typing import List, Optional
from pydantic import BaseModel, EmailStr


class AboutResponse(BaseModel):
    """Модель информации о себе"""
    name: str
    title: Optional[str] = None
    description: str
    bio: str
    location: Optional[str] = None
    email: Optional[EmailStr] = None
    github: str

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Имя Фамилия",
                "title": None,
                "description": "Описание",
                "bio": "Биография...",
                "location": None,
                "email": None,
                "github": "https://github.com/username"
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
    email: Optional[EmailStr] = None
    github: str
    linkedin: Optional[str] = None
    telegram: Optional[str] = None

