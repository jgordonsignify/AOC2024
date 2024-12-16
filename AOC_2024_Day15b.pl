#!/usr/bin/perl
use strict;
use warnings;

# Check for command line argument
die "Usage: $0 <input_file>\n" unless @ARGV == 1;
my $input_file = $ARGV[0];

# Direction mappings
my %directions = (
    '^' => [ 0, -1],  # Up: no change in x, -1 in y
    'v' => [ 0,  1],  # Down: no change in x, +1 in y
    '<' => [-1,  0],  # Left: -1 in x, no change in y
    '>' => [ 1,  0]   # Right: +1 in x, no change in y
);

# Initialize variables
my @map;
my @moves;
my $robot = [0, 0];  # [x, y]
my $reading_map = 1;  # Flag to track which part we're reading

sub move_space {
    my ($from_pos, $to_pos, $validate_only) = @_;
    return 1 if $validate_only;
    
    # Move the content from source to destination
    $map[$to_pos->[1]][$to_pos->[0]] = $map[$from_pos->[1]][$from_pos->[0]];
    $map[$from_pos->[1]][$from_pos->[0]] = '.';
    return 1;
}

sub move_robot {
    my ($pos, $vel, $validate_only) = @_;
    
    # Calculate target position
    my $new_x = $pos->[0] + $vel->[0];
    my $new_y = $pos->[1] + $vel->[1];
    
    # Check bounds
    return 0 if $new_x < 0 || $new_y < 0 || $new_y >= scalar(@map) || $new_x >= scalar(@{$map[0]});
    
    # Get what's in the target space
    my $target = $map[$new_y][$new_x];
    
    # Hit a wall
    return 0 if $target eq '#';
    
    # Empty space
    if ($target eq '.') {
        return move_space($pos, [$new_x, $new_y], $validate_only);
    }
    
    # Hit a box ([ or ])
    if ($target eq '[' || $target eq ']') {
        # For vertical moves, need to check both halves
        if ($vel->[1] != 0) {  # Moving up or down
            # Try to move both parts of the box
            my $other_x = ($target eq '[') ? $new_x + 1 : $new_x - 1;
            
            # Both parts must move or neither can
            if (move_robot([$new_x, $new_y], $vel, 1) && 
                move_robot([$other_x, $new_y], $vel, 1)) {
                if (move_robot([$new_x, $new_y], $vel, $validate_only) && 
                    move_robot([$other_x, $new_y], $vel, $validate_only)) {
                    return move_space($pos, [$new_x, $new_y], $validate_only);
                }                
            }
            return 0;
        } else {  # Moving horizontally
            # Try to move the box
            if (move_robot([$new_x, $new_y], $vel, $validate_only)) {
                return move_space($pos, [$new_x, $new_y], $validate_only);
            }
            return 0;
        }
    }
    
    return 0;  # Default case
}

# Read the input file
open(my $fh, '<', $input_file) or die "Could not open file '$input_file': $!";

while (my $line = <$fh>) {
    chomp $line;
    
    # Skip empty lines - these separate the map from the moves
    if ($line =~ /^\s*$/) {
        $reading_map = 0;
        next;
    }
    
    if ($reading_map) {
        # Process map line
        my @row;
        my @chars = split //, $line;
        for my $char (@chars) {
            if ($char eq '#') {
                push @row, '#', '#';
            }
            elsif ($char eq 'O') {
                push @row, '[', ']';
            }
            elsif ($char eq '.') {
                push @row, '.', '.';
            }
            elsif ($char eq '@') {
                push @row, '@', '.';
                $robot->[0] = scalar(@row) - 2;  # Position of @ in expanded map
                $robot->[1] = scalar(@map);
            }
        }
        push @map, \@row;
    } else {
        # Process moves line
        # Convert arrows to direction vectors
        my @chars = split //, $line;
        foreach my $char (@chars) {
            if (exists $directions{$char}) {
                push @moves, $directions{$char};
            }
        }
    }
}

close $fh;

# Print initial state
print "Initial map:\n";
for my $row (@map) {
    print join('', @$row) . "\n";
}

print "\nRobot position: ($robot->[0], $robot->[1])\n";
print "\nMoves: ";
my $i = 0;
for my $move (@moves) {
    print "[$move->[0],$move->[1]] ";
    if(move_robot($robot, $move, 1)) {
        print "Move is valid\n";
    }
    if(move_robot($robot, $move, 0)) {
        $robot->[0] += $move->[0];
        $robot->[1] += $move->[1];
    }
    # print "Iteration: $i\n";
    # for my $row (@map) {
    #     print join('', @$row) . "\n";
    # }
}
print "\n";

print "\nFinal map:\n";
for my $row (@map) {
    print join('', @$row) . "\n";
}
# Calculate final score
my $total_score = 0;
for my $y (0..$#map) {
    for my $x (0..$#{$map[$y]}) {
        if ($map[$y][$x] eq '[') {
            # Calculate distance to both edges and use the smaller one
            my $left_edge_dist = $x;
            # my $right_edge_dist = scalar(@{$map[$y]}) - 1 - $x;
            # my $score = (100 * $y) + ($left_edge_dist < $right_edge_dist ? $left_edge_dist : $right_edge_dist);
            my $score = (100 * $y) + $left_edge_dist;
            $total_score += $score;
            print "Found [ at ($x,$y) - Left dist: $left_edge_dist, Score: $score, Running total: $total_score\n";
        }
    }
}

print "Final score: $total_score\n";