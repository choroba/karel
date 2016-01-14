#!/usr/bin/perl
use warnings;
use strict;

use Karel::Robot;
use Test::More;


my $r = 'Karel::Robot'->new;

$r->load_grid( string => << '__GRID__');
# karel 4 3
WWWWWW
W    W
W ^   W
W    W
WWWWWW
__GRID__

$r->_run([ ['s'], ['l'] ]);
ok($r->_stack, 'stack');

$r->step;
is($r->x, 2, 'horizontal');
is($r->y, 1, 'vertical');
is($r->facing, 'W', 'facing wall');

$r->step;
is($r->direction, 'W', '2nd step');

ok(! $r->_stack, 'stack empty');
isnt(eval { $r->step; 1 }, 1, "can't step");


$r->_run([ ['r', 3, [ ['r', 2, [ ['l'] ] ] ] ], ['s'] ]);
my $c = 0;
$c++, $r->step while $r->is_running;
is($c, 7, 'step count');
is($r->direction, 'E', 'right=3xleft');
is($r->x, 3, 'moved');


done_testing();
