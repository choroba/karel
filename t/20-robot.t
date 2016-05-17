#!/usr/bin/perl
use warnings;
use strict;

use Karel::Robot;
use Karel::Grid;
use Test::More;
use Test::Exception;

my $k = 'Karel::Robot'->new;
ok($k, 'constructor');
is(ref $k, 'Karel::Robot');
dies_ok { $k->left } 'no direction';
dies_ok { $k->grid } 'no grid';

my $m = 'Karel::Grid'->new(x => 1, y => 2);
$k->set_grid($m, 1, 1);
is($k->grid, $m, 'grid');
ok($k->does('Karel::Robot::WithGrid'), 'role');
is($k->direction, 'N', 'default direction');

$k->left;
is($k->direction, 'W', 'turn left');
$k->left for 1 .. 3;
is($k->direction, 'N', 'back north');

dies_ok { $k->run_step } 'no step in edit mode';

is($k->facing, 'W', 'facing wall');
$k->left;
my @f = $k->facing_coords;
is($f[0], 0, 'facing x coord');
is($f[1], 1, 'facing y coord');
$k->left;
is($k->facing, ' ', 'facing blank');

done_testing();

