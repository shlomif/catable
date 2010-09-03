package MyTest::Mech;

use Moose;

extends 'Test::WWW::Mechanize::Catalyst', 'Test::WWW::Mechanize::LibXML';

sub _update_page
{
    my $self = shift;

    my $ret = $self->Test::WWW::Mechanize::Catalyst::_update_page(@_);
    $self->Test::WWW::Mechanize::LibXML::_update_page(@_);

    return $ret;
}

1;
