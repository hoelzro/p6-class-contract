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

done;

# all ancestor classes' invariants are checked
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
