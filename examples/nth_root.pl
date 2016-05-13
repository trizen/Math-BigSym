#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 06 July 2013
# https://github.com/trizen

# Get the n^th root of a number.
# For example, nth_root(3, 125) == 5 because 5^3 == 125
#              nth_root(7,19, 2694.64663369533) =~ 3 because 3^7.19 =~ 2694.64663369533

#
## Solves x^y=z if you know 'y' and 'z'.
#
# x^3=125 --> nth_root(3, 125) --> 5
#
## A little bit more complicated than the straightforward: z^(1/y)
#

use 5.010;
use strict;
use warnings;

sub calculate {
    my ($pow, $num) = @_;
    my $sym = nth_root($pow, $num);
    state $pi = atan2(0, -'inf');
    my $value = eval("$sym");
    say "nth_root($pow, $num) = $sym = $value";
    my $real = eval "($num) ** (1/($pow))";
    if ($value ne $real) {
        warn "\tHowever, this is incorrect: $value != $real";
    }
}

use lib qw(../lib);
use Math::BigSym qw(:constant pi e);

sub nth_root {
    my ($pow, $num) = @_;

    my $i   = int($pow) - 1;
    my $res = $num;

    for (1 .. $i) {
        $res = sqrt($res);
    }

    $res**(2**$i / $pow);
}

#
## Main
#

calculate(3, 125);                    # 5
calculate(7.19, 2694.64663369533);    # 3
calculate(5, pi**5);                  # pi
calculate(4, e**4);                   # e
calculate(6, 25.5);                   # 1.71562893961418
