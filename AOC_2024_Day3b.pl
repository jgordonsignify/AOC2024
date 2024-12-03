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
# The best way to do this would be to find the indexes of the do()s and don't()s and read everything after a do() until the next don't()

my @doindexes = FindAllOccurences("do()", $inputstring);
# print join ",", @doindexes,"\n";
my @dontindexes = FindAllOccurences("don't()", $inputstring);
# print join ",", @dontindexes,"\n";
my $sum = 0;

# there's almost certainly a better way to remove redundant dos and don'ts

# We start enabled
my $nextdo = 0;
my $nextdont = shift @dontindexes;
while(defined $nextdo){
    #if the next do index is still less than the next don't, it's irrelevant.
    while($doindexes[0] && ($doindexes[0] < $nextdont)){
        shift @doindexes;
    }
    # print "Next do: $nextdo\n";
    # print "Next don't: $nextdont\n";
    # print "Length: ".($nextdont-$nextdo)."\n";
    my $string = substr($inputstring, $nextdo, ($nextdont-$nextdo));
    # print "$string\n";
    my @mulcommands = $string =~ /(mul\(\d+,\d+\))/g;
    
    foreach my $mulcommand (@mulcommands){
        my (@operands) = $mulcommand =~ /\((\d+),(\d+)\)/;
        $sum += $operands[0] * $operands[1];
    }
    # move to next do()
    $nextdo = shift @doindexes;
    # if the next don't is before the next do, it's irrelevant.
    while($dontindexes[0] && ($dontindexes[0] < $nextdo)){
        shift @dontindexes;
    }
    # move to next don't
    $nextdont = shift @dontindexes;
    # if we're out of don't, go to the end of the string
    if(!$nextdont){
        $nextdont = length($inputstring);
    }
}
print "\n\n\n\nSum: $sum\n";

sub FindAllOccurences{
    my ($matchstring, $checkstring) = @_;

    my $index = index($checkstring, $matchstring);
    my $offset=0;
    my @indexes;
    while ($index != -1){
        push(@indexes, $index);
        $offset = $index +1;
        $index = index($checkstring, $matchstring, $offset);
    }
    return @indexes;
}