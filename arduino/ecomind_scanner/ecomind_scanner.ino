/*
 * ============================================================================
 *                     ECOMIND AI — RFID SCANNER FIRMWARE
 * ============================================================================
 * Hardware:
 *   Arduino Uno + MFRC522 RFID Reader + HC-05 Bluetooth Module
 *
 * Wiring:
 *   MFRC522: SDA=D10, SCK=D13, MOSI=D11, MISO=D12, RST=D9, 3.3V, GND
 *   HC-05:   TXD->D2(RX), RXD<-D3(TX via 5V->3.3V voltage divider), 5V, GND
 *
 * Protocol Output (over HC-05 Bluetooth at 9600 baud):
 *   PRODUCT:<UID>\n       e.g.  PRODUCT:A1B2C3D4
 *
 * Architecture: UNIDIRECTIONAL — Arduino only SENDS, never receives commands.
 *   RFID Tag → MFRC522 → Arduino → HC-05 → Web Serial API → FastAPI Backend
 * ============================================================================
 */

#include <SPI.h>
#include <MFRC522.h>
#include <SoftwareSerial.h>

// ── Pin Configuration ─────────────────────────────────────────────────────────
#define RST_PIN        9           // MFRC522 Reset
#define SS_PIN         10          // MFRC522 SPI Slave Select (SDA)
#define BT_RX_PIN      2           // Arduino RX ← HC-05 TXD
#define BT_TX_PIN      3           // Arduino TX → HC-05 RXD (via voltage divider)
#define DEBOUNCE_MS    2500        // Ignore same tag re-read within 2.5 seconds

// ── Hardware Objects ──────────────────────────────────────────────────────────
MFRC522 mfrc522(SS_PIN, RST_PIN);
SoftwareSerial btSerial(BT_RX_PIN, BT_TX_PIN);

// ── State ─────────────────────────────────────────────────────────────────────
String lastUID = "";
unsigned long lastScanTime = 0;
bool rfidReady = false;

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Converts raw MFRC522 UID bytes to uppercase hex string (e.g. A1B2C3D4).
 */
String formatUID(MFRC522::Uid *uid) {
  String result = "";
  for (byte i = 0; i < uid->size; i++) {
    if (uid->uidByte[i] < 0x10) result += "0";
    result += String(uid->uidByte[i], HEX);
  }
  result.toUpperCase();
  return result;
}

/**
 * Sends the PRODUCT:<UID> message over HC-05 Bluetooth and USB Serial Monitor.
 */
void sendProductUID(const String &uid) {
  String msg = "PRODUCT:" + uid;
  btSerial.print(msg);
  btSerial.print("\n");       // Web Serial API splits on \n
  Serial.println("[BT TX] " + msg);
}

// ── Setup ─────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(9600);
  while (!Serial && millis() < 3000);

  // Bluetooth
  btSerial.begin(9600);
  Serial.println(F("[INIT] HC-05 SoftwareSerial ready at 9600 baud."));

  // MFRC522
  SPI.begin();
  mfrc522.PCD_Init();
  byte ver = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
  if (ver == 0x00 || ver == 0xFF) {
    Serial.println(F("[ERROR] MFRC522 not detected. Check SPI wiring and 3.3V supply."));
    rfidReady = false;
  } else {
    rfidReady = true;
    Serial.print(F("[INIT] MFRC522 OK. Chip version: 0x"));
    Serial.println(ver, HEX);
  }

  Serial.println(F("================================"));
  Serial.println(F("    ECOMIND AI SCANNER READY    "));
  Serial.println(F("================================"));
  Serial.println(F("Waiting for RFID tag..."));
  Serial.println();
}

// ── Main Loop ─────────────────────────────────────────────────────────────────
void loop() {
  if (!rfidReady) {
    // Retry every 5 seconds if RFID failed to initialise
    static unsigned long lastRetry = 0;
    if (millis() - lastRetry > 5000) {
      lastRetry = millis();
      SPI.begin();
      mfrc522.PCD_Init();
      byte ver = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
      rfidReady = (ver != 0x00 && ver != 0xFF);
      Serial.println(rfidReady ? F("[RETRY] MFRC522 OK.") : F("[RETRY] MFRC522 still not detected."));
    }
    return;
  }

  // Wait for a card
  if (!mfrc522.PICC_IsNewCardPresent()) return;
  if (!mfrc522.PICC_ReadCardSerial()) {
    Serial.println(F("[ERROR] Card read failed."));
    return;
  }

  String uid = formatUID(&(mfrc522.uid));

  // Debounce — ignore same tag within DEBOUNCE_MS
  unsigned long now = millis();
  if (uid == lastUID && (now - lastScanTime) < DEBOUNCE_MS) {
    mfrc522.PICC_HaltA();
    mfrc522.PCD_StopCrypto1();
    return;
  }

  lastUID = uid;
  lastScanTime = now;

  Serial.println(F("--- TAG DETECTED ---"));
  Serial.print(F("UID: "));
  Serial.println(uid);

  sendProductUID(uid);

  Serial.println(F("--- SCAN COMPLETE ---"));
  Serial.println(F("Waiting for next tag..."));
  Serial.println();

  mfrc522.PICC_HaltA();
  mfrc522.PCD_StopCrypto1();
}
