import sys
sys.setrecursionlimit(20000)
# Global variables
start_x = 0
start_y = 0
size = 71
end_x = size - 1
end_y = size - 1
best_score = {}

def read_grid(filename, num_lines):
    # Initialize empty 71x71 grid with dots
    grid = [['.' for _ in range(size)] for _ in range(size)]
    
    try:
        with open(filename, 'r') as file:
            # Read only the specified number of lines
            lines_read = 0
            for line in file:
                # Parse X,Y coordinates from each line
                coords = line.strip().split(',')
                if len(coords) == 2:
                    x = int(coords[0])
                    y = int(coords[1])
                    # Place # at each coordinate if within bounds
                    if 0 <= x < size and 0 <= y < size:
                        grid[y][x] = '#'
                    lines_read += 1
                    if lines_read >= num_lines:
                        return grid
                        
            return grid
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)

def get_possible_next_move(grid, x, y):
    
    # Calculate grid dimensions from the grid itself
    max_x = len(grid[0])
    max_y = len(grid)
    possible_moves = []
    
    turns = [(0,1), (0,-1), (1,0), (-1,0)] # Check every adjacent square
        
    # Check turns
    for turn_dx, turn_dy in turns:
        new_x, new_y = x + turn_dx, y + turn_dy
        if 0 <= new_x < max_x and 0 <= new_y < max_y and grid[new_y][new_x] != '#':
            possible_moves.append((new_x, new_y))
            
    return possible_moves

def do_race(grid, x, y, current_score, visited_squares):
    global best_score
    position_key = (x, y) 
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
    score = 1
    # Debug print
    print(f"Trying position ({x}, {y}) with score {current_score}")
    #print(f"Visited squares: {visited_squares}")
    
    if(x == end_x and y == end_y):
        print(f"Reached end with score: {current_score}")
        return
        
    possible_moves = get_possible_next_move(grid, x, y)
    #print(f"Possible moves from ({x}, {y}): {possible_moves}")
    
    for new_x, new_y in possible_moves:
        if (new_x, new_y) not in visited_squares:
            print(f"Moving to ({new_x}, {new_y}) with additional score {score}")
            do_race(grid, new_x, new_y, current_score + score, visited_squares + [(new_x, new_y)])
        else:
            print(f"Skipping ({new_x}, {new_y}) - already visited")
    
    print(f"Finished exploring from ({x}, {y})")

def main():
    if len(sys.argv) != 3:
        print("Usage: python AOC_2024_Day18.py <input_file>")
        sys.exit(1)
    
    filename = sys.argv[1]
    num_lines = int(sys.argv[2])
    grid = read_grid(filename, num_lines)
    
    # Initialize best_score as a dictionary
    global best_score
    best_score = {}
    
    # Print the grid to verify
    print("Race track:")
    for row in grid:
        print(''.join(row))
    do_race(grid, start_x, start_y, 0, [])
    
    # Find the minimum score to reach the end
    end_scores = [score for (x, y), score in best_score.items() if x == end_x and y == end_y]
    if end_scores:
        print("Best score to reach end:", min(end_scores))
    else:
        print("No path found to end")
if __name__ == "__main__":
    main()



