#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

#The only things we care about are:
#Current disk array
my @diskarray;

my $currentline = 0;
while (my $line = <$input_fh>){
    chomp $line;
    my @chars = split //, $line;
    my $i = 0;
    for(my $i=0;$i<scalar(@chars);$i++){
        my $char = int($chars[$i]);
        my $new_elem = "";
        if($i % 2){ # odd characters are spaces
            $new_elem="."
        }
        else {
            $new_elem = int($i/2);
        }
        for(my $j=0;$j<$char;$j++){
            push(@diskarray, $new_elem);
        }
    }
}

print Dumper(\@diskarray);
my $iter = 0;
my $sum = 0;
while($iter < scalar(@diskarray)){
    #if the last character is a ., remove it.
    if($diskarray[-1] eq '.'){
        pop(@diskarray);
    }
    elsif($diskarray[$iter] eq '.'){
        $diskarray[$iter] = $diskarray[-1];
        $diskarray[-1] = '.';
        $sum += $diskarray[$iter] * $iter;
        $iter++;
    }
    else{
        $sum += $diskarray[$iter] * $iter;
        $iter++;
    }
}
print Dumper(\@diskarray);
print "Sum: $sum\n";
