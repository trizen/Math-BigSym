#!perl

use strict;
use warnings;

use Test::More tests => 51;
use Math::BigSym;

foreach my $pair (
                  qw(
                  123:123:123
                  123.4:123.4:617/5
                  1.4:1.4:7/5
                  0.1:0.1:1/10
                  -0.1:-0.1:-1/10
                  -1.1:-1.1:-11/10
                  -123.4:-123.4:-617/5
                  -123:-123:-123
                  123e2:123e2:12300
                  123e-1:12.3:123/10
                  123e-4:0.0123:123/10000
                  123e-3:0.123:123/1000
                  123.345e-1:12.3345:24669/2000
                  123.456e+2:12345.6:61728/5
                  1234.567e+3:1234567:1234567
                  1234.567e+4:1234567E1:12345670
                  1234.567e+6:1234567E3:1234567000
                  )
  ) {
    my ($x, $y, $z) = split(/:/, $pair);

    my $n = Math::BigSym->new($x);
    my $m = Math::BigSym->new($y);

    is($n,   $m, qq/new("$x") = $y/);
    is("$n", $z, qq/"$x" = $z/);
    is("$m", $z, qq/"$y" = $z/);
}
