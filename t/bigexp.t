#!perl

use strict;
use warnings;

use Test::More tests => 2;

use Math::BigSym qw(:constant);

my $ln_ev = -7 / (10**17);
my $ev = exp($ln_ev);

is("$ev", "exp(-7/100000000000000000)");
cmp_ok($ev, '!=', 0, '$ev should not equal 0');
