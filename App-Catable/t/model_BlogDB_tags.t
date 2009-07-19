use strict;
use warnings;
use Test::More tests => 25;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $posts_rs = $schema->resultset('Post');
    my $tags_rs = $schema->resultset('Tag');
    my $assoc_rs = $schema->resultset('PostTagAssoc');

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
                pubdate => DateTime->new(
                    year => 2009,
                    month => 6,
                    day => 30,
                    hour => 16,
                    minute => 5,
                    second => 0,
                ),
                update_date => DateTime->new(
                    year => 2009,
                    month => 7,
                    day => 1,
                    hour => 10,
                    minute => 44,
                    second => 57,
                ),
                can_be_published => 1,
            }
        );

        # TEST
        ok ($cat_post, "Post could be initialised.");

        $post_id = $cat_post->id();

        my $cats_tag = $tags_rs->find_or_create(
            {
                label => "cats",
            }
        );

        # TEST
        ok ($cats_tag, "Cat tag was initialiased.");

        my $blogging_tag = $tags_rs->find_or_create(
            {
                label => "blogging",
            }
        );

        # TEST
        ok ($blogging_tag, "Cat tag was initialiased.");
        
        # TEST
        ok ($cats_tag->id() != $blogging_tag->id(),
            "The cats and blogging tags are different."
        );

        # TEST
        is ($cats_tag->label(), "cats", "cats tag has proper label.");

        {

            my $assoc1 = $assoc_rs->find_or_create(
                {
                    tag => $cats_tag,
                    post => $cat_post,
                }
            );

            # TEST
            ok ($assoc1, "Initialised an association");
        }

        {
            my $cat_post_tags_rs = $cat_post->tags_rs();

            # TEST
            ok ($cat_post_tags_rs, 
                "Post->tags_rs() returned a proper result set."
            );

            my $tag1 = $cat_post_tags_rs->next();
            # TEST
            is ($tag1->label(), "cats", 
                "Got the right label for the first tag"
            );

            # TEST
            ok (!defined($cat_post_tags_rs->next()),
                "No more tags",
            );
        }

        my $nouv_post = $posts_rs->create(
            {
                title => "Nouveau",
                body => <<'EOF',
<p>
Having seen <a href="http://nouveau.freedesktop.org/wiki">Nouveau</a>,
the open source 3-D drivers for Nvidia cards, mentioned in 
<a href="http://lwn.net/">Linux Weekly News</a> and recalling 
that I wanted to help work on them myself, I decided to use some of my
free time to give it a try.
</p>
EOF
                pubdate => DateTime->new(
                    year => 2009,
                    month => 7,
                    day => 5,
                    hour => 16,
                    minute => 5,
                    second => 0,
                ),
                update_date => DateTime->new(
                    year => 2009,
                    month => 7,
                    day => 7,
                    hour => 10,
                    minute => 44,
                    second => 57,
                ),
                can_be_published => 1,
            }
        );

        # TEST
        ok ($nouv_post, "Post could be initialised.");

        {
            my $nouv_post_tags_rs = $nouv_post->tags_rs();

            # TEST
            ok ($nouv_post_tags_rs, '$nouveau->tags_rs() is true.');

            # TEST
            ok (!defined($nouv_post_tags_rs->next()), 
                '$nouv_post_tags_rs returns 0 results.'
            );
        }

        $nouv_post->add_tags(
            {
                tags => [$cats_tag, $blogging_tag],
            }
        );

        {
            my $nouv_post_tags_rs = $nouv_post->tags_rs();

            # TEST
            ok ($nouv_post_tags_rs, '$nouveau->tags_rs() is true.');

            my $tag1 = $nouv_post_tags_rs->next();

            # TEST
            is ($tag1->label(), "blogging", "First tag is blogging.");

            my $tag2 = $nouv_post_tags_rs->next();

            # TEST
            is ($tag2->label(), "cats", "Second tag is blogging.");

            # TEST
            ok (!defined($nouv_post_tags_rs->next()), 
                '$nouv_post_tags_rs returns 2 results.'
            );
        }

        {
            my $cat_post_tags_rs = $cat_post->tags_rs();

            # TEST
            ok ($cat_post_tags_rs, 
                "CatPost->tags_rs() returned a proper result set 2nd time."
            );

            my $tag1 = $cat_post_tags_rs->next();
            # TEST
            is ($tag1->label(), "cats", 
                "Got the right label for the first tag 2nd time"
            );

            # TEST
            ok (!defined($cat_post_tags_rs->next()),
                "No more CatsPost->tags - 2nd time",
            );
        }

        my $dogs_tag = $tags_rs->find_or_create(
            {
                label => "dogs",
            }
        );

        my $ferrets_tag = $tags_rs->find_or_create(
            {
                label => "ferrets",
            }
        );

        my $france_tag = $tags_rs->find_or_create(
            {
                label => "france",
            }
        );

        my $food_tag = $tags_rs->find_or_create(
            {
                label => "food",
            }
        );

        my $horses_tag = $tags_rs->find_or_create(
            {
                label => "horses",
            }
        );

        my $zebras_tag = $tags_rs->find_or_create(
            {
                label => "zebras",
            }
        );

        my $foxes_tag = $tags_rs->find_or_create(
            {
                label => "foxes",
            }
        );

        my $hawks_tag = $tags_rs->find_or_create(
            {
                label => "hawks",
            }
        );

        my $ducks_tag = $tags_rs->find_or_create(
            {
                label => "ducks",
            }
        );

        my $llamas_tag = $tags_rs->find_or_create(
            {
                label => "llamas",
            }
        );

        $nouv_post->clear_tags();

        {
            my $nouv_post_tags_rs = $nouv_post->tags_rs();

            # TEST
            ok ($nouv_post_tags_rs, '$nouveau->tags_rs() is true.');

            # TEST
            ok (!defined($nouv_post_tags_rs->next()),
                "nouv posts now has no tags."
            );
        }

        {
            my $cat_post_tags_rs = $cat_post->tags_rs();

            # TEST
            ok ($cat_post_tags_rs, 
                "CatPost->tags_rs() after NouvPost->tags_del()"
            );

            my $tag1 = $cat_post_tags_rs->next();
            # TEST
            is ($tag1->label(), "cats", 
                "Got tag after NouvPost->tags_del()" 
            );

            # TEST
            ok (!defined($cat_post_tags_rs->next()),
                "No more CatsPost->tags - after NouvPost->tags_del()", 
            );
        }
    }
}
