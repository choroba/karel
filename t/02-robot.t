#!/usr/bin/perl
use warnings;
use strict;

use Karel::Robot;
use Karel::Grid;
use Test::More;

my $k = 'Karel::Robot'->new;
ok($k, 'constructor');
ok($k->DOES('Karel::Robot'), 'type');
is($k->mode, 'born', 'born');
isnt(eval { $k->direction; 1 }, 1, 'no direction');

my $m = 'Karel::Grid'->new(x => 1, y => 2);
$k->set_grid($m, 1, 1);
is($k->mode, 'edit', 'edit');
is($k->direction, 'N', 'default direction');

isnt(eval { $k->step; 1 }, 1, 'no step in edit mode');

done_testing();

