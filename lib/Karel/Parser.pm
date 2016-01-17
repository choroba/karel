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

    sub concat  { $_[1] . $_[2] }
    sub left    { ['l'] }
    sub forward { ['s'] }
    sub pick    { ['p'] }
    sub drop    { ['d'] }
    sub repeat  { ['r', $_[1], $_[2] ] }

}


my $dsl = << '__DSL__';

:default ::= action => [name,values]
lexeme default = latm => 1

Def        ::= ('command') (space) NewCommand (space) Prog (space) ('end')
                                                             action => [values]
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => space                  action => [values]
Command    ::= 'left'                                        action => left
             | 'forward'                                     action => forward
             | 'drop-mark'                                   action => drop
             | 'pick-mark'                                   action => pick
             | ('repeat' space) Num (space Times space) Prog (space 'done')
                                                             action => repeat
Num        ::= non_zero                                      action => ::first
             | non_zero digits                               action => concat
Times      ::= 'times'
             | 'x'
#            | ('if' space) Condition Prog ('done')          action => If


alpha      ~ [a-z]
valid_name ~ [-a-z_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
space      ~ [\s]+

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
    my $value = $self->_grammar->parse(\$input, 'Karel::Parser::Actions');
    return @$$value
}


=back

=cut

__PACKAGE__
