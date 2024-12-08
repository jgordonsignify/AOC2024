#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

#The only things we care about are:
# Grid size - xMax, yMax
my ($xMax, $yMax);
# positions of antennas - Hashmap of
my $antennas;
# Past positions of guard
my $antinodes;

my $currentline = 0;
while (my $line = <$input_fh>){
    chomp $line;
    my @chars = split //, $line;
    my $i = 0;
    foreach my $char (@chars){
        if($char ne '#' && $char ne '.'){
            push(@{$antennas->{$char}}, [$i, $currentline]);
        }
        $i++;
    }
    $xMax = $i-1;
    $currentline++;
}
$yMax = $currentline-1;

#print Dumper($antennas);
foreach my $a_type (keys %{$antennas}){
    my @node = @{$antennas->{$a_type}};
    for(my $i = 0;$i<scalar(@node)-1;$i++){
        for(my $j = $i+1;$j<scalar(@node);$j++){
            my $distance = [$node[$j]->[0] - $node[$i]->[0], $node[$j]->[1] - $node[$i]->[1]];
            my $new_an = $node[$j];
            while(($new_an->[0] >= 0 && $new_an->[0] <= $xMax && $new_an->[1] >= 0 && $new_an->[1] <= $yMax)){
                $antinodes->{$new_an->[0]}->{$new_an->[1]}++;
                $new_an = [$new_an->[0] + $distance->[0], $new_an->[1] + $distance->[1]];
            }
            $new_an = $node[$i];
            while(($new_an->[0] >= 0 && $new_an->[0] <= $xMax && $new_an->[1] >= 0 && $new_an->[1] <= $yMax)){
                $antinodes->{$new_an->[0]}->{$new_an->[1]}++;
                $new_an = [$new_an->[0] - $distance->[0], $new_an->[1] - $distance->[1]];
            }
        }
    }
}
my $count = 0;
foreach my $x (keys %$antinodes){
    $count += scalar(keys %{$antinodes->{$x}});
}
print "Count: $count\n";
