use strict;
use warnings;
use Test::More tests => 5;

# Lots of stuff to get Test::WWW::Mechanize::Catalyst to work with
# the testing model.

use vars qw($schema);
BEGIN 
{ 
    $ENV{CATALYST_CONFIG} = "t/var/catable.yml";
    use App::Catable::Model::BlogDB; 

    use lib 't/lib';
    use AppCatableTestSchema;

    $schema = AppCatableTestSchema->init_schema(no_populate => 0);
}

use Test::WWW::Mechanize::Catalyst 'App::Catable';

my $mech = Test::WWW::Mechanize::Catalyst->new;

# TEST
$mech->get_ok("http://localhost/posts/add");

# TEST
$mech->submit_form_ok(
    { 
        fields =>
        {
            body => "<p>Kit Kit Catty Skooter</p>",
            title => "Grey and White Cat",
        },
        button => "preview",
    },
    "Submitting the preview form",
);

# TEST
$mech->submit_form_ok(
    {
        button => "submit",
    },
    "Submitting the submit form",    
);

# TEST
$mech->get_ok("http://localhost/posts/list/");

# TEST
like(
    $mech->content, 
    qr/Grey and White Cat/, 
    "Contains the submitted body",
);

