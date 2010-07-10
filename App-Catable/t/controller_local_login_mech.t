#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;

# Lots of stuff to get Test::WWW::Mechanize::Catalyst to work with
# the testing model.

use vars qw($schema);
BEGIN 
{ 
    $ENV{CATALYST_CONFIG} = "t/var/catable.yml";
    use App::Catable::Model::BlogDB; 

    use lib 't/lib';
    use AppCatableTestSchema;

    $schema = AppCatableTestSchema->init_schema(no_populate => 0);
}

use Test::WWW::Mechanize::Catalyst 'App::Catable';

{
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok("http://localhost/");

    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{Login.*username}i,
        }
    );

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                user => "user",
                pass => "bla",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_contains( 'Username or password not recognised', "Login failed - bad pass" );

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                user => "nobody",
                pass => "bla",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_contains( 'Username or password not recognised', "Login failed - bad user" );

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                user => "user",
                pass => "password",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_like(
        qr/Logged in as.*?user.*?Log out/ms, 
        "Seems to be logged in" 
    );

    # TEST
    $mech->content_unlike(
        qr{Login},
        "No links to login since already logged in."
    );
}

