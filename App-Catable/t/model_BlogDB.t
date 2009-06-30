use strict;
use warnings;
use Test::More tests => 6;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $posts_rs = $schema->resultset('Post');

    my $date = DateTime->new(
        year => 2009,
        month => 6,
        day => 30,
        hour => 16,
        minute => 5,
        second => 0,
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
                update_date => $date,
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
    }
}
