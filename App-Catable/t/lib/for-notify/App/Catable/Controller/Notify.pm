package App::Catable::Controller::Notify;

use strict;
use warnings;
use base 'Catalyst::Controller';

# Provided so tests can use notify without relying on any other mechanism
sub hello_world : Local {
	my ($self, $c) = @_;
	$c->add_notification("Hello, world!");
	$c->stash->{'template'} = 'index.tt2';
	return;
}

1;
