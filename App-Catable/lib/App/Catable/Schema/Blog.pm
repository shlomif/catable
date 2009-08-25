package App::Catable::Schema::Blog;

use strict;
use warnings;

=head1 NAME

App::Catable::Schema::Blog - a schema class representing an entire blog!

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB");

    my $blog_rs = $schema->resultset('Blog');

    my $blog = $blog_rs->find({
        id => 2_400,
        });

    print $blog->display_name();

=head1 DESCRIPTION

This class holds meta data about an entire blog. It is intended for use
on a site which holds multiple blogs by providing a foreign key relation
to all other tables whose data may be associated with an individual blog.

In other words, this table is the table that other tables refer to when
they say "blog_id".

=head1 FIELDS

This field list also comprises a method list, since DBIC
creates accessor methods for each field.

=head2 id

Auto-incremented blog ID.

=head2 owner

This is the user id of the user that owns the blog. This is why we store
OpenID users in the account table.

=head2 url

This is the path part that will identify this user's blog. Whether this
is generated or selected by the user can be left up to the sysadmin of
the Catable installation.

=head2 title 

This is the blog title and is (may be) printed on the blog's page.

=head2 theme

This is the CSS style used by the blog.

=head2 ctime

The datetime the blog was created.

=head2 mtime

The datetime the blog info was modified (not the blog posts etc)

=head2 visitor_can_set_theme

B<NOT YET IMPLEMENTED>

This is a nice-to-have that I may implement, which will alert the template
engine to the fact that the blog owner wishes the visitor to be able to
select the CSS style.

This may become a list.

=head1 METHODS

=cut

use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( TimeStamp InflateColumn::DateTime Core ) );
__PACKAGE__->table( 'blog' );
__PACKAGE__->add_columns(
    id => {
        data_type         => 'bigint',
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    owner => {
        data_type         => 'bigint',
        is_nullable       => 0,
    },
    url => {
        data_type         => 'varchar',
        size              => 32,
        is_nullable       => 0,
    },
    title => {
        data_type         => 'varchar',
        size              => 255,
        is_nullable       => 0,
    },
    theme => {
        data_type         => 'varchar',
        size              => 1024,
        is_nullable       => 0,
    },
    ctime => {
        data_type => 'datetime',
        is_nullable => 0,
        set_on_create => 1,
    },
    mtime => {
        data_type => 'datetime',
        is_nullable => 0,
        set_on_create => 1,
        set_on_update => 1,
    },
);
__PACKAGE__->set_primary_key( qw( id ) );
__PACKAGE__->add_unique_constraint ( [ 'url' ]);

__PACKAGE__->has_one(qw( owner App::Catable::Schema::Account ));
__PACKAGE__->has_many(
    posts =>
    "App::Catable::Schema::Post",
    "blog"
);

=head1 SEE ALSO

L<App::Catable::Schema>, L<App::Catable>, L<DBIx::Class>

L<App::Catable::Schema::Post>

=head1 AUTHOR

Alastair Douglas L<www.grammarpolice.co.uk>

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

1;
