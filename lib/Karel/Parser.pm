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

{   package Karel::Parser::Actions;

    sub def      { [ $_[1], $_[2], $_[0] ] }
    sub concat   { $_[1] . $_[2] }
    sub left     { ['l'] }
    sub forward  { ['s'] }
    sub pick     { ['p'] }
    sub drop     { ['d'] }
    sub stop     { ['q'] }
    sub repeat   { ['r', $_[1], $_[2] ] }
    sub While    { ['w', $_[1], $_[2] ] }
    sub If       { ['i', $_[1], $_[2], $_[3]] }
    sub first_ch { substr $_[1], 0, 1 }
    sub negate   { '!' . $_[1] }
    sub call     { $_[0]{ $_[1] } = 1; ['c', $_[1] ] }

}


my $dsl = << '__DSL__';

:default ::= action => [name,values]
lexeme default = latm => 1

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
             | ('if' sp) Condition (sp) Prog ('done' sp 'else' sp) Prog ('done')
                                                             action => If
            || NewCommand                                    action => call
Condition  ::= ('there' q 's' sp 'a' sp) Covering            action => ::first
             | ('there' sp 'isn' q 't' sp 'a' sp) Covering   action => negate
             | ('facing' sp) Wind                            action => ::first
             | ('not' sp 'facing' sp) Wind                   action => negate
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


alpha      ~ [a-z]
valid_name ~ [-a-z_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
sp         ~ [\s]+
q          ~ [']
__DSL__


has parser => ( is => 'ro' );

has _dsl => ( is      => 'ro',
              default => $dsl,
            );

has _grammar => ( is => 'lazy' );

sub _build__grammar {
    my ($self) = @_;
    my $g = 'Marpa::R2::Scanless::G'->new({ source => \$self->_dsl });
    return $g
}

=item parse

  $robot->_learn($parser->parse($definition))

=cut

sub parse {
    my ($self, $input) = @_;
    $input =~ s/^\s+|\s+$//g;
    my $value = $self->_grammar->parse(\$input, 'Karel::Parser::Actions');
    return @$$value
}


=back

=cut

__PACKAGE__
