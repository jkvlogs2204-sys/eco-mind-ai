# EcoMind Mobile App — Part 3

The **EcoMind Mobile App** is the user interface and central integration bridge for **EcoMind AI**. Built using Flutter and Material 3, it connects to the Arduino + HC-05 scanner from Part 1, queries the Eco Decision Engine from Part 2, displays complete environmental impact analysis, and broadcasts decision feedback commands (`GREEN`, `YELLOW`, `RED`) to prepare for Part 4 (Physical Eco Indicator).

---

## 1. System Integration Flow

```text
1. ARDUINO SCANNER (Part 1)
   ↓ Broadcasts PRODUCT:<UID> via HC-05 Bluetooth
2. ECOMIND MOBILE APP (Part 3)
   ↓ Receives UID, validates format
3. ECO DECISION ENGINE (Part 2)
   ↓ GET /api/products/rfid/{rfid_uid}
4. ECOMIND MOBILE APP (Part 3)
   ↓ Displays Eco Score gauge, grade, environmental impact & alternative
5. ARDUINO FEEDBACK (Part 4)
   ↓ Transmits GREEN / YELLOW / RED decision command back over HC-05
```

---

## 2. Requirements & Dependencies

- **Flutter SDK**: 3.0.0 or higher
- **Android Studio / VS Code** with Flutter extension
- **Target OS**: Android (API level 21 or higher)

### Pub Dependencies (`pubspec.yaml`)
- `flutter_bluetooth_serial`: HC-05 Bluetooth Classic communication
- `http`: REST API communication with Part 2 backend
- `provider`: State management across Bluetooth and scanning pipelines
- `intl`: Date and timestamp formatting

---

## 3. How to Build & Run

### Step 1: Install Dependencies
Navigate to the `mobile` folder and fetch packages:
```bash
cd ecomind-ai/mobile
flutter pub get
```

### Step 2: Configure API Base URL
- For **Android Emulator**: Uses default `http://10.0.2.2:8000`.
- For **Physical Android Device**:
  1. Find your computer's local IP address (e.g. `192.168.1.15`).
  2. Open the **Settings** screen inside the app.
  3. Set API Base URL to `http://<YOUR_IP>:8000` and tap **SAVE**.

### Step 3: Run on Connected Device
```bash
flutter run
```

---

## 4. Key Features & Screens

- **Home Dashboard (`home_screen.dart`)**: Features header banner, real-time scanner connection status, and quick scan button.
- **Bluetooth Scanner View (`bluetooth_screen.dart`)**: Scan, pair, and connect to HC-05 Bluetooth devices with optional mock hardware mode for testing.
- **Real-Time RFID Scanner (`scan_screen.dart`)**: Listens to incoming `PRODUCT:<UID>` streams and supports demo tag selection (`A1B2C3D4`, `93F81C22`, `04A7BC91`).
- **Product Result Analysis (`result_screen.dart`)**: Displays animated circular Eco Score gauge, Grade (A+ to E), Environmental Impact breakdown, and data status indicator (`DEMO / ESTIMATED / VERIFIED`).
- **Product Comparison (`comparison_screen.dart`)**: Side-by-side comparison between scanned product and recommended sustainable alternative.
- **Scan History (`history_screen.dart`)**: Log of previous scans with timestamp and drill-down review.
- **Learn Sustainability (`learn_screen.dart`)**: Educational hub covering Carbon Footprint, Water Footprint, Recycling, Packaging, and Reuse (SDG 12).
