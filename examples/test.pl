use 5.010;

use lib qw(../lib);
use Math::BigSym qw(:constant pi i tau e phi ln2);

say phi;
say ln2;

say sqrt(24);

say log(pi * 4);
say cos(pi- 12) * exp(-12 * i) + exp(-24 * i) * 1 / 2;
say log(42);
say log(exp(42));

say log(-1) / i;
say cos(pi);
say log(e**2);

say sqrt(pi);
say pi**(1 / 2);

say Math::BigSym->new('pi');

my $x    = 42;
my $copy = $x;
say $x + 1;

++$x;
say $x;
say $copy;

--$x;
say $copy;
say $x;

++$x;
say $copy;
say $x;

say 32.52**12.52;

say 125->root(3);

my $x = Math::BigSym->new("1231298412747129719275172129321738");
my $y = Math::BigSym->new(1.23456);

my $z = Math::BigSym->new(25);

say $x;
say $y;

say sqrt($x * $y) + $y;
say sqrt($y) / $y;

say Math::BigSym->new(0)**Math::BigSym->new(-4);

say $z**$z;
say $y**$y;

say $z / 0;

#say $z ** 0.5;
say sqrt($z);

say sqrt($y)**$y;

say sqrt($z);

{
    use Math::BigSym qw(:constant);

    # Rational operations
    my $x = 2 / 3;
    say $x * 3;           # => 2
    say 2 / $x;           # => 3
    say $x;               # => "2/3"
    say 1 + 4.5**(-3);    # => "737/729"

    # Floating-point operations
    say "equal" if (1.1 + 2.2 == 3.3);    # => "equal"

    # Symbolic
    say log(42) / 2;                      # => "1/2*log(42)"
    say sqrt(exp(-1));                    # => "sqrt(exp(-1))"
}

say 1 / 0;
say -42 / 0;
say((-42)**2.3);

say +(42 * i)->cross(-2342);

say ~(sqrt(-3) * i);

say +(3 + 4 * i)->unit;

say +(412 / 94123)**4000 / (412 / 94123)**3999;
say +(127 / 3)**5000;
