package App::Catable::View::TT;

use strict;
use warnings;

use Catalyst::View::TT 0.35;

use base 'Catalyst::View::TT';

use App::Catable;

sub next_in_rs {
    my ($self, $c, $rs) = @_;

    # Returns "" instead of undef or the next result.
    return $rs->next() || "";
}

__PACKAGE__->config(
    # Change default TT extension
    TEMPLATE_EXTENSION => '.tt2',
    # Set the location for TT files
    INCLUDE_PATH => [
    App::Catable->path_to( 'root', 'src' ),
    ],
    WRAPPER => "wrapper.tt2",
    STRICT => 1,
    expose_methods => [qw/next_in_rs/],
);


=head1 NAME

App::Catable::View::TT - TT View for App::Catable

=head1 DESCRIPTION

TT View for App::Catable. 

=head1 METHODS

=head2 next_in_rs($self, $c, $rs)

An exposed method that is useful to fetch the next result of a 
L<DBIx::Class> resultset. It returns
an empty string (which is still false) instead of undef() as the next result
or the next result if it's a valid result.

Use in a template like so:

    [% WHILE post = next_in_rs(posts_rs) %]

    [%# Do something with 'post' %]

    [% END %]

=head1 SEE ALSO

L<App::Catable>

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
