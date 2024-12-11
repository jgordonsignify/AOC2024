import sys

def read_stones(filename):
    stones = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                stones.extend(int(x) for x in line.strip().split())
        return stones
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except ValueError:
        print("Error: File contains invalid number format")
        sys.exit(1)
# Global cache to store results
stone_cache = {}

def process_stone(stone, blinks_remaining):
    # Check cache first
    cache_key = (stone, blinks_remaining)
    if cache_key in stone_cache:
        return stone_cache[cache_key]
        
    if blinks_remaining == 0:
        result = 1
    # Rule 1: If stone is 0, replace with 1
    elif stone == 0:
        result = process_stone(1, blinks_remaining - 1)
    
    # Rule 2: If number has even digits, split into two stones
    elif len(str(stone)) % 2 == 0:
        stone_str = str(stone)
        mid = len(stone_str) // 2
        left = int(stone_str[:mid])
        right = int(stone_str[mid:])
        # Sum the lengths of both resulting stone processes
        result = process_stone(left, blinks_remaining - 1) + process_stone(right, blinks_remaining - 1)
    
    # Rule 3: Multiply by 2024
    else:
        result = process_stone(stone * 2024, blinks_remaining - 1)
    
    # Cache the result before returning
    stone_cache[cache_key] = result
    return result

def process_stones(stones, num_blinks):
    total_length = 0
    for stone in stones:
        total_length += process_stone(stone, num_blinks)
    return total_length

def main():
    if len(sys.argv) != 3:
        print("Usage: python AOC_2024_Day11.py <input_file> <number_of_blinks>")
        sys.exit(1)
    
    try:
        filename = sys.argv[1]
        num_blinks = int(sys.argv[2])
        if num_blinks < 0:
            raise ValueError("Number of blinks must be non-negative")
    except ValueError as e:
        print(f"Error: Invalid number of blinks - {e}")
        sys.exit(1)
    
    stones = read_stones(filename)
    #print(f"Initial stones: {stones}")
    #print(f"Initial length: {len(stones)}")
    
    # Clear cache before processing
    stone_cache.clear()
    
    # Process all stones and get final length
    final_length = process_stones(stones, num_blinks)
    print(f"Final length after {num_blinks} blinks: {final_length}")
    print(f"Cache size: {len(stone_cache)}")

if __name__ == "__main__":
    main()
