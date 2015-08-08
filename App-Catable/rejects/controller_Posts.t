#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use HTTP::Request::Common;

# TEST
BEGIN { use_ok 'Catalyst::Test', 'App::Catable' }
# TEST
BEGIN { use_ok 'App::Catable::Controller::Posts' }

# TEST
ok( request('/posts')->is_success, 'Request to /posts should succeed' );

# TEST
ok( request('/blog/usersblog/posts')->is_success, 'Request should succeed' );

# TEST
ok( !request('/posts/fakeblog/posts')->is_success, 'Fake blog does not exist' );

TODO: {
    local $TODO = "Not yet implemented /posts/add behaviour";

    my $response = request(
        POST(
        "/posts/add",
        [
            preview => 1,
            title => "Here, Kitty, Kitty, Kitty",
            body => "<p>The Kit has landed on its feet.</p>",
        ]
    )
    );

    # TEST
    ok( !request('/posts/add-submit')->is_success,
        'vanilla add-submit request should fail'
    );

    {
        my $response = request(
            POST(
            "/posts/add-submit",
            [
                preview => 1,
                title => "Here, Kitty, Kitty, Kitty",
                body => "<p>The Kit has landed on its feet.</p>",
            ]
        )
        );

        # TEST
        ok(
            $response->is_success(),
            "request with preview, title and body should succeed."
        );
    }
}
