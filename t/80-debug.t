#!/usr/bin/perl
use Test::Spec;

use Karel::Robot;
use Karel::Grid;


my $program1 = << '__EOF__';
command turn-about repeat 2 x lleft done end
command right turn-about left end
command turn-twice repeat 2 x right done end
command ten-steps
    repeat 10 times
        if there's a wall
            repeat 2 x turn-about done
        else
            forward
        done
    done
end
__EOF__

my $program2 = 'command lleft left left left left left end';

my $r = 'Karel::Robot'->new;
$r->learn($program2);
$r->learn($program1);
$r->set_grid( 'Karel::Grid'->new(x => 3, y => 3), 2, 1 );

describe 'source code' => sub {
    it 'is used in stepping through' => sub {
        $r->run('ten-steps');
        while ($r->is_running) {
            my ($src, $from, $length) = $r->current;
            substr $src, $from + $length, 0, '>>';
            substr $src, $from, 0, '<<';
            print STDERR $src, "\n---\n";
            print STDERR "STEP: ", $r->step, "\n";
        }
    };

};


runtests();
