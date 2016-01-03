#!/usr/bin/perl
use warnings;
use strict;

#use Data::Dumper;

use Test::More;
use Karel::Grid;

my $m = 'Karel::Grid'->new(x => 1, y => 2);

is($m->at(1, 2), ' ', 'map');
is($m->at(0, 0), 'W', 'wall');
is($m->at(2, 2), 'W', 'wall');

$m->build_wall(1, 2);
is($m->at(1, 2), 'w', 'wall built');
$m->remove_wall(1, 2);
is($m->at(1, 2), ' ', 'wall removed');

isnt(eval { $m->remove_wall(1, 2); 1 }, 1, "can't remove non-wall");
isnt(eval { $m->_set(1, 2, '!'); 1 }, 1, 'unknown object');

$m->drop_mark(1, 2);
is($m->at(1,2), 1, 'mark dropped');
$m->drop_mark(1, 2) for 2 .. 9;
is($m->at(1,2), 9, 'nine marks dropped');
isnt(eval { $m->drop_mark(1, 2); 1 }, 1, "can't drop ten marks");

$m->pick_mark(1, 2);
is($m->at(1, 2), 8, 'mark picked');
$m->pick_mark(1, 2) for 1 .. 8;
is($m->at(1, 2), ' ', 'all marks picked');
isnt(eval { $m->pick_mark(1, 2); 1 }, 1, "can't pick no mark");

$m->drop_mark(1, 2);
$m->clear(1, 2);
is($m->at(1, 2), ' ', 'mark cleared');
$m->build_wall(1, 2);
$m->clear(1, 2);
is($m->at(1, 2), ' ', 'wall cleared');

isnt(eval { $m->clear(0, 0); 1 }, 1, "can't clear W");

done_testing();
