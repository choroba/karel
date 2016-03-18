#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Parser::Czech;
use utf8;

ok(1, 'used');
my $p = 'Karel::Parser::Czech'->new;
ok($p, 'constructor');

my $fail = eval {
    my ($wrong) = $p->parse(<< '__EOF__');
příkaz chyba
dokud je zeď
  krok
__EOF__
    1 };
my $E = $@;
ok(! $fail, 'failure');
is(ref $E, 'Karel::Parser::Czech::Exception', 'exception object');
is($E->{last_completed}, 'krok', 'last completed');
my @expected = @{ $E->{expected} };
is(scalar @expected, 3, 'three expected');
for my $lexeme (qw( hotovo )) {
    ok(scalar(grep $_ eq $lexeme, @expected), $lexeme);
}

$fail = eval {
    my ($wrong) = $p->parse(<< '__EOF__');
příkaz chyba
dokud je zeď
  krok
hotovo
__EOF__
    1 };
$E = $@;
ok(! $fail, 'failure');
is(ref $E, 'Karel::Parser::Czech::Exception', 'exception object');
like($E->{last_completed}, qr/dokud .* hotovo/xs, 'last completed');
@expected = @{ $E->{expected} };
is(scalar @expected, 2, 'two');
for my $lexeme (qw( octothorpe space )) {
    ok(scalar(grep $_ eq $lexeme, @expected), $lexeme);
}



done_testing();
