#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 15;

# Lots of stuff to get Test::WWW::Mechanize::Catalyst to work with
# the testing model.

use vars qw($schema);
BEGIN
{
    # This statement aims to silence perl -w.
    $SQL::Translator::Schema::DEBUG = 0;

    $ENV{CATALYST_CONFIG} = "t/var/catable.yml";
    use App::Catable::Model::BlogDB;

    use lib 't/lib';
    use AppCatableTestSchema;

    $schema = AppCatableTestSchema->init_schema(no_populate => 1);
}

use Test::WWW::Mechanize::Catalyst 'App::Catable';

{
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok(
        "http://localhost/",
        "Got to the front page"
    );

    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{Register.*account}i,
        },
        "Followed the register link",
    );

    # TEST
    $mech->submit_form_ok(
        {
            fields =>
            {
                username => "",
                password => "bla",
                password_check => "bla",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_contains(
        'This field is required',
        "Login failed - did not provide username"
    );

    # TEST
    $mech->submit_form_ok(
        {
            fields =>
            {
                username => "user",
                password => "bla",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_contains(
        'Does not match',
        "Login failed - did not repeat password"
    );

    # TEST
    $mech->submit_form_ok(
        {
            fields =>
            {
                username => "user",
                password => "bla",
                password_check => "flip",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_contains(
        'Does not match',
        "Login failed - wrong repeated password"
    );

    # TEST
    $mech->submit_form_ok(
        {
            fields =>
            {
                username => "user",
                password => "password",
                password_check => "password",
            },
            button => "submit",
        },
        "Submitting the login form",
    );

    # TEST
    $mech->content_like(
        qr/Logged in as.*?user.*?Log out/ms,
        "Seem to be logged in"
    );
}

{
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok("http://localhost/logout");

    # TEST
    $mech->content_contains("You have been logged out", "We have been logged out");
}

{
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok("http://localhost/login");

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
    $mech->content_like( qr/Logged in as.*?user.*?Log out/ms, "Seem to be logged in" );
}
