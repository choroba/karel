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

my %faces = ( '^' => 'N',
              '>' => 'E',
              'v' => 'S',
              '<' => 'W' );

sub load_grid {
    my ($self, $type, $that) = @_;

    my %backup;
    if ($self->can('grid')) {
        @backup{qw{ grid x y direction }} = map $self->$_,
                qw( grid x y direction );
    }

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
    my (@pos, $direction);
    while (<$IN>) {
        chomp;
        my @chars = split //;
        my $c = 0;
        while ($c != $#chars) {
            next if 'W' eq $chars[$c]
                 && (   $r == 0 || $r == $y + 1
                     || $c == 0 || $c == $x + 1);
            my $build = { W   => 'build_wall',
                          w   => 'build_wall',
                          ' ' => 'clear',
                          # marks
                          ( map {
                              my $x = $_;
                              $x => sub {
                                  $_[0]->drop_mark(@_[1, 2]) for 1 .. $x
                              }
                          } 1 .. 9 ),
                          # robot
                          ( map {
                              my $f = $_;
                              $f => sub {
                                  croak 'Two robots in a grid' if $direction;
                                  $direction = $faces{$f};
                                  @pos = ($c, $r);
                                  splice @chars, $c, 1;
                                  no warnings 'exiting';
                                  redo
                              }
                          } keys %faces )
                        }->{ $chars[$c] };
            croak "Unknown grid character '$chars[$c]'" unless $build;
            $grid->$build($c, $r);
        } continue {
            ++$c;
        }
    } continue {
        ++$r;
    }

    eval {
        $_[0]->set_grid($grid, @pos);
    1 } or do {
        $_[0]->set_grid(@backup{qw{ grid x y }});
        $_[0]->left until $_[0]->direction eq $backup{direction};
        croak $@
    };
    $_[0]->left until $_[0]->direction eq $direction;
}


=back

=cut


__PACKAGE__
