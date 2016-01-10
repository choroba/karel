package Karel::Robot::WithGrid;

=head1 NAME

Karel::Robot::WithGrid

=head1 DESCRIPTION

A robot with an associated grid. To create the robot, use

    my $robot = 'Karel::Robot'->new;
    my $grid  = 'Karel::Grid'->new(x => 10, y => 12);
    $robot = $robot->set_grid($grid, 1, 1);

=head1 METHODS

=over 4

=cut

use warnings;
use strict;
use parent 'Karel::Robot';
use Karel::Util qw{ positive_int };
use Carp;
use List::Util qw{ first };
use Moo;
use namespace::clean;


=item $robot->x, $robot->y

    my ($x, $y) = map $robot->$_, qw( x y );

Coordinates of the robot in its grid.

=cut

has "$_"  => ( is  => 'rwp',
               isa => \&positive_int,
             ) for qw( x y );

=item $robot->grid

    my $grid = $robot->grid;

The associated C<Karel::Grid> object.

=cut

my $grid_type    = sub {
    'Karel::Grid' eq ref shift or croak "Invalid grid type\n"
};


has 'grid' => ( is  => 'rwp',
                isa => $grid_type,
              );

=item $robot->set_grid($grid, $x, $y, $direction);

=cut

sub set_grid {
    my ($self, $grid, $x, $y, $direction) = @_;
    $self->_set_grid($grid);
    $self->_set_x($x);
    $self->_set_y($y);
    $self->_set_direction($direction) if $direction;
    croak "Wall at starting position" if $self->cover =~ /w/i;

}

=item $robot->direction

  my $direction = $robot->direction;

Returns the robot's direction: one of C<qw( N W S E )>.

=cut

my $string_list = sub {
    do {
        my %strings = map { $_ => 1 } @_;
        sub { $strings{+shift} or croak "Invalid string" }
    }
};

has 'direction' => ( is      => 'rwp',
                     isa     => $string_list->(qw( N W S E )),
                     default => 'N',
                   );

=item $robot->left

Turn the robot to the left.

=cut

my @directions = qw( N W S E );
sub left {
    my $self = shift;
    my $dir = $self->direction;
    my $idx = first { $directions[$_] eq $dir } 0 .. $#directions;
    $self->_set_direction($directions[ ($idx + 1) % @directions ]);
}

=item $robot->coords

Returns the robot's coordinates, i.e. C<x> and C<y>.

=cut

sub coords {
    my ($self) = @_;
    return ($self->x, $self->y)
}

=item $robot->cover

Returns the grid element at the robot's coordinates, i.e.

  $r->grid->at($r->coords)

=cut

sub cover {
    my ($self) = @_;
    return $self->grid->at($self->coords)
}

=item $robot->facing_coords

Returns the coordinates of the grid element the robot is facing.

=cut

my %facing = ( N => [0, -1],
               E => [1, 0],
               S => [0, 1],
               W => [-1, 0]
             );

sub facing_coords {
    my $self = shift;
    my $direction = $self->direction;
    my @coords = map $_ + shift @{ $facing{$direction} }, $self->coords;
    return @coords
}

=item $robot->facing

Returns the contents of the grid element the robot is facing.

=cut

sub facing {
    my $self = shift;
    $self->grid->at($self->facing_coords)
}


=back

=cut

__PACKAGE__

