package App::Catable::Schema::ResultSet::Account;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub auto_create
{
    my $self = shift;
    my $auth_info = shift;

    return $self->create({ url => $auth_info->{'url'} });
}

1;

=head1 NAME

App::Catable::ResultSet::Account - resultset for an account. Needed by OpenID.

=head1 SYNOPSIS
      
    TBD

=head1 DESCRIPTION

=head1 METHODS

=head2 $self->auto_create($auth_info)

Auto creates based on $auth_info.

=head1 AUTHOR

Shlomi Fish L<http://www.shlomifish.org/> .

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

