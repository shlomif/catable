package App::Catable::Controller::Posts;

use strict;
use warnings;
use base 'Catalyst::Controller';

use DateTime;
use HTML::Scrubber;

=head1 NAME

App::Catable::Controller::Posts - Catalyst Posts Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 add

Add a post.

=cut

sub add : Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template
    # $c->stash->{books} = [$c->model('DB::Book')->all];
    # But, for now, use this code until we create the model later
    $c->stash->{books} = '';

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'posts/add.tt2';

    return;
}

=head2 list

Displays a list of posts:

http://localhost:3000/posts/list

=cut

sub list : Path('list') {
    my ($self, $c) = @_;

    my @posts = $c->model('BlogDB')->resultset('Post')
        ->search( { can_be_published => 1,
                    pubdate => { "<=" => \"DATETIME('NOW')" },
                  } );

    $c->log->debug( sprintf "Found %d posts", scalar @posts );

    $c->stash->{posts} = \@posts;
    $c->stash->{template} = 'posts/list.tt2';

    return;
}

=head2 add_submit

This controller method handles the blog post submission.

=cut

sub add_submit : Path('add-submit') {
    my ($self, $c) = @_;

    my $req = $c->request;

    my $title = $req->param('title');
    my $body = $req->param('body');
    my $tags_string  = $req->param('tags');
    my $can_be_published = $req->param('can_be_published');
    my $is_preview = defined($req->param('preview'));
    my $is_submit = defined($req->param('submit'));

    if (!($is_preview xor $is_submit))
    {
        $c->response->status(404);
        $c->response->body("Cannot submit and preview at once.");
    }
    elsif ($is_preview)
    {
        $c->stash->{template} = "posts/add-preview.tt2";
        $c->stash->{post_title} = $title;
        $c->stash->{post_body} = $body;
        $c->stash->{post_tags} = $tags_string;
        $c->stash->{can_be_published} = $can_be_published ? 1 : 0;
    }
    else
    {
        my $now = DateTime->now();
        # Add the post to the model.
        my $new_post = $c->model('BlogDB::Post')->create(
            {
                title => $title,
                body => $body,
                can_be_published => $can_be_published ? 1 : 0,
                pubdate => $now->clone(),
                update_date => $now->clone(),
            }
        );

        my @tags = 
        (
            grep { m{\A(?:[^[:punct:]\n\r\t]|\-)+\z}ms } 
            split(/\s*,\s*/, $tags_string)
        );

        $new_post->assign_tags(
            {
                tags => \@tags,
            }
        );

        $c->stash->{new_post} = $new_post;
        
        $c->stash->{template} = 'posts/add-submit.tt2';
    }

    return;
}

=head2 tag

Displays a posts listing of a tag . Accepts the tag query as a parameter

http://localhost:3000/posts/tag/cute-cats

=cut

sub tag :Path(tag) :CaptureArgs(1)  {
    my ($self, $c, $tags_query) = @_;

    my $tag = $c->model("BlogDB::Tag")->find({label => $tags_query});

    if (!$tag)
    {
        $c->res->code( 404 );
        $c->res->body( "Tag '$tags_query' not found." );
        $c->detach;
    }

    $c->stash (tag => $tag);

    $c->stash->{template} = 'posts/tag.tt2';
}


=head2 show

Displays a post . Accepts the post number as an argument:

http://localhost:3000/posts/show/1/

=cut

sub show :Path(show) :CaptureArgs(1)  {
    my ($self, $c, $post_id) = @_;

    my $post = $c->model("BlogDB::Post")->find({id => $post_id });

    if (!$post)
    {
        $c->res->code( 404 );
        # TODO : Possible XSS attack here?
        $c->res->body( "Post '$post_id' not found." );
        $c->detach;
    }

    # Taken from the HTML::Scrubber POD.
    my @default = (
        0   =>    # default rule, deny all tags
        {
            '*'           => 1, # default rule, allow all attributes
            'href'        => qr{^(?!(?:java)?script)}i,
            'src'         => qr{^(?!(?:java)?script)}i,
    #   If your perl doesn't have qr
    #   just use a string with length greater than 1
            'cite'        => '(?i-xsm:^(?!(?:java)?script))',
            'language'    => 0,
            'name'        => 1, # could be sneaky, but hey ;)
            'onblur'      => 0,
            'onchange'    => 0,
            'onclick'     => 0,
            'ondblclick'  => 0,
            'onerror'     => 0,
            'onfocus'     => 0,
            'onkeydown'   => 0,
            'onkeypress'  => 0,
            'onkeyup'     => 0,
            'onload'      => 0,
            'onmousedown' => 0,
            'onmousemove' => 0,
            'onmouseout'  => 0,
            'onmouseover' => 0,
            'onmouseup'   => 0,
            'onreset'     => 0,
            'onselect'    => 0,
            'onsubmit'    => 0,
            'onunload'    => 0,
            'src'         => 0,
            'type'        => 0,
        }
    );

    my @rules = (
        script => 0,
        img => {
            src => qr{^(?!http://)}i, # only relative image links allowed
            alt => 1,                 # alt attribute allowed
            '*' => 0,                 # deny all other attributes
        },
    );

    my $scrubber = HTML::Scrubber->new(
        allow => [
            qw(
            a p b i u hr br
            ul ol li dl dt dd
            table tr td th
            h1 h2 h3 h4 h5 h6
            )
        ],
        rules => \@rules,
        default => \@default,
    );

    $c->stash (post => $post);
    $c->stash (scrubber => $scrubber);

    $c->stash->{template} = 'posts/show.tt2';
}

=head2 add_comment

Adds a comment to a post. Accepts a form using post.

http://localhost:3000/posts/add-comment

=cut

sub add_comment :Path(add-comment) {
    my ($self, $c) = @_;

    my $req = $c->request;

    my $title = $req->param('title');
    my $body = $req->param('body');
    my $post_id = $req->param('post_id');

    my $can_be_published = 1;

    my $post = $c->model("BlogDB::Post")->find({id => $post_id });

    if (!$post)
    {
        $c->res->code( 404 );
        # TODO : Possible XSS attack here?
        $c->res->body( "Post '$post_id' not found." );
        $c->detach;
    }

    my $now = DateTime->now();

    my $new_comment = $post->add_comment(
        {
            title => $title,
            body => $body,
            can_be_published => $can_be_published,
            pubdate => $now->clone(),
            update_date => $now->clone(),
        }
    );

    $c->stash (comment => $new_comment);

    $c->stash->{template} = 'posts/add-comment.tt2';

    return;
}

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched App::Catable::Controller::Posts in Posts.');
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
