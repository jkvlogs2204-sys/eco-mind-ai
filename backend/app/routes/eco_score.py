from fastapi import APIRouter
from ..schemas import EcoScoreInput, EcoScoreBreakdown
from ..services.eco_engine import EcoEngine

router = APIRouter(prefix="/api/eco-score", tags=["Eco Score Engine"])

@router.post("/calculate", response_model=EcoScoreBreakdown)
def calculate_eco_score(payload: EcoScoreInput):
    """
    Calculate an explainable Eco Score (0-100), grade (A+ to E), and decision
    for arbitrary environmental parameters without database persistence.
    """
    eval_result = EcoEngine.evaluate(
        carbon_footprint=payload.carbon_footprint,
        water_footprint=payload.water_footprint,
        packaging=payload.packaging,
        recyclability=payload.recyclability,
        reuse_potential=payload.reuse_potential
    )

    return EcoScoreBreakdown(
        eco_score=eval_result["eco_score"],
        grade=eval_result["grade"],
        decision=eval_result["decision"],
        explanation=eval_result["explanation"],
        components=eval_result["components"]
    )
