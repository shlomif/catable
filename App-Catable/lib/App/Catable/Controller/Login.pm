package App::Catable::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

App::Catable::Controller::Login - Catalyst Login Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 openid

Display the openid authentication form.

=cut

sub openid : Local {
    my ($self, $c) = @_;

    $c->stash->{template} = 'login/openid.tt2';

    return;
}

=head2 login

This is what happens if we just go to /login.

Note that it is Global and takes no Args and ends the chain.

=cut

sub login : Global Args(0) FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    # If we do this here, we can return later without having to worry.
    # If login succeeds we redirect anyway.
    $c->stash->{template} = 'login.tt2';

    if ($form->submitted_and_valid) {
        my $login_params = $form->params;

        unless ($c->authenticate( { 
                    username => $login_params->{user},
                    password => $login_params->{pass}, },
                    "local", # realm
        ) ) {
            $c->stash->{error} = "Username or password not recognised";
            return;
        }

        my $next_url 
            = delete $c->session->{goto_after_login}
           || $c->uri_for( '/' )
           || do { $c->log->debug( "Didn't know where to go after /login successful" ); $c->res->status( 404 ) };

=for Logging
        $c->log->debug( "Login successful - sending to $next_url" );
=cut

        $c->res->redirect( $next_url );
    }
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

Alastair Douglas, L<http://www.grammarpolice.co.uk/>

=head1 COPYRIGHT

Copyright by Shlomi Fish, 2010.

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
