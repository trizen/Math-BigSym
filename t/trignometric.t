#!perl -T

use 5.006;
use strict;
use warnings;

use Test::More tests => 9;

use Math::BigSym qw(:constant);

my $pi = log(-1) / sqrt(-1);

my $d = 45;
my $r = $pi / 4;

sub rad2deg {
    180 / $pi * $_[0];
}

sub deg2rad {
    $pi / 180 * $_[0];
}

is(ref(sin(13)), 'Math::BigSym');
is(ref(cos(13)), 'Math::BigSym');

#like(sin($r), qr/^0\.7071067811865/);
#like(cos($r), qr/^0\.7071067811865/);

#like(sin(deg2rad($d)), qr/^0\.7071067811865/);
#like(cos(deg2rad($d)), qr/^0\.7071067811865/);

#is($r->tan, "1");
#is($r->cot, "1");

is(sin(12), "1/2*&i*exp(-12*&i)-1/2*&i*exp(12*&i)");

is(sin($r), "1/2*&i*exp(-1/4*log(-1))-1/2*&i*exp(1/4*log(-1))");
is(cos($r), "1/2*exp(-1/4*log(-1))+1/2*exp(1/4*log(-1))");

is(sin(deg2rad($d)), "1/2*&i*exp(-1/4*log(-1))-1/2*&i*exp(1/4*log(-1))");
is(cos(deg2rad($d)), "1/2*exp(-1/4*log(-1))+1/2*exp(1/4*log(-1))");

is($r->tan,
"1/2*&i/(1/2*exp(-1/4*log(-1))+1/2*exp(1/4*log(-1)))*exp(-1/4*log(-1))-1/2*&i/(1/2*exp(-1/4*log(-1))+1/2*exp(1/4*log(-1)))*exp(1/4*log(-1))"
  );
is($r->cot,
"1/2/(1/2*&i*exp(-1/4*log(-1))-1/2*&i*exp(1/4*log(-1)))*exp(-1/4*log(-1))+1/2/(1/2*&i*exp(-1/4*log(-1))-1/2*&i*exp(1/4*log(-1)))*exp(1/4*log(-1))"
  );
