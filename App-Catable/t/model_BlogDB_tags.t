use strict;
use warnings;
use Test::More tests => 3;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $posts_rs = $schema->resultset('Post');
    my $tags_rs = $schema->resultset('Tag');

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
        my $cat_post = $posts_rs->create(
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
        ok ($cat_post, "Post could be initialised.");

        $post_id = $cat_post->id();

        my $cat_tag = $tags_rs->find_or_create(
            {
                label => "cats",
            }
        );

        # TEST
        ok ($cat_tag, "Cat tag was initialiased.");
    }
}
