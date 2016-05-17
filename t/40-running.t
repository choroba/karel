#!/usr/bin/perl
use warnings;
use strict;

use Karel::Robot;
use Test::More;
use Test::Exception;

sub count_steps {
    my $r = shift;
    my $c = 0;
    $c++, $r->step while $r->is_running;
    return $c
}


my $r = 'Karel::Robot'->new;

$r->load_grid( string => << '__GRID__');
# karel v0.01 4 3
WWWWWW
W    W
W ^   W
W    W
WWWWWW
__GRID__


$r->_run([ ['f'], ['l'] ]);
ok($r->_stack, 'stack');

$r->step;
is($r->x, 2, 'horizontal');
is($r->y, 1, 'vertical');
is($r->facing, 'W', 'facing wall');

$r->step;
is($r->direction, 'W', '2nd step');

ok(! $r->_stack, 'stack empty');
dies_ok { $r->step } "can't step";

$r->_run([ (['l']) x 4]);
is(count_steps($r), 4, 'count steps');
ok(! $r->_stack, 'stack empty');


$r->_run([ ['r', 3, [ ['r', 2, [ ['l'] ] ] ] ], ['f'] ]);

is(count_steps($r), 11, 'step count');

is($r->direction, 'E', 'right=3xleft');
is($r->x, 3, 'moved');

$r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1);
$r->_run([ ['r', 9, [ ['d'] ] ] ]);

is(count_steps($r), 10, 'steps=10');

is($r->cover, '9', 'dropped all');

$r->_run([ ['r', 3, [ ['r', 3, [ ['p'] ] ] ] ] ]);

is(count_steps($r), 13, 'steps=13');

is($r->cover, ' ', 'picked all');

$r->load_grid( string => << '__GRID__');
# karel v0.01 3 3
WWWWW
W   W
W   W
W ^  W
WWWWW
__GRID__

$r->_run([ ['w', '!w', [ ['f'] ] ],
           ['i', 'w', [ ['l'], ['l'] ] ],
           ['i', 'm', [ ['p'] ], [ ['d'] ] ] ] );
$r->step while $r->is_running;
is($r->y, 1, 'moved up');
is($r->direction, 'S', 'turned');
is($r->cover, '1', 'dropped');


$r->load_grid( string => << '__GRID__');
# karel v0.01 1 4
WWW
W W
W W
W W
W^ W
WWW
__GRID__

$r->_run([ ['r', 4, [ ['i', '!w', [ ['f'] ] ],
                      ['d'] ] ],
           ['w', '!S', [ ['r', 3, [ ['l'] ] ] ] ] ]);

$r->step while $r->is_running;
is($r->y, 1, 'walked');
is($r->direction, 'S', 'turned');
is($r->cover, 2, 'two marks');
is($r->facing, 1, 'one mark');


$r->_run([ ['r', 2, [ ['i', 'S', [ ['l'], ['q'] ] ] ] ],
           ['f'], ['f'] ]);
is(count_steps($r), 3, 'quit');

$r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1, 'N');
$r->_set_knowledge({ right => [ [ 'r', 3, [ ['l'] ] ] ] });
$r->_run([ [ 'c', 'right' ], ['l'] ]);
$r->step while $r->is_running;
is($r->direction, 'N', 'knowledge');

done_testing();
