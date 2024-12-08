#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

my $sum = 0;
while (my $line = <$input_fh>){
    chomp $line;
    my ($target, @operands) = $line =~ /(\d+)/g;
    print "TARGET: $target\n";
    print "Oper: ".join(",", @operands)."\n";
    # Super hack, since this is perl, we can just generate every possible equation
    # as a string and "eval" it.  Each combination of operators can be viewed as a
    # binary number since there are two options
    my $maxnumber = 3**(scalar(@operands)-1);
    print scalar(@operands). " Operands\n";
    print "Max: $maxnumber\n";
    for(my $i=0;$i<$maxnumber;$i++){
        my $total = $operands[0];
        for (my $j=1;$j<scalar(@operands);$j++){
            my $op = int($i / (3**($j-1))) % 3;
            #print join(",", $total, $op, $operands[$j])."\n";
            my $current_operator;
            if($op == 0 ){ # * 
                $total = $total * $operands[$j];
            }
            elsif($op == 1){ # + 
                $total = $total + $operands[$j];
            }
            else { # ||
                $total = "$total"."$operands[$j]";
            }
            #print "$total\n";
        }
        if($total == $target){
            $sum += $target;
            last;
        }
    }
}
print "Sum: $sum\n";
