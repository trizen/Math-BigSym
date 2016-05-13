#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 92;

use Math::BigSym;

my $int1 = Math::BigSym->new(3);
my $int2 = Math::BigSym->new(-4);

#################################################################
# integer

my $r = $int1**$int1;
is("$r", "27");

$r = $int1->pow($int1);
is("$r", "27");

$r = $int1**4;
is("$r", "81");

$r = $int1->pow(4);
is("$r", "81");

$r = 4**$int1;
is("$r", "64");

$r = $int2**$int1;
is("$r", "-64");

$r = $int2**2;
is("$r", "16");

$r = $int1**$int2;
ok($r == 1 / ($int1**abs($int2)));

$r = $int1->pow($int2);
is("$r", "1/81");

$r = $int2->pow($int1);
is("$r", "-64");

$r = $int2->pow(2);
is("$r", "16");

$r = (-$int1)**($int2);
ok($r == 1 / ($int1**abs($int2)));

$r = (-$int1)**($int2 - 1);
ok($r == -(1 / ($int1**abs($int2 - 1))));

$r = $int2**(-$int1);
is("$r", "-1/64");

$r = $int2**(-$int1 + 1);
is("$r", "1/16");

#################################################################
# float + int

my $float1 = Math::BigSym->new(3.45);
my $float2 = Math::BigSym->new(-5.67);

$r = $float1**$int1;
is("$r", "328509/8000");

$r = $float1**$int2;
is("$r", "160000/22667121");

$r = $float1**$float2;
is("$r", "exp(-567/100*log(69/20))");

$r = $float2**$int1;
is("$r", "-182284263/1000000");

$r = $float2**$int2;
is("$r", "100000000/103355177121");

$r = $float2**abs($int2);
is("$r", "103355177121/100000000");

$r = $float1**4;
is("$r", "22667121/160000");

$r = $float2**2;
is("$r", "321489/10000");

$r = $float2**3;
is("$r", "-182284263/1000000");

$r = $float1**2.34;
is("$r", "exp(117/50*log(69/20))");

$r = $float2**2.25;
is("$r", "exp(9/4*log(-567/100))");

$r = 3**$float1;
is("$r", "exp(69/20*log(3))");

$r = 1.23**$float2;
is("$r", "exp(-567/100*log(123/100))");

$r = Math::BigSym->new(0)**$int1;
is("$r", "0");

$r = $float1**0;
is("$r", "1");

$r = $float2**Math::BigSym->new(0);
is("$r", "1");

$r = $int2**0;
is("$r", "1");

$r = $int1**Math::BigSym->new(0);
is("$r", "1");

##############################################################
# extreme powers

{
    use Math::BigSym qw(:constant);

    is((412 / 94123)**4000 / (412 / 94123)**3999, 412 / 94123);
    is((-42)**2.3,      exp(23 / 10 * log(-42)));
    is((127 / 3)**5000, exp(5000 * log(127 / 3)));
    is(0->pow(-4),      -log(0));
    is((-4)**0,         1);
    is((-4.5)**0,       1);
    is(4.5**0,          1);
    is(4.5**1,          4.5);
    is(0**4.5,          0);
    is(0**0,            1);
    is(0**127,          0);
}

##############################################################
# real test

{
    use Math::BigSym qw(:constant);

    sub round_nth {
        my ($orig, $nth) = @_;

        my $n = abs($orig);
        my $p = 10**$nth;

        $n *= $p;
        $n += 0.5;

        if ($n == int($n) and "$n" % "2" != 0) {
            $n -= 0.5;
        }

        $n = int($n);
        $n /= $p;
        $n = -$n if ($orig < 0);

        return $n;
    }

    my @tests = (

        # original | rounded | places
        [+1.6,      +2,        0],
        [+1.5,      +2,        0],
        [+1.4,      +1,        0],
        [+0.6,      +1,        0],
        [+0.5,      0,         0],
        [+0.4,      0,         0],
        [-0.4,      0,         0],
        [-0.5,      0,         0],
        [-0.6,      -1,        0],
        [-1.4,      -1,        0],
        [-1.5,      -2,        0],
        [-1.6,      -2,        0],
        [3.016,     3.02,      2],
        [3.013,     3.01,      2],
        [3.015,     3.02,      2],
        [3.045,     3.04,      2],
        [3.04501,   3.05,      2],
        [-1234.555, -1000,     -3],
        [-1234.555, -1200,     -2],
        [-1234.555, -1230,     -1],
        [-1234.555, -1235,     0],
        [-1234.555, -1234.6,   1],
        [-1234.555, -1234.56,  2],
        [-1234.555, -1234.555, 3],
    );

    foreach my $pair (@tests) {
        my ($n, $expected, $places) = @$pair;
        my $rounded = round_nth($n, $places);

        is(ref($rounded), 'Math::BigSym');
        ok($rounded == $expected);
    }
}
