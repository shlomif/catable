package App::Catable::Controller::Posts;

use strict;
use warnings;
use base 'Catalyst::Controller';

use DateTime;

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

=head2 add_submit

This controller method handles the blog post submission.

=cut

sub add_submit : Path('add-submit') {
    my ($self, $c) = @_;

    my $req = $c->request;

    my $title = $req->param('title');
    my $body = $req->param('body');
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
    }
    else
    {
        my $now = DateTime->now();
        # Add the post to the model.
        my $new_post = $c->model('BlogDB::Post')->create(
            {
                title => $title,
                body => $body,
                pubdate => $now->clone(),
                update_date => $now->clone(),
            }
        );

        $c->stash->{new_post} = $new_post;
        
        $c->stash->{template} = 'posts/add-submit.tt2';
    }

    return;
}


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

    $c->stash (post => $post);
    $c->stash->{template} = 'posts/show.tt2';
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
