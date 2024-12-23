#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#define REFRESH_RATE 10

// WiFi and MQTT configuration
const char* ssid = "LAB_DIGITAL"; // WiFi SSID
const char* password = "C1-17*2018@labdig"; // WiFi Password
const char* mqtt_server = "192.168.17.189"; // MQTT server IP

// Digital pin definitions for rotation
const int pin_rotation_cw_right = 13;  // CW Right rotation pin
const int pin_rotation_ccw_right = 15; // CCW Right rotation pin
const int pin_rotation_cw_left = 5;    // CW Left rotation pin
const int pin_rotation_ccw_left = 4;   // CCW Left rotation pin

WiFiClient espClient;
PubSubClient client(espClient);

// Setup WiFi connection
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

// MQTT reconnection
void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);

    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("connected to MQTT broker");
      
      // Subscribe to topics
      Serial.println("Subscribing to topics...");
      client.subscribe("/move/forward");
      client.subscribe("/move/backward");
      client.subscribe("/move/left");
      client.subscribe("/move/right");
      Serial.println("Subscribed to topics");
    } else {
      Serial.print("Failed to connect, rc=");
      Serial.print(client.state());
      Serial.println(". Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

// MQTT message callback (not used in this case, but kept for structure)
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.println(topic);
}

// Main setup function
void setup() {
  Serial.begin(115200); // Serial communication
  Serial.println("Setting up...");

  setup_wifi(); // Connect to WiFi
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Setup digital pins for rotations
  pinMode(pin_rotation_cw_right, INPUT);
  pinMode(pin_rotation_ccw_right, INPUT);
  pinMode(pin_rotation_cw_left, INPUT);
  pinMode(pin_rotation_ccw_left, INPUT);
  
  Serial.println("Setup complete");
}

// Previous states for edge detection
int prev_cw_right = 0;
int prev_ccw_right = 0;
int prev_cw_left = 0;
int prev_ccw_left = 0;

void loop() {
  // Ensure MQTT connection is active
  if (!client.connected()) {
    Serial.println("MQTT not connected. Reconnecting...");
    reconnect();
  }
  client.loop(); // Handle MQTT loop

  // Read the current state of rotation pins
  int cw_right = digitalRead(pin_rotation_cw_right);
  int ccw_right = digitalRead(pin_rotation_ccw_right);
  int cw_left = digitalRead(pin_rotation_cw_left);
  int ccw_left = digitalRead(pin_rotation_ccw_left);

  // Rotation values, will only be set on a 0 -> 1 transition
  int right_rotation = 0;
  int left_rotation = 0;

  // Check for rising edges (0 -> 1 transition)
  if (cw_right == HIGH && prev_cw_right == LOW) {
    right_rotation = 1;  // CW Right rotation
    Serial.println("Right rotation: CW (detected edge)");
  } else if (ccw_right == HIGH && prev_ccw_right == LOW) {
    right_rotation = -1; // CCW Right rotation
    Serial.println("Right rotation: CCW (detected edge)");
  }

  if (cw_left == HIGH && prev_cw_left == LOW) {
    left_rotation = 1;   // CW Left rotation
    Serial.println("Left rotation: CW (detected edge)");
  } else if (ccw_left == HIGH && prev_ccw_left == LOW) {
    left_rotation = -1;  // CCW Left rotation
    Serial.println("Left rotation: CCW (detected edge)");
  }

  // Update previous states for next loop
  prev_cw_right = cw_right;
  prev_ccw_right = ccw_right;
  prev_cw_left = cw_left;
  prev_ccw_left = ccw_left;

  // Only publish if there was a rotation change detected
  if (right_rotation != 0 || left_rotation != 0) {
    char msg[50];
    snprintf(msg, sizeof(msg), "R:%d;L:%d", right_rotation, left_rotation);
    Serial.print("Publishing message: ");
    Serial.println(msg);

    if (client.publish("rotations", msg)) {
      Serial.println("Message published successfully");
    } else {
      Serial.println("Failed to publish message");
    }
  } else {
    Serial.println("No new rotation edge detected, not publishing.");
  }

  // Delay to avoid flooding the MQTT broker
  delay(REFRESH_RATE);
}
