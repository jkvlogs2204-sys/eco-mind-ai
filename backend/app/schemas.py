from datetime import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field, field_validator, ConfigDict

class ProductBase(BaseModel):
    rfid_uid: Optional[str] = Field(None, description="Clean uppercase RFID UID string")
    product_name: str
    brand: str
    category: str
    material: str
    packaging: str
    carbon_footprint: float = Field(..., ge=0.0, description="Carbon footprint in kg CO2e")
    carbon_unit: str = "kg CO2e"
    water_footprint: float = Field(..., ge=0.0, description="Water footprint in litres")
    water_unit: str = "litres"
    recyclability: float = Field(..., ge=0.0, le=100.0, description="Recyclability percentage 0-100")
    reuse_potential: float = Field(..., ge=0.0, le=100.0, description="Reuse potential percentage 0-100")
    lifespan: int = Field(..., ge=1, description="Expected lifespan in days")
    description: Optional[str] = None
    disposal_guidance: Optional[str] = None
    data_status: str = "VERIFIED REAL DATA"

    @field_validator("rfid_uid")
    @classmethod
    def normalize_rfid(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return None
        v_clean = v.strip().upper()
        return v_clean if v_clean else None


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    product_name: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[str] = None
    material: Optional[str] = None
    packaging: Optional[str] = None
    carbon_footprint: Optional[float] = Field(None, ge=0.0)
    carbon_unit: Optional[str] = None
    water_footprint: Optional[float] = Field(None, ge=0.0)
    water_unit: Optional[str] = None
    recyclability: Optional[float] = Field(None, ge=0.0, le=100.0)
    reuse_potential: Optional[float] = Field(None, ge=0.0, le=100.0)
    lifespan: Optional[int] = Field(None, ge=1)
    description: Optional[str] = None
    disposal_guidance: Optional[str] = None
    data_status: Optional[str] = None


class ProductResponse(ProductBase):
    id: int
    eco_score: Optional[float] = None
    eco_grade: Optional[str] = None
    recommendation: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class RFIDTagBase(BaseModel):
    rfid_uid: str = Field(..., description="Unique RFID UID string")
    product_id: Optional[int] = None
    status: str = "UNASSIGNED"

    @field_validator("rfid_uid")
    @classmethod
    def normalize_uid(cls, v: str) -> str:
        v_clean = v.strip().upper().replace(" ", "").replace(":", "")
        if not v_clean:
            raise ValueError("RFID UID cannot be empty")
        return v_clean


class RFIDTagCreate(RFIDTagBase):
    pass


class RFIDAssignPayload(BaseModel):
    rfid_uid: Optional[str] = None
    product_id: int

class RFIDTagAssign(RFIDAssignPayload):
    rfid_uid: str


class RFIDTagResponse(RFIDTagBase):
    id: int
    product_name: Optional[str] = None
    category: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class ComponentScores(BaseModel):
    carbon: float
    water: float
    packaging: float
    recyclability: float
    reuse: float


class EcoScoreBreakdown(BaseModel):
    eco_score: float
    grade: str
    decision: str
    explanation: str
    components: ComponentScores


class EcoScoreInput(BaseModel):
    carbon_footprint: float = Field(..., ge=0.0)
    water_footprint: float = Field(..., ge=0.0)
    packaging: str
    recyclability: float = Field(..., ge=0.0, le=100.0)
    reuse_potential: float = Field(..., ge=0.0, le=100.0)


class BetterAlternative(BaseModel):
    id: int
    product_name: str
    brand: str
    category: str
    eco_score: float
    eco_grade: str
    reason: str


class RecommendationResponse(BaseModel):
    scanned_product_id: int
    scanned_product_name: str
    scanned_eco_score: float
    scanned_eco_grade: str
    better_alternative: Optional[BetterAlternative] = None


class GeminiInsight(BaseModel):
    summary: str
    why_this_score: str
    impact_drivers: List[str]
    positive_factors: List[str]
    actions: Dict[str, Optional[str]]
    better_alternative: Optional[str] = None
    disposal_guidance: str
    confidence_note: str
    source: str


class MobileProductResponse(BaseModel):
    registered: bool = True
    product: Dict[str, Any]
    environment: Dict[str, Any]
    eco_score: Dict[str, Any]
    recommendation: str
    ai_insight: GeminiInsight
    better_alternative: Optional[BetterAlternative] = None
    data_status: str


class ScanCreate(BaseModel):
    rfid_uid: str
    user_id: Optional[str] = "default_user"

    @field_validator("rfid_uid")
    @classmethod
    def normalize_rfid(cls, v: str) -> str:
        v_clean = v.strip().upper().replace(" ", "").replace(":", "")
        if not v_clean:
            raise ValueError("RFID UID cannot be empty")
        return v_clean

class ScanHistoryCreate(ScanCreate):
    pass


class ScanHistoryResponse(BaseModel):
    id: int
    user_id: Optional[str] = "default_user"
    product_id: Optional[int] = None
    rfid_uid: str
    product_name: str
    eco_score: float
    grade: str
    scanned_at: Optional[str] = None
    timestamp: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
