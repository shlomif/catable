package App::Catable::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

App::Catable::Controller::Login - Catalyst Login Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 openid

Display the openid authentication form.

=cut

sub openid : Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'login/openid.tt2';

    return;
}

=head2 $self->index($c)

The http://localhost:3000/login/ URL.

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched App::Catable::Controller::Login in Posts.');
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
