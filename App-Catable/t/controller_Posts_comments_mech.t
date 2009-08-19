#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;

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
                post_body => <<'EOF',
<p>
I've been chatting on Instant Messaging today, and accidently typed "lough"
instead of "laugh". I noticed the spell checker did not highlight it when
I corrected my mistake and decided to check what it means. Here's
<a href="http://www.google.com/search?hl=en&amp;lr=&amp;ie=UTF-8&amp;oe=UTF-8&amp;c2coff=1&amp;safe=off&amp;defl=en&amp;q=define:lough&amp;sa=X&amp;oi=glossary_definition&amp;ct=title">the definition of "lough"</a> -
it's Irish for "lake". 
</p>

<p>
It reminded me of "loch" (which is the Scottish Gaelic equivalent) 
and the English word "lake" so I checked their etymologies on m-w.com. Turns
out they all stem from the same root, which is common in many 
<a href="http://en.wikipedia.org/wiki/Indo-European_languages">Indo-European 
languages</a>.
</p>

<p>
I normally do not recall new words that I encounter, but I think I'll remember
this one. Of course, it seems too obscure to be useful.
</p>
EOF
                post_title => "Word of the Day: Lough",
                can_be_published => 1,
                post_blog    => 'usersblog',
            },
            button => "preview",
        },
        "Submitting the preview form",
    );

    # TEST
    $mech->content_like(
        qr{<textarea[^>]*>.*?I normally do not recall new.*?</textarea>}ms,
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
    $mech->follow_link_ok(
        {
            text => "the New Post",
            url_regex => qr{/posts/show},
        },
        "Followed the link to the new post",
    );

    # TEST
    like( $mech->content, 
          qr/Word of the Day: Lough/, 
          "Contains the submitted post" );

    my $post_uri = $mech->uri();

    # TEST
    $mech->submit_form_ok(
        { 
            fields =>
            {
                body => <<'EOF',
<a href="http://www.gimp.org/">GIMP</a> - an image manipulation program.
EOF
                title => "GIMP - the GNU Image Manipulation Program",
            },
            button => "preview",
            form_id => "add-comment-form"
        },
        "Submitting the preview form",
    );

    # TEST
    like(
        $mech->content(),
        qr{GIMP - the GNU Image Manipulation Program},
        "Contains the preview title."
    );

    # TEST
    $mech->get_ok($post_uri, "Browsing again");

    # TEST
    like(
        $mech->content(),
        qr{GIMP - the GNU Image Manipulation Program},
        "Content matches the post."
    );

    # TEST
    $mech->html_lint_ok(
        "Checking the Post page with the comment for HTML validity."
    );
}

