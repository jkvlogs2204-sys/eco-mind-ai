# EcoMind AI — 60-Second Competition Exhibition Guide

This document provides the exact sequence for presenting **EcoMind AI** to competition judges and reviewers at an innovation exhibition.

---

## Elevator Pitch (15 Seconds)

> **"EcoMind AI is an interactive eco-decision system that connects physical product identification, transparent environmental scoring, mobile intelligence, and a physical decision indicator. Every choice has an environmental consequence."**

---

## 60-Second Exhibition Demonstration Sequence

```text
STEP 1: SCAN PRODUCT
Presenter places RFID product tag on the scanner reader.

STEP 2: IDENTIFICATION
MFRC522 reads UID (e.g. A1B2C3D4) and sends broadcast via HC-05 Bluetooth.

STEP 3: MOBILE ANALYSIS
EcoMind Mobile queries FastAPI Eco Decision Engine REST server.

STEP 4: TRANSPARENT SCORE
Animated gauge displays score (96/100, Grade A+) and methodology breakdown.

STEP 5: ECOMIND INSIGHT
EcoMind Insight explains key sustainability factors and suggests a better alternative.

STEP 6: PHYSICAL RESPONSE
Mobile sends GREEN command over Bluetooth.
Physical indicator changes: Green LED illuminates, Servo pointer moves to 150°, Buzzer confirms.

STEP 7: RESET DEMO
Presenter taps "SCAN ANOTHER PRODUCT" to reset hardware & UI state for the next visitor.
```

---

## Demonstration Fallback Commands (Serial Monitor)

If mobile Bluetooth is disabled during a live presentation, open the Arduino IDE Serial Monitor at **9600 baud**:

- `TEST GREEN` -> 150° Servo, Green LED, 1 confirmation beep (Grade A+/A).
- `TEST YELLOW` -> 90° Servo, Yellow LED, 2 confirmation beeps (Grade B/C).
- `TEST RED` -> 30° Servo, Red LED, 3 caution beeps (Grade D/E).
- `TEST RESET` -> 90° Servo center, LED Off.
