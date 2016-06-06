package Karel::Parser::Czech;

=head1 NAME

=encoding UTF-8

Karel::Parser::Czech

=head1 DESCRIPTION

Implements the Czech version of the Karel language:

  příkaz
  vlevo
  krok
  polož
  zvedni
  stůj
  když|dokud je|není značka|zeď|sever|východ|jih|západ
  jinak
  opakuj 5 krát|x
  hotovo
  konec

=cut

use warnings;
use strict;
use utf8;

use Moo;
extends 'Karel::Parser';
use namespace::clean;

{   package # Hide from CPAN.
        Karel::Parser::Czech::Actions;

    'Karel::Parser::Actions'->import(qw( def concat left forward pick
                                         drop stop repeat While If
                                         negate call list defs ));

    sub object {
        { značka => 'm',
          zeď    => 'w',
          sever  => 'N',
          východ => 'E',
          jih    => 'S',
          západ  => 'W',
        }->{ $_[1] }
    }
}

my %terminals = (
    poloz      => 'polož',
    stuj       => 'stůj',
    kdyz       => 'když',
    prikaz     => 'příkaz',
    octothorpe => '#',
    neni       => 'není',
    znacka     => 'značka',
    zed        => 'zeď',
    vychod     => 'východ',
    zapad      => 'západ',
    krat       => 'krát',
);
$terminals{$_} = $_
    for qw( vlevo krok hotovo jinak opakuj konec dokud zvedni je sever jih );
sub _terminals { \%terminals }

my $dsl = << '__DSL__';

:default ::= action => []
lexeme default = latm => 1

START      ::= Defs                                          action => ::first
             | ('run' SC) Command                            action => [value]

Defs       ::= Def+  separator => SC                         action => defs
Def        ::= (SCMaybe) (< prikaz >) (SC) NewCommand (SC) Prog (SC) (konec)
                                                             action => def
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => SC                     action => list
Command    ::= vlevo                                         action => left
             | krok                                          action => forward
             | poloz                                         action => drop
             | zvedni                                        action => pick
             | stuj                                          action => stop
             | (opakuj SC) Num (SC Times SC) Prog (SC hotovo)
                                                             action => repeat
             | (dokud SC) Condition (SC) Prog (hotovo)       action => While
             | (kdyz SC) Condition (SC) Prog (hotovo)        action => If
             | (kdyz SC) Condition (SC) Prog (jinak SC) Prog (hotovo)
                                                             action => If
             | NewCommand                                    action => call
Condition  ::= (je SC) Object                                action => ::first
             | (neni SC) Object                              action => negate
Object     ::= znacka                                        action => object
             | zed                                           action => object
             | sever                                         action => object
             | vychod                                        action => object
             | jih                                           action => object
             | zapad                                         action => object
Num        ::= non_zero                                      action => ::first
             | non_zero digits                               action => concat
Times      ::= krat
             | x
Comment    ::= (octothorpe non_lf lf)
SC         ::= SpComm+
SCMaybe    ::= SpComm*
SpComm     ::= Comment
            || space

alpha      ~ [[:lower:]]
valid_name ~ [-[:lower:]_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
space      ~ [\s]+
non_lf     ~ [^\n]*
lf         ~ [\n]
x          ~ [x×]

__DSL__

$dsl .= join "\n", map "$_ ~ '$terminals{$_}'", keys %terminals;

around '_dsl' => sub { $dsl };

sub action_class { 'Karel::Parser::Czech::Actions' }

__PACKAGE__
