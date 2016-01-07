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

sub BUILD {
    my $self = shift;
    my ($x, $y, $grid) = map $self->$_, qw( x y grid );
    $grid->at($x, $y) =~ /w/i and croak "Can't go through walls";
    $self->_set_grid($grid);
    $self->_set_x($x);
    $self->_set_y($y);
}

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


=back

=cut

__PACKAGE__

