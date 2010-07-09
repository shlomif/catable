#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema qw(get_user_id_by_name);

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $blogs_rs = $schema->resultset('Blog');

    my $cats_blog = $blogs_rs->create(
        {
            owner_id => get_user_id_by_name($schema, 'user'),
            title => 'All about Cats',
            url => 'catsblog',
            theme => 'default',
        },
    );

    my $foxes_blog = $blogs_rs->create(
        {
            owner_id => get_user_id_by_name($schema, 'user'),
            title => 'Foxes Blog',
            url => 'foxes',
            theme => 'default',
        },
    );

    my $posts_rs = $schema->resultset('Entry');

    my $date = DateTime->new(
        year => 2009,
        month => 6,
        day => 20,
        hour => 16,
        minute => 5,
        second => 0,
    );

    my $post_id;

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
            can_be_published => 1,
        }
    );

    # TEST
    ok ($new_post, "Post could be initialised.");

    $cats_blog->add_to_posts($new_post);

    my $foxes_post = $posts_rs->create(
        {
            title => "Foxkeh",
            body => <<'EOF',
<p>
<a href="http://www.getpersonas.com/en-US/gallery/Foxkeh/Popular">Check
out the Foxkeh personas</a> about Firefox.
</p>
EOF
            pubdate => $date,
            update_date => $date,
            can_be_published => 1,
        }
    );

    # TEST
    ok ($foxes_post, "Post could be initialised.");

    $foxes_blog->add_to_posts($foxes_post);

    my $fox_posts = $posts_rs->by_blogs([$foxes_blog]);

    # TEST
    is ($fox_posts->first->title(), "Foxkeh", "Fox posts");

    my $cat_posts = $posts_rs->by_blogs([$cats_blog]);

    # TEST
    is ($cat_posts->first->title(), "A Cute Cat", "Cats posts",);

    my $both_posts = $posts_rs->by_blogs([$foxes_blog, $cats_blog]);

    # TEST
    is_deeply(
        [sort { $a cmp $b } map { $_->title() } $both_posts->all() ],
        [sort { $a cmp $b } ("A Cute Cat", "Foxkeh")],
        "From both blogs.",
    );
}
