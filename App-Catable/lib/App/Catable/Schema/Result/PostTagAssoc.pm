package App::Catable::Schema::Result::PostTagAssoc;

use strict;
use warnings;

=head1 NAME

App::Catable::Schema::PostTagAssoc - a posts <-> tags association.

=head1 SYNOPSIS
      
=head1 DESCRIPTION

This table/class associates posts with tags/labels/keywords.

=head1 METHODS

=cut

use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( Core ) );
__PACKAGE__->table( 'post_tag_assoc' );
__PACKAGE__->add_columns(
    post_id => {
        data_type         => 'bigint',
        is_nullable       => 0,
    },
    tag_id => {
        data_type   => 'bigint',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key( qw( post_id tag_id ) );
__PACKAGE__->resultset_attributes( { order_by => [ 'post_id', 'tag_id' ] } );
__PACKAGE__->belongs_to(
    post => 'App::Catable::Schema::Result::Entry',
    'post_id',
);
__PACKAGE__->belongs_to(
    tag => 'App::Catable::Schema::Result::Tag',
    'tag_id',
);

=head1 SEE ALSO

L<App::Catable::Schema::Tag> , L<App::Catable::Schema::Post>

=head1 AUTHOR

Shlomi Fish L<http://www.shlomifish.org/> .

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Shlomi Fish, 2009.

=cut

1;
