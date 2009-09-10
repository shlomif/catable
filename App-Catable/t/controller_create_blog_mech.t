#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;

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
            text_regex => qr{login.*?username}i,
        },
        "Followed the link to the registration",
    );

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
    $mech->get_ok("http://localhost/");

    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{Create a new blog}i,
        },
        "Can follow the link to create a new blog",
    );

    # TEST
    $mech->submit_form_ok(
        {
            fields =>
            {
                url => "shlomif-tech",
                title => "Shlomi Fish's Tech Blog",
            },
            button => "create",
        },
        "Submitting the create new blog form",
    );

    # TEST
    $mech->content_like(
        qr{New blog created successfully}i,
    );
    
    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{Go see the blog}i,
        },
        "Can see the new blog",
    );

    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{Add new post}i,
        },
        "Follow the add new post link",
    );

    # TODO : test that the add new post works.
}
