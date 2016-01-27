#!/usr/bin/perl
use warnings;
use strict;

#use Data::Dumper;

use Karel::Robot;

use Test::More;

my $r = 'Karel::Robot'->new;

$r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1, 'N');

$r->run('left');
$r->step while $r->is_running;
is($r->direction, 'W', 'run core');




done_testing();
