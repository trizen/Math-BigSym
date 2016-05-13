#!perl

use strict;
use warnings;

use Test::More tests => 4;

use Math::BigSym qw(e pi);    # import 'e' and 'pi'

my $euler = Math::BigSym->e;
my $PI    = Math::BigSym->pi;

is(e,  $euler);
is(pi, $PI);

my $e = exp(1);
my $pi = atan2(0, -'inf');

ok(eval("$euler") =~ /^2\.71828182/);
ok(eval("$PI") =~ /^3\.14159265/);
