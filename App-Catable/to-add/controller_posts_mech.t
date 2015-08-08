#
#===============================================================================
#
#         FILE:  to-add.t
#
#  DESCRIPTION:  #
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (),
#      COMPANY:
#      VERSION:  1.0
#      CREATED:  07/08/09 21:29:37
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

{
    sleep(1);
    my $mech = Test::WWW::Mechanize::Catalyst->new;

    # TEST
    $mech->get_ok("http://localhost/blog/usersblog/posts/add");

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

    my $post_uri = $mech->uri();

    # TEST
    ok ($mech->find_link(
            url => "http://www.shlomifish.org/",
            text_regex => qr{Lopmonyotron},
        ),
        "Link to the page."
    );

    # TEST
    $mech->follow_link_ok(
        {
            url => "http://localhost/blog/usersblog/posts/tag/cats",
            text => "cats",
        },
        "Following the link to the cats tag",
    );

    # TEST
    $mech->follow_link_ok(
        {
            url => "$post_uri",
            text_regex => qr{Link to Shlomif Homepage},
        },
        "Link exists back to the post.",
    );

    # TEST
    is(
        ($mech->uri() . ""),
        "$post_uri",
        "Same URL as before",
    );
}

