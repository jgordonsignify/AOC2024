#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my ($rules_file, $orders_file) = @ARGV;
open( my $input_fh, "<", $rules_file ) || die "Can't open $rules_file: $!";

my %beforemap; # list of values that have to be before "key"
my %aftermap; # list of values that have to be after "key"
while (my $line = <$input_fh>){
    chomp $line;
    my ($rulebefore, $ruleafter) = split('\|',$line);
    #print "$rulebefore, $ruleafter\n";
    if(!defined $beforemap{$ruleafter}){
        $beforemap{$ruleafter} = [];
    }
    if(!defined $aftermap{$rulebefore}){
        $aftermap{$rulebefore} = [];
    }
    push(@{$beforemap{$ruleafter}}, $rulebefore);
    push(@{$aftermap{$rulebefore}}, $ruleafter);
}
#print Dumper(\%beforemap);

open( my $orders_fh, "<", $orders_file ) || die "Can't open $orders_file: $!";
my $sum = 0;
while (my $line = <$orders_fh>){
    chomp $line;
    my @orderpages = split(',', $line);
    print "Order: ".join(",",@orderpages)."\n";
    my $correct = 1;
    for (my $i = 0; $i<scalar(@orderpages);$i++){
        my @pages_that_need_to_be_before_current = @{$beforemap{$orderpages[$i]} || []};
        #my @pages_that_need_to_be_after_current = @{$aftermap{$orderpages[$i]} || []};
        my @pages_before = @orderpages[0.. ($i-1)];
        my @pages_after = @orderpages[$i+1 .. (scalar(@orderpages)-1)];
        #my @wrong_before = Intersect(\@pages_that_need_to_be_after_current,\@pages_before);
        my @wrong_after = Intersect(\@pages_that_need_to_be_before_current, \@pages_after);
        print "Current Page: $orderpages[$i]\n";
        #print "before:". join(",",@pages_before)."\n";
        print "after:".join(",",@pages_after)."\n";
        print "Need to be before:". join(",",@pages_that_need_to_be_before_current)."\n";
        #print "Need to be after:".join(",",@pages_that_need_to_be_after_current)."\n";
        
        if(scalar(@wrong_after)){#} || scalar(@wrong_before)){
            $correct = 0;
            #fix the ones we are aware of and start over.  There is almost certainly some optimization that we could do here instead.
            @orderpages = (@pages_before, @wrong_after, $orderpages[$i], SubtractArray(\@pages_after, \@wrong_after));
            print "Reordering to: ".join(",", @orderpages)."\n";
            $i=-1;
        }
    }
    if(!$correct){
        
        print "Order Fixed!\n"; 
        my $middle = (scalar(@orderpages)) / 2;
        print "Middle: $orderpages[$middle]\n";
        $sum += $orderpages[$middle];
    }
}

print "Sum: $sum\n";
sub Intersect {
    my ($left, $right) = @_;
    my %left = map {$_ => 1} @{$left};
    my @retval;
    foreach my $elem (@{$right}){
        if(defined $left{$elem}){
            push(@retval, $elem);
        }
    }
    return @retval;
}
sub SubtractArray {
    my ($left, $right) = @_;
    my %right = map {$_ => 1} @{$right};
    my @retval;
    foreach my $elem (@{$left}){
        if(!defined $right{$elem}){
            push(@retval, $elem);
        }
    }
    return @retval;
}