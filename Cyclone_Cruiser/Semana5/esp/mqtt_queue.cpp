#include <WiFi.h>
#include <PubSubClient.h>
#include <queue> // Include the queue library

// WiFi and MQTT configuration
const char* ssid = "LAB_DIGITAL";       // WiFi SSID
const char* password = "C1-17*2018@labdig"; // WiFi Password
const char* mqtt_server = "192.168.17.189"; // MQTT server IP

WiFiClient espClient;
PubSubClient client(espClient);

// Message Queue
std::queue<String> messageQueue; // Queue to hold unsent messages

// Digital pin definitions for rotation
const int pin_rotation_cw_right = 4;  // CW Right rotation pin
const int pin_rotation_ccw_right = 22; // CCW Right rotation pin
const int pin_rotation_cw_left = 18;    // CW Left rotation pin
const int pin_rotation_ccw_left = 23;   // CCW Left rotation pin

// Serial pins configuration
#define RXD1 21 // RX for Serial1
#define TXD1 19 // TX for Serial1
#define RXD2 16 // RX for Serial2
#define TXD2 17 // TX for Serial2

// Serial instances
HardwareSerial mySerial1(1); // Serial1
HardwareSerial mySerial2(2); // Serial2

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);

    if (client.connect(clientId.c_str())) {
      Serial.println("Connected to MQTT broker");

      // Resend queued messages
      while (!messageQueue.empty()) {
        String msg = messageQueue.front();
        if (client.publish("queued", msg.c_str())) {
          Serial.println("Queued message sent: " + msg);
          messageQueue.pop(); // Remove the message from the queue
        } else {
          Serial.println("Failed to send queued message");
          break; // Stop trying if the publish fails
        }
      }
    } else {
      Serial.print("Failed to connect, rc=");
      Serial.print(client.state());
      Serial.println(". Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

String extractLastValue(String message) {
  int lastComma = message.lastIndexOf(',');
  if (lastComma != -1) {
    return message.substring(lastComma + 1);
  }
  return "";
}

void handleSerialInput(HardwareSerial &serial, const char* topic) {
  static String buffer = "";
  while (serial.available()) {
    char incomingByte = serial.read();

    if (incomingByte == '#') {
      String lastValue = extractLastValue(buffer);
      if (!lastValue.isEmpty()) {
        String message = "D:" + lastValue;
        if (client.connected()) {
          if (client.publish(topic, message.c_str())) {
            Serial.println("Serial message published successfully");
          } else {
            Serial.println("Failed to publish serial message");
            messageQueue.push(message); // Add to the queue if publish fails
          }
        } else {
          messageQueue.push(message); // Add to the queue if not connected
        }
      }
      buffer = "";
    } else {
      buffer += incomingByte;
    }
  }
}

void setup() {
  Serial.begin(115200);

  // Setup WiFi and MQTT
  setup_wifi();
  client.setServer(mqtt_server, 1883);

  // Start Serial1 and Serial2
  mySerial1.begin(115200, SERIAL_8N1, RXD1, TXD1);
  mySerial2.begin(115200, SERIAL_8N1, RXD2, TXD2);

  // Setup digital pins for rotation detection
  pinMode(pin_rotation_cw_right, INPUT);
  pinMode(pin_rotation_ccw_right, INPUT);
  pinMode(pin_rotation_cw_left, INPUT);
  pinMode(pin_rotation_ccw_left, INPUT);

  Serial.println("Setup complete");
}

int prev_cw_right = 0, prev_ccw_right = 0, prev_cw_left = 0, prev_ccw_left = 0;

void detectRotationAndPublish() {
  int cw_right = digitalRead(pin_rotation_cw_right);
  int ccw_right = digitalRead(pin_rotation_ccw_right);
  int cw_left = digitalRead(pin_rotation_cw_left);
  int ccw_left = digitalRead(pin_rotation_ccw_left);

  int right_rotation = 0, left_rotation = 0;

  if (cw_right == HIGH && prev_cw_right == LOW) right_rotation = 1;
  else if (ccw_right == HIGH && prev_ccw_right == LOW) right_rotation = -1;

  if (cw_left == HIGH && prev_cw_left == LOW) left_rotation = 1;
  else if (ccw_left == HIGH && prev_ccw_left == LOW) left_rotation = -1;

  prev_cw_right = cw_right;
  prev_ccw_right = ccw_right;
  prev_cw_left = cw_left;
  prev_ccw_left = ccw_left;

  if (right_rotation != 0 || left_rotation != 0) {
    char msg[50];
    snprintf(msg, sizeof(msg), "R:%d;L:%d", right_rotation, left_rotation);
    String message = String(msg);
    if (client.connected()) {
      if (client.publish("rotations", msg)) {
        Serial.println("Rotation message published");
      } else {
        Serial.println("Failed to publish rotation message");
        messageQueue.push(message); // Add to the queue if publish fails
      }
    } else {
      messageQueue.push(message); // Add to the queue if not connected
    }
  }
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  handleSerialInput(mySerial1, "sonar1");
  handleSerialInput(mySerial2, "sonar2");

  detectRotationAndPublish();
  delay(10); // Small delay to prevent flooding
}
