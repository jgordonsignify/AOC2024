#!/usr/bin/perl
use strict;
use warnings;

# Check for command line argument
die "Usage: $0 <input_file>\n" unless @ARGV == 1;
my $input_file = $ARGV[0];

my %cache;

sub check_pattern {
    my ($pattern, $piecelist) = @_;
    if (defined $cache{$pattern}){
        return $cache{$pattern};
    }
    my $possiblecombos = 0;
    foreach my $piece (@{$piecelist}){
        # Debug: Print current piece being checked
        print "Checking piece: $piece against pattern: $pattern\n";
        # Check if piece matches start of pattern
        if (substr($pattern, 0, length($piece)) eq $piece) {
            # Get remaining pattern after matching piece
            my $remaining = substr($pattern, length($piece));
            
            # If no pattern remains, we found a match
            if($remaining eq ''){
                $possiblecombos += 1;
            }
            else {            
                # Recursively check remaining pattern with rest of pieces
                $possiblecombos += check_pattern($remaining, $piecelist);
            }
        }
    }
    $cache{$pattern} = $possiblecombos;
    return $possiblecombos;
}

# Read and parse input file
open(my $input_fh, "<", $input_file) || die "Can't open $input_file: $!";

my @towels;
my @desired_patterns;
my $reading_patterns = 0;

while (my $line = <$input_fh>) {
    chomp $line;
    
    # Switch to reading patterns after blank line
    if ($line eq '') {
        $reading_patterns = 1;
        next;
    }
    
    if ($reading_patterns) {
        push @desired_patterns, $line;
    }
    else {
        # Split CSV line into array and add to possible towels
        @towels = (split /, /, $line);
    }
}

close $input_fh;

# Print parsed data for verification
print "Possible Towels:\n";
print join("\n", @towels)."\n";

print "\nDesired Patterns:\n";
for my $pattern (@desired_patterns) {
    print "$pattern\n";
}

my $count = 0;
foreach my $pattern (@desired_patterns){
    print "Starting: $pattern\n";
    my $pat_count = check_pattern($pattern, \@towels);
    $count += $pat_count;
    print "Pattern: $pattern has $pat_count possibilities, running total: $count\n";
}

print "Possible: $count\n";