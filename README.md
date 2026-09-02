# EcoMind AI — Complete End-to-End System

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: Arduino](https://img.shields.io/badge/Platform-Arduino%20Uno-blue.svg)](https://www.arduino.cc/)
[![Backend: FastAPI](https://img.shields.io/badge/Backend-FastAPI%20Python-009688.svg)](https://fastapi.tiangolo.com/)
[![Mobile: Flutter](https://img.shields.io/badge/Mobile-Flutter%20Material%203-02569B.svg)](https://flutter.dev/)

**EcoMind AI** is an integrated hardware-software sustainability solution that physically scans products via RFID, evaluates their environmental impact using a transparent decision engine, displays detailed analysis on a mobile app, and visualizes sustainability scores on a physical mechanical indicator.

---

## 4-Part Integrated Architecture

```text
                ECOMIND AI SYSTEM ARCHITECTURE
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
   PHYSICAL WORLD                             DIGITAL WORLD
        │                                         │
   PHYSICAL PRODUCT                               │
        ↓                                         │
   RFID TAG                                       │
        ↓                                         │
[PART 1: ECO SCAN]                                │
Arduino Uno + MFRC522                             │
        ↓                                         │
   HC-05 BLUETOOTH ────────────────────────→ [PART 3: ECOMIND MOBILE]
                                                  │ (Flutter Android App)
                                                  ↓
                                           [PART 2: DECISION ENGINE]
                                           (FastAPI Python REST Server)
                                                  │
                                                  ↓
                                             ECO SCORE & GRADE
                                                  │
                                                  ↓
                                           DECISION COMMAND
                                          (GREEN / YELLOW / RED)
                                                  │
      ┌───────────────────────────────────────────┘
      ↓
   HC-05 BLUETOOTH
      ↓
[PART 4: PHYSICAL INDICATOR]
Arduino Uno Controller
 ┌────┼──────────┐
 ↓    ↓          ↓
LED  SERVO     BUZZER
```

---

## Deliverables & Directory Structure

```text
ecomind-ai/
│
├── arduino/                           # Embedded Firmware (Parts 1 & 4)
│   ├── ecomind_scanner/
│   │   └── ecomind_scanner.ino        # Part 1 RFID scanning & Bluetooth transmission
│   ├── ecomind_indicator/
│   │   └── ecomind_indicator.ino      # Integrated Parts 1 & 4 hardware controller
│   └── README.md                      # Arduino compilation & test guide
│
├── hardware/                          # Hardware Schematics & Visual Scale Templates
│   ├── pinout.md                      # Part 1 pinout mapping tables
│   ├── wiring.md                      # Part 1 breadboard assembly instructions
│   ├── part4_wiring.md                # Part 4 indicator wiring & servo setup
│   └── gauge_template.md              # Eco Meter physical scale template design
│
├── backend/                           # Part 2 (Eco Decision Engine)
│   ├── app/                           # FastAPI REST API, ORM models, scoring engine
│   ├── tests/                         # PyTest suite (100% pass rate)
│   ├── seed.py                        # Database seeder with 10 demo products
│   ├── requirements.txt               # Backend dependencies
│   └── README.md                      # Server deployment & Swagger docs (/docs)
│
├── mobile/                            # Part 3 (EcoMind Mobile App)
│   ├── lib/                           # Flutter Dart source (Material 3 UI, Bluetooth, REST API)
│   ├── pubspec.yaml                   # Flutter manifest
│   └── README.md                      # Android build & setup instructions
│
└── README.md                          # Root system overview (this document)
```

---

## Component Summary

### Part 1 — Eco Scan System
- **Hardware**: Arduino Uno, MFRC522 RFID reader, HC-05 Bluetooth module.
- **Protocol**: `PRODUCT:<RFID_UID>\n` transmitted at 9600 baud.

### Part 2 — Eco Decision Engine
- **Technology**: Python, FastAPI, SQLite / SQLAlchemy, Pydantic v2.
- **Scoring**: 5-component transparent calculation: Carbon (30%), Water (20%), Packaging (15%), Recyclability (20%), Reuse/Lifespan (15%). Grades A+ to E.
- **API**: `GET /api/products/rfid/{rfid_uid}`.

### Part 3 — EcoMind Mobile App
- **Technology**: Flutter, Dart, Material 3.
- **Features**: HC-05 Bluetooth stream listener, interactive score gauge, environmental impact breakdown, sustainable alternative recommendations, scan history, and SDG 12 educational guides.

### Part 4 — Physical Eco Indicator
- **Hardware**: SG90 Servo motor (D6), RGB LED (D3/D5/D7), Piezo Buzzer (D4).
- **Physical Feedback**:
  - `GREEN` -> Servo 150°, Green LED, 1 beep (Score 80–100 / Grades A+, A).
  - `YELLOW` -> Servo 90°, Yellow LED, 2 beeps (Score 60–79 / Grades B, C).
  - `RED` -> Servo 30°, Red LED, 3 beeps (Score 0–59 / Grades D, E).
  - `RESET` -> Servo 90°, LED Off.

---

## Live Exhibition Demonstration Flow

```text
1. JUDGE PLACES PRODUCT ON RFID SCANNER
       ↓
2. ARDUINO READS UID AND BROADCASTS OVER BLUETOOTH
       ↓
3. MOBILE APP QUERIES FASTAPI BACKEND & DISPLAYS ANALYSIS
       ↓
4. BACKEND CALCULATES TRANSPARENT ECO SCORE (e.g. 88 / Grade A)
       ↓
5. MOBILE APP TRANSMITS DECISION COMMAND ("GREEN") BACK TO ARDUINO
       ↓
6. PHYSICAL INDICATOR VISUALLY RESPONDS:
   🟢 Green LED illuminates
   ↗ Servo pointer moves to 150° on physical scale
   🔊 Audio beeper confirms decision
```
