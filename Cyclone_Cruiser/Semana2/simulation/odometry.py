import math
import numpy as np
import matplotlib.pyplot as plt

# Initial position and orientation
x, y, theta = 0, 0, 0  # Initial position (x, y) in meters and theta in degrees

# Parameters: Curved path for 100 steps with only 1, 0, or -1 values
movements = [
    {"delta_right": 0, "delta_left": 1},   # Turn left
    {"delta_right": -1, "delta_left": 0},  # Turn right
    {"delta_right": 0, "delta_left": 1},   # Turn right
    {"delta_right": -1, "delta_left": 0},  # Turn left
    {"delta_right": 1, "delta_left": 1},   # Move forward
    {"delta_right": 1, "delta_left": 1}    # Move forward
] 

# Constants
wheel_radius = 0.05  # meters
wheel_base = 0.1     # meters, in Verilog this would be multiplied by 2

# Lists to store positions for plotting
x_positions = [x]
y_positions = [y]

# Main loop to update position based on wheel movements
for i, movement in enumerate(movements):
    # Extract movement values for each wheel
    delta_right = movement["delta_right"]
    delta_left = movement["delta_left"]

    # Calculate distances moved by each wheel
    d_right = wheel_radius * 2 * np.pi * delta_right  # Distance traveled by the right wheel
    d_left = wheel_radius * 2 * np.pi * delta_left    # Distance traveled by the left wheel

    # Calculate orientation change (delta_theta) and average distance (d)
    delta_theta = (d_right - d_left) / (2 * wheel_base)  # Change in orientation (radians)
    delta_deg = (delta_theta*180)/(2*np.pi)
    d = (d_right + d_left) / 2                           # Average distance moved
    
    delta_x = d * math.cos(math.radians(theta) + (delta_theta / 2))
    delta_y = d * math.sin(math.radians(theta) + (delta_theta / 2))
    # Update x and y position using the odometry model with the updated angle
    x += d * math.cos(math.radians(theta) + delta_theta / 2)  # New x position
    y += d * math.sin(math.radians(theta) + delta_theta / 2)  # New y position

    # Update orientation (theta), converting delta_theta to degrees for consistency
    theta += math.degrees(delta_theta)
    theta = (theta + 180) % 360 - 180  # Normalize theta to stay within [-180, 180] degrees

    # Append updated position to the lists for plotting
    x_positions.append(x)
    y_positions.append(y)

    # Print updated position and orientation for debugging
    print(f"Step {i+1} -> X: {x:.4f}, Y: {y:.4f}, Theta: {theta:.2f} degrees, delta_x: {delta_x:.4f},  delta_y: {delta_y:.4f}, delta_theta: {delta_deg:.2f}, avg: {d}")

# Plot the trajectory with numbered points
plt.figure(figsize=(10, 10))
plt.plot(x_positions, y_positions, marker='o', color='b', linestyle='-', markersize=5)
plt.title("Robot Trajectory with Step Numbers")
plt.xlabel("X Position (m)")
plt.ylabel("Y Position (m)")
plt.grid(True)
plt.axis("equal")

# Add numbers to each plotting point for debugging
for idx, (x, y) in enumerate(zip(x_positions, y_positions)):
    plt.text(x, y, str(idx), fontsize=20, ha='right')

plt.show()
