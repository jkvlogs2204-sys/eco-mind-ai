# Part 1 Hardware Wiring Guide — Eco Scan System

This document outlines breadboard assembly and pin connections for the **Eco Scan System** (MFRC522 RFID Reader and HC-05 Bluetooth Module).

---

## 1. MFRC522 RFID Reader Connections

| MFRC522 Pin | Arduino Uno Pin | Wiring Description |
| :--- | :--- | :--- |
| **SDA / SS** | **D10** | Digital Pin 10 (SPI Slave Select) |
| **SCK** | **D13** | Digital Pin 13 (SPI Clock) |
| **MOSI** | **D11** | Digital Pin 11 (SPI MOSI) |
| **MISO** | **D12** | Digital Pin 12 (SPI MISO) |
| **RST** | **D9** | Digital Pin 9 (Reset) |
| **3.3V** | **3.3V** | **POWER STRICTLY FROM 3.3V HEADER** |
| **GND** | **GND** | System Ground |

> [!CAUTION]
> Connecting the MFRC522 `3.3V` pin to the 5V header pin will destroy the RFID module.

---

## 2. HC-05 Bluetooth Module Connections

| HC-05 Pin | Arduino Uno Pin | Wiring Description |
| :--- | :--- | :--- |
| **VCC** | **5V** | 5V Power rail |
| **GND** | **GND** | System Ground |
| **TXD** | **D2** | Arduino SoftwareSerial RX (Direct Jumper) |
| **RXD** | **D8** | Arduino SoftwareSerial TX (**1kΩ / 2kΩ Voltage Divider**) |

```text
Arduino D8 (5V TX) ─── [ 1kΩ R1 ] ───┬─── HC-05 RXD (3.3V Logic)
                                    │
                              [ 2kΩ R2 ]
                                    │
                                   GND
```
