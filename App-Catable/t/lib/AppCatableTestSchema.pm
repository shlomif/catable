package # hide from PAUSE
    AppCatableTestSchema;

use strict;
use warnings;
use App::Catable::Schema;
use YAML;

my $attrs          = {add_drop_table => 1, no_comments => 1};


=head1 NAME

AppCatableTestSchema - Library to be used by DBIx::Class test scripts.

=head1 SYNOPSIS

  use lib qw(t/lib);
  use AppCatableTestSchema;
  use Test::More;

  my $schema = AppCatableTestSchema->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
App::Catable::Schema. Shamelessly stolen from MojoMojoTestSchema which
was in turn shamelessly stolen from DBICTest in the DBIx::Class test suite.

=head1 METHODS

=head2 init_schema

  my $schema = AppCatableTestSchema->init_schema(
    no_deploy=>1,
    no_populate=>1,
  );

This method removes the test SQLite database in t/var/mojomojo.db
and then creates a new, empty database.

This method will call deploy_schema() by default, unless the
no_deploy flag is set.

Also, by default, this method will call populate_schema() by
default, unless the no_deploy or no_populate flags are set.

=cut

sub init_schema {
    my $self = shift;
    my %args = @_;

    my $db_dir = 't/var';
    my $db_file = "$db_dir/catable.db";

    unlink($db_file) if -e $db_file;
    mkdir($db_dir) unless -d $db_dir;

    my $dsn = $ENV{"CATABLE_TEST_SCHEMA_DSN"} || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"CATABLE_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"CATABLE_TEST_SCHEMA_DBPASS"} || '';

    my $schema = App::Catable::Schema->connect( $dsn, $dbuser, $dbpass);
    if ( !$args{no_deploy} ) {
        __PACKAGE__->deploy_schema( $schema );
        __PACKAGE__->populate_schema( $schema ) if( !$args{no_populate} );
    }
    my $config = {
       name => 'App::Catable Test Suite',
       'Model::BlogDB' => {
           connect_info => [ $dsn ],
       },
       authentication => {
           default_realm => 'local',
           use_session => 1,
           realms => {
                local => {
                    credential => {
                        class => 'Password',
                        password_field => 'password',
                        password_type => 'hashed',
                        password_hash_type => 'SHA-1'
                    },
                    store => {
                        class => 'DBIx::Class',
                        user_class => 'BlogDB::Account',
                    }
                }
           }
        },
        'View::Email' => { sender => { mailer => 'Test' } },
    };
    YAML::DumpFile('t/var/catable.yml',$config);
    $ENV{CATALYST_CONFIG} = "t/var/catable.yml";

    return $schema;
}

=head2 deploy_schema

  AppCatableTestSchema->deploy_schema( $schema );

This method does one of two things to the schema.  It can either call
the experimental $schema->deploy() if the DBICTEST_SQLT_DEPLOY environment
variable is set, otherwise the default is to read in the db/sqlite/mojomojo.sql
file and execute the SQL within. Either way you end up with a fresh set
of tables for testing.

=cut

sub deploy_schema {
    my $self = shift;
    my $schema = shift;

    return $schema->deploy();
}

=head2 populate_schema

  DBICTest->populate_schema( $schema );

After you deploy your schema you can use this method to populate
the tables with test data.

=cut

sub populate_schema {
    my $self = shift;
    my $db = shift;

    $db->storage->dbh->do("PRAGMA synchronous = OFF");

    $db->storage->ensure_connected;
    $db->deploy( $attrs );

    $db->create_initial_data;
    $self->create_test_data($db);

    return;
}

sub create_test_data {
    my ($self,$schema) = @_;

    $schema->resultset('Account')->create( {
        username    => 'user',
        password    => 'password', 
    } );

    my $user_id = $schema->resultset('Account')->single( {username => 'user'} )->id;
    $schema->resultset('Blog')->create( {
        owner_id => $user_id,
        title    => 'Blog',
        url      => 'usersblog',
        theme    => 'default',
    } );

    return;
}

=begin Removed

sub create_test_data {
    my ($self,$schema)=@_;
    my @roles = $schema->resultset('Role')->search();
    $schema->populate('PathPermissions',
        [
            [ qw/path role apply_to_subpages create_allowed delete_allowed edit_allowed view_allowed attachment_allowed / ],
            [ '/admin', $roles[0]->id, qw/ no yes yes yes yes yes yes/ ],
            [ '/admin', $roles[0]->id, qw/ yes yes yes yes yes yes yes/ ],
            [ '/help', $roles[0]->id, qw/no yes yes yes yes yes yes/ ],
            [ '/help', $roles[0]->id, qw/ yes yes yes yes yes yes yes/ ],
        ]
    )
}

=end Removed

=cut

1;
