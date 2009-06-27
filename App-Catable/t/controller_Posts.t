use strict;
use warnings;
use Test::More tests => 4;

# TEST
BEGIN { use_ok 'Catalyst::Test', 'App::Catable' }
# TEST
BEGIN { use_ok 'App::Catable::Controller::Posts' }

# TEST
ok( request('/posts')->is_success, 'Request should succeed' );
# TEST
ok( request('/posts/add')->is_success, 'Request should succeed' );


