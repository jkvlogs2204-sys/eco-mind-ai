from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import List, Optional

from app.database import get_db
from app.models import Product, RFIDTag, ScanHistory
from app.schemas import (
    ProductCreate, ProductResponse, MobileProductResponse
)
from app.services.eco_engine import EcoEngine
from app.services.gemini_service import GeminiService

router = APIRouter(prefix="/api/products", tags=["Product Catalog"])

@router.get("")
def list_products(db: Session = Depends(get_db)):
    products = db.query(Product).all()
    results = []
    for p in products:
        score_data = EcoEngine.evaluate(
            carbon_footprint=p.carbon_footprint,
            water_footprint=p.water_footprint,
            packaging=p.packaging,
            recyclability=p.recyclability,
            reuse_potential=p.reuse_potential
        )
        results.append({
            "id": p.id,
            "product_name": p.product_name,
            "brand": p.brand,
            "category": p.category,
            "material": p.material,
            "packaging": p.packaging,
            "carbon_footprint": p.carbon_footprint,
            "water_footprint": p.water_footprint,
            "recyclability": p.recyclability,
            "reuse_potential": p.reuse_potential,
            "lifespan": p.lifespan,
            "eco_score": score_data["eco_score"],
            "eco_grade": score_data["grade"],
            "data_status": p.data_status or "VERIFIED REAL DATA",
            "created_at": p.created_at.isoformat() if p.created_at else None,
        })
    return results


@router.get("/search")
def ai_search_products(
    q: str = Query(..., description="Natural language search query"),
    db: Session = Depends(get_db)
):
    """
    AI-powered product search using Gemini.
    Accepts natural language: 'low carbon drinks', 'glass recyclable', 'best eco score clothing'.
    Gemini extracts filters (brand, category, material, carbon, water, recyclability, sort).
    Falls back to keyword search if Gemini API key is not set.
    """
    # Parse query via Gemini AI (or rule-based fallback)
    filters = GeminiService.ai_parse_search_query(q)

    query_obj = db.query(Product)

    # ── Apply structured filters ──────────────────────────────────────
    # Keyword: search across name, brand, category, material
    keyword = filters.get("keyword")
    if keyword:
        kw = f"%{keyword}%"
        query_obj = query_obj.filter(
            or_(
                Product.product_name.ilike(kw),
                Product.brand.ilike(kw),
                Product.category.ilike(kw),
                Product.material.ilike(kw),
                Product.packaging.ilike(kw),
            )
        )

    # Exact / partial matches on specific fields
    if filters.get("brand"):
        query_obj = query_obj.filter(Product.brand.ilike(f"%{filters['brand']}%"))
    if filters.get("category"):
        query_obj = query_obj.filter(Product.category.ilike(f"%{filters['category']}%"))
    if filters.get("material"):
        query_obj = query_obj.filter(Product.material.ilike(f"%{filters['material']}%"))

    # Numeric range filters
    if filters.get("max_carbon") is not None:
        query_obj = query_obj.filter(Product.carbon_footprint <= filters["max_carbon"])
    if filters.get("max_water") is not None:
        query_obj = query_obj.filter(Product.water_footprint <= filters["max_water"])
    if filters.get("min_recyclability") is not None:
        query_obj = query_obj.filter(Product.recyclability >= filters["min_recyclability"])
    if filters.get("min_reuse") is not None:
        query_obj = query_obj.filter(Product.reuse_potential >= filters["min_reuse"])

    products = query_obj.all()

    # ── Score and sort results ────────────────────────────────────────
    results = []
    for p in products:
        score_data = EcoEngine.evaluate(
            carbon_footprint=p.carbon_footprint,
            water_footprint=p.water_footprint,
            packaging=p.packaging,
            recyclability=p.recyclability,
            reuse_potential=p.reuse_potential
        )
        eco_score = score_data["eco_score"]

        # Apply eco_score range filter (post-computation)
        if filters.get("min_eco_score") is not None and eco_score < filters["min_eco_score"]:
            continue
        if filters.get("max_eco_score") is not None and eco_score > filters["max_eco_score"]:
            continue

        results.append({
            "id": p.id,
            "product_name": p.product_name,
            "brand": p.brand,
            "category": p.category,
            "material": p.material,
            "packaging": p.packaging,
            "carbon_footprint": p.carbon_footprint,
            "water_footprint": p.water_footprint,
            "recyclability": p.recyclability,
            "reuse_potential": p.reuse_potential,
            "lifespan": p.lifespan,
            "eco_score": eco_score,
            "eco_grade": score_data["grade"],
            "decision": score_data["decision"],
            "data_status": p.data_status or "VERIFIED REAL DATA",
        })

    # ── Sort ──────────────────────────────────────────────────────────
    sort_by = filters.get("sort_by", "eco_score")
    sort_order = filters.get("sort_order", "desc")
    sort_map = {
        "eco_score": "eco_score",
        "carbon_footprint": "carbon_footprint",
        "water_footprint": "water_footprint",
        "recyclability": "recyclability",
        "product_name": "product_name",
    }
    sort_key = sort_map.get(sort_by, "eco_score")
    reverse = (sort_order == "desc")
    results.sort(key=lambda x: x.get(sort_key, 0), reverse=reverse)

    return {
        "query": q,
        "ai_powered": filters.get("ai_powered", False),
        "explanation": filters.get("explanation", ""),
        "filters_applied": {k: v for k, v in filters.items() if v is not None and k not in ("explanation", "ai_powered")},
        "total": len(results),
        "results": results,
    }



def get_product_by_rfid(rfid_uid: str, db: Session = Depends(get_db)):
    clean_uid = rfid_uid.strip().upper()
    tag = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()

    if not tag or not tag.product_id:
        raise HTTPException(
            status_code=404,
            detail={"registered": False, "message": f"RFID Tag UID {clean_uid} is unregistered or not assigned."}
        )

    product = db.query(Product).filter(Product.id == tag.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail={"registered": True, "message": "Assigned product not found."})

    # Compute Eco Score
    score_data = EcoEngine.evaluate(
        carbon_footprint=product.carbon_footprint,
        water_footprint=product.water_footprint,
        packaging=product.packaging,
        recyclability=product.recyclability,
        reuse_potential=product.reuse_potential
    )

    # Check for better alternative
    better_alt = EcoEngine.find_better_alternative(db, product, score_data["eco_score"])

    # Generate Gemini Sustainability AI Insight
    ai_insight = GeminiService.generate_sustainability_insight(
        product_id=product.id,
        product_name=product.product_name,
        brand=product.brand,
        category=product.category,
        material=product.material,
        packaging=product.packaging,
        carbon_footprint=product.carbon_footprint,
        water_footprint=product.water_footprint,
        recyclability=product.recyclability,
        reuse_potential=product.reuse_potential,
        lifespan=product.lifespan,
        eco_score=score_data["eco_score"],
        eco_grade=score_data["grade"],
        decision=score_data["decision"],
        data_status=product.data_status or "VERIFIED REAL DATA",
        components=score_data["components"],
        better_alt_name=better_alt["product_name"] if better_alt else None
    )

    return {
        "registered": True,
        "product": {
            "id": product.id,
            "name": product.product_name,
            "brand": product.brand,
            "category": product.category,
            "material": product.material,
            "description": f"Verified product: {product.product_name} by {product.brand}."
        },
        "environment": {
            "carbon": {"value": product.carbon_footprint, "unit": "kg CO2e"},
            "water": {"value": product.water_footprint, "unit": "litres"},
            "packaging": product.packaging,
            "recyclability": product.recyclability,
            "reuse_potential": product.reuse_potential,
            "lifespan_days": product.lifespan,
            "disposal_guidance": f"Recycle or dispose according to {product.material} standards."
        },
        "eco_score": {
            "value": score_data["eco_score"],
            "grade": score_data["grade"],
            "decision": score_data["decision"],
            "explanation": score_data["explanation"],
            "components": score_data["components"]
        },
        "recommendation": score_data["explanation"],
        "ai_insight": ai_insight,
        "better_alternative": better_alt,
        "data_status": product.data_status or "VERIFIED REAL DATA"
    }


@router.post("", response_model=ProductResponse)
def create_product(product_in: ProductCreate, db: Session = Depends(get_db)):
    new_prod = Product(
        product_name=product_in.product_name,
        brand=product_in.brand,
        category=product_in.category,
        material=product_in.material,
        carbon_footprint=product_in.carbon_footprint,
        water_footprint=product_in.water_footprint,
        packaging=product_in.packaging,
        recyclability=product_in.recyclability,
        reuse_potential=product_in.reuse_potential,
        lifespan=product_in.lifespan,
        data_status=product_in.data_status or "VERIFIED REAL DATA"
    )
    db.add(new_prod)
    db.commit()
    db.refresh(new_prod)

    score_data = EcoEngine.evaluate(
        carbon_footprint=new_prod.carbon_footprint,
        water_footprint=new_prod.water_footprint,
        packaging=new_prod.packaging,
        recyclability=new_prod.recyclability,
        reuse_potential=new_prod.reuse_potential
    )

    return {
        "id": new_prod.id,
        "product_name": new_prod.product_name,
        "brand": new_prod.brand,
        "category": new_prod.category,
        "material": new_prod.material,
        "eco_score": score_data["eco_score"],
        "eco_grade": score_data["grade"],
        "data_status": new_prod.data_status
    }


@router.delete("/{product_id}", status_code=status.HTTP_200_OK)
def delete_product(product_id: int, db: Session = Depends(get_db)):
    prod = db.query(Product).filter(Product.id == product_id).first()
    if not prod:
        raise HTTPException(status_code=404, detail="Product not found")

    # Unassign RFID tags linked to this product
    tags = db.query(RFIDTag).filter(RFIDTag.product_id == product_id).all()
    for t in tags:
        t.product_id = None
        t.status = "UNASSIGNED"

    db.delete(prod)
    db.commit()
    return {"message": f"Product {product_id} deleted successfully."}
