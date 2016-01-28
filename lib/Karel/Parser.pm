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
    sub skip     { ['x'] }
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
             | ('run' sp) Command                            action => [value]

Defs       ::= Def+  separator => sp                         action => defs
Def        ::= ('command') (sp) NewCommand (sp) Prog (sp) ('end')
                                                             action => def
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => sp                     action => [values]
Command    ::= 'left'                                        action => left
             | 'forward'                                     action => forward
             | 'drop-mark'                                   action => drop
             | 'pick-mark'                                   action => pick
             | 'stop'                                        action => stop
             | ('repeat' sp) Num (sp Times sp) Prog (sp 'done')
                                                             action => repeat
             | ('while' sp) Condition (sp) Prog ('done')     action => While
             | ('if' sp) Condition (sp) Prog ('done')        action => If
             | ('if' sp) Condition (sp) Prog ('else' sp) Prog ('done')
                                                             action => If
             | (Comment)                                     action => skip
             | NewCommand                                    action => call
Condition  ::= ('there' q 's' sp 'a' sp) Covering            action => ::first
             | (Negation sp) Covering                        action => negate
             | ('facing' sp) Wind                            action => ::first
             | ('not' sp 'facing' sp) Wind                   action => negate
Negation   ::= ('there' sp 'isn' q 't' sp 'a')
             | ('there' sp 'is' sp 'no')
             | ('there' q 's' sp 'no')
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

alpha      ~ [a-z]
valid_name ~ [-a-z_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
sp         ~ [\s]+
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
