#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 25;

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

# TEST:$c=0;
sub _add_post
{
    my $mech = shift;
    my $fields = shift;
    my $blurb_base = shift;

    my $blog = "usersblog";

    # TEST:$c++;
    $mech->get_ok("http://localhost/blog/${blog}/posts/add",
        "$blurb_base - get to the posts add page."
    );

    # TEST:$c++;
    $mech->submit_form_ok(
        { 
            fields =>
            {
                post_blog => $blog,
                can_be_published => 1,

                post_body => $fields->{post_body},
                post_title => $fields->{post_title},
                tags => join(",", @{$fields->{tags}}),
            },
            button => "preview",
        },
        "Submitting the preview form",
    );

    # TEST:$c++;
    $mech->submit_form_ok(
        {
            button => "submit",
        },
        "Submitting the submit form",    
    );
}
# TEST:$add_post=$c;

{
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    $mech->get("http://localhost/blog/usersblog/posts/add");

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
 
    # TEST*$add_post
    _add_post(
        $mech,
        {
            post_body => "<p>This is the second post.</p>",
            post_title => "SECOND POST!!!1",
            tags => [qw(second post)],
        },
        "Second post",
    );

    # TEST*$add_post
    _add_post(
        $mech,
        {
            post_body => <<'EOF',
<p>The third post about cats and what's in between</p>
<p>Enjoy the <a href="http://en.wiktionary.org/wiki/kitten">English wiktionary 
definition of "kitten"</a>.</p>
EOF
            post_title => "Third post about cats in a row.",
            tags => [qw(cat kitten third post)],
        },
        "Third post - wiktionary kitten",
    );

    # TEST:$access_second_post=2;
    my $access_second_post = sub {
        $mech->get_ok("http://localhost/posts/list", "List of posts");

        $mech->follow_link_ok(
            {
                text_regex => qr{SECOND POST},
            },
            "Can access the second post for finding the links."
        );
    };

    # TEST*$access_second_post
    $access_second_post->();

    # TEST
    $mech->follow_link_ok(
        {
            url_regex => qr{Previous: Grey and White Cat},
        },
        "Follow the link to the previous post.",
    );

    # TEST
    $mech->content_like(qr{Kit Kit Catty Skooter}, "Went to the first post.");
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
