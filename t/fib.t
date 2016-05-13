#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 4;

use Math::BigSym qw(:constant tau);

my $S = sqrt(5);
my $T = ($S + 1) / 2;
my $U = 1 - $T;

sub fib1 {
    my ($n) = @_;
    (($T**$n - ($U**$n * cos(tau * $n))) / $S);
}

sub fib2 {
    my ($n) = @_;
    (($T**$n - (-$U)**$n) / $S);
}

my (@s1, @s2);

my $start = 10;
my $end   = 20;

for (my $i = $start ; $i < $end ; $i += 1) {

    my $f1 = fib1($i);
    my $f2 = fib2($i);

    push @s1, $f1;
    push @s2, $f2;
}

is(scalar(@s1), $end - $start);
is(scalar(@s2), $end - $start);

my @f1 = qw(
  -1/(sqrt(5))*exp(10*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(10*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(11*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(11*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(12*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(12*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(13*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(13*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(14*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(14*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(15*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(15*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(16*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(16*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(17*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(17*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(18*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(18*log(1/2*sqrt(5)+1/2))
  -1/(sqrt(5))*exp(19*log(-1/2*sqrt(5)+1/2))+1/(sqrt(5))*exp(19*log(1/2*sqrt(5)+1/2))
  );

my @f2 = qw(
  1/(sqrt(5))*exp(10*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(10*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(11*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(11*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(12*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(12*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(13*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(13*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(14*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(14*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(15*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(15*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(16*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(16*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(17*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(17*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(18*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(18*log(1/2*sqrt(5)-1/2))
  1/(sqrt(5))*exp(19*log(1/2*sqrt(5)+1/2))-1/(sqrt(5))*exp(19*log(1/2*sqrt(5)-1/2))
  );

is(join("\n", @s1), join("\n", @f1));
is(join("\n", @s2), join("\n", @f2));
