#!perl

use strict;
use warnings;

use Test::More tests => 24;

use Math::BigSym;

# 2 ** 240 =
# 1766847064778384329583297500742918515827483896875618958121606201292619776

test_broot('2', '240', 8,  "exp(1/8*log(1766847064778384329583297500742918515827483896875618958121606201292619776))");
test_broot('2', '240', 9,  "exp(1/9*log(1766847064778384329583297500742918515827483896875618958121606201292619776))");
test_broot('2', '120', 9,  "exp(1/9*log(1329227995784915872903807060280344576))");
test_broot('2', '120', 17, "exp(1/17*log(1329227995784915872903807060280344576))");

test_broot('2', '120', 8,  "exp(1/8*log(1329227995784915872903807060280344576))");
test_broot('2', '60',  8,  "exp(1/8*log(1152921504606846976))");
test_broot('2', '60',  9,  "exp(1/9*log(1152921504606846976))");
test_broot('2', '60',  17, "exp(1/17*log(1152921504606846976))");

sub test_broot {
    my ($x, $n, $y, $expected) = @_;

    # Test "pow(BigSym, Scalar)" and "root(BigSym, Scalar)"
    my $froot = Math::BigSym->new($x)->pow($n)->root($y);

    is($froot, $expected, "Try: Math::BigSym->new($x)->bpow($n)->broot($y) == $expected");

    # Test "pow(BigSym, Scalar)" and "root(BigSym, Scalar)"
    is(Math::BigSym->new($x)->pow($n)->root($y), $expected, "Try: Math::BigSym->new($x)->pow($n)->root($y) == $expected");

    # Test "pow(BigSym, BigSym)" and "root(BigSym, BigSym)"
    is(Math::BigSym->new($x)->pow(Math::BigSym->new($n))->root(Math::BigSym->new($y)), $expected);
}
