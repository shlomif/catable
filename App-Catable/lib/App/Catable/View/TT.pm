package App::Catable::View::TT;

use strict;
use base 'Catalyst::View::TT';

use App::Catable;

__PACKAGE__->config(
    # Change default TT extension
    TEMPLATE_EXTENSION => '.tt2',
    # Set the location for TT files
    INCLUDE_PATH => [
    App::Catable->path_to( 'root', 'src' ),
    ],
    WRAPPER => "wrapper.tt2",
);

=head1 NAME

App::Catable::View::TT - TT View for App::Catable

=head1 DESCRIPTION

TT View for App::Catable. 

=head1 SEE ALSO

L<App::Catable>

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
