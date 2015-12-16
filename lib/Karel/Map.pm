package Karel::Map;

=head1 Karel::Map

=cut

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Karel::Util qw{ positive_int m_to_n };
use Moo;

use namespace::clean;

has $_ => (is       => 'ro',
           isa      => \&positive_int,
           required => 1,
  ) for qw( x y );


has _grid => ( is  => 'rw',
               isa => sub {
                   die "Grid should be an AoA!"
                       if 'ARRAY' ne ref $_[0]
                       || grep 'ARRAY' ne ref, @{ $_[0] }
                   },
             );

sub BUILD {
    my $self = shift;
    my ($x, $y) = map $self->$_, qw( getx gety );
    $self->_grid([ map [ (' ') x ($y + 2) ], 0 .. $x + 1 ]);
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
    return $self->_grid->[$x][$y]
}

sub _set {
    my ($self, $x, $y, $what) = @_;
    m_to_n($x, 0, $self->getx + 1);
    m_to_n($y, 0, $self->gety + 1);
    $self->_grid->[$x][$y] = $what;
}

# TODO
sub build_wall {}
sub remove_wall {}
sub drop_mark {}
sub pick_mark {}

__PACKAGE__
