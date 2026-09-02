# Hardware Wiring & Assembly Guide

This document provides complete instructions for wiring the **Eco Scan System** hardware components on a solderless breadboard.

---

## 1. Component List

1. **Arduino Uno** Board with USB cable
2. **MFRC522 RFID Reader** Module + RFID Card / Keyfob tags
3. **HC-05 Bluetooth Module** (4-pin or 6-pin breakout)
4. **Solderless Breadboard**
5. **Resistors**:
   - 1× 1 kΩ resistor
   - 1× 2 kΩ resistor (or 2× 1 kΩ resistors in series)
6. **Jumper Wires**: Male-to-Male and Male-to-Female

---

## 2. Step-by-Step Assembly Instructions

### Step 1: Power Rail Setup
1. Connect the **5V** pin of the Arduino Uno to the red positive power rail (`+`) on the breadboard.
2. Connect a **GND** pin of the Arduino Uno to the blue ground rail (`-`) on the breadboard.
3. Connect the **3.3V** pin of the Arduino Uno directly to the MFRC522 `3.3V` pin using a jumper wire.

### Step 2: MFRC522 RFID Connection
Connect the MFRC522 header pins directly to the Arduino Uno:
- MFRC522 `SDA (SS)`  --> Arduino **D10**
- MFRC522 `SCK`       --> Arduino **D13**
- MFRC522 `MOSI`      --> Arduino **D11**
- MFRC522 `MISO`      --> Arduino **D12**
- MFRC522 `RST`       --> Arduino **D9**
- MFRC522 `GND`       --> Breadboard Ground (`-`)
- MFRC522 `3.3V`      --> Arduino **3.3V**

> [!WARNING]
> Double-check the 3.3V connection before powering on the USB cable. Do NOT connect MFRC522 to 5V.

### Step 3: HC-05 Bluetooth Connection & Voltage Divider
Connect power & communication pins for the HC-05:
1. HC-05 `VCC` --> Breadboard 5V Rail (`+`)
2. HC-05 `GND` --> Breadboard Ground Rail (`-`)
3. HC-05 `TXD` --> Arduino **D2** (Direct jumper connection)
4. HC-05 `RXD` voltage divider setup:
   - Connect a 1 kΩ resistor between Arduino **D3** and HC-05 `RXD`.
   - Connect a 2 kΩ resistor between HC-05 `RXD` and Breadboard Ground Rail (`-`).

---

## 3. Schematic Diagram

```text
                  +-----------------------------------+
                  |            ARDUINO UNO            |
                  |                                   |
                  |   3.3V ----------------+          |
                  |    5V  ---+            |          |
                  |    GND ---|----+       |          |
                  |           |    |       |          |
                  |    D2 <---|----|-------|-----+    |
                  |    D3 ----|----|--[1k]-+     |    |
                  |           |    |       |     |    |
                  |    D9 ----|----|-------|--+  |    |
                  |    D10 ---|----|---|---|--|--+    |
                  |    D11 ---|----|---|---|--|--|--+ |
                  |    D12 ---|----|---|---|--|--|--| |
                  |    D13 ---|----|---|---|--|--|--| |
                  +-----------|----|---|---|--|--|--|-+
                              |    |   |   |  |  |  | |
                              |    |  [2k] |  |  |  | |
                              |    |   |   |  |  |  | |
       +----------------------+    |   GND |  |  |  | |
       |                           |       |  |  |  | |
       v                           v       v  v  v  v v
+--------------+                +-----------------------+
|  HC-05 BT    |                |    MFRC522 RFID       |
|              |                |                       |
| VCC  GND TXD |                | 3.3V GND RST SDA MOSI |
|  |    |   |  |                |  |    |   |   |   |   |
+--------------+                +-----------------------+
                                           MISO SCK
                                            |    |
                                            v    v
                                           D12  D13
```

---

## 4. Power & Operation Safety Checklist

- [x] MFRC522 powered strictly via 3.3V output header.
- [x] Common Ground established between Arduino, MFRC522, and HC-05.
- [x] HC-05 RXD voltage divider configured to step 5.0V signal down to 3.3V.
- [x] No bare wires or metal contact on the RFID antenna loop.
