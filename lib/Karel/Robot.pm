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
use Module::Load;
use Moo;
use namespace::clean;

=item my $robot = 'Karel::Robot'->new

The constructor. It takes no parameters.

=item $robot->set_grid($grid, $x, $y)

Returns a new C<Karel::Robot::WithGrid> instance based on
$robot. C<$grid> must be a C<Karel::Grid> instance, $x and $y denote
the position of the robot in the grid.

=cut

sub set_grid {
    my $self = shift;
    my ($grid, $x, $y) = @_;
    load(__PACKAGE__ . '::WithGrid');
    $self = 'Karel::Robot::WithGrid'->new(grid => $grid,
                                          x    => $x,
                                          y    => $y);
    return $self
}

=back

=cut


__PACKAGE__
