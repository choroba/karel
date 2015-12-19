package Karel::Grid;

=head1 NAME

Karel::Grid

=head1 DESCRIPTION

Represents the map in which the robot moves.

=head1 METHODS

=over 4

=item 'Karel::Grid'->new

  my $grid = 'Karel::Grid'->new( x => 10, y => 12 );

The constructor creates an empty grid of the given size.

=cut

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Karel::Util qw{ positive_int m_to_n };
use List::Util qw{ any first };
use Moo;
use namespace::clean;

=item $grid->x, $grid->y

    my ($x, $y) = map $grid->$_, qw( x y );

Returns the size of the grid.

=cut

has $_ => (is       => 'ro',
           isa      => \&positive_int,
           required => 1,
          ) for qw( x y );


has _grid => ( is  => 'rw',
               isa => sub {
                   die "Grid should be an AoA!"
                       if 'ARRAY' ne ref $_[0]
                       || any { 'ARRAY' ne ref } @{ $_[0] };
               },
             );

# Create an empty grid
sub BUILD {
    my $self = shift;
    my ($x, $y) = map $self->$_, qw( x y );
    $self->_grid([ map [ (' ') x ($y + 2) ], 0 .. $x + 1 ]);
    $self->_set($_, 0, 'W'), $self->_set($_, $y + 1, 'W') for 0 .. $x + 1;
    $self->_set(0, $_, 'W'), $self->_set($x + 1, $_, 'W') for 0 .. $y + 1;
    return $self
}

=item $grid->at($x, $y)

Returns a space if there's nothing at the given position. For marks,
it returns 1 - 9. For walls, it returns "W" (outer walls) or "w"
(inner walls).

=cut

sub at {
    my ($self, $x, $y) = @_;
    m_to_n($x, 0, $self->x + 1);
    m_to_n($y, 0, $self->y + 1);
    return $self->_grid->[$x][$y]
}


sub _set {
    my ($self, $x, $y, $what) = @_;
    m_to_n($x, 0, $self->x + 1);
    m_to_n($y, 0, $self->y + 1);
    $self->_grid->[$x][$y] = $what;
}

# TODO
# sub build_wall {}
# sub remove_wall {}
# sub drop_mark {}
# sub pick_mark {}

=back

=cut

__PACKAGE__
