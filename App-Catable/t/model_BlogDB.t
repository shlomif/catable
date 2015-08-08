#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 18;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $posts_rs = $schema->resultset('Entry');

    my $date = DateTime->new(
        year => 2009,
        month => 6,
        day => 30,
        hour => 16,
        minute => 5,
        second => 0,
    );

    my $update_date = DateTime->new(
        year => 2009,
        month => 7,
        day => 1,
        hour => 10,
        minute => 44,
        second => 57,
    );

    my $post_id;

    {
        my $new_post = $posts_rs->create(
            {
                title => "A Cute Cat",
                body => <<'EOF',
<p>
<a href="http://geminigeek.com/blog/archives/2006/09/that-cat-is-cute/">Check
out this post</a> about a cute cat. Well, it's not the cutest cat ever
(Altreus' cat is cuter), but it's still pretty cute.
</p>
EOF
                pubdate => $date,
                update_date => $update_date,
                can_be_published => 1,
            }
        );

        # TEST
        ok ($new_post, "Post could be initialised.");

        $post_id = $new_post->id();
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        # TEST
        is ($cats_post->title(), "A Cute Cat", "Existing Post Title is OK.");

        # TEST
        like (
            $cats_post->body(),
            qr{\Qhttp://geminigeek.com/blog/\E},
            "Existing Post Body is OK."
        );

        # TEST
        is ($cats_post->pubdate->year(), 2009, "Year is OK.");

        # TEST
        is ($cats_post->pubdate->month(), 6, "Month is OK.");

        # TEST
        is (
            $cats_post->update_date->month(), 7,
            "update_date Month is OK."
        );

        # TEST
        is (
            $cats_post->update_date->second(), 57,
            "update_date Second field is OK."
        );

        # TEST
        is (
            $cats_post->update_date->day(), 1,
            "update_date Second field is OK."
        );

        # TEST
        is (
            $cats_post->update_date->year(), 2009,
            "update_date Year field is OK."
        );

    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        $cats_post->update_date(
            DateTime->new(
                year => 2009,
                month => 7,
                day => 5,
                hour => 14,
                minute => 0,
                second => 0,
            )
        );

        $cats_post->update();
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        # TEST
        is ($cats_post->update_date->day(), 5,
            "Day changed",
        );

        # TEST
        is ($cats_post->update_date->hour(), 14,
            "Hour changed.",
        );

        # TEST
        is ($cats_post->update_date->minute(), 0,
            "Hour changed.",
        );
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        # TEST
        is ($cats_post->title(), "A Cute Cat", "Existing Title is OK.");

        $cats_post->title("OMG! Ponies");

        # TEST
        is ($cats_post->title(), "OMG! Ponies", "Title changed");

        $cats_post->update();

        # TEST
        is ($cats_post->title(), "OMG! Ponies",
            "Title is still changed after update"
        );
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        # TEST
        ok ($cats_post, "Could find cat's post");

        # TEST
        is ($cats_post->title(), "OMG! Ponies", "Title has changed after update.");
    }


}
