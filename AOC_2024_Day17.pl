#!/usr/bin/perl
use strict;
use warnings;
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
    print "Processing command: opcode=$opcode, operand=$operand, operand_value=$operand_value\n";
    print "Before execution:\n";
    print "  A=$A\n";
    print "  B=$B\n"; 
    print "  C=$C\n";
    print "  IP=$instruction_pointer\n";
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
    print "After execution:\n";
    print "  A=$registers{'A'}\n";
    print "  B=$registers{'B'}\n"; 
    print "  C=$registers{'C'}\n";
    print "  IP=$instruction_pointer\n";
}

# Read input file
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
while($instruction_pointer < @program -1){
    process_command($program[$instruction_pointer], $program[$instruction_pointer + 1]);
}

print "Outputs: ".join(",", @outputs)."\n";