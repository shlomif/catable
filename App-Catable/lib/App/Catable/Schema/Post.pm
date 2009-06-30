package App::Catable::Schema::Post;

use strict;
use warnings;

=head1 NAME

App::Catable::Schema::Post - a schema class representing a blog post.

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB");

    my $posts_rs = $schema->resultset('Post');

    my $post = $posts_rs->find({
        id => 2_400,
        });

    print $post->title();

=head1 DESCRIPTION

This is the post schema class for L<CPANHQ>.

=head1 METHODS

=cut

use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( Core ) );
__PACKAGE__->table( 'post' );
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
    pubdate => {
        data_type => 'datetime',
        is_nullable => 0,
    },
    update_date => {
        data_type => 'datetime',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key( qw( id ) );
__PACKAGE__->resultset_attributes( { order_by => [ 'pubdate' ] } );
__PACKAGE__->add_unique_constraint( [ 'pubdate' ] );

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
