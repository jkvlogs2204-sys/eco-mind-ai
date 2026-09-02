# Part 4 Hardware Wiring & Pinout Guide — Physical Eco Indicator

This document provides complete instructions for wiring the **Physical Eco Indicator** (SG90 Servo, RGB LED, Piezo Buzzer, MFRC522 RFID, and HC-05 Bluetooth) to an **Arduino Uno**.

---

## 1. Master Pin Assignment Table

| Subsystem | Component Pin | Arduino Uno Pin | Wiring Notes & Voltage Leveling |
| :--- | :--- | :--- | :--- |
| **MFRC522 RFID** | SDA / SS | **D10** | Digital Pin 10 |
| | SCK | **D13** | Digital Pin 13 |
| | MOSI | **D11** | Digital Pin 11 |
| | MISO | **D12** | Digital Pin 12 |
| | RST | **D9** | Digital Pin 9 |
| | 3.3V | **3.3V** | **STRICTLY 3.3V HEADER (DO NOT USE 5V)** |
| | GND | **GND** | System Ground |
| **HC-05 Bluetooth** | VCC | **5V** | 5V Power rail |
| | GND | **GND** | System Ground |
| | TXD | **D2** | Arduino SoftwareSerial RX |
| | RXD | **D8** | Arduino SoftwareSerial TX (**via 1kΩ / 2kΩ divider**) |
| **SG90 Servo Motor**| Signal (Orange)| **D6** | PWM Servo control pin |
| | VCC (Red) | **Ext 5V** | **External 5V supply recommended** |
| | GND (Brown) | **GND** | Common ground connected to Arduino GND |
| **RGB LED** | Red Anode/Cathode| **D3** | Via 220Ω resistor |
| | Green Anode/Cathode|**D5** | Via 220Ω resistor |
| | Blue Anode/Cathode| **D7** | Via 220Ω resistor |
| | Common Ground | **GND** | (Common Cathode) or 5V (Common Anode) |
| **Piezo Buzzer** | Positive (+) | **D4** | Direct digital output |
| | Negative (-) | **GND** | System Ground |

---

## 2. Power Supply & Servo Protection Notice

> [!CAUTION]
> **COMMON GROUND REQUIREMENT:**
> When powering the SG90 servo motor from an external 5V USB adapter or battery pack, **you MUST connect the negative (-) terminal of the external battery directly to an Arduino GND pin**. Without a shared common ground, control signals will become unstable.

---

## 3. Circuit Diagram Overview

```text
                  +-----------------------------------+
                  |            ARDUINO UNO            |
                  |                                   |
                  |   3.3V -----------------+         |
                  |    5V  ----+            |         |
                  |    GND ----|----+       |         |
                  |            |    |       |         |
                  |    D2 <----|----|-------|----+    |
                  |    D3 ----[220] |       |    |    | ---> RED LED
                  |    D4 -----------|-------|----+    | ---> BUZZER (+)
                  |    D5 ----[220] |       |         | ---> GREEN LED
                  |    D6 ------------------|----+    | ---> SERVO SIGNAL
                  |    D7 ----[220] |       |    |    | ---> BLUE LED
                  |    D8 -----[1k]-+       |    |    | ---> HC-05 RXD (via 2k to GND)
                  |    D9 ----------|-------|--+ |    | ---> MFRC522 RST
                  |    D10 ---------|-------|--|-+    | ---> MFRC522 SDA
                  |    D11 ---------|-------|--|--+   | ---> MFRC522 MOSI
                  |    D12 ---------|-------|--|--|--+| ---> MFRC522 MISO
                  |    D13 ---------|-------|--|--|--|| ---> MFRC522 SCK
                  +-----------------+-------+--+--+--++
                                    |       |  |  |  ||
                             +------+-------+--+--+--++
                             |      |       |  |  |  ||
                             v      v       v  v  v  vv
                         [HC-05] [SERVO]  [MFRC522 RFID]
```

---

## 4. Exhibition Test Commands (Serial Monitor)

You can trigger Part 4 physical responses directly from the Arduino IDE Serial Monitor (set to **9600 baud**):

- `TEST GREEN` -> Moves servo pointer to 150°, turns RGB LED Green, plays 1 beep.
- `TEST YELLOW` -> Moves servo pointer to 90°, turns RGB LED Yellow, plays 2 beeps.
- `TEST RED` -> Moves servo pointer to 30°, turns RGB LED Red, plays 3 beeps.
- `TEST RESET` -> Returns servo pointer to 90° center, turns RGB LED Off.
- `SCORE:85` -> Maps score 85 to servo angle ~132° and sets Green indicator.
