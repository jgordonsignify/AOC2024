#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
my $input_file = $ARGV[0];
open( my $input_fh, "<", $input_file ) || die "Can't open $input_file: $!";

#The only things we care about are:
#Current disk array
my @diskarray;

my $current_index = 0;
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
        my $diskslice = {
            ID => $new_elem,
            START_INDEX => $current_index,
            END_INDEX => $current_index + $char - 1,
            LENGTH => $char,
        };
        $current_index = $current_index + $char;
        push(@diskarray, $diskslice);
    }
}

print Dumper(\@diskarray);
my $iter = 0;
# Start from the back and work forward.
while($iter < scalar(@diskarray)){
    my $array_index = scalar(@diskarray) - $iter - 1;
    
    if(!defined $diskarray[$array_index]->{ID} || $diskarray[$array_index]->{ID} eq '.'){ #if we hit freespace, iterate
        $iter++;
    } else {# If we have an id not free space
        #Find the earliest freespace block equal or longer than the file
        my ($firstfreesector) = sort { $a->{START_INDEX} <=> $b->{START_INDEX} } grep { $_->{ID} eq '.' && $_->{LENGTH} >= $diskarray[$array_index]->{LENGTH} } @diskarray;
        #print "Disk:".Dumper($diskarray[$array_index]);
        #print "Free:".Dumper($firstfreesector);
        if(!defined $firstfreesector->{START_INDEX} || $firstfreesector->{START_INDEX} > $diskarray[$array_index]->{START_INDEX}){
            $iter++;
            next;
        }
        #if the freespace length is longer, we split into two sectors and insert the new empty sector after 
        if($firstfreesector->{LENGTH} > $diskarray[$array_index]->{LENGTH}){
            my $newfreesector = { 
                LENGTH => $firstfreesector->{LENGTH} - $diskarray[$array_index]->{LENGTH},
                ID => '.',
                START_INDEX => $firstfreesector->{START_INDEX} + $diskarray[$array_index]->{LENGTH},
                END_INDEX => $firstfreesector->{END_INDEX},
            };
            #Swap the $firstfreesector for the real file, then insert the new sector after the $firstfreesector
            $firstfreesector->{ID} = $diskarray[$array_index]->{ID};
            $firstfreesector->{LENGTH} = $diskarray[$array_index]->{LENGTH};
            $firstfreesector->{END_INDEX} = $firstfreesector->{START_INDEX} + $diskarray[$array_index]->{LENGTH} -1;
            $diskarray[$array_index]->{ID} = '.';
            #Insert new sector and reorder
            @diskarray = sort { $a->{START_INDEX} <=> $b->{START_INDEX} } (@diskarray, $newfreesector);
            $iter--;
        } else {
            $firstfreesector->{ID} = $diskarray[$array_index]->{ID};
            $firstfreesector->{LENGTH} = $diskarray[$array_index]->{LENGTH};
            $firstfreesector->{END_INDEX} = $firstfreesector->{START_INDEX} + $diskarray[$array_index]->{LENGTH} -1;
            $diskarray[$array_index]->{ID} = '.';
        }
    }
    #PrintGrid(@diskarray);
}
#print Dumper(@diskarray);
print "Sum:".SumGrid(@diskarray)."\n";

sub PrintGrid{
    my @arr = @_;
    foreach my $slice (@arr){
        print $slice->{ID} x $slice->{LENGTH};
    }
    print "\n";
}

sub SumGrid{
    my $sum = 0;
    my @arr = @_;
    foreach my $slice (@arr){
        my $id = $slice->{ID} eq '.' ? 0 : $slice->{ID};
        # the value of the slice is the id times the start index times the length, plus the ID times the triangular number of the length - 1
        $sum += (($id * $slice->{START_INDEX} * $slice->{LENGTH}) + ($id * ($slice->{LENGTH} * ($slice->{LENGTH}-1))/2));
    }
    return $sum;
}