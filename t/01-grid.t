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

done_testing();
