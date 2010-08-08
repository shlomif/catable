package App::Catable::Controller::Register;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

App::Catable::Controller::Login - Catalyst Login Controller

=head1 DESCRIPTION

Handles registration attempts.

=head1 METHODS

=cut

=head2 register

This is what happens if we just go to /register.

Note that it is Global and takes no Args and ends the chain.

This will register the user with the local login system.

=cut

sub register : Global Args(0) FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    # If we do this here, we can return later without having to worry.
    # If register succeeds we redirect anyway.
    $c->stash->{template} = 'register.tt2';
    
    # Avoid an empty session var, Just In Case.
    $c->session->{goto_after_register} = delete $c->session->{goto_after_login} 
        if $c->session->{goto_after_login};

    if ($form->submitted_and_valid) {
        my $salt = join "", map { chr(rand(137)+40) } 1..16;

        my $params = $form->params;
        delete $params->{password_check};
        delete $params->{submit};

        unless ($c->model('BlogDB')
                      ->resultset('Account')
                      ->create( { 
                                  %$params, 
#                                  options => { password_salt => $salt, 
#                                  %{ $c->config('Plugin::Authentication')->{local}->{credential} } 
#                                  }
                                } ) ) 
        {
            # Uncomment this when we have implemented real exceptions
            $c->stash->{error} = "Fail."; #$error->message;
            return;
        }

        $c->authenticate( {
            username => $params->{username},
            password => $params->{password}, },
            'local', # realm
        );
        my $next_url 
            = delete $c->session->{goto_after_register}
           || $c->uri_for( '/' )
           || do { $c->log->debug( "Didn't know where to go after /register successful" ); $c->res->status( 404 ) };

=for log
        $c->log->debug( "Login successful - sending to $next_url" );
=cut

        $c->res->redirect( $next_url );
    }
}

1;

__END__

