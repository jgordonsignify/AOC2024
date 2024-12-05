#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

my @characters = map { chomp; [split //] } <$input_fh>; close $input_fh;

my $count = SearchGrid(\@characters,"XMAS");
print "Count: $count\n";

sub SearchGrid {
    my ($grid, $target) = @_;
    #print Dumper($target, $grid);
    my $cols = scalar(@{$grid->[0]});
    my $rows = scalar(@{$grid});
    my $len = length($target);
    #print "$cols, $rows\n";
    my $count = 0;
    my @directions = ( [ 0, 1], # Right
        [ 1, 0], # Down
        [ 1, 1], # Diagonal down-right 
        [ 1, -1], # Diagonal down-left 
        [ 0, -1], # Left 
        [-1, 0], # Up 
        [-1, -1], # Diagonal up-left 
        [-1, 1], # Diagonal up-right
    );
    foreach my $i (0 .. $rows - 1) {
        foreach my $j (0 .. $cols - 1) {
            foreach my $dir (@directions) {
                my ($dx, $dy) = @$dir;
                my $found = 1;
                for my $k (0 .. $len - 1) {
                    my $x = $i + $k * $dx;
                    my $y = $j + $k * $dy;
                    #printf("X: %s, Y: %s, GRID: %s, TARGET: %s\n", $x, $y, $grid->[$x][$y], substr($target, $k, 1));
                    if ($x < 0 || $x >= $rows || $y < 0 || $y >= $cols || $grid->[$x][$y] ne substr($target, $k, 1)) {
                        $found = 0;
                        last;
                    }
                }
                $count += $found;
            }
        }
    }
    return $count;
}