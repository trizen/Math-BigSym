#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 142;

# Initialization

{
    use Math::BigSym qw();
    my $x = Math::BigSym->new("1010", 2);
    is("$x", "10");

    $x = Math::BigSym->new("ff", 16);
    is("$x", "255");

    $x = Math::BigSym->new("1.23456");
    is("$x", "3858/3125");
}

# Basic operations
{
    use Math::BigSym qw(:constant);

    # Division
    my $x = 1 / 3;
    my $y = $x * 3;
    is("$y", "1");

    # stringification
    is("$x", "1/3");

    my $bigstr =
        "46663107721972076340849619428133350245357984132190810"
      . "73429648194760879999661495780447073198807825914312684"
      . "8960413611879125592605458432000000000000000000000000.5";

    my $bigrat =
        '9332621544394415268169923885626670049071596826438162146'
      . '8592963895217599993229915608941463976156518286253697920'
      . '827223758251185210916864000000000000000000000001/2';

    my $bignum = Math::BigSym->new($bigstr);
    is("$bignum", $bigrat);

    $bignum = Math::BigSym->new($bigrat);
    is("$bignum", $bigrat);

    # Negation
    ok($y->neg == -1);

    # Absolute values
    my $n     = 42;
    my $neg_n = -$n;

    is("$neg_n", "-42");
}

# Complex numbers
{
    use Math::BigSym qw(:constant i);

    my $z = 3 + 4 * i;
    is("$z", "3+4*&i");

    my $z2 = $z + 2;
    is("$z2", "5+4*&i");

    my $i = sqrt(-1);
    is("$i", '&i');

    $z = 10 + 0 * i;

    my $re = $z->re;
    is("$re", "10");

    my $im = $z->im;
    is("$im", "0");
}

# Float
{
    use Math::BigSym qw(:constant);

    my $x = 1.2;
    my $y = 3.4;
    my $z;

    # Addition
    $z = $x + $y;
    is($z, 4.6);

    # Subtraction
    $z = $y - $x;
    is($z, 2.2);

    # Multiplication
    $z = $x * $y;
    is($z, 4.08);

    # Division
    $y += 0.2;
    $z = $y / $x;
    is($z, 3);

    # Square root
    $z = sqrt(25);
    is("$z", "5");

    # Cube root
    $z = 125**(1 / 3);
    my $re = join(
        '|',
        map { quotemeta($_) }
          qw(
          5
          5**(1/3)
          exp(1/3*log(125))
          )
    );
    like("$z", qr{^(?:$re)\z});

    # Sqr
    $z = 3**2;
    is("$z", "9");

    # Root
    $z = 125->root(3);
    like("$z", qr{^(?:$re)\z});
}

# Power
{
    use Math::BigSym qw();

    my $x = Math::BigSym->new(3);
    my $y = Math::BigSym->new(4);

    # Obj**Obj
    my $z = $x**$y;
    is("$z", 3**4);

    # Obj**Scalar
    my $z2 = $x**2;
    is("$z2", 3**2);

    # Scalar**Obj
    my $z3 = 2**$x;
    is("$z3", 2**3);
}

# Mixed arithmetic
{
    use Math::BigSym;

    my $x = Math::BigSym->new(12);
    my $y = $x->div(4);
    is("$y", "3");
    is("$x", "12");

    $x /= 3;
    is("$x", "4");

    $x /= Math::BigSym->new(2);
    is("$x", "2");

    $x *= 5;
    is("$x", "10");

    $x *= Math::BigSym->new(0.5);
    is("$x", "5");

    $x -= 1;
    is("$x", "4");

    $x += 38;
    is("$x", "42");

    $x -= Math::BigSym->new(10);
    is("$x", "32");

    $x += Math::BigSym->new(3);
    is("$x", "35");

    my $copy = Math::BigSym->new("$x");
    $x /= Math::BigSym->new('5');
    is("$x",    7);
    is("$copy", 35);

    $x = Math::BigSym->new(16);
    $y = 2 * $x;
    is("$y", "32");

    $y = 2 + $x;
    is("$y", "18");

    $y = 2 - $x;
    is("$y", "-14");

    $y = 2 / $x;
    is("$y", "1/8");

    $y = 2**$x;
    is("$y", "65536");
}

# Comparisons
{
    use Math::BigSym qw(:constant);
    ok(3.2 < 4);
    ok(1.5 <= 1.5);
    ok(2.3 <= 3);
    ok(3 > 1.2);
    ok(3 >= 3);
    ok(9 >= 2.1);
    ok(9 == 9);
    ok(!(3 == 4));
    ok(8 != 3);
    ok(!(4 != 4));

    is(4 <=> 4,     "0");
    is(4.2 <=> 4.2, "0");
    is(3.4 <=> 6.4, "-1");
    is(9.4 <=> 2.3, "1");
}

# Mixed comparisons
{
    use Math::BigSym qw(:constant);

    is(4 <=> 4, 0);
    is(3 <=> 4, -1);
    is(4 <=> 3, 1);

    is(2 <=> 3, -1);
    is(4 <=> 2, 1);
    is(3 <=> 3, 0);

    is(3.4 <=> 3.4, 0);
    is(8.3 <=> 2.3, 1);
    is(1.4 <=> 3,   -1);

    is(3.4 <=> 3.4, 0);
    is(2.3 <=> 8.3, -1);
    is(3.1 <=> 1.4, 1);

    ok(3 > 1);
    ok(3.4 > 2.3);
    ok(!(4 > 5));
    ok(!(4.3 > 5.7));

    ok(3 > 1);
    ok(3.4 > 2.3);
    ok(!(4 > 5));
    ok(!(4.3 > 5.7));

    ok(9 >= 9);
    ok(4.5 >= 3.4);
    ok(5.6 >= 5.6);
    ok(!(4.3 >= 10.3));
    ok(!(3 >= 21));

    ok(9 >= 9);
    ok(4.5 >= 3.4);
    ok(5.6 >= 5.6);
    ok(!(4.3 >= 10.3));
    ok(!(3 >= 21));

    ok(1 < 3);
    ok(2.3 < 3.4);
    ok(!(5 < 4));
    ok(!(5.7 < 4.3));

    ok(1 < 3);
    ok(2.3 < 3.4);
    ok(!(5 < 4));
    ok(!(5.7 < 4.3));

    ok(9 <= 9);
    ok(3.4 <= 4.5);
    ok(5.6 <= 5.6);
    ok(!(10.3 <= 4.3));
    ok(!(21 <= 3));

    ok(9 <= 9);
    ok(3.4 <= 4.5);
    ok(5.6 <= 5.6);
    ok(!(12.3 <= 4.3));
    ok(!(21 <= 3));
}

# new() + SCALAR
{
    use Math::BigSym;

    my $x = Math::BigSym->new(42);
    my $y = Math::BigSym->new(1227);

    my $int =
        '53885464952588636769288796952610833906623325457053423'
      . '69492596680077919898979278105197183545838519370517708'
      . '740399910496813982887129';

    my $i = $y**42;
    is("$i", $int);

    $i = $y**$x;
    is("$i", $int);

    $y = -$y;

    my $r = $x * $y;
    is("$r", "-51534");

    $r = $x * 4.7;
    is("$r", "987/5");

    $x *= 9;
    is("$x", "378");

    $x *= $r;
    is("$x", "373086/5");
    is("$r", "987/5");

    $r = $r * -3;
    is("$r", "-2961/5");

    $r *= -5;
    is("$r", "2961");

    $r = $x - 1234;
    is("$r", "366916/5");

    $r = $x - -42;
    is("$r", "373296/5");

    $r -= Math::BigSym->new(12345);
    is("$r", "311571/5");

    $r -= -5;
    is("$r", "311596/5");

    $r -= 51207;
    is("$r", "55561/5");

    $r = $x + 42;
    is("$r", "373296/5");

    $r = $x + -10;
    is("$r", "373036/5");

    $r = $x + Math::BigSym->new(10);
    is("$r", "373136/5");

    $x += -60000;
    is("$x", "73086/5");

    $x += 10;
    is("$x", "73136/5");

    $x += Math::BigSym->new(-3002);
    is("$x", "58126/5");
}

# :constant + SCALAR
{
    use Math::BigSym qw(:constant);

    my $y = 2;
    $y += 3;
    is("$y", "5");

    $y -= "3";
    is("$y", "2");

    $y = -$y;
    is("$y", "-2");

    $y = abs($y);
    is("$y", "2");
}

# op= operations
{
    use Math::BigSym;

    my $x = Math::BigSym->new(10);
    my $y = Math::BigSym->new(42);

    $y += $x;
    is("$y", "52");

    $y -= $x;
    is("$y", "42");

    $y *= 2;
    is("$y", "84");

    $y -= 42;
    is("$y", "42");

    $y /= $x;
    is("$y", "21/5");

    $y += -0.2;
    is("$y", "4");

    $x**= 3;
    is("$x", "1000");

    $x /= 4;
    is("$x", "250");

    $x**= $y;
    is("$x", "3906250000");

    $y *= $x;
    is("$y", "15625000000");

    ++$y;
    is("$y", "15625000001");

    --$x;
    is("$x", "3906249999");

    $x++;
    is("$x", "3906250000");

    $y--;
    is("$y", "15625000000");
}
