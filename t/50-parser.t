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

my ($parsed) = $p->parse('command right left left left end');
$r->_learn(%$parsed);
ok($r->knows('right'), 'learned');
$r->_run([ ['c', 'right'] ]);
$r->step while $r->is_running;
is($r->direction, 'W', 'right');


my ($repeat) = $p->parse('command right2 repeat 3 times left done end');
$r->_learn(%$repeat);
$r->_run([ ['c', 'right2'] ]);
$r->step while $r->is_running;
is($r->direction, 'N', 'repeat');


my ($while, $while_u) = $p->parse(<< '__EOF__');
command to-south
    while not facing South
        right
    done
end
__EOF__

is($while_u->{right}, 1, 'unknown propagated');
$r->_learn(%$while);
$r->_run([ ['c', 'to-south'] ]);
$r->step while $r->is_running;
is($r->direction, 'S', 'while');


my ($to_wall) = $p->parse(<< '__EOF__');
command to-wall
    while there isn't a wall
        forward
    done
end
__EOF__

$r->_learn(%$to_wall);
$r->_run([ ['c', 'to-wall'] ]);
$r->step while $r->is_running;
is($r->y, 4, 'walked');
is($r->facing, 'W', 'to-wall');


my ($parse, $unknown) = $p->parse(<< '__EOF__');
command to-north
    repeat 3 x
        if not facing North
            right
        else
            stop
        done
    done
end
__EOF__

my ($command_name, $command_def) = %$parse;
$r->_learn($command_name, $command_def);
is(0 + keys %$unknown, 1, 'one unknown');
ok($r->knows($_), "known $_") for keys %{ $unknown };
$r->_run([ ['c', 'to-north'] ]);
$r->step while $r->is_running;
is($r->direction, 'N', 'if');


my ($d9_ss, $unknwon) =  $p->parse( << '__EOF__');
command safe-step
    if there's no wall
        forward
    done
end
command drop9
    repeat 4 times
        repeat 2 times
            drop-mark
        done
    done
    pick-mark
    repeat 2 x
        drop-mark
    done
end
__EOF__

for my $name (keys %$d9_ss) {
    $r->_learn($name, $d9_ss->{$name});
}
ok($r->knows($_), "unknown $_") for keys %{ $unknwon };
$r->_run([ ['c', 'drop9' ] ]);
$r->step while $r->is_running;
is($r->cover, 9, 'all dropped');

$r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1, 'N');
$r->run('left');
$r->step while $r->is_running;
is($r->direction, 'W', 'run core');

done_testing();



