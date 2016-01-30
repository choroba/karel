package Karel::Parser;

=head1 NAME

Karel::Parser

=head1 METHODS

=over 4

=cut

use warnings;
use strict;

use Moo;
use Marpa::R2;
use namespace::clean;

{   package # Hide from CPAN.
        Karel::Parser::Actions;

    sub def      { [ $_[1], $_[2] ] }
    sub concat   { $_[1] . $_[2] }
    sub left     { ['l'] }
    sub forward  { ['f'] }
    sub pick     { ['p'] }
    sub drop     { ['d'] }
    sub stop     { ['q'] }
    sub repeat   { ['r', $_[1], $_[2] ] }
    sub While    { ['w', $_[1], $_[2] ] }
    sub If       { ['i', $_[1], $_[2], $_[3]] }
    sub first_ch { substr $_[1], 0, 1 }
    sub negate   { '!' . $_[1] }
    sub call     { $_[0]{ $_[1] } = 1; ['c', $_[1] ] }
    sub list     { [ grep defined, @_[ 1 .. $#_ ] ] }
    sub defs {
        my $unknown = shift;
        my %h;
        $h{ $_->[0] }= $_->[1] for @_;
        return [ \%h, $unknown ]
    }

}


my $dsl = << '__DSL__';

:default ::= action => []
lexeme default = latm => 1

START      ::= Defs                                          action => ::first
             | ('run' SC) Command                            action => [value]

Defs       ::= Def+  separator => SC                         action => defs
Def        ::= ('command') (SC) NewCommand (SC) Prog (SC) ('end')
                                                             action => def
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => SC                     action => list
Command    ::= 'left'                                        action => left
             | 'forward'                                     action => forward
             | 'drop-mark'                                   action => drop
             | 'pick-mark'                                   action => pick
             | 'stop'                                        action => stop
             | ('repeat' SC) Num (SC Times SC) Prog (SC 'done')
                                                             action => repeat
             | ('while' SC) Condition (SC) Prog ('done')     action => While
             | ('if' SC) Condition (SC) Prog ('done')        action => If
             | ('if' SC) Condition (SC) Prog ('else' SC) Prog ('done')
                                                             action => If
             | NewCommand                                    action => call
Condition  ::= ('there' q 's' SC 'a' SC) Covering            action => ::first
             | (Negation SC) Covering                        action => negate
             | ('facing' SC) Wind                            action => ::first
             | ('not' SC 'facing' SC) Wind                   action => negate
Negation   ::= ('there' SC 'isn' q 't' SC 'a')
             | ('there' SC 'is' SC 'no')
             | ('there' q 's' SC 'no')
Covering   ::= 'mark'                                        action => first_ch
             | 'wall'                                        action => first_ch
Wind       ::= 'North'                                       action => first_ch
             | 'East'                                        action => first_ch
             | 'South'                                       action => first_ch
             | 'West'                                        action => first_ch
Num        ::= non_zero                                      action => ::first
             | non_zero digits                               action => concat
Times      ::= 'times'
             | 'x'
Comment    ::= ('#' non_lf lf)
SC         ::= SpComm+
SpComm     ::= Comment
            || space


alpha      ~ [a-z]
valid_name ~ [-a-z_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
space      ~ [\s]+
q          ~ [']
non_lf     ~ [^\n]*
lf         ~ [\n]

__DSL__


has parser => ( is => 'ro' );

has _dsl => ( is      => 'ro',
              default => $dsl,
            );

has _grammar => ( is => 'lazy' );

has action_class => ( is => 'ro',
                      default => 'Karel::Parser::Actions',
                    );

sub _build__grammar {
    my ($self) = @_;
    my $g = 'Marpa::R2::Scanless::G'->new({ source => \$self->_dsl });
    return $g
}

=item my ($new_commands, $unknown) = $parser->parse($definition)

C<$new_commands> is a hash that you can use to teach the robot:

  $robot->_learn($_, $new_commands->{$_}) for keys %$new_commands;

C<$unknwon> is a hash whose keys are all the non-basic commands needed
to run the parsed programs.

When the input starts with C<run >, it should contain just one
command. The robot's C<run> function uses it to parse commands you
run, as simple C<[[ 'c', $command ]]> doesn't work for core commands
(C<left>, C<forward>, etc.).

=cut

sub parse {
    my ($self, $input) = @_;
    $input =~ s/^\s+|\s+$//g;
    my $value = $self->_grammar->parse(\$input, $self->action_class);
    return $input =~ /^run / ? $value : @$$value
}


=back

=cut

__PACKAGE__
