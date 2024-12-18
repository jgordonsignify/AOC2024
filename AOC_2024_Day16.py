import sys
sys.setrecursionlimit(20000)
# Global variables
start_x = 0
start_y = 0
end_x = 0
end_y = 0
best_score = {}
def read_grid(filename):
    grid = []
    try:
        with open(filename, 'r') as file:
            y = 0
            for line in file:
                row = list(line.strip())
                # Check for start and end positions
                for x, char in enumerate(row):
                    if char == 'S':
                        global start_x, start_y
                        start_x = x
                        start_y = y
                    elif char == 'E':
                        global end_x, end_y
                        end_x = x
                        end_y = y
                grid.append(row)
                y += 1
        return grid
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)

def get_possible_next_move(grid, x, y, dx, dy):
    
    # Calculate grid dimensions from the grid itself
    max_x = len(grid[0])
    max_y = len(grid)
    """Returns list of possible next coordinates based on current direction of travel.
    Returns coordinates for continuing straight or turning 90 degrees left/right.
    Excludes positions containing '#'."""
    possible_moves = []
    
    # Define left and right turns based on current direction
    if dx == 0 and dy == 1:  # Moving down
        turns = [(-1,0), (1,0)]  # Left is west, right is east
    elif dx == 0 and dy == -1:  # Moving up  
        turns = [(1,0), (-1,0)]  # Left is east, right is west
    elif dx == 1 and dy == 0:  # Moving right
        turns = [(0,-1), (0,1)]  # Left is north, right is south
    else:  # Moving left
        turns = [(0,1), (0,-1)]  # Left is south, right is north
        
    # Check continuing straight
    new_x, new_y = x + dx, y + dy
    if 0 <= new_x < max_x and 0 <= new_y < max_y and grid[new_y][new_x] != '#':
        possible_moves.append((new_x, new_y, 1))
        
    # Check turns
    for turn_dx, turn_dy in turns:
        new_x, new_y = x + turn_dx, y + turn_dy
        if 0 <= new_x < max_x and 0 <= new_y < max_y and grid[new_y][new_x] != '#':
            possible_moves.append((new_x, new_y, 1001))
            
    return possible_moves

def do_race(grid, x, y, current_score, dx, dy, visited_squares):
    global best_score
    position_key = (x, y, dx, dy)  # Include direction in the key since same position with different direction might be better
    # Check if current score is already worse than best known path to end
    end_key = (end_x, end_y)
    if end_key in best_score and current_score >= best_score[end_key]:
        print(f"Current score {current_score} is already worse than best path to end {best_score[end_key]}")
        return
    # Check if we've been here before with a better score
    if position_key in best_score and current_score >= best_score[position_key]:
        print(f"Already found better path to {position_key} with score {best_score[position_key]}")
        return
        
    # Update best score for this position
    best_score[position_key] = current_score
    
    # Debug print
    print(f"Trying position ({x}, {y}) with score {current_score}, direction ({dx}, {dy})")
    #print(f"Visited squares: {visited_squares}")
    
    if(x == end_x and y == end_y):
        print(f"Reached end with score: {current_score}")
        return
        
    possible_moves = get_possible_next_move(grid, x, y, dx, dy)
    #print(f"Possible moves from ({x}, {y}): {possible_moves}")
    
    for new_x, new_y, score in possible_moves:
        if (new_x, new_y) not in visited_squares:
            # Calculate new direction based on difference between new and current position
            new_dx = new_x - x
            new_dy = new_y - y
            print(f"Moving to ({new_x}, {new_y}) with additional score {score}")
            do_race(grid, new_x, new_y, current_score + score, new_dx, new_dy, visited_squares + [(new_x, new_y)])
        else:
            print(f"Skipping ({new_x}, {new_y}) - already visited")
    
    print(f"Finished exploring from ({x}, {y})")

def main():
    if len(sys.argv) != 2:
        print("Usage: python AOC_2024_Day16.py <input_file>")
        sys.exit(1)
    
    filename = sys.argv[1]
    grid = read_grid(filename)
    
    # Initialize best_score as a dictionary
    global best_score
    best_score = {}
    
    # Print the grid to verify
    print("Race track:")
    for row in grid:
        print(''.join(row))
    do_race(grid, start_x, start_y, 0, 1, 0, [])
    
    # Find the minimum score to reach the end
    end_scores = [score for (x, y, dx, dy), score in best_score.items() if x == end_x and y == end_y]
    if end_scores:
        print("Best score to reach end:", min(end_scores))
    else:
        print("No path found to end")
if __name__ == "__main__":
    main()



