#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

#The only things we care about are:
# Grid size - xMax, yMax
my ($xMax, $yMax);
# Topo map
my $grid;
# Trailhead list for easy access
my $trailheads;

my $currentline = 0;
while (my $line = <$input_fh>){
    chomp $line;
    my @chars = split //, $line;
    my $i = 0;
    foreach my $char (@chars){
        $grid->{$i}->{$currentline} = $char;
        if($char eq '0'){
            $trailheads->{$i}->{$currentline} = {}; # Init with empty object, we will store all reachable 9's
        }
        $i++;
    }
    $xMax = $i-1;
    $currentline++;
}
$yMax = $currentline-1;

foreach my $trailhead_x (keys %{$trailheads}){
    foreach my $trailhead_y (keys %{$trailheads->{$trailhead_x}}){
        #starting from x,y - recursively search all paths upwards and record all 9's reachable;
        my $peaks_list = [];
        FindPeaks($grid, $trailhead_x, $trailhead_y, $peaks_list);
        foreach my $peak (@$peaks_list){
            $trailheads->{$trailhead_x}->{$trailhead_y}->{$peak->[0]}->{$peak->[1]}++;
        }
    }
}
my $sum = 0;
foreach my $trailhead_x (keys %{$trailheads}){
    foreach my $trailhead_y (keys %{$trailheads->{$trailhead_x}}){
        foreach my $peak_x (keys %{$trailheads->{$trailhead_x}->{$trailhead_y}}){
            $sum += keys %{$trailheads->{$trailhead_x}->{$trailhead_y}->{$peak_x}};
        }
    }
}
print "Sum: $sum\n";

sub FindPeaks{
    my ($grid, $startX, $startY, $peaks_list) = @_;
    my $current_height = $grid->{$startX}->{$startY};
    if ($current_height == 9){
        push(@{$peaks_list}, [$startX, $startY]);
    }
    else{
        my @directions = (
            [0,1],
            [1,0],
            [0,-1],
            [-1,0]
        );
        foreach my $dir (@directions){
            if(
                defined $grid->{$startX + $dir->[0]} &&
                defined $grid->{$startX + $dir->[0]}->{$startY + $dir->[1]} && 
                $grid->{$startX + $dir->[0]}->{$startY + $dir->[1]} == $current_height + 1
            ){
                FindPeaks($grid, $startX + $dir->[0], $startY + $dir->[1], $peaks_list);
            }
        }
    }
}