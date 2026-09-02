/*
 * EcoMind AI — RFID Scanner Firmware (Unidirectional Architecture)
 *
 * Responsibility:
 * 1. Detect RFID tag on MFRC522 reader.
 * 2. Read and normalize UID (e.g. A1B2C3D4).
 * 3. Apply 2.5s scan debounce.
 * 4. Transmit PRODUCT:<UID>\n over HC-05 Bluetooth to Flutter Mobile App.
 *
 * Hardware Pin Connections:
 * MFRC522 RFID:
 *   SDA/SS  -> D10
 *   SCK     -> D13
 *   MOSI    -> D11
 *   MISO    -> D12
 *   RST     -> D9
 *   3.3V    -> 3.3V power (DO NOT use 5V)
 *
 * HC-05 Bluetooth (SoftwareSerial):
 *   HC-05 TX -> Arduino D2 (RX)
 *   HC-05 RX -> Arduino D8 (TX via 1kΩ/2kΩ resistor divider)
 *   Buzzer    -> D4 (Scan Audio Confirmation)
 */

#include <SPI.h>
#include <MFRC522.h>
#include <SoftwareSerial.h>

#define SS_PIN 10
#define RST_PIN 9
MFRC522 mfrc522(SS_PIN, RST_PIN);

// SoftwareSerial HC-05: D2=RX, D8=TX
SoftwareSerial btSerial(2, 8);

#define BUZZER_PIN 4

// Scan Debounce Cooldown
String lastScannedUid = "";
unsigned long lastScanTime = 0;
const unsigned long DEBOUNCE_MS = 2500;

void setup() {
  Serial.begin(9600);
  btSerial.begin(9600);
  SPI.begin();
  mfrc522.PCD_Init();

  pinMode(BUZZER_PIN, OUTPUT);

  Serial.println(F("EcoMind AI RFID Reader — System Initialized"));
  btSerial.println(F("ECOMIND_READY"));
}

void loop() {
  // Physical MFRC522 RFID Tag Detection
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    String uidStr = getUidString(mfrc522.uid.uidByte, mfrc522.uid.size);
    unsigned long now = millis();

    // Check duplicate scan debounce
    if (uidStr != lastScannedUid || (now - lastScanTime) > DEBOUNCE_MS) {
      lastScannedUid = uidStr;
      lastScanTime = now;

      // Broadcast UID over Bluetooth to Mobile App
      String msg = "PRODUCT:" + uidStr;
      btSerial.println(msg);
      Serial.println("Broadcasting: " + msg);

      // Audio confirmation tone on successful scan
      tone(BUZZER_PIN, 1000, 100);
    }
    mfrc522.PICC_HaltA();
    mfrc522.PCD_StopCrypto1();
  }
}

String getUidString(byte *buffer, byte bufferSize) {
  String uid = "";
  for (byte i = 0; i < bufferSize; i++) {
    if (buffer[i] < 0x10) uid += "0";
    uid += String(buffer[i], HEX);
  }
  uid.toUpperCase();
  return uid;
}
