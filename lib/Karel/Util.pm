package Karel::Util;

=head1 Karel::Util

=cut

use warnings;
use strict;

use Carp;
use parent qw( Exporter );
our @EXPORT_OK = qw{ positive_int m_to_n };


sub m_to_n {
    my ($i, $m, $n) = @_;
    defined && /[0-9]+/ or croak "$_ should be non negative integer"
        for $i, $m, $n;
    $m <= $i && $i <= $n or croak "$i bigger than $n";
}


sub positive_int {
    my $i = shift;
    m_to_n($i, 1, $i)
}


__PACKAGE__
