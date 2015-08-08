package App::Catable::Schema::Result::BlogEntry;

use strict;
use warnings;


=head1 NAME

App::Catable::Schema::Result::BlogEntry - a schema class representing a blog
entry.

=head1 SYNOPSIS

    TBD

=cut
use base qw( DBIx::Class );

__PACKAGE__->load_components( qw( Core ) );
__PACKAGE__->table( 'blog_entry' );

__PACKAGE__->add_columns(
    blog_id => {
        data_type       => 'bigint',
        is_nullable     => 0,
    },
    entry_id => {
        data_type       => 'bigint',
        is_nullable     => 0,
    },
);
__PACKAGE__->set_primary_key( qw( blog_id entry_id ) );

__PACKAGE__->belongs_to(
    'blog' => 'App::Catable::Schema::Result::Blog',
    'blog_id'
);
__PACKAGE__->belongs_to(
    'entry' => 'App::Catable::Schema::Result::Entry',
    'entry_id',
);

1;

__END__

=head1 DESCRIPTION

This class holds meta data about a blog entry/post. It is intended for use
on a site which holds multiple blogs by providing a foreign key relation
to all other tables whose data may be associated with an individual blog.

=head1 FIELDS

This field list also comprises a method list, since DBIC
creates accessor methods for each field.

=head2 blog_id

The blog ID to which this entry belongs.

=head2 entry_id

The ID of the entry.


=head1 SEE ALSO

L<App::Catable::Schema>, L<App::Catable>, L<DBIx::Class>

L<App::Catable::Schema::Result::Blog>

=head1 AUTHOR

Alastair Douglas L<www.grammarpolice.co.uk>

=head1 LICENSE

This module is free software, available under the MIT X11 Licence:

L<http://www.opensource.org/licenses/mit-license.php>

Copyright by Alastair Douglas, 2009.

=cut
