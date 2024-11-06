import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import math
import numpy as np
import matplotlib.pyplot as plt

# Initial position and orientation
x, y, theta = 0, 0, 0  # Initial position (x, y) in meters and theta in degrees

# Constants
wheel_radius = 0.05  # meters
wheel_base = 0.1     # meters
sonar_radius = 0   # meters, distance from center of vehicle to sonar

# Lists to store positions for plotting
x_positions = [x]
y_positions = [y]
sonar_points_x = []  # List to store x positions of detected objects
sonar_points_y = []  # List to store y positions of detected objects

class RotationListener(Node):
    def __init__(self):
        super().__init__('rotation_listener')
        self.subscription = self.create_subscription(
            String,
            '/rotations',
            self.listener_callback,
            10
        )
        self.sonar1_subscription = self.create_subscription(
            String,
            '/sonar1',
            self.sonar1_callback,
            10
        )
        self.sonar2_subscription = self.create_subscription(
            String,
            '/sonar2',
            self.sonar2_callback,
            10
        )

        # Set up the plot
        plt.ion()  # Turn on interactive mode
        self.fig, self.ax = plt.subplots(figsize=(10, 10))
        self.ax.set_title("Robot Trajectory with Step Numbers and Sonar Points")
        self.ax.set_xlabel("X Position (m)")
        self.ax.set_ylabel("Y Position (m)")
        self.ax.grid(True)
        self.ax.axis("equal")

    def listener_callback(self, msg):
        global x, y, theta, x_positions, y_positions
        
        # Parse the message, e.g., "R:1;L:0"
        rotation_data = msg.data.split(";")
        delta_right = int(rotation_data[0].split(":")[1])
        delta_left = int(rotation_data[1].split(":")[1])

        # Calculate distances moved by each wheel
        d_right = wheel_radius * 2 * (np.pi/20) * delta_right  # Distance by right wheel
        d_left = wheel_radius * 2 * (np.pi/20) * delta_left    # Distance by left wheel

        # Calculate orientation change (delta_theta) and average distance (d)
        delta_theta = (d_right - d_left) / (2 * wheel_base)  # Change in orientation (radians)
        d = (d_right + d_left) / 2                           # Average distance moved

        # Update x and y position using the odometry model
        x += d * math.cos(math.radians(theta) + delta_theta / 2)
        y += d * math.sin(math.radians(theta) + delta_theta / 2)

        # Update orientation (theta), converting delta_theta to degrees
        theta += math.degrees(delta_theta)
        theta = (theta + 180) % 360 - 180  # Normalize theta to [-180, 180] degrees

        # Append updated position to lists for plotting
        x_positions.append(x)
        y_positions.append(y)

        # Print updated position and orientation for debugging
        self.get_logger().info(f"X: {x:.6f}, Y: {y:.6f}, Theta: {theta:.2f} degrees")

        # Update the plot in real-time
        self.ax.plot(x_positions, y_positions, marker='o', color='b', linestyle='-', markersize=5)

        # Plot sonar points in real-time
        self.ax.plot(sonar_points_x, sonar_points_y, marker='x', color='r', linestyle='None', markersize=10)

        self.fig.canvas.draw()
        self.fig.canvas.flush_events()

    def sonar1_callback(self, msg):
        global x, y, theta, sonar_points_x, sonar_points_y
        
        # Extract the distance value from the message (e.g., "D:20")
        try:
            distance = float(msg.data.split(":")[1]) / 100.0  # Convert cm to meters
        except ValueError:
            self.get_logger().error(f"Invalid sonar1 message: {msg.data}")
            return
        
        # Calculate the position of the detected object from sonar1 (90 degrees)
        sonar_x = x + sonar_radius * math.cos(math.radians(theta + 90))
        sonar_y = y + sonar_radius * math.sin(math.radians(theta + 90))

        # Calculate the position of the object
        obj_x = sonar_x + distance * math.cos(math.radians(theta + 90))
        obj_y = sonar_y + distance * math.sin(math.radians(theta + 90))

        # Append the detected object position to the list
        sonar_points_x.append(obj_x)
        sonar_points_y.append(obj_y)

    def sonar2_callback(self, msg):
        global x, y, theta, sonar_points_x, sonar_points_y
        
        # Extract the distance value from the message (e.g., "D:20")
        try:
            distance = float(msg.data.split(":")[1]) / 100.0  # Convert cm to meters
        except ValueError:
            self.get_logger().error(f"Invalid sonar2 message: {msg.data}")
            return
        
        # Calculate the position of the detected object from sonar2 (-90 degrees)
        sonar_x = x + sonar_radius * math.cos(math.radians(theta - 90))
        sonar_y = y + sonar_radius * math.sin(math.radians(theta - 90))

        # Calculate the position of the object
        obj_x = sonar_x + distance * math.cos(math.radians(theta - 90))
        obj_y = sonar_y + distance * math.sin(math.radians(theta - 90))

        # Append the detected object position to the list
        sonar_points_x.append(obj_x)
        sonar_points_y.append(obj_y)

def main(args=None):
    rclpy.init(args=args)
    rotation_listener = RotationListener()

    try:
        rclpy.spin(rotation_listener)
    except KeyboardInterrupt:
        pass

    rotation_listener.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
