package App::Catable::Schema::Result::Account;

use strict;
use warnings;

use Digest;

=head1 NAME

App::Catable::Schema::Account - a schema class representing an account.

=head1 SYNOPSIS

    my $schema = App::Catable->model("BlogDB");

    my $account_rs = $schema->resultset('Account');

    my $account = $account_rs->find({
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

Auto-incremented user ID.

=head2 url

This is the 'username' for OpenID authentication. If set, the user is an
OpenID user, and the C<username> and C<password> fields will not be set.

=head2 username

This is the username for login using the local user system.

=head2 password

This is the password for login using the local user system.

=head2 homepage

=head2 real_name

=head2 nickname

=head2 age

=head2 gender

These are all optional fields for the user to fill in if they wish.

=head2 last_logon_ts

A timestamp for when the user last successfully logged on.

=head2 ctime

A timestamp for when the account was created.

=head2 mtime

A timestamp for when the account was last updated.

=head1 METHODS

=cut

use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( TimeStamp InflateColumn::DateTime Core ) );
__PACKAGE__->table( 'account' );
__PACKAGE__->resultset_class('App::Catable::Schema::ResultSet::Account');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'bigint',
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    url => {
        data_type         => 'varchar',
        size              => 1024,
        is_nullable       => 1,
    },
    username => {
        data_type         => 'varchar',
        size              => 50,
        is_nullable       => 1,
    },
    password => {
        data_type         => 'char',
        size              => 40,
        is_nullable       => 1,
    },
    homepage => {
        data_type         => 'varchar',
        size              => 1024,
        is_nullable       => 1,
    },
    real_name => {
        data_type         => 'varchar',
        size              => 100,
        is_nullable       => 1,
    },
    nickname => {
        data_type         => 'varchar',
        size              => 100,
        is_nullable       => 1,
    },
    age => {
        data_type         => 'int',
        size              => 3,
        is_nullable       => 1,
    },
    gender => {
        data_type         => 'char',
        size              => 1,
        is_nullable       => 1,
    },
    last_logon_ts => {
        data_type => 'datetime',
        is_nullable => 0,
        set_on_create => 1,
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

__PACKAGE__->might_have(
    blogs => 'App::Catable::Schema::Result::Blog',
    'owner_id',
);
__PACKAGE__->might_have(
    posts => 'App::Catable::Schema::Result::Entry',
    'author_id',
    { where => { 'foreign.parent_id' => 0 }},
);

=head2 new

=head4 Parameters

Hashref containing C<username> and C<password>. You may also pass in a hashref under
the C<options> key. That hashref is used as follows.

The password will be hashed using the SHA-1 algorithm unless you pass in a type in
the C<password_type> hash key.

For convenience, and to make it easier to borrow code, the hashing types supported
are the same as those supported by the Catalyst Authentication plugin's Password
credential type (as of Authentication v0.10011) - C<clear>, C<crypted>,
C<salted_hash>, C<hashed>.

To support the C<salted_hash> and C<hashed> types you need to therefore pass
in either C<password_salt_len> or C<password_pre_salt> and C<password_post_salt>
as well.

To support the C<crypted> type you will have to also provide a C<password_salt>. This
is only used to create the password, and if you're using crypted then I assume you know
how it all works anyway.

Bright sparks will notice, then, that this means you can combine the
C<$c->config('Plugin::Authentication')->{$realm}->{credential}> config to the
Authentication plugin with a C<password_salt> if you are using C<crypted>, and pass
this whole hash as a reference under C<options>.

=cut

sub new {
    my ($class, $args) = @_;

    my $options = delete $args->{options} || {};

    my $self = $class->next::method( $args );

    $options->{password_type}      ||= 'hashed';
    $options->{password_hash_type} ||= 'SHA-1';

    my $password = $self->password;

    if ($options->{'password_type'} eq 'crypted') {
        $password = crypt( $password, $options->{password_salt} );
    }
    elsif ($options->{'password_type'} eq 'salted_hash') {
        require Crypt::SaltedHash;
        my $salt_len = $options->{'password_salt_len'} ? $options->{'password_salt_len'} : 0;

        my $shash = Crypt::SaltedHash->new( salt_len => $salt_len );
        $shash->add( $args->{password} );

        $password = $shash->generate;
    }
    elsif ($options->{'password_type'} eq 'hashed') {
        my $d = Digest->new( $options->{'password_hash_type'} );
        $d->add( $options->{'password_pre_salt'} || '' );
        $d->add( $password );
        $d->add( $options->{'password_post_salt'} || '' );

        my $computed    = $d->clone()->digest;

        # me running tests shows that this is the one that gives us a 40-char string
        $password = unpack( "H*", $computed );
    }

    $self->password( $password );

    return $self;
}

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
