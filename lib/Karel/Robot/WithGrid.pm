package Karel::Robot::WithGrid;

=head1 WithGrid

=cut

use warnings;
use strict;
use parent 'Karel::Robot';
use Karel::Util qw{ positive_int };
use Carp;
use Moo;
use namespace::clean;


has "$_"  => ( is  => 'rwp',
                isa => \&positive_int,
              ) for qw( x y );

my $grid_type    = sub {
    'Karel::Grid' eq ref shift or croak "Invalid grid type\n"
};

has 'grid' => ( is  => 'rwp',
                 isa => $grid_type,
           );

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


sub left {
    my $self = shift;
    my $dir = $self->direction;
    $self->_set_direction({ N => 'W',
                            W => 'S',
                            S => 'E',
                            E => 'N',
                          }->{$dir});
}




__PACKAGE__
