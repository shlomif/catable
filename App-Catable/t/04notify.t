#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'App::Catable');
$mech->get_ok('/_test_notify');
$mech->content_contains('Hello, world!');
