use strict;
use warnings;
use Test::More qw(no_plan);

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'App::Catable');
$mech->get('/not-a-valid-url');
is($mech->status, 404, 'Invalid URL should return 404 status');
