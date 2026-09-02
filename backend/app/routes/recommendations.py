from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..schemas import RecommendationResponse
from ..services.product_service import ProductService
from ..services.recommendation_engine import RecommendationEngine

router = APIRouter(prefix="/api/recommendations", tags=["Recommendations"])

@router.get("/{product_id}", response_model=RecommendationResponse)
def get_recommendation(product_id: int, db: Session = Depends(get_db)):
    """
    Get eco-friendly product recommendation/better alternative for a given scanned product.
    """
    product = ProductService.get_product_by_id(db, product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": f"Product with ID {product_id} not found"}
        )

    ProductService.ensure_calculated_score(db, product)
    alt = RecommendationEngine.find_better_alternative(db, product)

    return RecommendationResponse(
        scanned_product_id=product.id,
        scanned_product_name=product.product_name,
        scanned_eco_score=product.eco_score,
        scanned_eco_grade=product.eco_grade,
        better_alternative=alt
    )
