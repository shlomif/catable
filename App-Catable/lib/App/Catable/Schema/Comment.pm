package App::Catable::Schema::Comment;

use strict;
use warnings;

=head1 NAME

App::Catable::Schema::Comment - a schema class representing a blog comment.

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB");

    my $posts_rs = $schema->resultset('Post');

    my $post = $posts_rs->find({
        id => 2_400,
        });

    print $post->title();

=head1 DESCRIPTION

This is the comment schema class for L<App::Catable>.

=head1 FIELDS

This field list also comprises a method list, since DBIC
creates accessor methods for each field.

=head2 id

Auto-incremented comment ID.

=head2 title

Each comment can have a title up to 400 chars long.

=head2 body

The body of the blog post is arbitrary text. It is parsed between
DB and display based on selected plugins to deal with markup.

=head2 can_be_published

This is a boolean field that suppresses the publishing of a
comment, in order to allow bloggers to draft posts or to write
private comments.

=head2 pubdate

The date to publish this comment, or the date the post was published.

=head2 parent

The parent post or comment to which this comment belongs.

=head2 update_date

A timestamp for when the post was last updated.

=head1 METHODS

=cut

use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( InflateColumn::DateTime Core ) );
__PACKAGE__->table( 'comment' );
__PACKAGE__->add_columns(
    id => {
        data_type         => 'bigint',
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    title => {
        data_type => 'varchar',
        size => 400,
        is_nullable => 0,
    },
    body => {
        data_type => 'blob',
        is_nullable => 1,
    },
    can_be_published => {
        data_type => 'bool',
        is_nullable => 0,
    },
    pubdate => {
        data_type => 'datetime',
        is_nullable => 0,
    },
    update_date => {
        data_type => 'datetime',
        is_nullable => 0,
    },
    parent_id => {
        data_type         => 'bigint',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key( qw( id ) );
__PACKAGE__->resultset_attributes( { order_by => [ 'pubdate' ] } );
__PACKAGE__->belongs_to(
    parent => 'App::Catable::Schema::Post',
    'parent_id',
);

=head1 SEE ALSO

L<App::Catable::Schema>, L<App::Catable>, L<DBIx::Class>

=head1 AUTHOR

Shlomi Fish L<http://www.shlomifish.org/> .

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

1;
