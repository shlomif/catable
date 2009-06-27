use strict;
use warnings;
use Test::More tests => 5;

# TEST
BEGIN { use_ok 'Catalyst::Test', 'App::Catable' }
# TEST
BEGIN { use_ok 'App::Catable::Controller::Posts' }

# TEST
ok( request('/posts')->is_success, 'Request should succeed' );

# TEST
ok( request('/posts/add')->is_success, 'add request should succeed' );

# TEST
ok( request('/posts/add-submit')->is_success, 'add-submit request should succeed' );


