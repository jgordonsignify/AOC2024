#!/usr/bin/perl
use strict;
use warnings;

   print("i        part a   part b   final\n");
for(my $i = 0; $i < 2 ** 8 - 1; $i++){
    printf("%08b", $i);
    print " ";
    my $part_a = ($i ^ 0b1010) ^ 0b1001;
    my $part_b = int($i / (($i % 8) ^ 0b1001 )); # A divided by the last 3 binary digits of A XORed with 1001 - This is going to be at least 8.
    printf("%08b", $part_a);
    print " ";
    printf("%08b", $part_b);
    print " ";
    printf("%08b", $part_a ^ $part_b);
    print "\n";
}