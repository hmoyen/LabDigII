#include <WiFi.h>
#include <PubSubClient.h>

// WiFi and MQTT configuration
const char* ssid = "LAB_DIGITAL";       // WiFi SSID
const char* password = "C1-17*2018@labdig"; // WiFi Password
const char* mqtt_server = "192.168.17.189"; // MQTT server IP

WiFiClient espClient;
PubSubClient client(espClient);

// Digital pin definitions for rotation
const int pin_rotation_cw_right = 4;    // CW Right rotation pin
const int pin_rotation_ccw_right = 22; // CCW Right rotation pin
const int pin_rotation_cw_left = 18;   // CW Left rotation pin
const int pin_rotation_ccw_left = 23;  // CCW Left rotation pin

// Serial pins configuration
#define RXD1 21
#define TXD1 19
#define RXD2 16
#define TXD2 17

// Serial instances
HardwareSerial mySerial1(1);
HardwareSerial mySerial2(2);

// Rotation totals
int total_cw_right = 0, total_ccw_right = 0;
int total_cw_left = 0, total_ccw_left = 0;

// Previous states
int prev_cw_right = LOW, prev_ccw_right = LOW;
int prev_cw_left = LOW, prev_ccw_left = LOW;

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
      client.subscribe("robot/reset");
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
        if (client.publish(topic, message.c_str())) {
          Serial.println("Serial message published successfully");
        } else {
          Serial.println("Failed to publish serial message");
        }
      }
      buffer = "";
    } else {
      buffer += incomingByte;
    }
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  // Convert the payload to a string
  String message;
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("Message received on topic ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(message);

  // Check if the message is "1" on the reset topic
  if (String(topic) == "robot/reset" && message == "1") {
    total_ccw_right=0.0;
    total_cw_right=0.0;
    total_ccw_left=0.0;
    total_cw_left=0.0;
    Serial.println("Robot reset");
  }
}

void detectAndPublishRotation() {
  int cw_right = digitalRead(pin_rotation_cw_right);
  int ccw_right = digitalRead(pin_rotation_ccw_right);
  int cw_left = digitalRead(pin_rotation_cw_left);
  int ccw_left = digitalRead(pin_rotation_ccw_left);

  int right_rotation = 0, left_rotation = 0;

  // Detect right rotation
  if (cw_right == HIGH && prev_cw_right == LOW) {
    right_rotation = 1;
    total_cw_right++;
  } else if (ccw_right == HIGH && prev_ccw_right == LOW) {
    right_rotation = -1;
    total_ccw_right++;
  }

  // Detect left rotation
  if (cw_left == HIGH && prev_cw_left == LOW) {
    left_rotation = 1;
    total_cw_left++;
  } else if (ccw_left == HIGH && prev_ccw_left == LOW) {
    left_rotation = -1;
    total_ccw_left++;
  }

  // Update previous states
  prev_cw_right = cw_right;
  prev_ccw_right = ccw_right;
  prev_cw_left = cw_left;
  prev_ccw_left = ccw_left;

  // Publish delta rotation message
  if (right_rotation != 0 || left_rotation != 0) {
    char msg[50];
    snprintf(msg, sizeof(msg), "R:%d;L:%d", right_rotation, left_rotation);
    if (client.publish("rotations", msg)) {
      Serial.println("Rotation message published");
    } else {
      Serial.println("Failed to publish rotation message");
    }
  }

  // Publish total rotation message
  char total_msg[100];
  snprintf(total_msg, sizeof(total_msg),
           "RCCW:%d;RCW:%d;LCCW:%d;LCW:%d",
           total_ccw_right, total_cw_right, total_ccw_left, total_cw_left);
  if (client.publish("rotations/total", total_msg)) {
    Serial.println("Total rotation message published");
  } else {
    Serial.println("Failed to publish total rotation message");
  }
}

void setup() {
  Serial.begin(115200);

  // Setup WiFi and MQTT
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(mqttCallback); // Set the MQTT callback function
  mySerial1.begin(115200, SERIAL_8N1, RXD1, TXD1);
  mySerial2.begin(115200, SERIAL_8N1, RXD2, TXD2);

  // Setup digital pins for rotation detection
  pinMode(pin_rotation_cw_right, INPUT);
  pinMode(pin_rotation_ccw_right, INPUT);
  pinMode(pin_rotation_cw_left, INPUT);
  pinMode(pin_rotation_ccw_left, INPUT);

  Serial.println("Setup complete");
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  detectAndPublishRotation();

  handleSerialInput(mySerial1, "sonar1");
  handleSerialInput(mySerial2, "sonar2");
//  delay(1); // Prevent flooding
}
