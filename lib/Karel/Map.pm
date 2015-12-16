package Karel::Map;

=head1 Karel::Map

=cut

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Karel::Util qw{ positive_int m_to_n };

use namespace::clean;

sub new {
    my ($class, %args) = @_;
    positive_int(my $x = delete $args{x});
    positive_int(my $y = delete $args{y});

    croak "Invalid args ", join ', ', keys %args
        if keys %args;

    my $self = bless  { x    => $x,
                        y    => $y,
                        grid => [ map [ (' ') x ($y + 2) ], 0 .. $x + 1 ]
                      }, $class;
    $self->_set($_, 0, 'W'), $self->_set($_, $y + 1, 'W') for 0 .. $x + 1;
    $self->_set(0, $_, 'W'), $self->_set($x + 1, $_, 'W') for 0 .. $y + 1;
    return $self

}

sub getx { $_[0]{x} }
sub gety { $_[0]{y} }

sub at {
    my ($self, $x, $y) = @_;
    m_to_n($x, 0, $self->getx + 1);
    m_to_n($y, 0, $self->gety + 1);
    return $self->{grid}[$x][$y]
}

sub _set {
    my ($self, $x, $y, $what) = @_;
    m_to_n($x, 0, $self->getx + 1);
    m_to_n($y, 0, $self->gety + 1);
    $self->{grid}[$x][$y] = $what;
}

# TODO
sub build_wall {}
sub remove_wall {}
sub drop_mark {}
sub pick_mark {}

__PACKAGE__
