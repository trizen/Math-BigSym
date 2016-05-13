#!/usr/bin/perl

# Test blog function (and bpow, since it uses blog), as well as bexp().

use strict;
use warnings;

use Test::More tests => 11;

use Math::BigSym;

my $cl = "Math::BigSym";

#############################################################################
# test log($n)

is($cl->new("2/3")->log, "log(2/3)");
is($cl->new(0)->log,     "log(0)");
is($cl->new(-42)->log,   "log(-42)");
is($cl->new(2000)->log,  "log(2000)");

#############################################################################
# test exp($n)

is($cl->new(100)->exp,   "exp(100)");
is($cl->new(-2)->exp,    "exp(-2)");
is($cl->new("2/3")->exp, "exp(2/3)");

#############################################################################
# test bexp()

#is($cl->new(2)->exp, $cl->new(1)->exp->pow(2));
#is($cl->new("12.5")->exp(1), $cl->new(1)->exp(1)->pow(12.5));        # doesn't work, yet.
is($cl->new("12.5")->exp, "exp(25/2)");

#############################################################################
# some integer results
is($cl->new(2)->pow(32)->log(2), "1/(log(2))*log(4294967296)");
is($cl->new(3)->pow(32)->log(3), "1/(log(3))*log(1853020188851841)");
is($cl->new(2)->pow(65)->log(2), "1/(log(2))*log(36893488147419103232)");

#~ my $x    = $cl->new('777')**256;
#~ my $base = $cl->new('12345678901234');
#~ is($x->log($base), 56, 'blog(777**256, 12345678901234)');

#~ $x    = $cl->new('777')**777;
#~ $base = $cl->new('777');
#~ is($x->log($base), 777, 'blog(777**777, 777)');

# all done
1;
