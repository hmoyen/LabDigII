// Define RX and TX pins for Serial1 and Serial2
#define RXD1 21   // RX for Serial1
#define TXD1 19   // TX for Serial1
#define RXD2 16   // RX for Serial2
#define TXD2 17   // TX for Serial2

// Use HardwareSerial for Serial1 and Serial2
HardwareSerial mySerial1(1);  // Serial1
HardwareSerial mySerial2(2);  // Serial2

void setup() {
  // Start Serial Monitor for debugging
  Serial.begin(115200);
  
  // Start Serial1 and Serial2 with respective pins
  mySerial1.begin(115200, SERIAL_8N1, RXD1, TXD1);  // Serial1 setup (RX and TX pins)
  mySerial2.begin(115200, SERIAL_8N1, RXD2, TXD2);  // Serial2 setup (RX and TX pins)

  Serial.println("ESP32 UART Communication Test");
  Serial.println("Receiving data on Serial1 (pins 21, 19) and Serial2 (pins 16, 17)");
}

void loop() {
  // Handle Serial1 input with '#' delimiter
  String message1 = "";
  while (mySerial1.available()) {
    char incomingByte = mySerial1.read();
    
    if (incomingByte == '#') {
      // If '#' is encountered, print the message and reset the buffer
      Serial.print("Received on Serial1: ");
      Serial.println(message1);
      message1 = "";  // Reset message buffer for the next part
    } else {
      // Accumulate the message until '#' delimiter is encountered
      message1 += incomingByte;
    }
  }

  // Handle Serial2 input with '#' delimiter
  String message2 = "";
  while (mySerial2.available()) {
    char incomingByte = mySerial2.read();
    
    if (incomingByte == '#') {
      // If '#' is encountered, print the message and reset the buffer
      Serial.print("Received on Serial2: ");
      Serial.println(message2);
      message2 = "";  // Reset message buffer for the next part
    } else {
      // Accumulate the message until '#' delimiter is encountered
      message2 += incomingByte;
    }
  }

  // Optional: Send data from Serial Monitor (U0) to Serial1 and Serial2
  while (Serial.available()) {
    char incomingChar = Serial.read();
    mySerial1.print(incomingChar);  // Send data to Serial1
    mySerial2.print(incomingChar);  // Send data to Serial2
  }
}
