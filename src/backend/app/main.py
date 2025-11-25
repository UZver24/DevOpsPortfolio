"""
FastAPI Backend для сайта-визитки DevOps портфолио
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import about, skills, projects, contacts

app = FastAPI(
    title="DevOps Portfolio API",
    description="API для сайта-визитки DevOps инженера",
    version="1.0.0"
)

# Настройка CORS для работы с React фронтендом
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение роутеров
app.include_router(about.router, prefix="/api", tags=["about"])
app.include_router(skills.router, prefix="/api", tags=["skills"])
app.include_router(projects.router, prefix="/api", tags=["projects"])
app.include_router(contacts.router, prefix="/api", tags=["contacts"])


@app.get("/")
async def root():
    """Корневой эндпоинт"""
    return {"message": "DevOps Portfolio API", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    """Health check эндпоинт для мониторинга"""
    return {"status": "healthy"}

