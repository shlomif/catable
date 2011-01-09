#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'App::Catable');
$mech->get_ok('/posts/tag/not-a-real-tag-at-all');
$mech->content_contains('not-a-real-tag-at-all');
#TODO: Test for a real tag
