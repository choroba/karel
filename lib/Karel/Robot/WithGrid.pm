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
use Clone qw{ clone };
use Moo;
use constant {
    CONTINUE         => 0,
    FINISHED         => 1,
    FINISHED_DELAYED => 2,
};
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

???

=cut

sub set_grid {
    my ($self, $grid, $x, $y, $direction) = @_;
    $self->_set_grid($grid);
    $self->_set_x($x);
    $self->_set_y($y);
    $self->_set_direction($direction) if $direction;
    croak "Wall at starting position" if $self->cover =~ /w/i;
}

=item $robot->drop_mark

Drop mark in the current location. Dies if there are already 9 marks.

=cut

sub drop_mark {
    my ($self) = shift;
    $self->grid->drop_mark($self->coords);
    return 1
}

=item $robot->pick_mark

Picks up one mark from the current location. Dies if there's nothing
to pick.

=cut

sub pick_mark {
    my ($self) = shift;
    $self->grid->pick_mark($self->coords);
    return 1
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
    my ($self) = @_;
    my $dir = $self->direction;
    my $idx = first { $directions[$_] eq $dir } 0 .. $#directions;
    $self->_set_direction($directions[ ($idx + 1) % @directions ]);
    return FINISHED
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
    my ($self) = @_;
    my $direction = $self->direction;
    my @coords = $self->coords;
    $coords[$_] += $facing{$direction}[$_] for 0, 1;
    return @coords
}

=item $robot->facing

Returns the contents of the grid element the robot is facing.

=cut

sub facing {
    my ($self) = @_;
    $self->grid->at($self->facing_coords)
}

has _stack => ( is        => 'rwp',
                predicate => 'is_running',
                clearer   => 'not_running',
                isa       => sub {
                    my $s = shift;
                    'ARRAY' eq ref $s or croak "Invalid stack";
                    ! grep 'ARRAY' ne ref $_, @$s
                        or croak "Invalid stack element";
                }
              );

sub _pop_stack {
    my $self = shift;
    shift @{ $self->_stack };
    $self->not_running unless @{ $self->_stack };
}

sub _push_stack {
    my ($self, $commands) = @_;
    unshift @{ $self->_stack }, [ clone($commands), 0 ];
}


sub _stacked { shift->_stack->[0] }

sub _stack_command {
    my $self = shift;
    my ($commands, $index) = @{ $self->_stacked };
    return $commands->[$index]
}

sub _stack_index { shift->_stacked->[1] }

sub _run {
    my ($self, $prog) = @_;
    $self->_set__stack([ [$prog, 0] ]);
}

=item $robot->forward

Moves the robot one cell forward in its direction.

=cut

sub forward {
    my ($self) = @_;
    croak "Can't walk through walls" if $self->facing =~ /w/i;
    my ($x, $y) = $self->facing_coords;
    $self->_set_x($x);
    $self->_set_y($y);
    return FINISHED
}

=item $robot->repeat($count, $commands)

Runs the C<repeat> command: decreases the counter, and if it's
non-zero, pushes the body to the stack. Returns 0 (CONTINUE) when it
should stay in the stack, 1 (FINISHED) otherwise.

=cut

sub repeat {
    my ($self, $count, $commands) = @_;
    if ($count) {
        $self->_stack_command->[1] = $count - 1;
        $self->_push_stack($commands);
        return CONTINUE

    } else {
        return FINISHED
    }
}

=item $isnot_south = $robot->condition('!S')

Solve the given condition. Supported parameters are:

=over 4

=item * N E S W

Facing North, East, South, West

=item * m

Covering mark(s).

=item * w

Facing a wall.

=item * !

Negates the condition.

=back

Returns true or false, dies on invalid condition.

=cut

sub condition {
    my ($self, $condition) = @_;
    my $negation = $condition =~ s/!//;
    my $result;

    if ($condition =~ /^[NESW]$/) {
        $result = $self->direction eq $condition;

    } elsif ($condition eq 'w') {
        $result = $self->facing =~ /w/i;

    } elsif ($condition eq 'm') {
        $result = $self->cover =~ /^[1-9]$/;

    } else {
        croak "Invalid condition '$condition'"
    }

    $result = ! $result if $negation;
    return $result
}

=item $robot->If($condition, $commands, $else)

If $condition is true, puts $commands to the stack, otherwise puts
$else to the stack. Returns 2 (FINISH_DELAYED) in the former case, 1
(FINISHED) in the latter one.

=cut

sub If {
    my ($self, $condition, $commands, $else) = @_;
    if ($self->condition($condition)) {
        $self->_push_stack($commands);
    } elsif ($else) {
        $self->_push_stack($else);
    } else {
        return FINISHED
    }
    return FINISHED_DELAYED
}

=item $robot->While($condition, $commands)

Similar to C<If>, but returns 0 (CONTINUE) if the condition is true,
i.e. it stays in the stack.

=cut

sub While {
    my ($self, $condition, $commands) = @_;
    if ($self->condition($condition)) {
        $self->_push_stack($commands);
        return CONTINUE

    } else {
        return FINISHED
    }
}


=item $robot->step

Makes one step in the currently running program.

=cut

sub step {
    my ($self) = @_;
    croak 'Not running!' unless $self->is_running;

    my ($commands, $index) = @{ $self->_stacked };

    my $command = $commands->[$index];
    my $action = { s   => 'forward',
                   l   => 'left',
                   p   => 'pick_mark',
                   d   => 'drop_mark',
                   r   => 'repeat',
                   i   => 'If',
                   w   => 'While',
                   x => sub { FINISHED },
                 }->{ $command->[0] };
    croak "Unknown action " . $command->[0] unless $action;

    my $finished = $self->$action(@{ $command }[ 1 .. $#$command ]);

    { FINISHED, sub {
          if (++$index > $#$commands) {
              $self->_pop_stack;

          } else {
              $self->_stack->[0][1] = $index;
          }
      },
      CONTINUE, sub { @_ = ($self); goto &step },
      FINISHED_DELAYED, sub {
          $self->_stack->[1][0][ $self->_stack->[1][1] ][0] = 'x';
      },
    }->{ $finished }->();
}

=back

=cut

__PACKAGE__
