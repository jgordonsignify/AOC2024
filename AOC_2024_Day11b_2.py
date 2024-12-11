import sys

def read_stones(filename):
    stone_counts = {}
    try:
        with open(filename, 'r') as file:
            for line in file:
                for x in line.strip().split():
                    stone = int(x)
                    stone_counts[stone] = stone_counts.get(stone, 0) + 1
        return stone_counts
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except ValueError:
        print("Error: File contains invalid number format")
        sys.exit(1)

def process_stone(stone, count):
    # Rule 1: If stone is 0, replace with 1
    if stone == 0:
        return {1: count}
    
    # Rule 2: If number has even digits, split into two stones
    stone_str = str(stone)
    if len(stone_str) % 2 == 0:
        mid = len(stone_str) // 2
        left = int(stone_str[:mid])
        right = int(stone_str[mid:])
        return {left: count, right: count}
    
    # Rule 3: Multiply by 2024
    return {stone * 2024: count}

def process_stones(stone_counts):
    new_counts = {}
    for stone, count in stone_counts.items():
        result = process_stone(stone, count)
        for new_stone, new_count in result.items():
            new_counts[new_stone] = new_counts.get(new_stone, 0) + new_count
    return new_counts

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
    
    stone_counts = read_stones(filename)
    print(f"Initial stones: {dict(stone_counts)}")
    
    # Process stones for N blinks
    current_counts = stone_counts
    for blink in range(num_blinks):
        current_counts = process_stones(current_counts)
        #print(f"After blink {blink + 1}: {current_counts}")
    print(f"Length after blink {blink + 1}: {sum(current_counts.values())}")

if __name__ == "__main__":
    main()
