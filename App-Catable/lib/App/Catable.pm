package App::Catable;

use strict;
use warnings;

use Catalyst::Runtime '5.80';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

#-Debug
use Catalyst qw/
    StackTrace

    ConfigLoader
    Authentication
    Authorization::Roles
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Static::Simple
    /;

our $VERSION = '0.01';

# Configure the application. 
#
# Note that settings in App::Catable.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( 
    name => 'App::Catable',
);

# Start the application
__PACKAGE__->setup;


=head1 NAME

App::Catable - CATAlyst BLog Engine - written by Perl cats.

=head1 SYNOPSIS

    script/app_catable_server.pl

=head1 DESCRIPTION

Catable stands for CATAlyst BLog Engine and aims to be a Catalyst-based blog
engine freely available under the MIT/X11 License.s

=head2 METHODS

$c->add_notification($notification_string) - create a notification to be shown to a visitor, e.g. "You have been logged out"

$c->has_notifications - for use in templating

=cut

sub add_notification {
	my ($c, $message) = @_;
	$c->session->{'notifications'} = [] unless defined $c->session->{'notifications'};
	push(@{ $c->session->{'notifications'} }, $message);

	return;
}

sub has_notifications {
	my $c = shift;
	return (defined $c->session->{'notifications'} && $c->session->{'notifications'}) ? 1 : ''; 
}

sub notifications {
	my $c = shift;
	my @notifications = @{ $c->session->{'notifications'} };
	delete $c->session->{'notifications'};
	return @notifications;
}

=head1 SEE ALSO

L<App::Catable::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=head1 ACKNOWLEDGEMENTS

Thanks to the people on L<irc://irc.perl.org/#dbix-class> for their help
with DBIx::Class problems.

=cut

1;
