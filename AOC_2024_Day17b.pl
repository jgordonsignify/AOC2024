#!/usr/bin/perl
use strict;
use warnings;
no warnings 'portable';
use Data::Dumper;
# Check for command line argument
die "Usage: $0 <input_file>\n" unless @ARGV == 1;
my $input_file = $ARGV[0];

# Initialize global variables
my %registers;
my @program;
my @outputs;
my $instruction_pointer = 0;

# Command mappings
# The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.

# The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.

# The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.

# The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.

# The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)

# The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)

# The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)

# The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)

# There are two types of operands; each instruction specifies the type of its operand. The value of a literal operand is the operand itself. For example, the value of the literal operand 7 is the number 7. The value of a combo operand can be found as follows:

# Combo operands 0 through 3 represent literal values 0 through 3.
# Combo operand 4 represents the value of register A.
# Combo operand 5 represents the value of register B.
# Combo operand 6 represents the value of register C.
# Combo operand 7 is reserved and will not appear in valid programs.
sub process_command {
    my ($opcode, $operand) = @_;
    my $A = $registers{'A'};
    my $B = $registers{'B'};
    my $C = $registers{'C'};
    my $operand_value;
    if ($opcode == 3 || $opcode == 1) {
        $operand_value = $operand;
    }
    else {
        if($operand >= 0 && $operand <= 3){
            $operand_value = $operand;
        }
        elsif($operand == 4){
            $operand_value = $A;
        }
        elsif($operand == 5){
            $operand_value = $B;
        }
        elsif($operand == 6){
            $operand_value = $C;
        }
        else{
            die "Invalid operand for opcode $opcode: $operand\n";
        }
    }

    if ($opcode == 0) {
        $registers{'A'} = int($A / (2 ** $operand_value));
    }
    elsif ($opcode == 1) {
        $registers{'B'} = $B ^ $operand_value;
    }
    elsif ($opcode == 2) {
        $registers{'B'} = $operand_value % 8;
    }
    elsif ($opcode == 3) {
        if ($A != 0) {
            $instruction_pointer = $operand_value;
        }
        else{
            $instruction_pointer += 2;
        }
    }
    elsif ($opcode == 4) {
        $registers{'B'} = $B ^ $C;
    }
    elsif ($opcode == 5) {
        # printf "Round complete\n";
        # printf "        A=%46b\n", $A;
        # printf "        B=%46b\n", $B;
        # printf "        C=%46b\n", $C;
        #printf "        IP=%d\n", $instruction_pointer;
        push @outputs, $operand_value % 8;
    }
    elsif ($opcode == 6) {
        $registers{'B'} = int($A / (2 ** $operand_value));
    }
    elsif ($opcode == 7) {
        $registers{'C'} = int($A / (2 ** $operand_value));
    }
    if($opcode != 3){
        $instruction_pointer += 2;
    }
    # printf "After execution:\n";
    # printf "  A=%b\n", $registers{'A'};
    # printf "  B=%b\n", $registers{'B'}; 
    # printf "  C=%b\n", $registers{'C'};
    # printf "  IP=%d\n", $instruction_pointer;
}

# Read input file
sub read_input_file {
    open(my $fh, '<', $input_file) or die "Cannot open $input_file: $!";

    while (my $line = <$fh>) {
        chomp $line;
        
        if ($line =~ /^Register ([A-Z]): (\d+)$/) {
            # Store register values
            $registers{$1} = $2;
        }
        elsif ($line =~ /^Program: (.+)$/) {
            # Store program instructions
            @program = split /,/, $1;
        }
    }
    close($fh);
}

sub bin2dec {
    return oct("0b" . $_[0]);
}

# Each iteration through the program chops off the last three dinary digits of the A value, this means that the string gets shorter by 3 characters every time.
# It should be possible to build the string back up 3 binary digits at a time, since the first N digits still have to return the desired output.
# This means we have to try 8 possible strings 000 -> 111, checking to see if the output returned is the END of the program code, since we're building in reverse.
#
# Ok, so I thought we could just take the first value we hit, but since the other characters in the string affect the output, we need to store and try all possible
# strings that return the desired output. We can still guarantee that the string has to start with something that generates the end of the desired output.
# 
my @possiblestrings = ("");
for(my $chunknum=0;$chunknum<16;$chunknum++){  #should probably genericize this, but honestly that's difficult because I only know that this program cuts the A length by 3.
    print "Chunk Number $chunknum\n";
    my @newpossiblestrings=();
    for(my $iter = 0; $iter < 8; $iter++){
        foreach my $string (@possiblestrings){
            my $i = bin2dec($string . sprintf("%03b", $iter));
            printf "Iteration %b\n", $i;
            read_input_file();
            $registers{'A'} = $i;
            while($instruction_pointer < @program -1){
                process_command($program[$instruction_pointer], $program[$instruction_pointer + 1]);
            }
            #Compare outputs to last n character of program
            if (@outputs > 0) {
                my $output_str = join(",", @outputs);
                my $program_str = join(",", @program);
                my $output_len = length($output_str);
                my $program_end = substr($program_str, -$output_len);
                print "Output at iteration $i. \nProgram: $program_str\n Program end string: $program_end\n Outputs: $output_str\n";
                if ($output_str eq $program_end) {
                    @outputs = ();
                    $instruction_pointer = 0;
                    my $newstring = sprintf("%b", $i); # convert to binary
                    push @newpossiblestrings, $newstring;
                    print "Adding possible string: $string\n";
                }
            }
            if (join(",", @outputs) eq join(",", @program)) {
                print "Found matching output at iteration $i\n";
            }
            # Reset for next iteration
            @outputs = ();
            $instruction_pointer = 0;
        }
    }
    @possiblestrings = sort @newpossiblestrings;
    print "Possible strings:\n".join("\n", @possiblestrings)."\n";
}
print "Smallest integer is: " . bin2dec($possiblestrings[0])."\n";