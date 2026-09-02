from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import RFIDTag, Product
from ..schemas import RFIDTagCreate, RFIDTagResponse, RFIDAssignPayload

router = APIRouter(prefix="/api/rfid", tags=["RFID Management"])

def normalize_uid_str(uid: str) -> str:
    clean = uid.strip().upper().replace(" ", "").replace(":", "")
    if not clean:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "RFID UID cannot be empty"}
        )
    return clean

@router.get("", response_model=List[RFIDTagResponse])
def list_rfid_tags(query: Optional[str] = None, db: Session = Depends(get_db)):
    """List registered RFID tags with optional search filter."""
    q = db.query(RFIDTag)
    if query:
        clean_q = query.strip().upper()
        q = q.filter(RFIDTag.rfid_uid.contains(clean_q))
    
    tags = q.order_by(RFIDTag.created_at.desc()).all()
    results = []
    for tag in tags:
        prod_name = tag.product.product_name if tag.product else None
        cat = tag.product.category if tag.product else None
        results.append(
            RFIDTagResponse(
                id=tag.id,
                rfid_uid=tag.rfid_uid,
                product_id=tag.product_id,
                status=tag.status,
                product_name=prod_name,
                category=cat,
                created_at=tag.created_at,
                updated_at=tag.updated_at
            )
        )
    return results


@router.post("", response_model=RFIDTagResponse, status_code=status.HTTP_201_CREATED)
def register_rfid_tag(payload: RFIDTagCreate, db: Session = Depends(get_db)):
    """
    Register a new RFID tag with duplicate UID protection.
    """
    clean_uid = normalize_uid_str(payload.rfid_uid)

    existing = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()
    if existing:
        prod_name = existing.product.product_name if existing.product else "Unassigned"
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "error": "RFID Already Registered",
                "rfid_uid": clean_uid,
                "message": f"RFID {clean_uid} is already registered to: {prod_name}",
                "existing_id": existing.id
            }
        )

    # Validate product_id if provided
    status_str = "UNASSIGNED"
    if payload.product_id:
        prod = db.query(Product).filter(Product.id == payload.product_id).first()
        if not prod:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": f"Product with ID {payload.product_id} not found"}
            )
        status_str = "ASSIGNED"

    new_tag = RFIDTag(
        rfid_uid=clean_uid,
        product_id=payload.product_id,
        status=status_str
    )
    db.add(new_tag)
    db.commit()
    db.refresh(new_tag)

    prod_name = new_tag.product.product_name if new_tag.product else None
    cat = new_tag.product.category if new_tag.product else None

    return RFIDTagResponse(
        id=new_tag.id,
        rfid_uid=new_tag.rfid_uid,
        product_id=new_tag.product_id,
        status=new_tag.status,
        product_name=prod_name,
        category=cat,
        created_at=new_tag.created_at,
        updated_at=new_tag.updated_at
    )


@router.get("/{uid}", response_model=RFIDTagResponse)
def get_rfid_tag(uid: str, db: Session = Depends(get_db)):
    """Retrieve details for a specific RFID tag."""
    clean_uid = normalize_uid_str(uid)
    tag = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()
    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": "RFID Tag not found", "rfid_uid": clean_uid}
        )
    prod_name = tag.product.product_name if tag.product else None
    cat = tag.product.category if tag.product else None

    return RFIDTagResponse(
        id=tag.id,
        rfid_uid=tag.rfid_uid,
        product_id=tag.product_id,
        status=tag.status,
        product_name=prod_name,
        category=cat,
        created_at=tag.created_at,
        updated_at=tag.updated_at
    )


@router.post("/{uid}/assign", response_model=RFIDTagResponse)
def assign_rfid_tag(uid: str, payload: RFIDAssignPayload, db: Session = Depends(get_db)):
    """Assign an RFID tag to a specific product."""
    clean_uid = normalize_uid_str(uid)
    tag = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()
    
    # Auto-register tag if it doesn't exist yet
    if not tag:
        tag = RFIDTag(rfid_uid=clean_uid, status="UNASSIGNED")
        db.add(tag)
        db.commit()
        db.refresh(tag)

    product = db.query(Product).filter(Product.id == payload.product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": f"Product with ID {payload.product_id} not found"}
        )

    tag.product_id = product.id
    tag.status = "ASSIGNED"
    product.rfid_uid = clean_uid  # Keep legacy field in sync
    db.commit()
    db.refresh(tag)

    return RFIDTagResponse(
        id=tag.id,
        rfid_uid=tag.rfid_uid,
        product_id=tag.product_id,
        status=tag.status,
        product_name=product.product_name,
        category=product.category,
        created_at=tag.created_at,
        updated_at=tag.updated_at
    )


@router.post("/{uid}/unassign", response_model=RFIDTagResponse)
def unassign_rfid_tag(uid: str, db: Session = Depends(get_db)):
    """Unassign an RFID tag from its current product."""
    clean_uid = normalize_uid_str(uid)
    tag = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()
    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": "RFID Tag not found", "rfid_uid": clean_uid}
        )

    tag.product_id = None
    tag.status = "UNASSIGNED"
    db.commit()
    db.refresh(tag)

    return RFIDTagResponse(
        id=tag.id,
        rfid_uid=tag.rfid_uid,
        product_id=None,
        status="UNASSIGNED",
        product_name=None,
        category=None,
        created_at=tag.created_at,
        updated_at=tag.updated_at
    )


@router.delete("/{uid}", status_code=status.HTTP_200_OK)
def delete_rfid_tag(uid: str, db: Session = Depends(get_db)):
    """Delete an RFID tag from the registry."""
    clean_uid = normalize_uid_str(uid)
    tag = db.query(RFIDTag).filter(RFIDTag.rfid_uid == clean_uid).first()
    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": "RFID Tag not found", "rfid_uid": clean_uid}
        )

    db.delete(tag)
    db.commit()
    return {"message": f"RFID tag {clean_uid} successfully deleted"}
