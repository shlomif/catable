package App::Catable::Schema::ResultSet::Entry;

use strict;
use warnings;
use base qw( DBIx::Class::ResultSet );

=head1 NAME

App::Catable::ResultSet::Entry - ResultSet class representing Entries.

=head1 SYNOPSIS

    my $posts = App::Catable->model('BlogDB')
                            ->resultset('Entry)
                            ->posts;

    while ( my $post = $posts->next ) {
        # do something with this post.
    }

=head1 DESCRIPTION

A convenience class. ResultSet is designed to be extended, so here's
an extension that deals with the Entry table

=head1 METHODS

=head2 posts

    $rs->posts();

Returns all rows in the result set that are posts, i.e. have no parent.

=cut

sub posts {
    my $self = shift;

    my $me = $self->current_source_alias;

    return $self->search( [
        { "${me}.parent_id" => undef },
        { "${me}.parent_id" => 0 }
    ] );
}

=head2 by_blogs

    $rs->by_blogs( $blog_id_or_object, ... );

Returns a resultset filtered by the blog(s) you specify.

=cut

sub by_blogs {
    my $self = shift;
    my @blogs = @_;

    my $b_e_rs = $self->related_resultset('blog_entries');

    my $me = $b_e_rs->current_source_alias;

    return $b_e_rs->search( {
        "${me}.blog_id" => {
            '-in' => [ map {_blog_id( $_ ) } @blogs ],
        },
    } )->related_resultset('entry');
}

=head2 published_posts

Select only those Entries that are published. This flag only applies
to top-level entries - posts - and not comments, hence the name of the
method. Published also requires that the pubdate is earlier than now.

=cut

sub published_posts {
    my $self = shift;

    my $p_rs = $self->posts;

    my $me = $p_rs->current_source_alias;

    return $p_rs->search( {
        "${me}.can_be_published" => 1,
        "${me}.pubdate" => { "<=" => \"DATETIME('NOW')" },
    });
}

## Makes sure the provided thing is an id, not an object.
sub _blog_id {
    my $blog = shift;

    return ref $blog ? $blog->id : $blog;
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

