use strict;
use warnings;
use Test::More tests => 1;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);
