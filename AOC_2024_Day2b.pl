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

sub RemoveElementN{
    my($n, @elements) = @_;
    my @newelements;
    for(my $i=0;$i<@elements;$i++){
        next if($i == $n);
        push(@newelements,$elements[$i]);
    }
    return @newelements;
}

sub TestInputs{
    my @elements = @_;
    #test the list of elements against the sorted and reverse sorted lists to see if it's in increasing or decreasing order.
    my $inputline = join(' ', @elements);
    my $sortedline = join(' ',sort { $a <=> $b }(@elements));
    my $rsortedline = join(' ',sort { $b <=> $a }(@elements));
    unless($inputline eq $sortedline || $inputline eq $rsortedline){
        return 0;
    }
    my $current = int($elements[0]);
    #Go through elements and make sure the difference between current and next is >=1 and <=3
    for(my $i=1;$i<@elements;$i++){
        #print "$elements[$i] - $current\n";
        my $diff = abs(int($elements[$i]) - $current); 
        if( $diff > 3 ||$diff < 1){
            return 0;
        }
        $current = $elements[$i];
    }
    return 1;
}

my @testinput = split ('\n',$inputstring);
my $goodreport = 0;
foreach my $inputline (@testinput){
    my (@elements) = split(' ', $inputline);
    #test full line
    my $isgood = TestInputs(@elements);
    if (!$isgood){
        #if full line is no good, go through and remove each element and test the resulting array.
        for(my $i=0;$i<@elements;$i++){
            my @newelements = RemoveElementN($i,@elements);
            $isgood = TestInputs(@newelements);
            last if $isgood; #if this array is good, we're done
        }
    }
    $goodreport+=$isgood;
}

print "Good reports: $goodreport\n";