package App::Catable::Controller::Blogs;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

App::Catable::Controller::Blogs - For multiple blogs

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 load_blog

Private action /blogs/load_blog/*

Takes the blog name and returns the Row object for that blog.

    my $blog = $c->forward( '/blog/load_blog/', [$blog_name] );

See also C<blog> in C<App::Catable::Controller::Root>.

=cut

sub load_blog : Private{
    my ($self, $c, $blog_name) = @_;

    my $blog = 
        $c->model('BlogDB')
        ->resultset('Blog')
        ->single({ url => $blog_name});

    return $blog;
}

=head2 $self->create_blog($c)

Creates a new blog. Handles the '/create-blog' URL - accepts no arguments and 
ends the chain.

=cut

sub create_blog : Path('/create-blog') Args(0) FormConfig
{
    my ($self, $c) = @_;

    if( not $c->user_exists ) {
        $c->res->status( 400 );
        $c->res->body( 'You must log in to create a blog' );
    }
    my $form = $c->stash->{form};

    $c->stash->{template} = "create-blog.tt2";
    $c->stash->{'submitted'} = 0;

    if ($form->submitted_and_valid)
    {
        my $params = $form->params;

        $c->model('BlogDB')->resultset('Blog')
            ->create(
                {
                    (map 
                        { $_ => $params->{$_} }
                        (qw(url title))
                    ),
                    theme    => "catable",
                    owner_id => $c->user->id(),
                }
            );

        $c->stash->{'submitted'} = 1;
        $c->stash->{'url'} = $params->{'url'};
    }

    return;
}

=head2 list_posts

Handles the URL C</blog/*>. Chains from C<sub blog> in 
Controller::Root to load the actual blog and ends the chain.

Lists all posts in this blog. Forwards to Controller::Posts to do the
actual hard work.

=cut

sub list_posts : Chained('/blog') PathPart('') Args(0) {
    my ($self, $c) = @_;

    my $blog = $c->stash->{blog};

    # TOOD: Add after test.
    $c->stash->{title} = sprintf("%s - All posts", $blog->title());

    $c->detach( '/posts/list' );
}

=head2 add_post

Handles C</blog/*/posts/add>.

The add action for adding a post to a specific blog, specified in the URL.

Merely forwards control to the C<add> action in the Posts controller.

=cut

sub add_post : Chained('/blog') PathPart('posts/add') 
                  Args(0) {
    my ($self, $c) = @_;
    
    $c->detach( '/posts/add' );
}

=head2 tag

Handles C</blog/*/posts/tag/*>

Forwards control to C</posts/tag/*> (see L<App::Catable::Controller::Posts>),
which is designed to act with or without a blog filtering it.

=cut

sub tag : Chained('/blog') PathPart('posts/tag') CaptureArgs(1) {
    my ($self, $c, $tag) = @_;

    $c->detach( '/posts/tag/', [$tag] );
}

1;

__END__

=head1 AUTHOR

Alastair Douglas L<http://www.grammarpolice.co.uk/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

