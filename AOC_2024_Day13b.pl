#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;

my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

my $total = 0;

while (my $line = <$input_fh>) {
    chomp $line;
    next unless $line;
    
    # Read Button A line
    if ($line =~ /Button A: X\+(\d+), Y\+(\d+)/) {
        my $a_x = $1;
        my $a_y = $2;
        
        # Read Button B line
        $line = <$input_fh>;
        chomp $line;
        die "Invalid format: Expected Button B line" unless $line =~ /Button B: X\+(\d+), Y\+(\d+)/;
        my $b_x = $1;
        my $b_y = $2;
        
        # Read Prize line
        $line = <$input_fh>;
        chomp $line;
        die "Invalid format: Expected Prize line" unless $line =~ /Prize: X=(\d+), Y=(\d+)/;
        my $prize_x = $1 + 10000000000000;
        my $prize_y = $2 + 10000000000000;
        
        # Solve matrix equation
        my $determinant = ($a_x * $b_y) - ($b_x * $a_y);
        my $A = (($prize_x * $b_y) - ($b_x * $prize_y)) / $determinant;
        my $B = (($a_x * $prize_y) - ($prize_x * $a_y)) / $determinant;
        
        # print "Set:\n";
        # print "  Button A: X=$a_x, Y=$a_y\n";
        # print "  Button B: X=$b_x, Y=$b_y\n";
        # print "  Prize: X=$prize_x, Y=$prize_y\n";
        # print "Solution:\n";
        # print "  A = $A\n";
        # print "  B = $B\n";
        
        # Check if both A and B are integers
        if ($A == int($A) && $B == int($B)) {
            my $set_value = (3 * $A) + $B;
            $total += $set_value;
        }
    }
}

print "Total: $total\n";
close $input_fh;
