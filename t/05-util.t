#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Karel::Util qw{ positive_int m_to_n };

ok(positive_int(1));
isnt(eval { positive_int(0); 1 }, 1, 'positive zero');
isnt(eval { positive_int(1.5); 1 }, 1, 'float');
isnt(eval { positive_int(undef); 1 }, 1, 'undef');

ok(m_to_n(2, 1, 3), '1 < 2 < 3');
ok(m_to_n(2, 2, 3), '2 < 2 < 3');
ok(m_to_n(3, 2, 3), '2 < 3 < 3');

isnt(eval { m_to_n(3, 1, 2); 1 }, 1, '1 < 3 < 2');
isnt(eval { m_to_n(0, 1, 2); 1 }, 1, '1 < 0 < 2');
isnt(eval { m_to_n(1.5, 1, 2); 1 }, 1, '1 < 1.5 < 2 float');
isnt(eval { m_to_n(undef, 0, 1); 1 }, 1, '0 < undef < 1 float');

done_testing();
