package App::Catable::Controller::Posts;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

use DateTime;
use HTML::Scrubber;

=head1 NAME

App::Catable::Controller::Posts - Catalyst Posts Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 add

Add a post to *any* blog that the user is able to add a post to. 

http://localhost:3000/posts/add

=cut

sub add : Local FormConfig
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    $form->get_field({name => "post_blog"})
        ->options(
            [
                map { +{ label => $_->title(), value => $_->title(), } }
                ($c->model("BlogDB::Blog")->search({owner => $c->user->id()}))
            ],
        );

    # Commenting out because it's not needed.
    # $form->process($c->req->params);
    $form->process($c->req);

    # Idea: /posts/add would show a page wherein the user can add a post
    # to any blog they own, i.e. show a generic add form with a list of
    # available blogs as well.
    # Then /blog/blog-name/posts/add would show just the add form for that
    # blog.

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'posts/add.tt2';

    if ($form->submitted_and_valid && $c->req->params->{submit})
    {
        
        $c->stash->{blog} =
            $c->model("BlogDB::Blog")
              ->find({title => $c->req->params->{'post_blog'}})
              ;
        $c->detach('add_submit', [$form]);
    }

    return;
}

=head2 add_to_blog

The add action for adding a post to a specific blog, specified in the URL.

http://localhost:3000/blog/$blog_name/posts/add

=cut

sub add_to_blog : Chained('/blog/load_blog') PathPart('posts/add') 
                  Args(0) FormConfig('posts/add') {
    my ($self, $c) = @_;
    
    my $form = $c->stash->{form};
    
    $c->log->debug( sprintf " add_to_blog user [%d] blog owner [%d]",
                    $c->user->id, $c->stash->{blog}->owner )
        if( $c->user_exists);

    unless ($c->user_exists && $c->user->id == $c->stash->{blog}->owner->id) {
        $c->res->status(402);
        $c->res->body("Unauthorized - this is not your blog.");
    }
    $c->stash->{template} = "posts/add.tt2";

    $c->detach('add_submit', [$form]) if ($form->submitted_and_valid);
    
}

=head2 list

Displays a list of posts:

http://localhost:3000/posts/list

=cut

=begin Removed

sub list : Chained('/blog/load_blog') PathPart('posts/list') Args(0) {
    my ($self, $c) = @_;

    $c->log->debug( sprintf "Blog ID %d", $c->stash->{blog}->id );
    my @posts = $c->model('BlogDB')->resultset('Post')
        ->search( { can_be_published => 1,
                    pubdate => { "<=" => \"DATETIME('NOW')" },
                  } );

    $c->log->debug( sprintf "Found %d posts", scalar @posts );

    $c->stash->{posts} = \@posts;
    $c->stash->{template} = 'posts/list.tt2';

    return;
}

=end Removed

=cut

sub list : Path('list')
{
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

This controller method handles the blog post submission. It should
be able to handle submission from either /posts/add or
/blog/*/posts/add, but currently it only handles /blog/*/posts/add.

=cut

sub add_submit : Private {
    my ($self, $c) = @_;

    my $form    = $c->req->args->[0];
    my $params  = $form->params;
    my $blog_id = $c->stash->{blog}->id;

    my $now = DateTime->now();

    # TODO: iterate over blogs when coming from /posts/add
    $c->stash->{new_post}
    = $c->model('BlogDB')->resultset('Post')
        ->create( {
            title => $params->{post_title},
            body => $params->{post_body},
            can_be_published => ($params->{can_be_published} ? 1 : 0),
            pubdate => $now,
            update_date => $now,
            blog => $blog_id
        } );

    
    $c->stash->{template} = 'posts/add-submit.tt2';

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

=head2 get

A generic get function that loads a post. Has no path of its own, so
cannot be landed on by URL. Chain from this when you're dealing with 
a single post.

http://localhost:3000/blog/blogname/post/1/...

=cut


sub get :Chained('../load_blog') PathPart('post') CaptureArgs(1) {
    my ($self, $c, $post_id) = @_;

    my $post = $c->model("BlogDB::Post")->find({id => $post_id });

    if (!$post)
    {
        $c->res->code( 404 );
        # TODO : Possible XSS attack here?
        $c->res->body( "Post '$post_id' not found." );
        $c->detach;
    }

    $c->stash->{post} = $post;
    return;
}

=head2 show

Creates an endpoint for L<"get">. This sets up the default action to show
the post.

http://localhost:3000/blog/blogname/post/1/

=cut

=head2 $self->get2()

Handles the '/posts' URL.

=cut

sub get2 :Chained('/') :PathPart('posts') :CaptureArgs(0) {
    my ($self, $c) = @_;

    return;
}

# sub show :Chained(get) PathPart('') Args(0)  {
sub show : Chained('get2') PathPart('show') Args(1)  {
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

sub add_comment :Chained('post') Path('add-comment') {
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
