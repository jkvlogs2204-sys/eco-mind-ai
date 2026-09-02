# EcoMind AI Firmware Guide — Parts 1 & 4

This directory contains the primary Arduino C++ sketches powering **EcoMind AI Part 1 (Eco Scan System)** and **Part 4 (Physical Eco Indicator)**.

---

## Firmware Directory Overview

```text
arduino/
├── ecomind_scanner/
│   └── ecomind_scanner.ino      # Part 1 standalone RFID scanning & Bluetooth broadcast
└── ecomind_indicator/
    └── ecomind_indicator.ino    # Part 1 + Part 4 integrated RFID scanner & physical indicator
```

---

## 1. Integrated Firmware (`ecomind_indicator.ino`)

The `ecomind_indicator.ino` sketch combines all hardware capabilities into a single Arduino Uno board:
- **RFID Product Scanning** (MFRC522)
- **Bluetooth Broadcast & Command Listener** (HC-05 SoftwareSerial)
- **Smooth Servo Pointer Gauge** (SG90 PWM Servo on D6)
- **RGB LED Feedback** (Red=D3, Green=D5, Blue=D7)
- **Piezo Audio Beeper** (D4)

---

## 2. Pin Assignments

| Module | Signal Pin | Arduino Pin | Notes |
| :--- | :--- | :--- | :--- |
| **MFRC522 RFID** | SDA / SS | **D10** | Digital 10 |
| | SCK | **D13** | Digital 13 |
| | MOSI | **D11** | Digital 11 |
| | MISO | **D12** | Digital 12 |
| | RST | **D9** | Digital 9 |
| | 3.3V | **3.3V** | **Must be 3.3V header (Do not use 5V)** |
| | GND | **GND** | Ground |
| **HC-05 BT** | VCC | **5V** | 5V Power rail |
| | GND | **GND** | Ground |
| | TXD | **D2** | Arduino RX |
| | RXD | **D8** | Arduino TX (**Via 1kΩ / 2kΩ divider**) |
| **SG90 Servo** | Signal | **D6** | PWM Servo Control |
| | VCC / GND | **Ext 5V / GND**| Shared ground with Arduino |
| **RGB LED** | R / G / B | **D3 / D5 / D7**| Via 220Ω resistors |
| **Buzzer** | Signal | **D4** | Direct digital output |

---

## 3. Exhibition Testing via Serial Monitor

Open the Arduino Serial Monitor at **9600 baud** to test physical indicator hardware independently of the mobile app or backend:

- `TEST GREEN` -> Sets 150° servo position, turns RGB LED Green, plays 1 beep.
- `TEST YELLOW` -> Sets 90° servo position, turns RGB LED Yellow, plays 2 beeps.
- `TEST RED` -> Sets 30° servo position, turns RGB LED Red, plays 3 beeps.
- `TEST RESET` -> Returns servo to 90° center, turns RGB LED Off.
- `SCORE:88` -> Maps 0–100 score to 30°–150° servo gauge position.
