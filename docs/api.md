# Eco Decision Engine — REST API Documentation

The **Eco Decision Engine** exposes a RESTful JSON API implemented with FastAPI.

Base URL (Development): `http://localhost:8000` or `http://10.0.2.2:8000` (Android Emulator).

---

## Endpoints

### 1. Health Check
```http
GET /api/health
```
**Response (200 OK):**
```json
{
  "status": "ok",
  "service": "EcoMind AI Eco Decision Engine"
}
```

### 2. List All Products
```http
GET /api/products
```
**Response (200 OK):**
Returns a list of all registered products in the database with pre-calculated Eco Scores.

### 3. Mobile Product Lookup by RFID UID
```http
GET /api/products/rfid/{rfid_uid}
```
**Path Parameters:**
- `rfid_uid` (string, required): RFID tag UID (automatically normalized to uppercase, e.g. `A1B2C3D4`).

**Response (200 OK):**
```json
{
  "product": {
    "id": 1,
    "name": "Reusable Steel Thermal Bottle",
    "brand": "EcoMind Green",
    "category": "Beverage Containers",
    "material": "18/8 Stainless Steel & Food-grade Silicone",
    "description": "Premium double-wall vacuum insulated reusable water bottle."
  },
  "environment": {
    "carbon": { "value": 0.08, "unit": "kg CO2e" },
    "water": { "value": 0.5, "unit": "litres" },
    "packaging": "Recyclable Cardboard Box",
    "recyclability": 95.0,
    "reuse_potential": 98.0,
    "lifespan_days": 1825,
    "disposal_guidance": "100% recyclable at metal processing centers."
  },
  "eco_score": {
    "value": 96.5,
    "grade": "A+",
    "decision": "EXCELLENT CHOICE",
    "explanation": "This product has an outstanding Eco Score with high sustainability performance across key metrics.",
    "components": {
      "carbon": 97.6,
      "water": 95.0,
      "packaging": 80.0,
      "recyclability": 95.0,
      "reuse": 98.0
    }
  },
  "recommendation": "This product has an outstanding Eco Score with high sustainability performance across key metrics.",
  "better_alternative": null,
  "data_status": "DEMO DATA"
}
```

### 4. Real-time Score Calculation
```http
POST /api/eco-score/calculate
```
**Request Body:**
```json
{
  "carbon_footprint": 0.12,
  "water_footprint": 2.4,
  "packaging": "Plastic",
  "recyclability": 75.0,
  "reuse_potential": 20.0
}
```

### 5. Product Recommendation
```http
GET /api/recommendations/{product_id}
```
Returns a higher-scoring product in the same category along with a comparative rationale.

### 6. Record RFID Scan Event
```http
POST /api/scan
```
**Request Body:**
```json
{
  "rfid_uid": "A1B2C3D4",
  "user_id": "default_user"
}
```

### 7. User Scan History
```http
GET /api/history/{user_id}
```
Returns chronological list of previous scans for the specified user.
