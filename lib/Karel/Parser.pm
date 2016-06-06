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

    use parent 'Exporter';
    our @EXPORT_OK = qw{ def concat left forward pick drop stop repeat
                         While If first_ch negate call list defs };

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

my %terminals = (
    octothorpe => '#',
    drop_mark  => 'drop-mark',
    pick_mark  => 'pick-mark',
);

$terminals{$_} = $_
    for qw( command left forward stop repeat while if else end done
            wall mark there a facing not North East South West x times
            s is isn t no );


my $dsl = << '__DSL__';

:default ::= action => []
lexeme default = latm => 1

START      ::= Defs                                          action => ::first
             | ('run' SC) Command                            action => [value]

Defs       ::= Def+  separator => SC                         action => defs
Def        ::= (SCMaybe) (command) (SC) NewCommand (SC) Prog (SC) (end)
                                                             action => def
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => SC                     action => list
Command    ::= left                                          action => left
             | forward                                       action => forward
             | drop_mark                                     action => drop
             | pick_mark                                     action => pick
             | stop                                          action => stop
             | (repeat SC) Num (SC Times SC) Prog (SC done)
                                                             action => repeat
             | (while SC) Condition (SC) Prog (done)         action => While
             | (if SC) Condition (SC) Prog (done)            action => If
             | (if SC) Condition (SC) Prog (else SC) Prog (done)
                                                             action => If
             | NewCommand                                    action => call
Condition  ::= (there quote s SC a SC) Covering              action => ::first
             | (Negation SC) Covering                        action => negate
             | (facing SC) Wind                              action => ::first
             | (not SC facing SC) Wind                       action => negate
Negation   ::= (there SC isn quote t SC a)
             | (there SC is SC no)
             | (there quote s SC no)
Covering   ::= mark                                          action => first_ch
             | wall                                          action => first_ch
Wind       ::= North                                         action => first_ch
             | East                                          action => first_ch
             | South                                         action => first_ch
             | West                                          action => first_ch
Num        ::= non_zero                                      action => ::first
             | non_zero digits                               action => concat
Times      ::= times
             | x
Comment    ::= (octothorpe non_lf lf)
SC         ::= SpComm+
SCMaybe    ::= SpComm*
SpComm     ::= Comment
            || space

alpha      ~ [a-z]
valid_name ~ [-a-z_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
space      ~ [\s]+
quote      ~ [']
non_lf     ~ [^\n]*
lf         ~ [\n]

__DSL__
$dsl .= join "\n", map "$_ ~ '$terminals{$_}'", keys %terminals;


has parser => ( is => 'ro' );

has _dsl => ( is      => 'ro',
              default => $dsl,
            );

has _grammar => ( is => 'lazy' );

has action_class => ( is => 'ro',
                      default => 'Karel::Parser::Actions',
                    );

sub _terminals { \%terminals }

sub terminals {
    my $self = shift;
    return map $self->_terminals->{$_} // $_, @_
}

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
    my $recce = 'Marpa::R2::Scanless::R'
                ->new({ grammar           => $self->_grammar,
                        semantics_package => $self->action_class,
                      });

    my ($line, $column);
    eval {
        $recce->read(\$input);
    1 } or do {
        my $exception = $@;
        ($line, $column) = $recce->line_column;
    };

    my $value = $recce->value;
    if ($line || ! $value) {
        my ($from, $length) = $recce->last_completed('Command');
        my @expected = $self->terminals(@{ $recce->terminals_expected });
        my $E = bless { expected => \@expected }, ref($self) . '::Exception';
        my $last = $recce->substring($from, $length) if defined $from;
        $E->{last_completed} = $last if $last;
        if ($line) {
            $E->{pos} = [ $line, $column ];
        } else {
            $E->{pos} = [ $recce->line_column ];
        }
        die $E
    }
    return $input =~ /^run / ? $value : @$$value
}


=back

=cut

__PACKAGE__
