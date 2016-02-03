#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use Karel::Robot;
use Karel::Parser::Czech;
use Test::More;


my $robot = 'Karel::Robot'->new(parser => 'Karel::Parser::Czech'->new);
ok($robot);

$robot->learn('příkaz vpravo opakuj 3 krát vlevo hotovo konec');

$robot->set_grid('Karel::Grid'->new(x => 1, y => 1), 1, 1, 'N');

$robot->run('vlevo');
$robot->step while $robot->is_running;
is($robot->direction, 'W', 'cz left');

$robot->run('vpravo');
$robot->step while $robot->is_running;
is($robot->direction, 'N', 'learned cz right');

$robot->run('opakuj 2 x vpravo hotovo');
$robot->step while $robot->is_running;
is($robot->direction, 'S', 'composed cz');

$robot->learn('příkaz na-sever dokud není sever vpravo na-sever hotovo konec');
$robot->run('na-sever');
my $directions;
while ($robot->is_running) {
    $robot->step;
    $directions .= $robot->direction;
}
$directions =~ tr///cs;
is($directions, 'SENWSEN', 'one and half circles');
is($robot->direction, 'N', 'cz while not');

done_testing();
