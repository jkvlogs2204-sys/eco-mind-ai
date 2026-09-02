from typing import Optional, Dict, Any
from sqlalchemy.orm import Session
from ..models import Product

class RecommendationEngine:
    """
    Service to evaluate scanned products and find higher-scoring sustainable alternatives.
    """

    @classmethod
    def find_better_alternative(cls, db: Session, target_product: Product) -> Optional[Dict[str, Any]]:
        """
        Searches for a product in the same or related category with a significantly higher eco_score.
        """
        # Find candidates in the same category with higher eco score
        candidates = db.query(Product).filter(
            Product.category == target_product.category,
            Product.id != target_product.id,
            Product.eco_score > target_product.eco_score
        ).order_by(Product.eco_score.desc()).all()

        # Fallback to general products if category match isn't available
        if not candidates:
            candidates = db.query(Product).filter(
                Product.id != target_product.id,
                Product.eco_score > (target_product.eco_score + 10.0)
            ).order_by(Product.eco_score.desc()).all()

        if not candidates:
            return None

        best = candidates[0]
        
        # Build explanation of why this alternative is recommended
        reasons = []
        if best.reuse_potential > target_product.reuse_potential:
            reasons.append("Higher reuse potential and longer lifespan")
        if best.recyclability > target_product.recyclability:
            reasons.append("Superior recyclability rating")
        if best.carbon_footprint < target_product.carbon_footprint:
            reasons.append("Significantly lower carbon footprint")
        if best.water_footprint < target_product.water_footprint:
            reasons.append("Lower water footprint")

        reason_str = ", ".join(reasons) if reasons else "Overall superior environmental eco-score performance."

        return {
            "id": best.id,
            "product_name": best.product_name,
            "brand": best.brand,
            "category": best.category,
            "eco_score": best.eco_score,
            "eco_grade": best.eco_grade,
            "reason": reason_str
        }
