use strict;
use warnings;
use Test::More tests => 22;

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

    my $comment2_id;

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

        my $comment2_date = DateTime->new(
            year => 2009,
            month => 7,
            day => 12,
            hour => 9,
            minute => 45,
            second => 9,
        );

        # Create a new comment
        my $comment2 = $comments_rs->create(
            {
                parent => $cats_post,
                title => "Building STAF on Mandriva Cooker (and other Linuxes)",
                body => <<'EOF',
<p>
<a href="http://staf.sourceforge.net/index.php">STAF stands for "Software
Testing Automation Framework"</a> and is a framework for IBM for software
testing. I spent a large amount of the last two days trying to get it up and
running on my Mandriva Cooker Linux system, in order to fullfill
<a href="http://perl.org.il/pipermail/perl/2007-November/009250.html">this
request for a Linux beta-tester</a>.
</p>
EOF
                pubdate => $comment2_date,
                update_date => $comment2_date,
                can_be_published => 1,
            }
        );

        $comment2_id = $comment2->id();
    }

    {
        my $cats_post = $posts_rs->find( { id => $post_id } );

        my $post_comments_rs = $cats_post->comments;

        my $comment1 = $post_comments_rs->next();

        # TEST
        is ($comment1->id(), $comment_id, "Comment #1 ID");

        # TEST
        is ($comment1->title(),
            "Vim Tip: Copying Some Non-Adjacent Lines to a Register",
            "Comment #1 title"
        );

        my $comment2 = $post_comments_rs->next();

        # TEST
        ok ($comment2, "Comment 2 is initialised.");

        # TEST
        is ($comment2->id(), $comment2_id, "Comment #2 ID");

        # TEST
        is ($comment2->title(), 
            "Building STAF on Mandriva Cooker (and other Linuxes)",
            "Comment #2 Title",
        );

        # TEST
        is ($comment2->pubdate()->hour(), 9, "Comment #2 Hour");

        # TEST
        is ($comment2->update_date->minute(), 45, "Comment #2 update minute");

        # TEST
        ok ($comment2->can_be_published(), 
            "Comment #2 can_be_published is True."
        );

    }

}

