#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

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
    $mech->get_ok("http://localhost/posts/add");

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                post_body => "<p>Kit Kit Catty Skooter</p>",
                post_title => "Grey and White Cat",
                can_be_published => 1,
            },
            button => "preview",
        },
        "Submitting the preview form",
    );


    # TEST
    $mech->content_like(
        qr{<textarea[^>]*>.*?&lt;p&gt;Kit Kit Catty.*?</textarea>}ms,
        "Preview worked.",
    );

    # TEST
    $mech->submit_form_ok(
        {
            button => "submit",
        },
        "Submitting the submit form",    
    );

    # TEST
    $mech->content_like(
        qr{<h1>New Blog Entry Posted Successfully</h1>}ms,
        "Post was submitted successfully"
    );

    # TEST
    $mech->get_ok("http://localhost/posts/list/");

    # TEST
    like(
        $mech->content, 
        qr/Grey and White Cat/, 
        "Contains the submitted body",
    );
}

