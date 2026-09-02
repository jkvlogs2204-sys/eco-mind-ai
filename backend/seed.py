from app.database import SessionLocal, Base, engine
from app.models import Product, RFIDTag

def seed_database(db=None):
    close_when_done = False
    if db is None:
        Base.metadata.create_all(bind=engine)
        db = SessionLocal()
        close_when_done = True

    try:
        # Clear existing tables for clean seed
        db.query(RFIDTag).delete()
        db.query(Product).delete()
        db.commit()

        products_data = [
            {
                "product_name": "Reusable Steel Thermal Bottle",
                "brand": "EcoMind Green",
                "category": "Beverage Containers",
                "material": "18/8 Stainless Steel & Food-grade Silicone",
                "carbon_footprint": 0.08,
                "water_footprint": 0.5,
                "packaging": "Recyclable Cardboard Box",
                "recyclability": 95.0,
                "reuse_potential": 98.0,
                "lifespan": 1825,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["A1B2C3D4", "11223344"]
            },
            {
                "product_name": "Organic Cotton Tote Bag",
                "brand": "Pure Earth",
                "category": "Bags & Carriers",
                "material": "100% GOTS Certified Organic Cotton",
                "carbon_footprint": 0.15,
                "water_footprint": 12.0,
                "packaging": "Paper Band (Zero Plastic)",
                "recyclability": 90.0,
                "reuse_potential": 95.0,
                "lifespan": 730,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["E5F6A7B8"]
            },
            {
                "product_name": "Biodegradable Bamboo Toothbrush",
                "brand": "EcoSmile",
                "category": "Personal Care",
                "material": "Moso Bamboo & Castor Oil Nylon Bristles",
                "carbon_footprint": 0.05,
                "water_footprint": 0.2,
                "packaging": "Compostable Kraft Box",
                "recyclability": 85.0,
                "reuse_potential": 10.0,
                "lifespan": 90,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["C9D0E1F2"]
            },
            {
                "product_name": "Single-Use Plastic Water Bottle (500ml)",
                "brand": "AquaFast",
                "category": "Beverage Containers",
                "material": "PET Plastic",
                "carbon_footprint": 2.4,
                "water_footprint": 4.5,
                "packaging": "Single-use Plastic Wrap",
                "recyclability": 30.0,
                "reuse_potential": 5.0,
                "lifespan": 1,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["33445566"]
            },
            {
                "product_name": "Recycled Glass Food Storage Container",
                "brand": "ZeroWaste Kitchen",
                "category": "Kitchenware",
                "material": "Borosilicate Recycled Glass & Bamboo Lid",
                "carbon_footprint": 0.35,
                "water_footprint": 1.2,
                "packaging": "Recyclable Paper Sleeve",
                "recyclability": 98.0,
                "reuse_potential": 92.0,
                "lifespan": 1460,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["77889900"]
            },
            {
                "product_name": "Styrofoam Disposable Takeout Box",
                "brand": "FastPack",
                "category": "Food Packaging",
                "material": "Expanded Polystyrene (Styrofoam)",
                "carbon_footprint": 3.8,
                "water_footprint": 8.0,
                "packaging": "Plastic Film Bundle",
                "recyclability": 5.0,
                "reuse_potential": 0.0,
                "lifespan": 1,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["AA11BB22"]
            },
            {
                "product_name": "Solar Powered Portable Power Bank",
                "brand": "SunVolt Eco",
                "category": "Electronics",
                "material": "Recycled Aluminum & Monocrystalline Solar Panel",
                "carbon_footprint": 1.2,
                "water_footprint": 15.0,
                "packaging": "Cardboard Box with Soy Ink",
                "recyclability": 75.0,
                "reuse_potential": 88.0,
                "lifespan": 1095,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["CC33DD44"]
            },
            {
                "product_name": "Refillable Natural Deodorant Stick",
                "brand": "CleanBody Co.",
                "category": "Personal Care",
                "material": "Refillable Stainless Steel Case & Plant Formulas",
                "carbon_footprint": 0.12,
                "water_footprint": 0.8,
                "packaging": "Compostable Paper Cartridge",
                "recyclability": 92.0,
                "reuse_potential": 95.0,
                "lifespan": 1095,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["EE55FF66"]
            },
            {
                "product_name": "Virgin Plastic Disposable Cutlery Set",
                "brand": "PartyQuick",
                "category": "Utensils",
                "material": "Polystyrene Plastic",
                "carbon_footprint": 1.8,
                "water_footprint": 3.2,
                "packaging": "Plastic Pouch",
                "recyclability": 15.0,
                "reuse_potential": 2.0,
                "lifespan": 1,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["99001122"]
            },
            {
                "product_name": "Upcycled Denim Laptop Sleeve",
                "brand": "ReThread",
                "category": "Accessories",
                "material": "100% Upcycled Post-consumer Denim",
                "carbon_footprint": 0.22,
                "water_footprint": 0.4,
                "packaging": "Minimal Paper Tag",
                "recyclability": 85.0,
                "reuse_potential": 90.0,
                "lifespan": 1825,
                "data_status": "VERIFIED REAL DATA",
                "rfid_uids": ["55667788"]
            }
        ]

        for p_item in products_data:
            p_dict = dict(p_item)
            rfid_uids = p_dict.pop("rfid_uids", [])
            product = Product(**p_dict)
            db.add(product)
            db.commit()
            db.refresh(product)

            for uid in rfid_uids:
                tag = RFIDTag(rfid_uid=uid, product_id=product.id, status="ASSIGNED")
                db.add(tag)

        # Register two additional unassigned physical tags for demonstration
        unassigned = ["FF00AA11", "99887766"]
        for uid in unassigned:
            tag = RFIDTag(rfid_uid=uid, product_id=None, status="UNASSIGNED")
            db.add(tag)

        db.commit()

    finally:
        if close_when_done:
            db.close()

if __name__ == "__main__":
    seed_database()
