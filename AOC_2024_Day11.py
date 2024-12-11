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

def process_stone(stone):
    # Rule 1: If stone is 0, replace with 1
    if stone == 0:
        return [1]
    
    # Rule 2: If number has even digits, split into two stones
    stone_str = str(stone)
    if len(stone_str) % 2 == 0:
        mid = len(stone_str) // 2
        left = int(stone_str[:mid])
        right = int(stone_str[mid:])
        return [left, right]
    
    # Rule 3: Multiply by 2024
    return [stone * 2024]

def process_stones(stones):
    new_stones = []
    for stone in stones:
        new_stones.extend(process_stone(stone))
    return new_stones

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
    print(f"Initial stones: {stones}")
    
    # Process stones for N blinks
    current_stones = stones
    for blink in range(num_blinks):
        current_stones = process_stones(current_stones)
        #print(f"After blink {blink + 1}: {current_stones}")
        print(f"Length after blink {blink + 1}: {len(current_stones)}")

if __name__ == "__main__":
    main()
