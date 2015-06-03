#!/usr/bin/env perl6

use v6;

use Test;
use Class::Contract;

class HasPostInvariant {
    has $.value = 0;

    # the reason for using this instead of a generated
    # accessor is explained in the test for accessors
    # below
    method set-value(Int $new-value) {
        $!value = $new-value;
    }

    submethod POST {
        $!value.defined
    }
}

class PostInvariantChild is HasPostInvariant {
    method clear-value {
        self.set-value(Int);
    }

    submethod POST {
        self.value < 10
    }
}

my $o = HasPostInvariant.new;

lives-ok({
    $o.set-value(1);
}, q{conforming with constraints shouldn't die});

dies-ok({
    $o.set-value(Int);
}, 'violating constraints should throw an exception');

try {
    $o.set-value(Int);

    CATCH {
        when X::Phaser::PrePost {
            pass 'X::Phaser::PrePost should be thrown when a POST violation occurs';
        }

        default {
            fail 'X::Phaser::PrePost should be thrown when a POST violation occurs';
        }
    }
}

my $child = PostInvariantChild.new;

lives-ok({
    $child.set-value(5);
});

dies-ok({
    $child.set-value(Int);
});

lives-ok({
    $child.set-value(5);
});

dies-ok({
    $child.set-value(11);
});

lives-ok({
    $child.set-value(5);
});

dies-ok({
    $child.clear-value;
});

done;

# what about roles?
# PREs are checked before, POSTs after
# private methods aren't checked
# some sort of trait to tune things?
# make sure return values aren't affected
# automatically generated accessors should work
# BUILD should work, too
# type checking on incoming arguments
# stack frame?
# message for exception
# pre/post conditions for accessors?
# BUILD, DESTROY?
# ability to skip some methods (ex. if you know they don't modify anything?)
# $o.value = Any; # XXX this won't trigger it, because we're returning the container!
# a public calling another public should still check
# what if a child class doesn't use Class::Contract;? does it still get the right metaclass?
