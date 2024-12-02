#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";
my $inputstring;
while (my $line = <$input_fh>){
    $inputstring .= $line; 
}

my @testinput = split ('\n',$inputstring);
my $goodreport = 0;
foreach my $inputline (@testinput){
    my (@elements) = split(' ', $inputline);
    my $sortedline = join(' ',sort { $a <=> $b }(@elements));
    my $rsortedline = join(' ',sort { $b <=> $a }(@elements));
    unless($inputline eq $sortedline || $inputline eq $rsortedline){
        print "Skipping $inputline because it's not in order\n";
        next;
    }
    my $current = int($elements[0]);
    my $curisgood = 1;
    for(my $i=1;$i<@elements;$i++){
        print "$elements[$i] - $current\n";
        my $diff = abs(int($elements[$i]) - $current); 
        if( $diff > 3 ||$diff < 1){
            $curisgood=0;
        }
        $current = $elements[$i];
    }
    print "Good - $curisgood\n";
    $goodreport+=$curisgood;
}
print "Good reports: $goodreport\n";