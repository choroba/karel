package Karel::Robot;

=head1 Karel::Robot

=cut

use warnings;
use strict;

use Data::Dumper;
use Karel::Util qw{ positive_int };
use Carp;
use Moo;
use namespace::clean;

my $grid_type    = sub {
    'Karel::Grid' eq ref shift or croak "Invalid grid type\n"
};

my $string_list = sub {
    do {
        my %strings = map { $_ => 1 } @_;
        sub { $strings{+shift} or croak "Invalid string" }
    }
};


has $_  => ( is  => 'rwp',
             isa => \&positive_int,
           ) for qw( x y );

has grid => ( is  => 'rwp',
              isa => $grid_type,
           );

has mode => ( is      => 'rwp',
              isa     => $string_list->(qw( born edit run )),
              default => 'born',
            );

has direction => ( is      => 'rwp',
                   isa     => $string_list->(qw( N W S E )),
                   default => 'N',
                 );

before direction => sub {
    my $self = shift;
    croak "No direction without map!" if 'born' eq $self->mode;
};


sub set_grid {
    my $self = shift;
    my ($grid, $x, $y) = @_;
    $grid->at($x, $y) =~ /w/i and croak "Can't go through walls";
    $self->_set_grid($grid);
    $self->_set_x($x);
    $self->_set_y($y);
    $self->_set_mode('edit');
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

sub run_step {
    my $self = shift;
    croak "Not running a program!" unless 'run' eq $self->mode;
}


__PACKAGE__
