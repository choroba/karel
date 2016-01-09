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

use Karel::Grid;
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

=item $robot->load_grid( [ file | handle ] => '...' )

=cut

sub load_grid {
    my ($self, $type, $that) = @_;

    my $IN;
    my $open = { file   => sub { open $IN, '<', $that or croak "$that: $!" },
                 handle => sub { $IN = $that },
               }->{$type};
    croak "Unknown type $type" unless $open;
    $open->();

    my $header = <$IN>;
    croak 'Invalid format'
        unless $header =~ /^\# \s* karel \s+ ([0-9]+) \s+ ([0-9]+)/x;
    my ($x, $y) = ($1, $2);
    my $grid = 'Karel::Grid'->new( x => $x,
                                   y => $y,
                                 );

    my $r = 0;
    while (<$IN>) {
        chomp;
        my @chars = split //;
        for my $c (0 .. $#chars) {
            next if 'W' eq $chars[$c]
                 && (   $r == 0 || $r == $y + 1
                     || $c == 0 || $c == $x + 1);
            my $build = { W   => 'build_wall',
                          w   => 'build_wall',
                          ' ' => 'clear',
                          map {
                              my $x = $_;
                              $x => sub {
                                  $_[0]->drop_mark(@_[1, 2]) for 1 .. $x
                              }
                          } 1 .. 9
                        }->{ $chars[$c] };
            croak "Unknown grid character '$chars[$c]'" unless $build;
            $grid->$build($c, $r);
        }
    } continue {
        ++$r;
    }

    $_[0]->set_grid($grid, 1, 1);

}


=back

=cut


__PACKAGE__
