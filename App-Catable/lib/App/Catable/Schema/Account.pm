package App::Catable::Schema::Account;

use strict;
use warnings;

=head1 NAME

App::Catable::Schema::Account - a schema class representing an account.

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB");

    my $account_rs = $schema->resultset('Account');

    my $account = $posts_rs->find({
        id => 2_400,
        });

    print $account->display_name();

=head1 DESCRIPTION

This is the account schema class for L<App::Catable>. It represents a login
using OpenID or whatever.

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

__PACKAGE__->load_components( qw( TimeStamp InflateColumn::DateTime Core ) );
__PACKAGE__->table( 'account' );
__PACKAGE__->resultset_class('App::Catable::ResultSet::Account');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'bigint',
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    url => {
        data_type         => 'varchar',
        size              => 1024,
        is_nullable       => 0,
    },
    username => {
        data_type         => 'varchar',
        size              => 50,
        is_nullable       => 1,
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

=head2 $self->display()

The display name for the account - either the username or the OpenID URL. 

=cut

sub display
{
    my $self = shift;

    return $self->username() || $self->url();
}

=head1 SEE ALSO

L<App::Catable::Schema>, L<App::Catable>, L<DBIx::Class>

L<App::Catable::Schema::Post>

=head1 AUTHOR

Shlomi Fish L<http://www.shlomifish.org/> .

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

1;
