#!perl

# The formula for calculating the sum of consecutive
# numbers raised to a given power, such as:
#    1^p + 2^p + 3^p + ... + n^p
# where p is a positive integer.

# See also: https://en.wikipedia.org/wiki/Faulhaber%27s_formula

###############################################################################

use strict;
use warnings;

sub test_formula {
    my ($n, $f, $sum) = @_;
    is(sprintf("%.0f", eval($f)), $sum);
}

use Test::More tests => 22;
use Math::BigSym qw(:constant);

###############################################################################

# The binomial coefficient
# See: https://en.wikipedia.org/wiki/Binomial_coefficient
sub binomial {
    my ($n, $k) = @_;
    $k == 0 || $n == $k ? 1 : binomial($n - 1, $k - 1) + binomial($n - 1, $k);
}

*nok = \&binomial;

# This function returns the nth Bernoulli number
# See: https://en.wikipedia.org/wiki/Bernoulli_number
sub bernoulli_number {
    my ($n) = @_;

    return 0 if $n > 1 && "$n" % "2";    # Bn = 0 for all odd n > 1

    my @A;
    for my $m (0 .. $n) {
        $A[$m] = 1 / ($m + 1);
        for (my $j = $m ; $j > 0 ; $j--) {
            $A[$j - 1] = $j * ($A[$j - 1] - $A[$j]);
        }
    }

    return $A[0];                    # which is Bn
}

# The Faulhaber's formula
# See: https://en.wikipedia.org/wiki/Faulhaber%27s_formula
sub faulhaber_s_formula {
    my ($p, $n) = @_;

    my $sum = 0;
    for my $j (0 .. $p) {
        $sum += nok($p + 1, $j) * bernoulli_number($j) * ($n + 1)**($p + 1 - $j);
    }

    $sum / ($p + 1);
}

# Alternate expression using Bernoulli polynomials
# See: https://en.wikipedia.org/wiki/Faulhaber%27s_formula#Alternate_expressions

sub bernoulli_polynomials {
    my ($n, $x) = @_;

    my $sum = 0;
    for my $k (0 .. $n) {
        $sum += nok($n, $k) * bernoulli_number($n - $k) * $x**$k;
    }

    $sum;
}

sub faulhaber_s_formula_2 {
    my ($p, $n) = @_;
    1 + (bernoulli_polynomials($p + 1, $n + 1) - bernoulli_polynomials($p + 1, 1)) / ($p + 1);
}

# Test for 1^4 + 2^4 + 3^4 + ... + 10^4
foreach my $i (0 .. 10) {
    my $f1 = faulhaber_s_formula($i, Math::BigSym->new("n") - 1);
    my $f2 = faulhaber_s_formula_2($i, Math::BigSym->new("n") - 1);

    my $n = int(rand(5))+5;
    my $sum = 0;

    for(my $j = 1; $j <= $n; $j++) {
        $sum += $j**$i;
    }

    test_formula("$n", "$f1", "$sum");
    test_formula("$n", "$f2", "$sum");
}
