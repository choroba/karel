package Karel::Robot;

=head1 NAME

Karel::Robot

=head1 DESCRIPTION

Basic robot class. It represents a robot wihtout a grid.

=head1 METHODS

=over 4

=cut

use warnings;
use strict;

use Data::Dumper;
use Carp;
use Module::Load qw{ load };
use Moo;
use namespace::clean;

=item my $robot = 'Karel::Robot'->new

The constructor. It takes no parameters.

=item $robot->set_grid($grid, $x, $y)

Upgrades the robot to the C<Karel::Robot::WithGrid> instance based on
$robot. C<$grid> must be a C<Karel::Grid> instance, $x and $y denote
the position of the robot in the grid.

=cut

sub set_grid {
    my ($self, $grid, $x, $y) = @_;
    my $with_grid_class = ref($self) . '::WithGrid';
    load($with_grid_class);
    $_[0] = $with_grid_class->new(grid => $grid,
                                  x    => $x,
                                  y    => $y);
}

=back

=cut


__PACKAGE__
