#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Robot;

my $r = 'Karel::Robot'->new;

isnt(eval { $r->load_grid( url => 'http://' ); 1 }, 1, 'invalid type');


my $G = << '__GRID__';
# karel 2 2
WWWW
W 1W
W9wW
WWWW
__GRID__

is(eval { $r->load_grid( file => \$G ); 1 }, 1, 'loaded' . $@);

done_testing();
