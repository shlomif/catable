package App::Catable::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use Config::Any;
use List::MoreUtils qw( any );

use App::Catable::Exception::MissingConfigParam;

my $cfg  = Config::Any->load_files({ stems => [ 'conf/dbconfig' ]});

App::Catable::Exception::MissingConfigParam->throw( error => q[Connection string or individual connection parameters not found in DB config file.i] )
    if any { not exists $cfg->{$_} } qw( dsn user password );

__PACKAGE__->config(
    schema_class => 'App::Catable::Schema',
    connect_info => $cfg,
);

