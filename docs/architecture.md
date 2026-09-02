# EcoMind AI — System Architecture (Unidirectional One-Way Flow)

EcoMind AI implements a strict **unidirectional physical decision architecture**:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ECOMIND AI SYSTEM FLOW                           │
└─────────────────────────────────────────────────────────────────────────────┘

    PHYSICAL RFID TAG
           │
           ▼
    MFRC522 SENSOR
           │
           ▼
     ARDUINO UNO
           │
           ▼ (Bluetooth Transmission: PRODUCT:<UID>\n)
    HC-05 BLUETOOTH
           │
           ▼
   FLUTTER MOBILE APP
           │
           ▼ (REST API: GET /api/products/rfid/<UID>)
    FASTAPI BACKEND
           │
           ▼ (Database Query & LCA Computation)
  ECO SCORE ENGINE + GEMINI AI
           │
           ▼ (Structured Response)
   FLUTTER RESULT SCREEN
```

> [!NOTE]
> **UNIDIRECTIONAL ARCHITECTURE:**
> Bluetooth communication is strictly one-way (`Arduino -> HC-05 -> Flutter`). The Flutter application **does not send return decision commands (`GREEN`, `YELLOW`, `RED`) back to the Arduino**. Arduino's single hardware responsibility is detecting physical RFID tags and transmitting `PRODUCT:<UID>` over Bluetooth.

---

## Component Roles & Responsibilities

| Layer | Technology | Primary Function |
| :--- | :--- | :--- |
| **Physical Identification** | MFRC522 + Arduino Uno | Reads physical RFID tag UID and broadcasts `PRODUCT:<UID>\n`. |
| **Wireless Transport** | HC-05 Bluetooth | Transmits UID bytes unidirectionally from Arduino to Mobile App. |
| **Client Application** | Flutter / Dart | Listens to Bluetooth stream, applies 2.5s scan debounce, fetches REST API, and renders `ResultScreen`. |
| **Backend Engine** | Python FastAPI + SQLite | Performs database lookups (`rfid_tags` -> `products`) and computes transparent Eco Scores. |
| **AI Intelligence Layer**| Google Gemini AI (`gemini-3.6-flash`) | Generates qualitative sustainability explanations, key footprint drivers, positive factors, reduce/reuse/repair suggestions, and recycling advice. |
