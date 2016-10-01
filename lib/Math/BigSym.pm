package Math::BigSym;

use 5.014;
use strict;
use warnings;

use Math::GMPq qw();
use Math::GMPz qw();
use Scalar::Util qw();

use Math::Algebra::Symbols (symbols => '_sym');

our $VERSION = '0.01';

=encoding utf8

=head1 NAME

Math::BigSym - Fast symbolic calculations with arbitrary large rationals.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use 5.014;
    use Math::BigSym qw(:constant);

    # Rational operations
    my $x = 2/3;
    say $x * 3;                    # => 2
    say 2 / $x;                    # => 3
    say $x;                        # => "2/3"
    say 1 + 4.5**(-3);             # => "737/729"

    # Floating-point operations
    say "equal" if (1.1 + 2.2 == 3.3);  # => "equal"

    # Symbolic operations
    say log(-5) / 2;               # => "1/2*log(-5)"
    say sqrt(exp(-1));             # => "sqrt(exp(-1))"

=head1 DESCRIPTION

Math::BigSym provides a transparent interface to L<Math::GMPq> and L<Math::Algebra::Symbols>,
focusing on performance and easy-to-use.

=head1 HOW IT WORKS

Math::BigSym tries really hard to do the right thing and as efficiently as possible.
For example, if you say C<$x**$y>, it first checks to see if C<$x> and C<$y> are integers,
so it can optimize the operation to integer exponentiation, by calling the corresponding
I<mpz> function. Otherwise, it will check to see if C<$y> is an integer and will do rational
exponentiation, by multiplying C<$x> by itself C<$y> times. If both conditions fail, it will
do symbolic exponentiation, using the relation: C<a^b = exp(log(a) * b)>.

All numbers in Math::BigSym are stored as rational L<Math::GMPq> objects. Each operation
outside the functions provided by L<Math::GMPq>, is done symbolically, calling the corresponding
L<Math::Algebra::Symbols> functions.

=head1 IMPORT/EXPORT

Math::BigSym does not export anything by default, but it recognizes the following list of words:

    :constant       # will make any number a Math::BigSym object
    i               # "i" number (sqrt(-1))
    e               # "e" constant (2.7182...)
    pi              # "pi" constant (3.1415...)
    tau             # "tau" constant (2*pi)
    phi             # Golden ratio constant (1.618...)
    ln2             # Natural logarithm of two (log(2))

The syntax for importing something, is:

    use Math::BigSym qw(:constant pi);
    say cos(2*pi);

B<NOTE:> C<:constant> is lexical to the current scope only.

=head1 SUBROUTINES/METHODS

=cut

use overload
  '""' => \&stringify,
  '0+' => \&numify,
  bool => \&boolify,

  '+' => sub { $_[0]->add($_[1]) },
  '*' => sub { $_[0]->mul($_[1]) },

  '==' => sub { $_[0]->eq($_[1]) },
  '!=' => sub { $_[0]->ne($_[1]) },

  #'&'  => sub { $_[0]->and($_[1]) },
  #'|'  => sub { $_[0]->ior($_[1]) },
  #'^'  => sub { $_[0]->xor($_[1]) },
  '~' => \&conjugate,

  #'++' => \&binc,
  #'--' => \&bdec,

  '>'   => sub { Math::BigSym::gt($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '>='  => sub { Math::BigSym::ge($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<'   => sub { Math::BigSym::lt($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<='  => sub { Math::BigSym::le($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<=>' => sub { Math::BigSym::cmp($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  #'>>' => sub { Math::BigSym::rsft($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  #'<<' => sub { Math::BigSym::lsft($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  '**' => sub { Math::BigSym::pow($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '-'  => sub { Math::BigSym::sub($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '/'  => sub { Math::BigSym::div($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  #'%'  => sub { Math::BigSym::mod($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  #atan2 => sub { Math::BigSym::atan2($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  eq => sub { "$_[0]" eq "$_[1]" },
  ne => sub { "$_[0]" ne "$_[1]" },

  cmp => sub { $_[2] ? "$_[1]" cmp $_[0]->stringify : $_[0]->stringify cmp "$_[1]" },

  neg => \&neg,
  sin => \&sin,
  cos => \&cos,
  exp => \&exp,
  log => \&ln,

  #int  => \&int,
  abs  => \&abs,
  sqrt => \&sqrt;

{
    my %constants = (
                     e   => \&e,
                     i   => \&i,
                     phi => \&phi,
                     ln2 => \&ln2,
                     tau => \&tau,
                     pi  => \&pi,
                    );

    sub import {
        shift;

        my $caller = caller(0);

        foreach my $name (@_) {
            if ($name eq ':constant') {
                overload::constant
                  integer => sub { _new_int(shift, 10) },
                  float   => sub { _new_float(shift) },
                  binary  => sub {
                    my ($const) = @_;
                    my $prefix = substr($const, 0, 2);
                        $prefix eq '0x' ? _new_int(substr($const, 2), 16)
                      : $prefix eq '0b' ? _new_int(substr($const, 2), 2)
                      :                   _new_int(substr($const, 1), 8);
                  },
                  ;
            }
            elsif (exists $constants{$name}) {
                no strict 'refs';
                my $caller_sub = $caller . '::' . $name;
                if (!defined &$caller_sub) {
                    my $sub   = $constants{$name};
                    my $value = Math::BigSym->$sub;
                    *$caller_sub = sub() { $value }
                }
            }
            else {
                die "unknown import: <<$name>>";
            }
        }
        return;
    }
}

# Convert any mpz object to mpq
sub _mpz2mpq {
    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_z($r, $_[0]);
    $r;
}

# Return the numerator of an mpq integer object as mpz
sub _int2mpz {
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPq::Rmpq_get_num($z, $_[0]);
    $z;
}

sub _either {

    my $same = 1;
    my ($ref, @args);

    foreach my $val (@_) {
        if (ref($val) eq __PACKAGE__) {
            push @args, $$val;
        }
        else {
            push @args, _str2mpq($val);
        }

        if ($same) {
            my $arg = $args[-1];
            if (defined($ref)) {
                if (ref($arg) eq $ref) {
                    $same = ref($arg);
                }
                else {
                    $same = 0;
                }
            }
            else {
                $ref = ref($arg);
            }
        }
    }

    $same ? @args : (map { ref($_) eq 'Math::GMPq' ? _sym($_) : $_ } @args);
}

sub _symbols {
    map {
        my $val = ref($_) eq __PACKAGE__ ? $$_ : $_;
        index(ref($val), 'Math::Algebra::Symbols') == 0 ? $val : _sym($val);
    } @_;
}

sub _str2rat {
    my $str = lc($_[0] || "0");

    my $sign = substr($str, 0, 1);
    if ($sign eq '-') {
        substr($str, 0, 1, '');
        $sign = '-';
    }
    else {
        substr($str, 0, 1, '') if ($sign eq '+');
        $sign = '';
    }

    my $i;
    if (($i = index($str, 'e')) != -1) {

        my $exp = substr($str, $i + 1);
        my ($before, $after) = split(/\./, substr($str, 0, $i));

        if (!defined($after)) {    # return faster for numbers like "13e2"
            if ($exp >= 0) {
                return ("$sign$before" . ('0' x $exp));
            }
            else {
                $after = '';
            }
        }

        my $numerator   = "$before$after";
        my $denominator = "1";

        if ($exp < 1) {
            $denominator .= '0' x (CORE::abs($exp) + length($after));
        }
        else {
            my $diff = ($exp - length($after));
            if ($diff >= 0) {
                $numerator .= '0' x $diff;
            }
            else {
                my $s = "$before$after";
                substr($s, $exp + length($before), 0, '.');
                return _str2rat("$sign$s");
            }
        }

        "$sign$numerator/$denominator";
    }
    elsif (($i = index($str, '.')) != -1) {
        my ($before, $after) = (substr($str, 0, $i), substr($str, $i + 1));
        if ($after =~ tr/0// == length($after)) {
            return "$sign$before";
        }
        $sign . ("$before$after/1" =~ s/^0+//r) . ('0' x length($after));
    }
    else {
        "$sign$str";
    }
}

# Converts a string into an mpq object
sub _str2mpq {
    my $r = Math::GMPq::Rmpq_init();

    $_[0] || do {
        Math::GMPq::Rmpq_set_ui($r, 0, 1);
        return $r;
    };

    my $rat = $_[0] =~ tr/.Ee// ? _str2rat($_[0] =~ tr/_//dr) : ($_[0] =~ tr/_+//dr);
    if ($rat !~ m{^\s*[-+]?[0-9]+(?>\s*/\s*[-+]?[1-9]+[0-9]*)?\s*\z}) {
        require Carp;
        Carp::confess("Not a base-10 numerical value: <<$_[0]>>");
    }
    Math::GMPq::Rmpq_set_str($r, $rat, 10);
    Math::GMPq::Rmpq_canonicalize($r) if (index($rat, '/') != -1);

    $r;
}

#
## Constants
#

my $ZERO = _new_int(0);
my $ONE  = _new_int(1);
my $INF  = _new(-Math::Algebra::Symbols::Sum::zero()->Log);

=head2 pi

    BigSym->pi                     # => BigSym

Returns a symbolic object to represent the number B<PI>.

=cut

{
    my $pi = _new(Math::Algebra::Symbols::Sum::pi());
    ##my $pi = _new(CORE::log(Math::Algebra::Symbols::Sum::mOne()) / Math::Algebra::Symbols::Sum::i());
    sub pi { $pi }
}

=head2 tau

    BigSym->tau                    # => BigSym

Returns a symbolic object to represent the number B<TAU> (which is C<2*PI>).

=cut

{
    my $tau = _new(Math::Algebra::Symbols::Sum::pi()->multiply(Math::Algebra::Symbols::Sum::two()));
    sub tau { $tau }
}

=head2 i

    BigSym->i                      # => BigSym

Returns a symbolic object to represent the number B<i>.

=cut

{
    my $i = _new(Math::Algebra::Symbols::Sum::i());
    sub i { $i }
}

=head2 e

    BigSym->e                      # => BigSym

Returns a symbolic object to represent the B<e> mathematical constant.

=cut

{
    my $e = _new(Math::Algebra::Symbols::Sum::one()->Exp);
    sub e { $e }
}

=head2 ln2

    BigSym->ln2                    # => BigSym

Returns a symbolic object to represent the natural logarithm of two (C<log(2)>).

=cut

{
    my $ln2 = _new(Math::Algebra::Symbols::Sum::two()->Log);
    sub ln2 { $ln2 }
}

=head2 phi

    BigSym->phi                    # => BigSym

Returns a symbolic object to represent the Golden Ratio constant (C<(sqrt(5)+1)/2>).

=cut

{
    my $phi = _new(Math::Algebra::Symbols::Sum::one()->add(_sym(5)->Sqrt)->divide(Math::Algebra::Symbols::Sum::two()));
    sub phi { $phi }
}

#
## Initialization
#

sub _new {
    bless \$_[0], __PACKAGE__;
}

=head2 new

    BigSym->new(Scalar)            # => BigSym
    BigSym->new(Scalar, Scalar)    # => BigSym

Returns a new BigSym object with the value specified in the first argument,
which can be a Perl numerical value, a string representing a number in a
rational form, such as C<"1/2">, a string holding a floating-point number,
such as C<"0.5">, or a string holding an integer, such as C<"255">, or a symbol.

The second argument specifies the base of the number, which can range from 2
to 36 inclusive and defaults to 10.

This sets a symbol:

    my $x = Math::BigSym->new('x');

This sets an hexadecimal number:

    my $y = Math::BigSym->new("deadbeef", 16);

B<NOTE:> no prefix, such as C<"0x"> or C<"0b">, is allowed as part of the number.

=cut

sub new {
    my ($class, $str, $base) = @_;

    $str || return $ZERO;
    $str =~ tr/_//d;

    if (defined($base)) {
        if ($base < 2 or $base > 36) {
            require Carp;
            Carp::croak("base must be between 2 and 36, got $base");
        }
    }
    else {
        $base = 10;
    }

    my $obj;
    if ($base == 10 and Scalar::Util::looks_like_number($str)) {
        if ((~$str & $str) eq '0' and CORE::int($str) eq $str) {
            $obj = Math::GMPq::Rmpq_init();
            if ($str >= 0) {
                Math::GMPq::Rmpq_set_ui($obj, $str, 1);
            }
            else {
                Math::GMPq::Rmpq_set_si($obj, $str, 1);
            }
        }
        else {
            $obj = _str2mpq($str);
        }
    }
    elsif ($base != 10 or $str =~ m{^\s*[-+]?[0-9]+(?>\s*/\s*[1-9]+[0-9]*)?\s*\z}) {
        $obj = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set_str($obj, $str, $base);
        Math::GMPq::Rmpq_canonicalize($obj) if index($str, '/') != -1;
    }
    else {
        $obj = _sym($str);
    }

    bless \$obj, $class;
}

sub _new_int {
    my ($int, $base) = @_;

    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_str($r, "$int/1" =~ tr/_//rd, $base // 10);

    bless \$r, __PACKAGE__;
}

sub _new_float {
    my ($float) = @_;
    bless \_str2mpq($float), __PACKAGE__;
}

#
## Conversions
#

=head2 stringify

    $x->stringify                  # => Scalar

Returns a string representing the value of C<$x>.

=cut

sub stringify {
    ${$_[0]};
}

=head2 numify

    $x->numify                     # => Scalar

If C<$x> is a rational number, it returns a Perl numerical scalar with
the value of C<$x>, truncated if needed. Otherwise, it just returns the
symbolic value stored inside C<$x>.

=cut

sub numify {
    my $x = ${$_[0]};
    ref($x) eq 'Math::GMPq' ? Math::GMPq::Rmpq_get_d($x) : $x;
}

=head2 boolify

    $x->boolify                    # => Bool

Returns a true value when the number is not zero. False otherwise.

=cut

sub boolify {
    my $x = ${$_[0]};
    ref($x) eq 'Math::GMPq' ? !!Math::GMPq::Rmpq_sgn($x) : $x;
}

#
## Arithmetic operations
#

=head2 neg

    $x->neg                        # => BigSym
    -$x                            # => BigSym

Returns the negated value of C<$x>.

=cut

sub neg {
    my ($x) = _either(@_);
    _new(-$x);
}

=head2 abs

    $x->abs                        # => BigSym
    abs($x)                        # => BigSym

Absolute value of C<$x>.

=cut

sub abs {
    my ($x) = _either(@_);
    _new(CORE::abs($x));
}

=head2 add

    $x->add(BigSym)                # => BigSym
    $x->add(Scalar)                # => BigSym

    BigSym + BigSym                # => BigSym
    BigSym + Scalar                # => BigSym
    Scalar + BigSym                # => BigSym

Adds C<$y> to C<$x> and returns the result.

=cut

sub add {
    my ($x, $y) = _either(@_);
    _new($x + $y);
}

=head2 sub

    $x->sub(BigSym)                # => BigSym
    $x->sub(Scalar)                # => BigSym

    BigSym - BigSym                # => BigSym
    BigSym - Scalar                # => BigSym
    Scalar - BigSym                # => BigSym

Subtracts C<$y> from C<$x> and returns the result.

=cut

sub sub {
    my ($x, $y) = _either(@_);
    _new($x - $y);
}

=head2 mul

    $x->mul(BigSym)                # => BigSym
    $x->mul(Scalar)                # => BigSym

    BigSym * BigSym                # => BigSym
    BigSym * Scalar                # => BigSym
    Scalar * BigSym                # => BigSym

Multiplies C<$x> by C<$y> and returns the result.

=cut

sub mul {
    my ($x, $y) = _either(@_);
    _new($x * $y);
}

=head2 div

    $x->div(BigSym)                # => BigSym
    $x->div(Scalar)                # => BigSym

    BigSym / BigSym                # => BigSym
    BigSym / Scalar                # => BigSym
    Scalar / BigSym                # => BigSym

Divides C<$x> by C<$y> and returns the result.
Returns C<log(0) * +/-1> when C<$y> is zero.

=cut

sub div {
    my ($x, $y) = _either(@_);

    # Handle division by zero
    if (ref($y) eq 'Math::GMPq' and !Math::GMPq::Rmpq_sgn($y)) {
        return $INF * Math::GMPq::Rmpq_sgn($x);
    }

    _new($x / $y);
}

=head2 pow

    $x->pow(BigSym)                # => BigSym
    $x->pow(Scalar)                # => BigSym

    BigSym ** BigSym               # => BigSym
    BigSym ** Scalar               # => BigSym
    Scalar ** BigSym               # => BigSym

Raises C<$x> to power C<$y> symbolically, based on the relation:
C<a^b = exp(log(a) * b)>. When C<$x> and C<$y> are both integers,
or when C<$x> is a rational and C<$y> is an integer smaller than 2^12,
it will perform the actual calculation.

=cut

sub pow {
    my ($x, $y) = _either(@_);

    # Do integer exponentiation when both are integers
    if (ref($x) eq 'Math::GMPq' and ref($y) eq 'Math::GMPq') {

        my $ysgn = Math::GMPq::Rmpq_sgn($y);

        if (!$ysgn) {
            return $ONE;
        }
        elsif ($ysgn > 0 and !Math::GMPq::Rmpq_sgn($x)) {
            return $ZERO;
        }

        my $xint = Math::GMPq::Rmpq_integer_p($x);
        my $yint = Math::GMPq::Rmpq_integer_p($y);

        if ($xint and $yint) {
            my $pow = Math::GMPq::Rmpq_get_d($y);

            my $z = _int2mpz($x);
            Math::GMPz::Rmpz_pow_ui($z, $z, CORE::abs($pow));

            my $q = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_z($q, $z);

            if ($pow < 0) {
                if (!Math::GMPq::Rmpq_sgn($q)) {
                    return $INF;
                }
                Math::GMPq::Rmpq_inv($q, $q);
            }

            return _new($q);
        }

        # When $y is an integer, multiply $x by itself $y times
        elsif ($yint) {
            my $pow = Math::GMPq::Rmpq_get_d($y);
            $pow = -$pow if $ysgn < 0;

            my $num = Math::GMPz::Rmpz_init();
            my $den = Math::GMPz::Rmpz_init();

            Math::GMPq::Rmpq_numref($num, $x);
            Math::GMPq::Rmpq_denref($den, $x);

            Math::GMPz::Rmpz_pow_ui($num, $num, $pow);
            Math::GMPz::Rmpz_pow_ui($den, $den, $pow);

            my $r = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_num($r, $num);
            Math::GMPq::Rmpq_set_den($r, $den);
            Math::GMPq::Rmpq_canonicalize($r);

            Math::GMPq::Rmpq_inv($r, $r) if $ysgn < 0;

            return _new($r);
        }

        $x = _sym($x);
        $y = _sym($y);
    }

    _new($x->Log->multiply($y)->Exp);
}

=head2 root

    $x->root(BigSym)               # => BigSym
    $x->root(Scalar)               # => BigSym

Returns a symbolic representation for the I<n>th root of C<$x>,
based on the relation: C<a^(1/b) = exp(log(a) / b)>.

=cut

sub root {
    my ($x, $y) = _symbols(@_);
    _new($x->Log->divide($y)->Exp);
}

=head2 sqrt

    $x->sqrt                       # => BigSym
    sqrt($x)                       # => BigSym

Returns a symbolic representation for the square root of C<$x>.
When C<$x> is an integer that is a perfect square, it will perform
the actual calculation.

=cut

sub sqrt {
    my ($x) = _either(@_);

    if (ref($x) eq 'Math::GMPq') {

        # Check for perfect squares
        if (Math::GMPq::Rmpq_integer_p($x)) {
            my $nz = _int2mpz($x);
            if (Math::GMPz::Rmpz_perfect_square_p($nz)) {
                Math::GMPz::Rmpz_sqrt($nz, $nz);
                return _new(_mpz2mpq($nz));
            }
        }

        $x = _sym($x);
    }

    _new($x->Sqrt);
}

=head2 ln

    $x->ln                         # => BigSym

Returns a symbolic representation for the logarithm of C<$x> in base I<e>.

=cut

sub ln {
    my ($x) = _symbols(@_);
    _new($x->Log);
}

=head2 log

    $x->log                        # => BigSym
    $x->log(BigSym)                # => BigSym
    $x->log(Scalar)                # => BigSym
    log(BigSym)                    # => BigSym

Returns a symbolic representation for the logarithm of C<$x> in base C<$y>.
When C<$y> is not specified, it defaults to base I<e>.

=cut

sub log {
    my ($x, $y) = _symbols(@_);
    _new(defined($y) ? $x->Log / $y->Log : $x->Log);
}

=head2 exp

    $x->exp                        # => BigSym

Returns a symbolic representation for the exponential of C<$x> in base e. (C<e**$x>)

=cut

sub exp {
    my ($x) = _symbols(@_);
    _new($x->Exp);
}

#<<<
#~ sub mod {
    #~ my ($x, $y) = _either(@_);

    #~ if (ref($x) eq 'Math::GMPq') {
        #~ if (Math::GMPq::Rmpq_integer_p($x) and Math::GMPq::Rmpq_integer_p($y)) {

            #~ my $yz     = _int2mpz($y);
            #~ my $sign_y = Math::GMPz::Rmpz_sgn($yz);

            #~ # Probably, this should be an exception.
            #~ return $ZERO if !$sign_y;

            #~ my $r = _int2mpz($x);
            #~ Math::GMPz::Rmpz_mod($r, $r, $yz);
            #~ if (!Math::GMPz::Rmpz_sgn($r)) {
                #~ return $ZERO;    # return faster
            #~ }
            #~ elsif ($sign_y < 0) {
                #~ Math::GMPz::Rmpz_add($r, $r, $yz);
            #~ }

            #~ return _new(_mpz2mpq($r));
        #~ }

        #~ $x = _sym($x);
        #~ $y = _sym($y);
    #~ }

    #~ _new($x % $y);
#~ }
#>>>

#
## Trigonometry
#

=head2 tan

    $x->tan                        # => BigSym

Returns a symbolic representation for the tangent of C<$x>.

=cut

sub tan {
    my ($x) = _symbols(@_);
    _new($x->tan);
}

=head2 sec

    $x->sec                        # => BigSym

Returns a symbolic representation for the secant of C<$x>.

=cut

sub sec {
    my ($x) = _symbols(@_);
    _new($x->sec);
}

=head2 csc

    $x->csc                        # => BigSym

Returns a symbolic representation for the cosecant of C<$x>.

=cut

sub csc {
    my ($x) = _symbols(@_);
    _new($x->csc);
}

=head2 cot

    $x->cot                        # => BigSym

Returns a symbolic representation for the cotangent of C<$x>.

=cut

sub cot {
    my ($x) = _symbols(@_);
    _new($x->cot);
}

=head2 sin

    $x->sin                        # => BigSym

Returns a symbolic representation for the sine of C<$x>.

=cut

sub sin {
    my ($x) = _symbols(@_);
    _new($x->Sin);
}

=head2 cos

    $x->cos                        # => BigSym

Returns a symbolic representation for the cosine of C<$x>.

=cut

sub cos {
    my ($x) = _symbols(@_);
    _new($x->Cos);
}

#
## Hyperbolic operations
#

=head2 sinh

    $x->sinh                       # => BigSym

Returns a symbolic representation for the hyperbolic sine of C<$x>.

=cut

sub sinh {
    my ($x) = _symbols(@_);
    _new($x->sinh);
}

=head2 cosh

    $x->cosh                       # => BigSym

Returns a symbolic representation for the hyperbolic cosine of C<$x>.

=cut

sub cosh {
    my ($x) = _symbols(@_);
    _new($x->cosh);
}

=head2 tanh

    $x->tanh                       # => BigSym

Returns a symbolic representation for the hyperbolic tangent of C<$x>.

=cut

sub tanh {
    my ($x) = _symbols(@_);
    _new($x->tanh);
}

=head2 sech

    $x->sech                       # => BigSym

Returns a symbolic representation for the hyperbolic secant of C<$x>.

=cut

sub sech {
    my ($x) = _symbols(@_);
    _new($x->sech);
}

=head2 csch

    $x->csch                       # => BigSym

Returns a symbolic representation for the hyperbolic cosecant of C<$x>.

=cut

sub csch {
    my ($x) = _symbols(@_);
    _new($x->csch);
}

=head2 coth

    $x->coth                       # => BigSym

Returns a symbolic representation for the hyperbolic cotangent of C<$x>.

=cut

sub coth {
    my ($x) = _symbols(@_);
    _new($x->coth);
}

#
## Complex operations
#

=head2 conjugate

    ~$x                            # => BigSym
    $x->conjugate                  # => BigSym

Returns the complex conjugate of C<$x>.

=cut

sub conjugate {
    my ($x) = _symbols(@_);
    _new($x->conjugate);
}

=head2 cross

    $x->cross(BigSym)              # => BigSym

Returns the complex cross product of C<$x> and C<$y>.

=cut

sub cross {
    my ($x, $y) = _symbols(@_);
    _new($x->cross($y));
}

=head2 dot

    $x->dot(BigSym)                # => BigSym

Returns the complex dot product of C<$x> and C<$y>.

=cut

sub dot {
    my ($x, $y) = _symbols(@_);
    _new($x->dot($y));
}

=head2 unit

    $x->unit                       # => BigSym

Returns a complex number of unit length pointing in the same direction as C<$x>.

=cut

sub unit {
    my ($x) = _symbols(@_);
    _new($x->unit);
}

=head2 re

    $x->re                         # => BigSym

Returns the real part of the complex number C<$x>.

=cut

sub re {
    my ($x) = _symbols(@_);
    _new($x->re);
}

=head2 im

    $x->im                         # => BigSym

Returns the imaginary part of the complex number C<$x>.

=cut

sub im {
    my ($x) = _symbols(@_);
    _new($x->im);
}

#
## Comparisons
#

=head2 eq

    $x->eq(BigSym)                 # => Bool
    $x->eq(Scalar)                 # => Bool

    $x == $y                       # => Bool

Equality check: returns a true value when C<$x> and C<$y> are equal.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub eq {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x == $y : "$x" eq "$y";
}

=head2 ne

    $x->ne(BigSym)                 # => Bool
    $x->ne(Scalar)                 # => Bool

    $x != $y                       # => Bool

Inequality check: returns a true value when C<$x> and C<$y> are not equal.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub ne {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x != $y : "$x" ne "$y";
}

=head2 gt

    $x->gt(BigSym)                 # => Bool
    $x->gt(Scalar)                 # => Bool

    BigSym > BigSym                # => Bool
    BigSym > Scalar                # => Bool
    Scalar > BigSym                # => Bool

Returns a true value when C<$x> is greater than C<$y>.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub gt {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x > $y : "$x" gt "$y";
}

=head2 ge

    $x->ge(BigSym)                 # => Bool
    $x->ge(Scalar)                 # => Bool

    BigSym >= BigSym               # => Bool
    BigSym >= Scalar               # => Bool
    Scalar >= BigSym               # => Bool

Returns a true value when C<$x> is equal or greater than C<$y>.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub ge {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x >= $y : "$x" ge "$y";
}

=head2 lt

    $x->lt(BigSym)                 # => Bool
    $x->lt(Scalar)                 # => Bool

    BigSym < BigSym                # => Bool
    BigSym < Scalar                # => Bool
    Scalar < BigSym                # => Bool

Returns a true value when C<$x> is less than C<$y>.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub lt {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x < $y : "$x" lt "$y";
}

=head2 le

    $x->le(BigSym)                 # => Bool
    $x->le(Scalar)                 # => Bool

    BigSym <= BigSym               # => Bool
    BigSym <= Scalar               # => Bool
    Scalar <= BigSym               # => Bool

Returns a true value when C<$x> is equal or less than C<$y>.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub le {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x <= $y : "$x" le "$y";
}

=head2 cmp

    $x->cmp(BigSym)                # => Scalar
    $x->cmp(Scalar)                # => Scalar

    BigSym <=> BigSym              # => Scalar
    BigSym <=> Scalar              # => Scalar
    Scalar <=> BigSym              # => Scalar

Compares C<$x> to C<$y> and returns a negative value when C<$x> is less than C<$y>,
0 when C<$x> and C<$y> are equal, and a positive value when C<$x> is greater than C<$y>.

B<NOTE:> expects C<$x> and C<$y> to have rational values.
Symbolic representations, such as C<sqrt(2)>, are treated literally.

=cut

sub cmp {
    my ($x, $y) = _either(@_);
    ref($x) eq 'Math::GMPq' ? $x <=> $y : "$x" cmp "$y";
}

=head1 AUTHOR

Daniel Șuteu, C<< <trizenx at gmail.com> >>

=head1 BUGS and LIMITATIONS

Please report any bugs or feature requests to C<bug-math-bigsym at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-BigSym>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

The currently known issues are:

=over 4

=item * multiplication of logarithms is not currently supported by L<Math::Algebra::Symbols>.

=item * there are some "division by zero" exceptions raised by L<Math::Algebra::Symbols> in some trigonometric functions.

=item * integer operations, such as C<|>, C<&>, C<^>, C<E<lt>E<lt>>, C<E<gt>E<gt>>, are not supported.

=item * the modulo operator (C<%>) is also not supported.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::BigSym


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-BigSym>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-BigSym>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Math-BigSym>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-BigSym/>

=item * GitHub

L<https://github.com/trizen/Math-BigSym>

=back


=head1 SEE ALSO

L<Math::Algebra::Symbols>, L<Math::Symbolic>.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Daniel Șuteu.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Math::BigSym
