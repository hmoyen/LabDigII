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
