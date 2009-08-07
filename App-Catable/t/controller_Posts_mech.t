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

    $mech->get("http://localhost/blog/usersblog/posts/add");

    #TEST
    is( $mech->status, 402, "Cannot add post when not logged in" );

    login( $mech, "altreus", "password" );

    $mech->get("http://localhost/blog/usersblog/posts/add");

    #TEST
    is( $mech->status, 402, "This is not my blog!" );

    logout( $mech );
    login( $mech, "user", "password" );

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

sub login {
    my $mech     = shift;
    my $username = shift;
    my $password = shift;

    $mech->get( "http://localhost/login" );
    
    $mech->submit_form(
        fields =>
        {
            user => $username,
            pass => $password,
        },
        button => "submit",
    );
}

sub logout {
    my $mech = shift;

    $mech->get( "http://localhost/logout" );
}
