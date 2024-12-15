import sys
from dataclasses import dataclass
import time

@dataclass
class Robot:
    pos_x: int
    pos_y: int
    vel_x: int
    vel_y: int
    
    def update_position(self, ticks=1):
        # Update x position: add velocity * ticks then modulo with 101
        self.pos_x = (self.pos_x + (self.vel_x * ticks)) % 101
        
        # Update y position: add velocity * ticks then modulo with 103
        self.pos_y = (self.pos_y + (self.vel_y * ticks)) % 103

def read_robots(filename):
    robots = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                # Split the line into position and velocity parts
                pos_part, vel_part = line.strip().split()
                
                # Parse position coordinates
                pos_x, pos_y = map(int, pos_part.split('=')[1].split(','))
                
                # Parse velocity vector
                vel_x, vel_y = map(int, vel_part.split('=')[1].split(','))
                
                # Create new Robot instance
                robot = Robot(pos_x, pos_y, vel_x, vel_y)
                robots.append(robot)
                
        return robots
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except ValueError as e:
        print(f"Error parsing file: {e}")
        sys.exit(1)

def count_diagonal_adjacencies(robots):
    count = 0
    # For each robot
    for i in range(len(robots)):
        robot1 = robots[i]
        # Compare with every other robot
        for j in range(i+1, len(robots)):
            robot2 = robots[j]
            
            # Check if robot2 is diagonally adjacent to robot1
            dx = abs(robot1.pos_x - robot2.pos_x)
            dy = abs(robot1.pos_y - robot2.pos_y)
            if dx == 1 and dy == 1:  # Diagonally adjacent
                count += 1
    
    return count

def print_grid(robots, tick):
    # Count diagonal adjacencies first
    diagonal_count = count_diagonal_adjacencies(robots)
    
    # Only proceed with printing if count > 100
    if diagonal_count <= 175:
        return
    
    # Create empty grid
    grid = [['.'] * 101 for _ in range(103)]
    
    # Place robots on grid
    for i, robot in enumerate(robots):
        x, y = robot.pos_x, robot.pos_y
        # If multiple robots in same spot, show number instead of 'R'
        if grid[y][x] == '.':
            grid[y][x] = 'R'
        elif grid[y][x] == 'R':
            grid[y][x] = '2'
        else:
            grid[y][x] = str(int(grid[y][x]) + 1)
    
    # Print tick number and diagonal count
    print(f"\nTick {tick} (Diagonal adjacencies: {diagonal_count}):")
    
    # Print grid (with compressed view)
    for y in range(0, 103, 1):
        row = ''
        for x in range(0, 101, 1):
            char = grid[y][x]
            row += char
        print(row)
        # Count robots in quadrants
    quadrants = count_quadrants(robots)
    
    # Print quadrant counts
    print("\nQuadrant counts:")
    for quadrant, count in quadrants.items():
        print(f"{quadrant}: {count}")
    
    # Calculate product
    product = 1
    for count in quadrants.values():
        product *= count
    
    print(f"\nProduct of quadrant counts: {product}")

def count_quadrants(robots):
    # Initialize quadrant counts
    quadrants = {
        'top_left': 0,
        'top_right': 0,
        'bottom_left': 0,
        'bottom_right': 0
    }
    
    # Define middle points (excluding middle row/column)
    mid_x = 101 // 2  # 50
    mid_y = 103 // 2  # 51
    
    # Count robots in each quadrant
    for robot in robots:
        if robot.pos_x < mid_x:  # Left half
            if robot.pos_y < mid_y:  # Bottom half
                quadrants['bottom_left'] += 1
            elif robot.pos_y > mid_y:  # Top half
                quadrants['top_left'] += 1
        elif robot.pos_x > mid_x:  # Right half
            if robot.pos_y < mid_y:  # Bottom half
                quadrants['bottom_right'] += 1
            elif robot.pos_y > mid_y:  # Top half
                quadrants['top_right'] += 1
    
    return quadrants

def main():
    if len(sys.argv) != 2:
        print("Usage: python AOC_2024_Day14.py <input_file>")
        sys.exit(1)
    
    filename = sys.argv[1]
    robots = read_robots(filename)
    
    # Print initial positions
    #print("Initial positions:")
    #for i, robot in enumerate(robots, 1):
    #    print(f"Robot {i}: Position ({robot.pos_x}, {robot.pos_y}), Velocity ({robot.vel_x}, {robot.vel_y})")
    
    # Print initial grid
    #print_grid(robots, 0)
    
    # Update positions one tick at a time
    for tick in range(1, 10000):
        # Update each robot's position by one tick
        for robot in robots:
            robot.update_position(1)
        
        # Print the grid after each tick
        print_grid(robots, tick)
    
    # Count robots in quadrants
    quadrants = count_quadrants(robots)
    
    # Print quadrant counts
    print("\nQuadrant counts:")
    for quadrant, count in quadrants.items():
        print(f"{quadrant}: {count}")
    
    # Calculate product
    product = 1
    for count in quadrants.values():
        product *= count
    
    print(f"\nProduct of quadrant counts: {product}")

if __name__ == "__main__":
    main() 