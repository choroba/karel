#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Test::Exception;
use Karel::Robot;

my $r = 'Karel::Robot'->new;

dies_ok { $r->load_grid( url => 'http://' ) } 'invalid type';


my $G1 = << '__GRID__';
# karel v0.01 2 2
WWWW
W> 1W
W9wW
WWWW
__GRID__

open my $FH, '<', \$G1;

is(eval { $r->load_grid( handle => $FH ); 1 }, 1, 'loaded');
is($r->x, 1, 'x');
is($r->y, 1, 'y');
is($r->direction, 'E', 'direction');


my $G2 = << '__GRID__';
# karel v0.01 4 3
WWWWWW
W1234W
W5678W
W9wv  W
WWWWWW
__GRID__

is(eval { $r->load_grid( string => $G2 ); 1 }, 1, 'loaded');
is($r->x, 3, 'x');
is($r->y, 3, 'y');
is($r->direction, 'S', 'direction');

eval { $r->load_grid( file => 't/invalid.kg' ) };

like($@, qr/Wall at starting position/, 'start pos check');
is($r->x, 3, 'x backup');
is($r->y, 3, 'y backup');
is($r->direction, 'S', 'direction backup');

dies_ok { $r->load_grid( string => << '__GRID__' ) } 'W inside';
# karel v0.01 2 1
WWWW
W> WW
WWWW
__GRID__

done_testing();
