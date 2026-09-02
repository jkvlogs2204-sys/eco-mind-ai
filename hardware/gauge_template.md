# Eco Meter Gauge Scale Template — Physical Eco Indicator

This document provides printable measurements and design guidelines for building the physical **Eco Meter Scale** mounted behind the SG90 servo pointer in **Part 4**.

---

## 1. Physical Gauge Arc Layout

```text
                        ┌─────────────────────────┐
                        │       ECOMIND AI        │
                        │    ECO SCORE GAUGE      │
                        └─────────────────────────┘

                                 [ 90 ]
                                 SUSTAINABLE
                                /    |    \
                               /     |     \
                      [ 100 ] /      |      \ [ 70 ]
                       A+    /       |       \  B
                            /        |        \
                   [ 80 ]  /         |         \  [ 60 ]
                    A     /          |          \  C
                         /           |           \
                        /            |            \
               [ 50 ]  /             |             \ [ 40 ]
                D     /              |              \  E
                     /               |               \
                    /                |                \
             30° ──┴─────────────────┴─────────────────┴── 150°
               [RED / HIGH IMPACT] [YELLOW] [GREEN / EXCELLENT]
                                     ▲
                               SERVO POINTER
```

---

## 2. Angle Mapping Table

| Eco Score Range | Grade | Decision | Servo Angle (Degrees) | RGB Indicator Color |
| :--- | :--- | :--- | :--- | :--- |
| **90 – 100** | **A+** | EXCELLENT CHOICE | **140° – 150°** | 🟢 Green |
| **80 – 89** | **A** | EXCELLENT CHOICE | **120° – 139°** | 🟢 Green |
| **70 – 79** | **B** | GOOD CHOICE | **100° – 119°** | 🟡 Yellow / Amber |
| **60 – 69** | **C** | MODERATE IMPACT | **80° – 99°** | 🟡 Yellow / Amber |
| **50 – 59** | **D** | HIGH IMPACT | **60° – 79°** | 🔴 Red |
| **0 – 49** | **E** | VERY HIGH IMPACT | **30° – 59°** | 🔴 Red |

---

## 3. Printing & Construction Instructions

1. Print or draw the semi-circular arc scale on rigid cardboard or 3mm acrylic sheet.
2. Cut a small hole at the center pivot point to allow the SG90 servo shaft to protrude.
3. Attach a lightweight plastic or wooden needle/pointer arm to the servo horn.
4. Mount the RGB LED directly above or beside the scale center.
5. Calibrate the servo horn alignment at power-on (`RESET` position aligns pointer vertically to 90°).
