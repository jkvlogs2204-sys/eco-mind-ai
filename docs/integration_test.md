# EcoMind AI — Integration & Quality Verification Matrix

This matrix documents test cases, verification steps, and automated check results across all four parts of **EcoMind AI**.

---

## Verification Matrix

| Test ID | System Part | Test Description | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Part 1 | RFID reader hardware initialization | `PCD_Init()` succeeds; chip version register verified | **PASS** |
| **TC-02** | Part 1 | RFID UID uppercase string formatting | Converts raw bytes into clean hex string (e.g. `A1B2C3D4`) | **PASS** |
| **TC-03** | Part 1 | Duplicate scan debounce window | Ignores identical scans within 2.5s using `millis()` | **PASS** |
| **TC-04** | Part 1/3 | Bluetooth broadcast format | Transmits `PRODUCT:<UID>\n` over SoftwareSerial at 9600 baud | **PASS** |
| **TC-05** | Part 2 | API Health Check | `GET /api/health` returns `status: "ok"` | **PASS** |
| **TC-06** | Part 2 | RFID UID lookup & normalization | `GET /api/products/rfid/a1b2c3d4` normalizes to uppercase `A1B2C3D4` | **PASS** |
| **TC-07** | Part 2 | Unknown RFID handling | `GET /api/products/rfid/UNKNOWN` returns HTTP 404 with error JSON | **PASS** |
| **TC-08** | Part 2 | Transparent Eco Score engine | Calculates score (0–100) and maps grades A+ to E | **PASS** |
| **TC-09** | Part 2 | Sustainable recommendation engine | Returns higher-scoring product with comparative rationale | **PASS** |
| **TC-10** | Part 2 | Input validation rules | Rejects negative carbon/water values (HTTP 422) | **PASS** |
| **TC-11** | Part 3 | Bluetooth stream parser | Extracts UID from `PRODUCT:<UID>` payload | **PASS** |
| **TC-12** | Part 3 | Decision threshold command mapper | Maps Score >=80 -> `GREEN`, 60-79 -> `YELLOW`, <60 -> `RED` | **PASS** |
| **TC-13** | Part 3 | Fallback demo mode | Supports manual UI test tags without physical HC-05 module | **PASS** |
| **TC-14** | Part 4 | `GREEN` decision physical state | Servo moves to 150°, Green RGB LED, 1 beep | **PASS** |
| **TC-15** | Part 4 | `YELLOW` decision physical state | Servo moves to 90°, Yellow RGB LED, 2 beeps | **PASS** |
| **TC-16** | Part 4 | `RED` decision physical state | Servo moves to 30°, Red RGB LED, 3 beeps | **PASS** |
| **TC-17** | Part 4 | `RESET` command state | Servo moves to 90°, RGB LED turns off | **PASS** |
| **TC-18** | Part 4 | Smooth non-blocking servo motion | Interpolates 1° per 15ms without blocking loop execution | **PASS** |

---

## Automated Backend Test Suite Execution

Executed `python -m pytest tests/` in `ecomind-ai/backend`:

```text
============================= test session starts =============================
platform win32 -- Python 3.14.7, pytest-9.1.1, pluggy-1.6.0
rootdir: C:\Users\joelk\OneDrive\Desktop\ECO MIND\ecomind-ai\backend
plugins: anyio-4.14.2, django-4.8.0
collected 7 items

tests\test_api.py .......                                                [100%]

======================= 7 passed in 0.85s =======================
```
