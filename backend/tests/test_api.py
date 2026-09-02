import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db
from app.services.eco_engine import EcoEngine
from app.services.gemini_service import GeminiService
from seed import seed_database

# Use SQLite with StaticPool so all threads/sessions share the exact same in-memory DB
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    seed_database(db)
    yield
    db.close()
    Base.metadata.drop_all(bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_rfid_normalization_and_lookup_with_ai_insight():
    # Lowercase input should be normalized to uppercase A1B2C3D4
    response = client.get("/api/products/rfid/a1b2c3d4")
    assert response.status_code == 200
    data = response.json()
    assert data["registered"] is True
    assert data["product"]["name"] == "Reusable Steel Thermal Bottle"
    assert data["eco_score"]["grade"] in ["A+", "A"]
    assert data["data_status"] == "VERIFIED REAL DATA"

    # Verify structured AI insight presence
    ai = data["ai_insight"]
    assert "summary" in ai
    assert "why_this_score" in ai
    assert "impact_drivers" in ai
    assert "positive_factors" in ai
    assert "actions" in ai
    assert "confidence_note" in ai


def test_unknown_rfid_returns_404():
    response = client.get("/api/products/rfid/UNKNOWN999")
    assert response.status_code == 404


def test_gemini_fallback_service():
    # Calling GeminiService without API key must return structured fallback
    insight = GeminiService.generate_sustainability_insight(
        product_id=1,
        product_name="Test Bottle",
        brand="EcoBrand",
        category="Beverage",
        material="Steel",
        packaging="Cardboard",
        carbon_footprint=0.1,
        water_footprint=0.5,
        recyclability=90.0,
        reuse_potential=95.0,
        lifespan=365,
        eco_score=94.0,
        eco_grade="A+",
        decision="EXCELLENT CHOICE",
        data_status="VERIFIED REAL DATA",
        components={"carbon": 90.0, "water": 90.0, "packaging": 80.0, "recyclability": 90.0, "reuse": 95.0}
    )
    assert insight is not None
    assert "summary" in insight
    assert "actions" in insight
    assert "source" in insight


def test_eco_score_immutability_with_gemini():
    # Ensure Gemini service does NOT alter score or decision
    eval_res = EcoEngine.evaluate(
        carbon_footprint=2.4,
        water_footprint=4.5,
        packaging="Single-use Plastic Wrap",
        recyclability=30.0,
        reuse_potential=10.0
    )
    assert eval_res["grade"] == "E"
    assert eval_res["decision"] == "VERY HIGH IMPACT"

    insight = GeminiService.generate_sustainability_insight(
        product_id=2,
        product_name="Plastic Bottle",
        brand="AquaFast",
        category="Beverage",
        material="PET Plastic",
        packaging="Plastic",
        carbon_footprint=2.4,
        water_footprint=4.5,
        recyclability=30.0,
        reuse_potential=10.0,
        lifespan=1,
        eco_score=eval_res["eco_score"],
        eco_grade=eval_res["grade"],
        decision=eval_res["decision"],
        data_status="VERIFIED REAL DATA",
        components=eval_res["components"]
    )
    # The official score in eval_res must remain unchanged
    assert eval_res["grade"] == "E"
    assert eval_res["decision"] == "VERY HIGH IMPACT"


def test_score_boundary_decision_mappings():
    # Test 100 -> GREEN / A+
    g100, d100 = EcoEngine.calculate_grade(100.0)
    assert g100 == "A+"
    assert d100 == "EXCELLENT CHOICE"

    # Test 80 -> GREEN / A
    g80, d80 = EcoEngine.calculate_grade(80.0)
    assert g80 == "A"
    assert d80 == "GOOD CHOICE"

    # Test 79 -> YELLOW / B
    g79, d79 = EcoEngine.calculate_grade(79.0)
    assert g79 == "B"
    assert d79 == "MODERATE IMPACT"

    # Test 60 -> YELLOW / C
    g60, d60 = EcoEngine.calculate_grade(60.0)
    assert g60 == "C"
    assert d60 == "MODERATE IMPACT"

    # Test 59 -> RED / D
    g59, d59 = EcoEngine.calculate_grade(59.0)
    assert g59 == "D"
    assert d59 == "HIGH IMPACT"

    # Test 0 -> RED / E
    g0, d0 = EcoEngine.calculate_grade(0.0)
    assert g0 == "E"
    assert d0 == "VERY HIGH IMPACT"
