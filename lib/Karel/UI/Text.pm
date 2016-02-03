package Karel::UI::Text;

=head1 NAME

Karel::UI::Text

=head1 DESCRIPTION

Simple text UI for Karel.

=head1 SUBROUTINES

=over 4

=cut

use warnings;
use strict;
use feature qw{ say };

use Karel::Robot;

=item cls

Clears the screen.

=cut

sub cls {
    system 'MSWin32' eq $^O ? 'cls' : 'clear';
}


=item menu($robot, $default, [ [ $command => \&callback ], ... ])

Display a menu listing commands, return the callback associated with
the selected item.

=cut

sub menu {
    my ($robot, $default, $choices) = @_;
    my $reply = ' ';
    until ($reply =~ /^[0-9]*$/ && $reply && $reply <= @$choices) {
        my $i = 1;
        say $i++, ") $_->[0]" for @$choices;
        say "Default: $default" if defined $default;
        chomp( $reply = <> );
        $reply = $default if q() eq $reply && $default;
    }
    my $action = $choices->[$reply-1][1];
    $action->($robot);
}

=item show($robot)

Draw the grid with the robot.

=cut

sub show {
    my ($robot) = @_;
    cls();
    my $grid = $robot->grid;
    for my $y (0 .. $grid->y + 1) {
        for my $x (0 .. $grid->x + 1) {
            if ($x == $robot->x && $y == $robot->y) {
                print { N => '^',
                        E => '>',
                        S => 'v',
                        W => '<' }->{ $robot->direction };
            } else {
                print $grid->at($x, $y);
            }
        }
        print "\n";
    }
    say '[', $robot->cover, ']';
}

=item run

Show all the possible commands as a C<menu>, run the selected one.

=cut

sub run {
    my ($robot) = @_;
    my @commands = sort keys %{ $robot->knowledge };
    $robot->menu(undef, [ map {
                                  my $cmd = $_;
                                  [ $cmd => sub {
                                        $robot->run($cmd);
                                        $robot->step while $robot->is_running;
                                    } ]
                              } @commands ]);
}

=item main

Runs the application.

=cut

sub main {
    my $robot = 'Karel::Robot'->new;
    my $grid  = 'Karel::Grid'->new(x => 7, y => 7);
    $robot->set_grid($grid, 4, 4, 'N');

    # TODO: Use a Role instead!
    $robot->set_ui(__PACKAGE__,
                   { show => \&show,
                     menu => \&menu,
                   });

    $robot->learn('command right repeat 3 x left done end');
    while (1) {
        $robot->show;
        my $action = $robot
                     ->menu(undef,
                            [ [ Quit => sub { no warnings 'exiting'; last } ],
                              [ 'Run command' => \&run ],
                            ]);
    }
}

=back

=cut

__PACKAGE__
