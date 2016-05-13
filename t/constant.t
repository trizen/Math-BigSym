#!perl

use strict;
use warnings;

use Test::More tests => 17;

use Math::BigSym qw(:constant);

is(2**255, '578960446186580977117854925043439539266' . '34992332820282019728792003956564819968', '2 ** 255');

is(ref(0xff),  'Math::BigSym');
is(ref(0123),  'Math::BigSym');
is(ref(0b101), 'Math::BigSym');

# hexadecimal constants
is(0x123456ff, Math::BigSym->new('123456ff', '16'), 'hexadecimal constant');

# binary constants
is(0b0101010001100, Math::BigSym->new('0101010001100', '2'), 'binary constant');

# octal constants
is(01234567, Math::BigSym->new('1234567', '8'), 'octal constant');

my $x = 2 + 4.5;    # BigSym 6.5
is("$x", "13/2");

$x = 2**512 * 0.1;    # really is what you think it is
is("$x",
        "6703903964971298549787012499102923063739682910296"
      . "1966888617807218608820150367734884009371490834517"
      . "13845015929093243025426876941405973284973216824503"
      . "042048/5");

is(.5,          0.5);
is(1.23345e10,  "12334500000");
is(1.23445e-10, "24689/200000000000000");
is(100_000_000, "100000000");

is(727, 0x2d7);
is(727, 01327);
is(727, 0b1011010111);

is(1.0 / 3.0, "1/3");
