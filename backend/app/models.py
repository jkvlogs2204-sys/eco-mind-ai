from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from .database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    rfid_uid = Column(String, unique=True, index=True, nullable=True)  # Kept for backward compatibility
    product_name = Column(String, nullable=False)
    brand = Column(String, nullable=False)
    category = Column(String, nullable=False, index=True)
    material = Column(String, nullable=False)
    packaging = Column(String, nullable=False)
    
    # Environmental Metrics
    carbon_footprint = Column(Float, nullable=False)  # e.g., 0.12
    carbon_unit = Column(String, default="kg CO2e")
    water_footprint = Column(Float, nullable=False)   # e.g., 2.4
    water_unit = Column(String, default="litres")
    recyclability = Column(Float, nullable=False)     # 0 - 100 percentage
    reuse_potential = Column(Float, nullable=False)   # 0 - 100 percentage
    lifespan = Column(Integer, nullable=False)        # in days or uses

    # Stored Eco Calculations
    eco_score = Column(Float, nullable=True)          # 0 - 100
    eco_grade = Column(String, nullable=True)          # A+, A, B, C, D, E
    recommendation = Column(String, nullable=True)
    disposal_guidance = Column(String, nullable=True)
    description = Column(String, nullable=True)
    data_status = Column(String, default="DEMO DATA") # DEMO DATA, ESTIMATED DATA, VERIFIED DATA

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    scans = relationship("ScanHistory", back_populates="product")
    rfid_tags = relationship("RFIDTag", back_populates="product")


class RFIDTag(Base):
    __tablename__ = "rfid_tags"

    id = Column(Integer, primary_key=True, index=True)
    rfid_uid = Column(String, unique=True, index=True, nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    status = Column(String, default="UNASSIGNED")  # ASSIGNED, UNASSIGNED
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    product = relationship("Product", back_populates="rfid_tags")


class ScanHistory(Base):
    __tablename__ = "scan_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, default="default_user", index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    rfid_uid = Column(String, nullable=False)
    eco_score = Column(Float, nullable=False)
    eco_grade = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    product = relationship("Product", back_populates="scans")
