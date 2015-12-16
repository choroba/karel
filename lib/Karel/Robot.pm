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

my $map_type    = sub {
    'Karel::Map' eq ref shift or croak "Invalid map type\n"
};

my $valid_mode = do {
    my %modes = map { $_ => 1 } qw( born edit run );
    sub { $modes{+shift} or croak "Ivalid mode" }
};


has $_  => ( is  => 'rwp',
             isa => \&positive_int,
           ) for qw( x y );

has map => ( is  => 'rwp',
             isa => $map_type,
           );

has mode => ( is      => 'rwp',
              isa     => $valid_mode,
              default => 'born',
            );


sub set_map {
    my $self = shift;
    my ($map, $x, $y) = @_;
    $map->at($x, $y) =~ /w/i and croak "Can't go through walls";
    $self->_set_map($map);
    $self->_set_x($x);
    $self->_set_y($y);
    $self->_set_mode('edit');
}


sub step {
    my $self = shift;
    croak "Not running a program!" unless 'run' eq $self->mode;
}


__PACKAGE__
