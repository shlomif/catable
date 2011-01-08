package App::Catable::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

App::Catable::Controller::Root - Root Controller for App::Catable

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'index.tt2';

    return;
}

=head2 welcome

Displays the default Catalyst welcome message, which has some useful link.

Access with something like:

http://localhost:3000/welcome

=cut

sub welcome : Local {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );

    return;
}

=head2 $self->signin_openid($c)

Handles the OpenID sign-in. Copy and Pasted from:

L<http://search.cpan.org/perldoc?Catalyst::Plugin::Authentication::Credential::OpenID>

=cut

sub signin_openid : Local {
    my ($self, $c) = @_;

    if ($c->authenticate({}, "openid"))
    {
        $c->persist_user();
        $c->flash(message => "You signed in with OpenID!");
        $c->res->redirect( $c->uri_for('/') );
    }
    else
    {
        $c->flash(message => "Could not authenticate with OpenID");
        $c->response->body( "Could not authenticate with OpenID" );
        # Present OpenID form.
    }
}


=head2 $self->logout($c)

Logs out the currently logged-in user.

http://localhost:3000/logout/

=cut

sub logout : Local {
    my ($self, $c) = @_; 

    $c->logout();
    $c->response->body ("You have been logged out.");

    return;
}

=head2 blog

The action for /blog/*

=cut

sub blog : Chained('/') CaptureArgs(1) {
    my ($self, $c, $blog_name) = @_; 

=for logging
    # Enable in case you want it - otherwise it's just noise on the tests.
    $c->log->debug( ' === Root::blog' );
=cut

    $c->stash->{blog} 
        = $c->forward( '/blogs/load_blog', [$blog_name] );

    if (! $c->stash->{blog} ) {
        $c->res->status(404);
        $c->res->body("Blog $blog_name not found");
        $c->detach;
    }
    return;
}

=head2 post

The action for a single post: /post/*

Note that the actions for these are defined in Controller::Posts to save
fragmenting the code into lots of small files.

=cut

sub post : Chained('/') CaptureArgs(1) {
    my ($self, $c, $post_id) = @_; 

    $c->stash->{post} 
        = $c->forward( '/posts/load_post/', [$post_id] );
    return;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

# Provided so tests can use notify without relying on any other mechanism
sub _test_notify : Local {
	my ($self, $c) = @_;
	$c->add_notification("Hello, world!");
	$c->stash->{'template'} = 'index.tt2';
	return;
}
=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
