import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from dotenv import load_dotenv

from .database import engine, Base
from .routes import products, rfid, eco_score, recommendations, scans, bluetooth

load_dotenv()

# Create database tables automatically on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="EcoMind AI — Eco Decision Engine API",
    description=(
        "Unified backend engine for processing product RFID scans, RFID tag registration, "
        "product catalog management, transparent Eco Score calculations, sustainable alternatives, "
        "user scan history, and real-time Bluetooth hardware status."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS for mobile / web frontend development
raw_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080,http://127.0.0.1:8000")
origins = [origin.strip() for origin in raw_origins.split(",") if origin.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins if origins else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Routers
app.include_router(products.router)
app.include_router(rfid.router)
app.include_router(eco_score.router)
app.include_router(recommendations.router)
app.include_router(scans.router)
app.include_router(bluetooth.router)

# Mount static web app
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/", include_in_schema=False)
@app.get("/app", include_in_schema=False)
def serve_web_app():
    """Serve the interactive web demonstration interface."""
    index_path = os.path.join(static_dir, "index.html")
    if os.path.exists(index_path):
        return FileResponse(index_path)
    return {"message": "EcoMind AI Backend API running. Visit /docs for API documentation."}

@app.get("/api/health", tags=["Health Check"])
def health_check():
    """System health check endpoint."""
    return {
        "status": "ok",
        "service": "EcoMind AI Eco Decision Engine"
    }
