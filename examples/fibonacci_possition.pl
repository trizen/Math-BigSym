#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::BigSym qw(:constant phi);

my ($S, $T, $W);

if (rand(1) < 0.5) {
    $S = sqrt(1.25) + 0.5;
    $T = sqrt(1.25) - 0.5;
    $W = $S + $T;
}
else {
    $S = phi;
    $T = 1 - $S;
    $W = $S * 2 - 1;
}

sub fib_pos_1 {
    my ($fib, $i) = @_;
    log($fib * $W + (-$T)**$i) / log($S);
}

sub fib_pos_2 {
    my ($fib) = @_;
    log($fib * sqrt(5)) / log($S);
}

sub fib {
    my ($n) = @_;
    (($S**$n - (-$T)**$n) / $W);
}

for (my $i = 10 ; $i <= 100 ; $i += int(rand(15)) + 5) {
    my $fib = fib($i);
    say "=> pos($fib) = $i";
    say "\t", fib_pos_1($fib, $i);
    say "\t", fib_pos_2($fib);
    say "";
}
