#!perl
use warnings FATAL => 'all';
use strict;
use Test::More 'no_plan';

{
    package Foo;
    use Function::Parameters qw(:strict);

    method new (%args) {
        return bless {%args}, $self;
    }

    method set ($key, $val) {
        return $self->{$key} = $val;
    }

    method get ($key) {
        return $self->{$key};
    }

    method no_proto(@) {
        return($self, @_);
    }

    method empty_proto() {
        return($self, @_);
    }

#    method echo(@_) {
#        return($self, @_);
#    }

    method caller($height = 0) {
        return (CORE::caller($height))[0..2];
    }

#line 39
    method warn($foo = undef) {
        my $warning = '';
        local $SIG{__WARN__} = sub { $warning = join '', @_; };
        CORE::warn "Testing warn";

        return $warning;
    }

    # Method with the same name as a loaded class.
    method strict () {
        42
    }
}

my $obj = Foo->new( foo => 42, bar => 23 );
isa_ok $obj, "Foo";
is $obj->get("foo"), 42;
is $obj->get("bar"), 23;

$obj->set(foo => 99);
is $obj->get("foo"), 99;

is_deeply [$obj->no_proto], [$obj];
for my $method (qw(empty_proto)) {
    is_deeply [$obj->$method], [$obj];
    ok !eval { $obj->$method(23); 1 };
    like $@, qr{\QToo many arguments};
}

#is_deeply [$obj->echo(1,2,3)], [$obj,1,2,3], "echo";

is_deeply [$obj->caller], [__PACKAGE__, $0, __LINE__], 'caller works';

is $obj->warn, "Testing warn at $0 line 42.\n";

is eval { $obj->strict }, 42;
