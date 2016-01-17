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


my @while = $p->parse(<< '__EOF__');
command to-south
    while not facing South
        right
    done
end
__EOF__

is($while[2]{right}, 1, 'unknown propagated');
$r->_learn(@while);
$r->_run([ ['c', 'to-south'] ]);
$r->step while $r->is_running;
is($r->direction, 'S', 'while');


my @to_wall = $p->parse(<< '__EOF__');
command to-wall
    while there isn't a wall
        forward
    done
end
__EOF__

$r->_learn(@to_wall);
$r->_run([ ['c', 'to-wall'] ]);
$r->step while $r->is_running;
is($r->y, 4, 'walked');
is($r->facing, 'W', 'to-wall');


my @to_north = $p->parse(<< '__EOF__');
command to-north
    repeat 3 x
        if not facing North
            right
        done else
            stop
        done
    done
end
__EOF__

$r->_learn(@to_north);
$r->_run([ ['c', 'to-north'] ]);
$r->step while $r->is_running;
is($r->direction, 'N', 'if');

done_testing();
