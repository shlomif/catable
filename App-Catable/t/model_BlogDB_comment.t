use strict;
use warnings;
use Test::More tests => 14;

# TEST
BEGIN { use_ok 'App::Catable::Model::BlogDB' }

use lib 't/lib';
use AppCatableTestSchema;

use DateTime;

my $schema = AppCatableTestSchema->init_schema(no_populate => 0);

{
    my $posts_rs = $schema->resultset('Post');

    my $comments_rs = $schema->resultset('Comment');

    # TEST
    ok ($comments_rs, "There's a Comment result-set.");

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

    my $comment_id;

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        my $comment_date = DateTime->new(
            year => 2009,
            month => 7,
            day => 10,
            hour => 8,
            minute => 30,
            second => 5,
        );

        my $new_comment = $comments_rs->create(
            {
                parent => $cats_post,
                title => "Vim Tip: Copying Some Non-Adjacent Lines to a Register",
                body => <<'EOF',
<p>
Here's a vim tip on how to copy some non adjacent lines to a register 
(<tt>"r</tt>), but first the story that made me find out about how to
do it exactly. I need to add full POD (Perl's documentation format) 
coverage to a Perl module I inherited. What it means is that every
top-level function (or at least those that do not start with a "_") should
have their own entries. In Perl the function definitions goes like that:
</p>

<pre>
sub first_function {

}
</pre>
EOF
                pubdate => $comment_date,
                update_date => $comment_date,
                can_be_published => 0,
            },
        );

        # TEST
        ok ($new_comment, "Comment was initialised.");

        $comment_id = $new_comment->id();
    }

    {
        my $comment = $comments_rs->find( { id => $comment_id } );

        # TEST
        ok ($comment, "Comment was found.");

        # TEST
        is ($comment->title(), 
            "Vim Tip: Copying Some Non-Adjacent Lines to a Register",
            "Comment title is OK."
        );

        # TEST
        like ($comment->body(),
            qr{I need to add full POD},
            "Comment body() is OK."
        );

        # TEST
        is ($comment->pubdate->hour(), 8, "comment->pubdate->hour() is OK.");

        my $parent_post = $comment->parent();

        # TEST
        ok ($parent_post, "Parent post for comment is valid");

        # TEST
        is ($parent_post->id(), $post_id, 
            "Parent post has the right post ID",
        );

        # TEST
        is ($parent_post->title(), "A Cute Cat", "parent post title is OK.");

        # TEST
        like (
            $parent_post->body(), qr{\Qhttp://geminigeek.com/\E}, 
            "body is OK.",
        );
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        my $post_comments_rs = $cats_post->comments;

        my $comment1 = $post_comments_rs->next();

        # TEST
        is ($comment1->id(), $comment_id, "Comment of results set ID");

        # TEST
        is ($comment1->title(),
            "Vim Tip: Copying Some Non-Adjacent Lines to a Register",
            "Comment of comment result set is OK."
        );
    }
}

