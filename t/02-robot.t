#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Robot;
use Karel::Map;

my $k = 'Karel::Robot'->new;
ok($k, 'constructor');
ok($k->DOES('Karel::Robot'), 'type');
is($k->mode, 'born', 'born');

my $m = 'Karel::Map'->new(x => 1, y => 2);
$k->set_map($m, 1, 1);
is($k->mode, 'edit', 'edit');

isnt(eval { $k->step; 1 }, 1, 'no step in edit mode');

done_testing();

