#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

my @characters = map { chomp; [split //] } <$input_fh>; close $input_fh;

my $count = SearchGrid(\@characters,"MAS");
print "Count: $count\n";

sub SearchGrid {
    my ($grid, $target) = @_;
    #print Dumper($target, $grid);
    my $cols = scalar(@{$grid->[0]});
    my $rows = scalar(@{$grid});
    my $len = length($target);
    #print "$cols, $rows\n";
    my $count = 0;
    my %directions = ( 
        RIGHT => [ 0, 1], # Right
        DOWN => [ 1, 0], # Down
        DDR => [ 1, 1], # Diagonal down-right 
        DDL => [ 1, -1], # Diagonal down-left 
        LEFT => [ 0, -1], # Left 
        UP => [-1, 0], # Up 
        DUL => [-1, -1], # Diagonal up-left 
        DUR => [-1, 1], # Diagonal up-right
    );
    my $foundgridhashref;
    foreach my $i (0 .. $rows - 1) {
        foreach my $j (0 .. $cols - 1) {
            my %found_direction = map { $_ => 1} keys %directions;
            foreach my $dir (keys %directions) {
                my ($dx, $dy) = @{$directions{$dir}};
                #print Dumper(\%found_direction);
                #This is a hack that only works on length 3 strings, I really need to find the midpoint but lazy
                my $centerXpos = $i + 1*$dx;
                my $centerYpos = $j + 1*$dy;
                for my $k (0 .. $len - 1) {
                    my $x = $i + $k * $dx;
                    my $y = $j + $k * $dy;
                    #printf("X: %s, Y: %s, GRID: %s, TARGET: %s\n", $x, $y, $grid->[$x][$y], substr($target, $k, 1));
                    if ($x < 0 || $x >= $rows || $y < 0 || $y >= $cols || $grid->[$x][$y] ne substr($target, $k, 1)) {
                        $found_direction{$dir} = 0;
                        last;
                    }
                }
                if($found_direction{$dir}){
                    $foundgridhashref->{"$centerXpos,$centerYpos"}->{$dir} = 1;
                }
            }
        }
    }
    foreach my $gridpos (keys %$foundgridhashref){
        my %found_direction = %{$foundgridhashref->{$gridpos}};
        if (
                # (
                #     ($found_direction{UP} || $found_direction{DOWN}) &&
                #     ($found_direction{RIGHT} || $found_direction{LEFT})
                # ) ||
                (
                    ($found_direction{DDL} || $found_direction{DUR}) &&
                    ($found_direction{DDR} || $found_direction{DUL})
                )
        ){
            $count++;
        }
    }
    #print Dumper($foundgridhashref);
    return $count;
}