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


my $dsl = << '__DSL__';

:default ::= action => []
lexeme default = latm => 1

START      ::= Defs                                          action => ::first
             | ('run' SC) Command                            action => [value]

Defs       ::= Def+  separator => SC                         action => defs
Def        ::= ('příkaz') (SC) NewCommand (SC) Prog (SC) ('konec')
                                                             action => def
NewCommand ::= alpha valid_name                              action => concat
Prog       ::= Commands                                      action => ::first
Commands   ::= Command+  separator => SC                     action => list
Command    ::= 'vlevo'                                       action => left
             | 'krok'                                        action => forward
             | 'polož'                                       action => drop
             | 'zvedni'                                      action => pick
             | 'stůj'                                        action => stop
             | ('opakuj' SC) Num (SC Times SC) Prog (SC hotovo)
                                                             action => repeat
             | ('dokud' SC) Condition (SC) Prog (hotovo)     action => While
             | ('když' SC) Condition (SC) Prog (hotovo)      action => If
             | ('když' SC) Condition (SC) Prog ('jinak' SC) Prog (hotovo)
                                                             action => If
             | NewCommand                                    action => call
Condition  ::= ('je' SC) Object                              action => ::first
             | ('není' SC) Object                            action => negate
Object     ::= 'značka'                                      action => object
             | 'zeď'                                         action => object
             | 'sever'                                       action => object
             | 'východ'                                      action => object
             | 'jih'                                         action => object
             | 'západ'                                       action => object
Num        ::= non_zero                                      action => ::first
             | non_zero digits                               action => concat
Times      ::= 'krát'
             | 'x'
Comment    ::= (octothorpe non_lf lf)
SC         ::= SpComm+
SpComm     ::= Comment
            || space

hotovo     ~ 'hotovo'
octothorpe ~ '#'
alpha      ~ [[:lower:]]
valid_name ~ [-[:lower:]_0-9]+
non_zero   ~ [1-9]
digits     ~ [0-9]+
space      ~ [\s]+
non_lf     ~ [^\n]*
lf         ~ [\n]

__DSL__

has '+_dsl' => ( is      => 'ro',
                 default => $dsl,
               );

has '+action_class' => ( is => 'ro',
                         default => 'Karel::Parser::Czech::Actions',
                       );

__PACKAGE__
