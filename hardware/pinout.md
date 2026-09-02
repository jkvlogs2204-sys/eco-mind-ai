# Hardware Pinout Reference — Eco Scan System

This document outlines the pin configurations for connecting the **MFRC522 RFID Reader** and **HC-05 Bluetooth Module** to the **Arduino Uno**.

---

## 1. MFRC522 RFID Reader Pinouts

| MFRC522 Pin | Function | Arduino Uno Pin | Description |
| :--- | :--- | :--- | :--- |
| **SDA / SS** | SPI Slave Select | **D10** | Digital Pin 10 |
| **SCK** | SPI Clock | **D13** | Digital Pin 13 |
| **MOSI** | SPI Master Out Slave In | **D11** | Digital Pin 11 |
| **MISO** | SPI Master In Slave Out | **D12** | Digital Pin 12 |
| **IRQ** | Interrupt Request | *Unconnected* | Not required for polling mode |
| **GND** | Ground | **GND** | System Ground |
| **RST** | Reset Pin | **D9** | Digital Pin 9 |
| **3.3V** | Power Supply | **3.3V** | **MUST BE 3.3V ONLY** |

> [!CAUTION]
> **CRITICAL VOLTAGE NOTICE:**
> Never connect the MFRC522 `3.3V` pin to the Arduino `5V` header pin. Doing so will permanently damage the MFRC522 chip.

---

## 2. HC-05 Bluetooth Module Pinouts

| HC-05 Pin | Function | Arduino Uno Pin | Wiring Notes |
| :--- | :--- | :--- | :--- |
| **VCC** | Module Power | **5V** | Connect to Arduino 5V pin |
| **GND** | Ground | **GND** | Common ground connection |
| **TXD** | Transmit Data | **D2** | SoftwareSerial RX (Direct connection) |
| **RXD** | Receive Data | **D3** | SoftwareSerial TX (**Requires Voltage Divider**) |
| **STATE** | Status Indicator | *Unconnected* | Not required |
| **EN / KEY**| AT Mode Enable | *Unconnected* | Not required for default transmission |

---

## 3. Voltage Level Shifter / Divider Circuit (Arduino D3 TX -> HC-05 RXD)

Arduino Uno output pins operate at **5V logic**, whereas the HC-05 RXD input pin expects **3.3V logic**.

### Recommended Resistor Circuit:
- **Resistor R1**: 1 kΩ (placed between Arduino D3 and HC-05 RXD)
- **Resistor R2**: 2 kΩ (placed between HC-05 RXD and GND)

```text
Arduino D3 (5V TX) ─── [ 1kΩ R1 ] ───┬─── HC-05 RXD (3.3V Logic)
                                    │
                              [ 2kΩ R2 ]
                                    │
                                   GND
```

Using this 1:2 ratio steps down the 5.0V signal to approximately **3.33V**, protecting the HC-05 microcontroller.
