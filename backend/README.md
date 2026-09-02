# Eco Decision Engine — Backend API

The **Eco Decision Engine** is the central backend REST API for **EcoMind AI**. Built using Python, FastAPI, and SQLAlchemy (SQLite/PostgreSQL ready), it receives RFID UIDs from Part 1, queries product environmental characteristics, computes transparent Eco Scores (0–100 & A+ to E grades), provides comparative sustainable recommendations, and logs scan history.

---

## Architecture Overview

```text
RFID UID (Part 1 Broadcast)
          ↓
  GET /api/products/rfid/{rfid_uid}
          ↓
   Product Lookup
          ↓
  Eco Score Algorithm (Carbon, Water, Packaging, Recyclability, Reuse)
          ↓
  Decision & Alternative Recommendation
          ↓
  JSON Response to EcoMind Mobile App (Part 3)
```

---

## 1. Setup & Installation

### Prerequisites
- Python 3.9+ installed
- `pip` package manager

### Environment Setup

1. Create a virtual environment:
   ```bash
   python -m venv venv
   ```
2. Activate the virtual environment:
   - **Windows**: `venv\Scripts\activate`
   - **macOS/Linux**: `source venv/bin/activate`

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create configuration file:
   ```bash
   cp .env.example .env
   ```

---

## 2. Database Initialization & Seeding

Populate the SQLite database with 10 demonstration products across multiple categories (Beverage, Food, Personal Care, Household, Stationery, Electronics, Clothing):

```bash
python seed.py
```

Expected output:
```text
Seeding database with 10 demonstration products...
Database seeding completed successfully!
```

---

## 3. Running the API Server

Start the server using `uvicorn`:

```bash
uvicorn app.main:app --reload --port 8000
```

The server will start at `http://127.0.0.1:8000`.

---

## 4. Interactive API Documentation (Swagger UI)

FastAPI provides automatic interactive documentation:
- **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

---

## 5. Primary API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/health` | Health check endpoint |
| `GET` | `/api/products` | List all registered products |
| `GET` | `/api/products/{id}` | Get product details by primary key ID |
| `GET` | `/api/products/rfid/{rfid_uid}` | Get mobile-formatted product data by RFID UID |
| `POST`| `/api/eco-score/calculate` | Calculate Eco Score breakdown for arbitrary parameters |
| `GET` | `/api/recommendations/{product_id}` | Find eco-friendly alternative for a product |
| `POST`| `/api/scan` | Log an RFID product scan event |
| `GET` | `/api/history/{user_id}` | Retrieve scan history for a user |

---

## 6. Eco Score Calculation Engine

Scoring is transparent and explainable:

$$\text{Eco Score} = 0.30(\text{Carbon}) + 0.20(\text{Water}) + 0.15(\text{Packaging}) + 0.20(\text{Recyclability}) + 0.15(\text{Reuse})$$

### Grade & Decision Mapping

| Score Range | Grade | Decision |
| :--- | :--- | :--- |
| **90 – 100** | **A+** | EXCELLENT CHOICE |
| **80 – 89** | **A** | EXCELLENT CHOICE |
| **70 – 79** | **B** | GOOD CHOICE |
| **60 – 69** | **C** | MODERATE IMPACT |
| **50 – 59** | **D** | HIGH IMPACT |
| **0 – 49** | **E** | VERY HIGH IMPACT |

---

## 7. Running Tests

Run the automated test suite using `pytest`:

```bash
pytest tests/
```

---

## 8. Scientific Honesty & Data Labelling

> [!IMPORTANT]
> **Data Transparency Notice:**
> RFID technology **identifies** products; it does not directly measure carbon or water footprints. All product environmental metrics in the database carry explicit `data_status` tags (`DEMO DATA`, `ESTIMATED DATA`, or `VERIFIED DATA`).
