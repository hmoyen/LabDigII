#include <WiFi.h>
#include <PubSubClient.h>
#include <math.h>

// WiFi and MQTT configuration
const char* ssid = "LAB_DIGITAL";
const char* password = "C1-17*2018@labdig";
const char* mqtt_server = "192.168.17.189";

WiFiClient espClient;
PubSubClient client(espClient);

// Digital pin definitions for rotation
const int pin_rotation_cw_right = 4;
const int pin_rotation_ccw_right = 22;
const int pin_rotation_cw_left = 18;
const int pin_rotation_ccw_left = 23;

// Serial pins configuration
#define RXD1 21
#define TXD1 19
#define RXD2 16
#define TXD2 17

// Serial instances
HardwareSerial mySerial1(1);
HardwareSerial mySerial2(2);

// Wheel and robot parameters
const float wheel_radius = 0.05;  // Wheel radius in meters
const float wheel_base = 0.2;    // Distance between wheels in meters

// Robot state
float x = 0.0;
float y = 0.0;
float theta = 0.0;  // Orientation in degrees
float prev_theta = 0.0;  // Orientation in degrees
int prev_cw_right = 0, prev_ccw_right = 0, prev_cw_left = 0, prev_ccw_left = 0;

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
    x = 0.0;
    y = 0.0;
    theta = 0.0;
    Serial.println("Robot position reset to x=0, y=0, theta=0");
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
void calculatePositionAndPublish(int delta_right, int delta_left) {
  // Calculate distances moved by each wheel
  float d_right = wheel_radius * 2 * (M_PI / 15) * delta_right;
  float d_left = wheel_radius * 2 * (M_PI / 15) * delta_left;
  prev_theta = theta;

  // Calculate orientation change and average distance
  float delta_theta = (d_right - d_left) / (2 * wheel_base);
  float d = (d_right + d_left) / 2;

  // Update orientation
  theta += delta_theta * (180.0 / M_PI);  // Convert radians to degrees

  // Normalize theta to the range [-180, 180]
  while (theta > 180.0) theta -= 360.0;
  while (theta < -180.0) theta += 360.0;

  // Update position
  float avg_theta = radians(prev_theta) + delta_theta / 2;  // Use updated theta for movement
  x += d * cos(avg_theta);
  y += d * sin(avg_theta);

  // Publish rotation message (R:x, L:y)
  char rotation_msg[50];
  snprintf(rotation_msg, sizeof(rotation_msg), "R:%d,L:%d", delta_right, delta_left);
  if (client.publish("robot/rotations", rotation_msg)) {
    Serial.println("Rotation message published");
  } else {
    Serial.println("Failed to publish rotation message");
  }

  // Publish position and orientation (theta, x, y)
  char position_msg[100];
  snprintf(position_msg, sizeof(position_msg), "theta:%.2f,x:%.2f,y:%.2f", theta, x, y);
  if (client.publish("robot/position", position_msg)) {
    Serial.println("Position message published");
  } else {
    Serial.println("Failed to publish position message");
  }
}

void detectRotationAndCalculate() {
  int cw_right = digitalRead(pin_rotation_cw_right);
  int ccw_right = digitalRead(pin_rotation_ccw_right);
  int cw_left = digitalRead(pin_rotation_cw_left);
  int ccw_left = digitalRead(pin_rotation_ccw_left);

  int delta_right = 0, delta_left = 0;

  if (cw_right == HIGH && prev_cw_right == LOW) delta_right = 1;
  else if (ccw_right == HIGH && prev_ccw_right == LOW) delta_right = -1;

  if (cw_left == HIGH && prev_cw_left == LOW) delta_left = 1;
  else if (ccw_left == HIGH && prev_ccw_left == LOW) delta_left = -1;

  prev_cw_right = cw_right;
  prev_ccw_right = ccw_right;
  prev_cw_left = cw_left;
  prev_ccw_left = ccw_left;

  if (delta_right != 0 || delta_left != 0) {
    calculatePositionAndPublish(delta_right, delta_left);
  }
}

void setup() {
  Serial.begin(115200);

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(mqttCallback); // Set the MQTT callback function

  mySerial1.begin(115200, SERIAL_8N1, RXD1, TXD1);
  mySerial2.begin(115200, SERIAL_8N1, RXD2, TXD2);

  pinMode(pin_rotation_cw_right, INPUT);
  pinMode(pin_rotation_ccw_right, INPUT);
  pinMode(pin_rotation_cw_left, INPUT);
  pinMode(pin_rotation_ccw_left, INPUT);

  Serial.println("Setup complete");
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  handleSerialInput(mySerial1, "sonar1");
  handleSerialInput(mySerial2, "sonar2");

  detectRotationAndCalculate();
  delay(10);
}
