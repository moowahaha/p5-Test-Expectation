package Test::Expectation::Base;

use strict;
use warnings;
use Data::Dumper;
use Sub::Override;

sub new {
    my ($class, $expectedClass, $expectedMethod) = @_;

    $expectedClass = ref($expectedClass) if (ref($expectedClass));

    my $methodString = "${expectedClass}::${expectedMethod}";

    my $self = {
        -met => 0,
        -method => $methodString,
        -class => $expectedClass,
        -failure => $methodString . " not called",
        -returnValues => []
    };

    bless($self, $class);

    $self->_setReplacement(sub {
        $self->met();
        $self->{-returnValues}->[0];
    });

    return $self;
}

sub _setReplacement {
    my ($self, $code) = @_;

    eval {
        $self->_restore();
        $self->{-replacement} = Sub::Override->new(
            $self->{-method} => $code
        );
    };
}

sub with {
    my ($self, @expectedParams) = @_;

    $self->{-failure} = $self->{-failure} . " with '@expectedParams'";

    $self->_setReplacement(sub {
        my (@params) = @_;

        shift(@params) if (ref($params[0]) && (ref($params[0]) eq $self->{-class}));

        $self->{-failure} .= ", got '@params'";

        $self->met() if (Dumper(@params) eq Dumper(@expectedParams));

        $self->{-returnValues}->[0];
    });

    return $self;
}

# this isn't camel-cased so it's external interface is consistent
sub to_return {
    my ($self, @returnValues) = @_;

    @{$self->{-returnValues}} = @returnValues;
}

sub met {
    shift->{-met} = 1;
}

sub isMet {
    shift->{-met};
}

sub class {
    shift->{-class};
}

sub failure {
    shift->{-failure}
}

sub _restore {
    my $self = shift;
    $self->{-replacement}->restore() if $self->{-replacement};
}

sub DESTROY {
    shift->_restore();
}

1;

