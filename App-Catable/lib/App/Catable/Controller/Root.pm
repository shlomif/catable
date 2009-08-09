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

sub blog : Local CaptureArgs(1) {
    my ($self, $c, $blog_name) = @_; 

    $c->stash->{blog} 
        = $c->forward( $c->action_for( '/blog/load_blog/' . $blog_name ));
    return;
}

=head2 post

The action for a single post: /post/*

=cut

sub post : Local CaptureArgs(1) {
    my ($self, $c, $post_id) = @_; 

    $c->stash->{post} 
        = $c->forward( $c->action_for( '/post/load_post/' . $post_id ));
    return;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
