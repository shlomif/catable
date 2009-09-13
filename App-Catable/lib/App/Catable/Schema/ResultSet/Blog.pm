package App::Catable::Schema::ResultSet::Blog;

use strict;
use warnings;
use base qw( DBIx::Class::ResultSet );

=head1 NAME

App::Catable::ResultSet::Blog - ResultSet class representing Blogs.

=head1 SYNOPSIS

    my $blog = App::Catable->model('BlogDB')
                            ->resultset('Blog')
                            ->by_user($user);

    while ( my $blog = $blogs->next ) {
        # do something with this blog.
    }

=head1 DESCRIPTION

Convenience methods to deal with Blogs. Extension of the DBIC
ResultSet class.

=head1 METHODS

=head2 by_users

    $rs->by_users( $user, ... );

Returns a resultset for all blogs owned by any of the given array of
users.

=cut

sub by_users {
    my $self = shift;
    my @users = shift;

    return $self->search( {
        owner => {
            '-in' => [ map { _user_id( $_ ) } @users ],
        },
    } );
}

## Make sure users are their IDs.
sub _user_id {
    my $user = shift;

    return ref $user ? $user->id : $user;
}

=head1 SEE ALSO

L<App::Catable::Schema>, L<App::Catable>, L<DBIx::Class>

=head1 AUTHOR

Shlomi Fish L<http://www.shlomifish.org/>

Alastair Douglas L<http://www.podcats.in/>

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, Alastair Douglas 2009.

=cut

1;

__END__

