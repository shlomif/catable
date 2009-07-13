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
