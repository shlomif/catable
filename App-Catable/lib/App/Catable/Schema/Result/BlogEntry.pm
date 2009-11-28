package App::Catable::Schema::Result::BlogEntry;

use strict;
use warnings;

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

