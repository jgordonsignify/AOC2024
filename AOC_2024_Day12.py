import sys

# Global variables
regions = {}  # key: region_id, value: {perimeter: int, area: int}
space_regions = {}  # key: "x,y", value: region_id

def read_grid(filename):
    grid = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                # Convert each line into a list of characters and add to grid
                row = list(line.strip())
                grid.append(row)
        return grid
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)

def get_adjacent_coords(x, y, max_x, max_y):
    """Returns list of valid adjacent coordinates (no diagonals)"""
    adjacent = []
    for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]:  # right, down, left, up
        new_x, new_y = x + dx, y + dy
        if 0 <= new_x < max_x and 0 <= new_y < max_y:
            adjacent.append((new_x, new_y))
    return adjacent

def merge_regions(from_region, to_region):
    """Merges region data from higher ID region into lower ID region"""
    # Add area and perimeter from source region to destination region
    regions[to_region]["area"] += regions[from_region]["area"]
    regions[to_region]["perimeter"] += regions[from_region]["perimeter"]
    
    # Update all grid spaces from source region to point to destination region
    for coord, region in list(space_regions.items()):
        if region == from_region:
            space_regions[coord] = to_region
    
    # Remove the old region
    del regions[from_region]

def analyze_regions(grid):
    if not grid:
        return
    
    height = len(grid)
    width = len(grid[0])
    next_region_id = 1

    for y in range(height):
        for x in range(width):
            current_value = grid[y][x]
            coord_key = f"{x},{y}"
            
            # Debug: Print current coordinate and value
            print(f"\nAnalyzing ({x},{y}) = {current_value}")
            
            # Check adjacent squares for matching regions
            matching_regions = set()
            adjacent_coords = get_adjacent_coords(x, y, width, height)
            
            # Debug: Print adjacent squares
            print("Adjacent squares:")
            for adj_x, adj_y in adjacent_coords:
                print(f"  ({adj_x},{adj_y}) = {grid[adj_y][adj_x]}")
            
            # Find all matching regions
            for adj_x, adj_y in adjacent_coords:
                adj_key = f"{adj_x},{adj_y}"
                if adj_key in space_regions:
                    adj_region = space_regions[adj_key]
                    if grid[adj_y][adj_x] == current_value:
                        matching_regions.add(adj_region)
                        print(f"  Matching region {adj_region} found at ({adj_x},{adj_y})")
            
            # If matching regions found, use lowest ID and merge others
            if matching_regions:
                matching_region = min(matching_regions)
                # Merge any other matching regions into the lowest ID region
                for region in matching_regions:
                    if region > matching_region:
                        merge_regions(region, matching_region)
            else:
                # If no matching region found, create new one
                matching_region = next_region_id
                next_region_id += 1
                regions[matching_region] = {"perimeter": 0, "area": 0}
                print(f"  Creating new region {matching_region}")
            
            # Assign current space to region
            space_regions[coord_key] = matching_region
            regions[matching_region]["area"] += 1
            
            # Check perimeter - count edges and different values
            for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]:  # right, down, left, up
                adj_x, adj_y = x + dx, y + dy
                # Count out of bounds or different value squares as perimeter
                if (adj_x < 0 or adj_x >= width or 
                    adj_y < 0 or adj_y >= height or 
                    grid[adj_y][adj_x] != current_value):
                    regions[matching_region]["perimeter"] += 1

def main():
    if len(sys.argv) != 2:
        print("Usage: python AOC_2024_Day12.py <input_file>")
        sys.exit(1)
    
    filename = sys.argv[1]
    grid = read_grid(filename)
    
    # Print the grid to verify
    print("Crop Grid:")
    for row in grid:
        print(''.join(row))
    
    # Analyze regions
    analyze_regions(grid)
    
    # Print results
    print("\nRegions analysis:")
    for region_id, stats in regions.items():
        print(f"Region {region_id}: Area = {stats['area']}, Perimeter = {stats['perimeter']}")
    
    # Additional information about the grid
    if grid:
        print(f"\nGrid dimensions: {len(grid)} rows x {len(grid[0])} columns")
    
    # Calculate and print sum of area * perimeter
    total_sum = sum(stats['area'] * stats['perimeter'] for stats in regions.values())
    print(f"\nSum of area * perimeter for all regions: {total_sum}")

if __name__ == "__main__":
    main()
