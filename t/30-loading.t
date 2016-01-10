#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Robot;

my $r = 'Karel::Robot'->new;

isnt(eval { $r->load_grid( url => 'http://' ); 1 }, 1, 'invalid type');


my $G1 = << '__GRID__';
# karel 2 2
WWWW
W> 1W
W9wW
WWWW
__GRID__

is(eval { $r->load_grid( file => \$G1 ); 1 }, 1, 'loaded');
is($r->x, 1, 'x');
is($r->y, 1, 'y');
is($r->direction, 'E', 'direction');


my $G2 = << '__GRID__';
# karel 4 3
WWWWWW
W1234W
W5678W
W9wv  W
WWWWWW
__GRID__

is(eval { $r->load_grid( file => \$G2 ); 1 }, 1, 'loaded');
is($r->x, 3, 'x');
is($r->y, 3, 'y');
is($r->direction, 'S', 'direction');

eval { $r->load_grid( file => \<< '__GRID__' ) };
# karel 1 1
WWW
W>wW
WWW
__GRID__

like($@, qr/Wall at starting position/, 'start pos check');
is($r->x, 3, 'x backup');
is($r->y, 3, 'y backup');
is($r->direction, 'S', 'direction bakcup');


done_testing();
