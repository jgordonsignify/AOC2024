#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use Clone qw(clone);
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

#The only things we care about are:
# Grid size - xMax, yMax
my ($xMax, $yMax);
# positions of obstacles - Hashmap of
my $obstacles;
# Current position of guard
my $guardpos;
# Past positions of guard
my $allguardpositions;
# Current direction of guard, represented by an arrayref
# of how to increment the x and y next time the guard moves.
my $dir = [0, -1];

my $currentline = 0;
while (my $line = <$input_fh>){
    chomp $line;
    my @chars = split //, $line;
    my $i = 0;
    foreach my $char (@chars){
        if($char eq '#'){
            $obstacles->{$i}->{$currentline} = 1;
        }
        elsif ($char eq '^'){
            $guardpos = [$i, $currentline];
            $allguardpositions->{$i}->{$currentline}++;
        }
        $i++;
    }
    $xMax = $i-1;
    $currentline++;
}
$yMax = $currentline-1;

my $guardstart = clone($guardpos);
MoveGuard($obstacles,$guardpos,$dir,$allguardpositions,$xMax,$yMax);
print Dumper($allguardpositions);
my $count = 0;

#For each position visited (except the start) run a whatif scenario to see what would happen if we put an obstacle at that position
foreach my $xTest (keys %{$allguardpositions}) {
    foreach my $yTest (keys %{$allguardpositions->{$xTest}}){
        #skip if starting position
        next if($yTest == $guardstart->[1] && $xTest == $guardstart->[0]);
        $obstacles->{$xTest}->{$yTest} = 1;
        my $guardstart_clone = clone($guardstart);
        my $cleanguardpos;
        if(MoveGuard($obstacles, $guardstart_clone, [0,-1], $cleanguardpos, $xMax, $yMax)){
            $count++;
        }
        #remove the obstacle when we're done
        delete $obstacles->{$xTest}->{$yTest};
    }
}
print "Count: $count\n";

sub MoveGuard{
    my ($obstacles, $guardpos, $direction, $allguardpositions, $xMax, $yMax) = @_;
    #print Dumper($obstacles, $guardpos, $direction, $allguardpositions, $xMax, $yMax);
    my $nextpos = [$guardpos->[0]+$direction->[0], $guardpos->[1]+$direction->[1]];
    if($nextpos->[0] < 0 || $nextpos->[1] < 0 || $nextpos->[0] > $xMax || $nextpos->[1] > $yMax){
        return 0;
    }
    elsif($obstacles->{$nextpos->[0]}->{$nextpos->[1]}){
        my $oldX = $direction->[0];
        $direction->[0] = -1 * $direction->[1];
        $direction->[1] = $oldX;
    }
    else {
        if($allguardpositions->{$nextpos->[0]}->{$nextpos->[1]}->{$direction->[0]}->{$direction->[1]}){
            #we've already been here with this direction of travel, we're in a loop.
            return 1;
        }
        $allguardpositions->{$nextpos->[0]}->{$nextpos->[1]}->{$direction->[0]}->{$direction->[1]}++;
        $guardpos = $nextpos;
    }
    #Next move
    MoveGuard($obstacles, $guardpos, $direction, $allguardpositions, $xMax, $yMax);
}

sub PrintGrid{
    my ($grid, $xMax, $yMax) = @_;
    foreach my $y (0..$yMax){
        foreach my $x (0..$xMax){
            if ($grid->{$x}->{$y}){
                print "X";
            }
            else{
                print ".";
            }
        }
        print "\n";
    }
}