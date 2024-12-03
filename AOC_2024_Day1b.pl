#!/usr/bin/env perl
use warnings;
use strict;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";
my $inputstring;
while (my $line = <$input_fh>){
    $inputstring .= $line; 
}
my @testinput = split ('\n',$inputstring);

#array
my @firstcol;
#hashmap
my %secondcol;
my $sum = 0;
foreach my $line (@testinput){
    print "Line - $line\n";
    next if ($line !~ /\d+/);
    my @digits = split('   ',$line);
    #print join(',', @digits)."\n";
    push(@firstcol, int($digits[0]));
    #increment count of occurences of second number
    $secondcol{int($digits[1])}++;
}
@firstcol = sort(@firstcol);
use Data::Dumper;
print Dumper(@firstcol);
print Dumper(\%secondcol);
for(my $i=0;$i<@firstcol;$i++){
    $sum += ($firstcol[$i] * ($secondcol{$firstcol[$i]} || 0));
}
print "Sum is $sum\n";