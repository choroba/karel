requires warnings            => 0;
requires strict              => 0;
requires 'namespace::clean'  => 0;
requires Moo                 => 0;
requires Carp                => 0;
requires 'Moo::Role'         => 0;
requires feature             => 0;
requires utf8                => 0;
requires 'Syntax::Construct' => 0;
requires parent              => 0;
requires Exporter            => 0;
requires 'Module::Load'      => 0;
requires 'Marpa::R2'         => 0;
requires 'List::Util'        => 0;
requires Cwd                 => 0;
requires constant            => 0;
requires Clone               => 0;

on test => sub {
   requires 'Test::Spec'      => 0;
   requires 'Test::Exception' => 0;
}