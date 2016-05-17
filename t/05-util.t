#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use Test::Exception;
use Karel::Util qw{ positive_int m_to_n };

ok(positive_int(1));
dies_ok { positive_int(0)     } 'positive zero';
dies_ok { positive_int(1.5)   } 'float';
dies_ok { positive_int(undef) } 'undef';

ok(m_to_n(2, 1, 3), '1 < 2 < 3');
ok(m_to_n(2, 2, 3), '2 < 2 < 3');
ok(m_to_n(3, 2, 3), '2 < 3 < 3');

dies_ok { m_to_n(3, 1, 2)     } '1 < 3 < 2';
dies_ok { m_to_n(0, 1, 2)     } '1 < 0 < 2';
dies_ok { m_to_n(1.5, 1, 2)   } '1 < 1.5 < 2 float';
dies_ok { m_to_n(undef, 0, 1) } '0 < undef < 1 float';

done_testing();
