#!/usr/bin/perl
use warnings;
use strict;

use Karel::Robot;
use Karel::Grid;
use Test::More;

my $k = 'Karel::Robot'->new;
ok($k, 'constructor');
ok($k->DOES('Karel::Robot'), 'type');
is(ref $k, 'Karel::Robot');
isnt(eval { $k->left; 1 }, 1, 'no direction');

my $m = 'Karel::Grid'->new(x => 1, y => 2);
$k = $k->set_grid($m, 1, 1);
is(ref $k, 'Karel::Robot::WithGrid');
is($k->direction, 'N', 'default direction');

$k->left;
is($k->direction, 'W', 'turn left');
$k->left for 1 .. 3;
is($k->direction, 'N', 'back north');

isnt(eval { $k->run_step; 1 }, 1, 'no step in edit mode');

done_testing();

