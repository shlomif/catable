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
    $mech->get_ok("http://localhost/posts/add");

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                body => "<p>Kit Kit Catty Skooter</p>",
                title => "Grey and White Cat",
            },
            button => "preview",
        },
        "Submitting the preview form",
    );

    # TEST
    $mech->submit_form_ok(
        {
            button => "submit",
        },
        "Submitting the submit form",    
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

{
    sleep(1);
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok("http://localhost/posts/add");

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                body => 
    qq{<p><a href="http://www.shlomifish.org/">Shlomif Lopmonyotron</a></p>},
                title => "Link to Shlomif Homepage",
                tags => "perl, catable, catalyst, cats",
            },
            button => "preview",
        },
        "Submitting the preview form",
    );

    # TEST
    is ($mech->value("tags"),
        "perl, catable, catalyst, cats",
        "Keywords is OK on submitted form.",
    );

    # TEST
    $mech->submit_form_ok(
        {
            button => "submit",
        },
        "Submitting the submit form",    
    );

    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{New Post},
        },
        "Following the link to the /show URL homepage"
    );

    # TEST
    ok ($mech->find_link(
            url => "http://www.shlomifish.org/",
            text_regex => qr{Lopmonyotron},
        ),
        "Link to the page."
    );
}

