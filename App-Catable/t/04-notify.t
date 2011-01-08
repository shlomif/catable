#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);

use lib 't/lib/for-notify';
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'App::Catable');
$mech->get_ok('/notify/hello_world');
$mech->content_contains('Hello, world!');
