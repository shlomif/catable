use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'App::Catable' }
BEGIN { use_ok 'App::Catable::Controller::Posts' }

ok( request('/posts')->is_success, 'Request should succeed' );


