#!/usr/bin/perl

#
## http://rosettacode.org/wiki/Arithmetic-geometric_mean/Calculate_Pi#Perl
#

use 5.014;
use strict;
use warnings;

use lib qw(../lib);
use Math::BigSym qw(:constant);

my $digits = shift || 5;    # Get number of digits from command line
print agm_pi($digits), "\n";

sub agm_pi {
    my $digits = shift;

    my $acc = $digits + 8;

    my ($an, $bn, $tn, $pn) = (1, sqrt(0.5), 0.5**2, 1);
    while ($pn < $acc) {
        my $prev_an = $an;
        $an += $bn;
        $an *= 0.5;
        $bn = sqrt($bn * $prev_an);
        $prev_an -= $an;
        $tn -= $pn * $prev_an * $prev_an;
        $pn += $pn;
    }
    $an += $bn;
    $an**= 2;
    $an /= 4 * $tn;
    return $an;
}
