#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 11 May 2016
# Website: https://github.com/trizen

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::BigSym qw(:constant tau);

my $S = sqrt(5);
my $T = (1 + $S) / 2;
my $U = 2 / (1 + $S);

sub fib_cf {
    my ($n) = @_;
    (($T**$n - ($U**$n * cos(tau * $n))) / $S);
}

for (my $i = 10 ; $i <= 100 ; $i += 10) {
    my $f = fib_cf($i);
    print "F($i) = $f\n";
}
