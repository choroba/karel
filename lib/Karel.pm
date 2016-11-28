package Karel;

use strict;
use warnings;

use Karel::Robot;
use Karel::Grid;

=encoding utf-8

=head1 NAME

Karel - Learn programming with a robot that understands few simple
commands.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';


=head1 SYNOPSIS

This is still work in progress. The simplest text UI is present, you
can run it with

    perl -MKarel::UI::Text -we 'Karel::UI::Text::main()'

=head1 AUTHOR

E. Choroba, C<< <choroba at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to the GitHub repository:
L<https://github.com/choroba/karel/issues>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Karel


You can also look for information at:

=over 4

=item * Meta CPAN

L<http://metacpan.org/pod/Karel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Karel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Karel>

=item * Search CPAN

L<http://search.cpan.org/dist/Karel/>

=back


=head1 ACKNOWLEDGEMENTS

Karel Čapek, the author of R.U.R. (1920).

=head1 LICENSE AND COPYRIGHT

Copyright 2015 - 2016 E. Choroba.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

__PACKAGE__
