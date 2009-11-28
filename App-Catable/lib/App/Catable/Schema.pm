package App::Catable::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

=head1 NAME

App::Catable::Schema - the main schema module.

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB")

=head1 DESCRIPTION

This is the main schema module for the L<App::Catable> BlogDB model.

=head1 METHODS

=head2 $self->create_initial_data()

Populates the database with the initial data

=cut

sub create_initial_data
{
    my $self = shift;

    return;
}

=head1 SEE ALSO

L<App::Catable>, L<DBIx::Class>

=head2 Tables

=over 4

=item * L<App::Catable::Schema::Post>

=back

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

1;

__END__
