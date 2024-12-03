#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";
my $inputstring = "";
while (my $line = <$input_fh>){
    $inputstring .= $line; 
}
my @mulcommands = $inputstring =~ /(mul\(\d+,\d+\))/g;
my $sum = 0;
foreach my $mulcommand (@mulcommands){
    my (@operands) = $mulcommand =~ /\((\d+),(\d+)\)/;
    $sum += $operands[0] * $operands[1];
}

print "$sum\n";