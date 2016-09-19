#!perl

# Test that you can change the invocant.

use strict;
use warnings FATAL => 'all';

use Test::More
    eval { require Moose }
    ? (tests => 6)
    : (skip_all => "Moose required for testing types")
;

our $skip_no_invocants;

{
    package Stuff;

    use Test::More;
    use Function::Parameters qw(:moose);

    sub new { bless {}, __PACKAGE__ }

    method bar($arg) {
        return ref $arg || $arg;
    }

    method invocant($class:) {
        $class->bar(0);
    }

    method with_arg($class: $arg) {
        $class->bar($arg);
    }

    method without_space($class:$arg) {
        $class->bar($arg);
    }

    eval q{

        method no_invocant_class_type(Foo::Bar $arg) {
            $self->bar($arg);
        }

        method no_invocant_named_param(Foo :$arg) {
            $self->bar($arg);
        }

    };
    is $@, '', 'compiles without invocant';
}

{
    package Foo;
    sub new { bless {}, __PACKAGE__ }
}

{
    package Foo::Bar;
    sub new { bless {}, __PACKAGE__ }
}


is( Stuff->invocant,                0 );
is( Stuff->with_arg(42),            42 );
is( Stuff->without_space(42),       42 );

my $stuff = Stuff->new;
is( $stuff->no_invocant_class_type(Foo::Bar->new),     'Foo::Bar' );
is( $stuff->no_invocant_named_param(arg => Foo->new),  'Foo' );
