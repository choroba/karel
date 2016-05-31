#!/usr/bin/perl
use Test::Spec;

use Karel::Parser;
use Karel::Robot;

describe 'Karel::Parser' => sub {

    it 'instantiates' => sub {
        my $p = 'Karel::Parser'->new;
        isa_ok $p, 'Karel::Parser';
    };
};

describe 'Karel::Robot with Karel::Robot' => sub {

    my ($r, $p);
    before each => sub {
        $r = 'Karel::Robot'->new;
        $p = 'Karel::Parser'->new;
        $r->set_grid('Karel::Grid'->new(x => 5, y => 4), 3, 1, 'S');
    };

    describe 'privately' => sub {

        my $command;

        shared_examples_for 'learned' => sub {
            before each => sub {
                my ($parsed) = $p->parse($command);
                $r->_learn(%$parsed);
            };

            it 'learns the command' => sub {
                ok $r->knows('test');
            };

            it 'runs the command' => sub {
                $r->_run([ ['c', 'test'] ]);
                $r->step while $r->is_running;
                is $r->direction, 'W';
            };
        };

        describe 'simple commands' => sub {
            before all => sub {
                $command = 'command test left left left end';
            };
            it_should_behave_like 'learned';
        };

        describe 'repeat loop' => sub {
            before all => sub {
                $command = 'command test repeat 3 times left done end';
            };
            it_should_behave_like 'learned';
        };

        describe 'while loop' => sub {
            before all => sub {
                $command = << '__EOF__';
command test
while not facing West
    left
done
end
__EOF__
            };
            it_should_behave_like 'learned';
        };
    };

    describe 'unknown' => sub {
        it 'is propagated' => sub {
            my $command = << '__EOF__';
command test
while not facing West
    right
done
end
__EOF__
            my ($parsed, $unknown) = $p->parse($command);
            cmp_deeply $unknown, { right => 1 };

            $r->_learn(%$parsed);
        };
    };

    describe 'negation' => sub {
        it 'runs' => sub {
            my ($to_wall) = $p->parse(<< '__EOF__');
command to-wall
while there isn't a wall
    forward
done
end
__EOF__

            $r->_learn(%$to_wall);
            $r->_run([ ['c', 'to-wall'] ]);
            $r->step while $r->is_running;

            cmp_methods $r, [ y => 4,
                              facing => 'W',
                            ];
        };
    };

    describe 'nested if with unknown' => sub {
        it 'runs' => sub {
            $r->_learn(
                %{ ($p->parse('command right repeat 3 x left done end'))[0] });
            my ($parse, $unknown) = $p->parse(<< '__EOF__');
command to-north
    repeat 3 x
        if not facing North
            right
        else
            stop
        done
    done
end
__EOF__

            my ($command_name, $command_def) = %$parse;
            $r->_learn($command_name, $command_def);
            cmp_deeply $unknown, { right => 1 };
            cmp_methods $r, [ map { [ 'knows', $_ ] => bool(1) }
                              qw( right to-north )];

            $r->_run([ ['c', 'to-north'] ]);
            $r->step while $r->is_running;
            is $r->direction, 'N';
        };
    };

    describe 'dropping' => sub {

        it 'runs' => sub {
            $r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1, 'N');
            my ($d9_ss, $unknown) =  $p->parse(<< '__EOF__');
command safe-step
    if there's no wall
        forward
    done
end
command drop9
    repeat 4 times
        repeat 2 times
            drop-mark
        done
    done
    pick-mark
    repeat 2 x
        drop-mark
    done
end
__EOF__

            for my $name (keys %$d9_ss) {
                $r->_learn($name, $d9_ss->{$name});
            }

            cmp_deeply $unknown, {};

            $r->_run([ ['c', 'drop9' ] ]);
            $r->step while $r->is_running;
            is $r->cover, 9;

            $r->run('left');
            $r->step while $r->is_running;
            is $r->direction, 'W';
        };

    };

    describe 'core' => sub {
        it 'runs directly' => sub {
            $r->set_grid('Karel::Grid'->new( x => 1, y => 1 ), 1, 1, 'N');
            $r->run('left');
            $r->step while $r->is_running;
            is $r->direction, 'W';
        };
    };

    describe 'comments' => sub {
        they 'are ignored' => sub {
            my $code = << '__EOF__';
command run
# testing comment 'blah'
    while there's no # wait for it!
                     wall
        forward
    done
end
__EOF__

            my ($with_comment)    = $p->parse($code);
            my ($without_comment) = $p->parse(do {
                (my $code2 = $code) =~ s/#.*\n?//g;
                $code2
            });
            cmp_deeply $with_comment, $without_comment;
        };
    };
};

describe 'failures' => sub {

        my @valid = qw( alpha left forward drop_mark pick_mark stop
                        repeat while if octothorpe space );

        my ($E, $command, $expected_exception);
        shared_examples_for 'failure' => sub {
            it fails => sub {
                my $p = 'Karel::Parser'->new;
                trap { $p->parse($command) };
                $E = $trap->die;
                isa_ok $E, 'Karel::Parser::Exception';
                cmp_deeply $E, noclass($expected_exception);
            };
        };

        describe 'unfinished body' => sub {
            before all => sub {
                $command = << '__EOF__';
command wrong
while there's a wall
  forward
__EOF__

                $expected_exception = { last_completed => 'forward',
                                        expected => bag(@valid, 'done'),
                                        pos => [ 3, 11 ],
                                    };
            };
            it_should_behave_like 'failure';
        };

        describe 'missing end' => sub {
            before all => sub {
                $command = << '__EOF__';
command wrong
while there's a wall
  forward
done
__EOF__
                $expected_exception = { last_completed => re(qr/while .* done/xs),
                                        expected => bag(@valid, 'end'),
                                        pos => [ 4, 6 ],
                                    };
            };
            it_should_behave_like 'failure';
        };
    };

runtests();
