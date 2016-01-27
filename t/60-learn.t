#!/usr/bin/perl
use warnings;
use strict;

#use Data::Dumper;

use Test::More;
use Karel::Robot;

my $r = 'Karel::Robot'->new;
$r->learn( << '__CMD__');
command right repeat 3 x left done end
command westward if not facing West left westward done end
command pick-all if there's a mark pick-mark pick-all done end
__CMD__

ok($r->knows('right'), 'learns without grid');
ok($r->knows('westward'), 'learns without grid');
$r->set_grid('Karel::Grid'->new(x => 5, y => 5), 3, 3, 'N');

$r->run('right');
$r->step while $r->is_running;
is($r->direction, 'E', 'right');

$r->run('westward');
$r->step while $r->is_running;
is($r->direction, 'W', 'recursion2');

$r->run('xxx'); # ignored
$r->run('repeat 9 x drop-mark done');
$r->step while $r->is_running;
is($r->cover, '9', 'dropped');

$r->run('pick-all');
$r->step while $r->is_running;
is($r->cover, ' ', 'recursion9');

isnt(eval { $r->run('forward forward'); 1 }, 1, 'only 1 command');

done_testing();
