from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import ScanHistory
from ..schemas import ScanCreate, ScanHistoryResponse
from ..services.product_service import ProductService

router = APIRouter(tags=["Scan History"])

@router.post("/api/scan", response_model=ScanHistoryResponse, status_code=status.HTTP_201_CREATED)
def record_scan(payload: ScanCreate, db: Session = Depends(get_db)):
    """
    Log an RFID scan event sent from mobile app/Part 1 integration.
    """
    clean_uid = payload.rfid_uid.strip().upper()
    if not clean_uid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "RFID UID cannot be empty"}
        )

    product = ProductService.get_product_by_rfid(db, clean_uid)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": "Product not found for RFID scan", "rfid_uid": clean_uid}
        )

    ProductService.ensure_calculated_score(db, product)

    scan_item = ScanHistory(
        user_id=payload.user_id or "default_user",
        product_id=product.id,
        rfid_uid=clean_uid,
        eco_score=product.eco_score,
        eco_grade=product.eco_grade
    )
    db.add(scan_item)
    db.commit()
    db.refresh(scan_item)

    return ScanHistoryResponse(
        id=scan_item.id,
        user_id=scan_item.user_id,
        product_id=scan_item.product_id,
        rfid_uid=scan_item.rfid_uid,
        product_name=product.product_name,
        eco_score=scan_item.eco_score,
        eco_grade=scan_item.eco_grade,
        timestamp=scan_item.timestamp
    )


@router.get("/api/history/{user_id}", response_model=List[ScanHistoryResponse])
def get_user_scan_history(user_id: str, db: Session = Depends(get_db)):
    """
    Retrieve scan history log for a specific user ID.
    """
    history_items = db.query(ScanHistory).filter(ScanHistory.user_id == user_id).order_by(ScanHistory.timestamp.desc()).all()
    results = []
    for item in history_items:
        prod_name = item.product.product_name if item.product else "Unknown Product"
        results.append(
            ScanHistoryResponse(
                id=item.id,
                user_id=item.user_id,
                product_id=item.product_id,
                rfid_uid=item.rfid_uid,
                product_name=prod_name,
                eco_score=item.eco_score,
                eco_grade=item.eco_grade,
                timestamp=item.timestamp
            )
        )
    return results
