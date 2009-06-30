package App::Catable::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-30 19:41:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LzdS+LV0uC4IyGyV8CBUNA

=head1 NAME

App::Catable::Schema - the main schema module.

=head1 SYNOPSIS
      
    my $schema = App::Catable->model("BlogDB");

=head1 DESCRIPTION

This is the main schema module for the L<App::Catable> BlogDB model.

=head1 METHODS

None.

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
