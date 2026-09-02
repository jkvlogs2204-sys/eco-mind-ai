from typing import Optional, List
from sqlalchemy.orm import Session
from ..models import Product
from .eco_engine import EcoEngine

class ProductService:
    """
    Data access and business logic wrapper for Products.
    """

    @classmethod
    def get_all_products(cls, db: Session, limit: int = 100) -> List[Product]:
        return db.query(Product).limit(limit).all()

    @classmethod
    def get_product_by_id(cls, db: Session, product_id: int) -> Optional[Product]:
        return db.query(Product).filter(Product.id == product_id).first()

    @classmethod
    def get_product_by_rfid(cls, db: Session, rfid_uid: str) -> Optional[Product]:
        clean_uid = rfid_uid.strip().upper()
        return db.query(Product).filter(Product.rfid_uid == clean_uid).first()

    @classmethod
    def ensure_calculated_score(cls, db: Session, product: Product) -> Product:
        """
        Ensures product score, grade, and recommendations are populated.
        """
        if product.eco_score is None or product.eco_grade is None:
            eval_result = EcoEngine.evaluate(
                carbon_footprint=product.carbon_footprint,
                water_footprint=product.water_footprint,
                packaging=product.packaging,
                recyclability=product.recyclability,
                reuse_potential=product.reuse_potential
            )
            product.eco_score = eval_result["eco_score"]
            product.eco_grade = eval_result["grade"]
            product.recommendation = eval_result["explanation"]
            db.commit()
            db.refresh(product)
        return product
