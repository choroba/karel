#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Parser;
use Karel::Robot;

ok(1, 'used');
my $p = 'Karel::Parser'->new;
ok($p, 'constructor');

my $r = 'Karel::Robot'->new;
$r->set_grid('Karel::Grid'->new(x => 5, y => 4), 3, 1, 'S');

my @parsed = $p->parse('command right left left left end');
$r->_learn(@parsed);
ok($r->knows('right'), 'learned');
$r->_run([ ['c', 'right'] ]);
$r->step while $r->is_running;
is($r->direction, 'W', 'right');


my $repeat = 'command right2 repeat 3 times left done end';
$r->_learn($p->parse($repeat));
$r->_run([ ['c', 'right2'] ]);
$r->step while $r->is_running;
is($r->direction, 'N', 'repeat');


done_testing();

