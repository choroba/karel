package Karel::Robot;

=head1 Karel::Robot

=cut

use warnings;
use strict;

use Data::Dumper;
use Carp;
use Module::Load;
use Moo;
use namespace::clean;


for my $method (qw( x y grid direction left run_step )) {
    no strict 'refs';
    *{$method} = sub {
        use strict;
        my $self = shift;
        my $class = ref $self;
        croak "$method not implemented in $class";
    }
}

sub set_grid {
    my $self = shift;
    my ($grid, $x, $y) = @_;
    load(__PACKAGE__ . '::WithGrid');
    $self = 'Karel::Robot::WithGrid'->new(grid => $grid,
                                          x    => $x,
                                          y    => $y);
    return $self
}

__PACKAGE__
