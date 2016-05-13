#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok('Math::BigSym') || print "Bail out!\n";
}

diag("Testing Math::BigSym $Math::BigSym::VERSION, Perl $], $^X");
