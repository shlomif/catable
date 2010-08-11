#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 19;

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

    my $goto_add_post = sub {
        $mech->get("http://localhost/blog/usersblog/posts/add");
    };

    $goto_add_post->();

    # TEST
    is( $mech->status, 401, "Cannot add post when not logged in" );

    login( $mech, "altreus", "password" );

    $mech->get("http://localhost/blog/usersblog/posts/add");

    # TEST
    is( $mech->status, 401, "This is not my blog!" );

    logout( $mech );
    login( $mech, "user", "password" );

    # TEST
    $mech->get_ok("http://localhost/posts/add");

    {
        my $forms = $mech->forms();

        # TEST
        is (scalar(@$forms), 1, "Only one form in the add page after login.");

        $mech->form_number(1);

        my @buttons = $mech->find_all_inputs(type => "submit");
        
        # TEST
        is_deeply(
            [map { $_->{'value'} } @buttons],
            ["Preview"],
            "Only a preview button at first."
        );
    }

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                post_blog => "usersblog",
                post_body => "<p>Kit Kit Catty Skooter</p>",
                post_title => "Grey and White Cat",
                can_be_published => 1,
                tags => "grey, white, cat",
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

    # TEST
    $mech->get_ok("http://localhost/blog/usersblog");
    
    # TEST
    $mech->follow_link_ok(
        {
            text_regex => qr{\AGrey and White Cat\z},
        },
        "Followed the link to the grey and white cat.",
    );

    # TEST
    like(
        $mech->content, 
        qr{Kit Kit Catty Skooter},
        "Followed to the post OK. Contains the body."
    );

    # TEST
    like(
        $mech->content(),
        qr{<a\s*rel="tag category"\s*href="[^"]+/posts/tag/grey">grey</a>}ms,
        "Contains a link to one of the tags.",
    );
    
    $goto_add_post->();

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                post_blog => "usersblog",
                post_body => "<p>This is the second post.</p>",
                post_title => "SECOND POST!!!1",
                can_be_published => 1,
                tags => "second post",
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

    $goto_add_post->();

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                post_blog => "usersblog",
                post_body => <<'EOF',
<p>The third post about cats and what's in between</p>
<p>Enjoy the <a href="http://en.wiktionary.org/wiki/kitten">English wiktionary 
definition of "kitten"</a>.</p>
EOF
                post_title => "Third post about cats in a row.",
                can_be_published => 1,
                tags => "cat, kitten, third, post",
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
