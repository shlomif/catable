# This file is under the MIT X11 License:
# http://www.opensource.org/licenses/mit-license.php

use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $build = Test::Run::Builder->new(
    module_name => "App::Catable",
    build_requires =>
    {
        "HTML::Lint" => 0,
        "Test::Trap" => 0,
        "Test::WWW::Mechanize::Catalyst" => 0,
        "Test::WWW::Mechanize::LibXML" => 0,
    },
    requires => 
    {
        'Catalyst' => '5.80005',
        'Catalyst::Action::RenderView' => 0,
        'Catalyst::Plugin::Authentication' => '0.03',
        'Catalyst::Authentication::Credential::OpenID' => 0,
        'Catalyst::Model::DBIC::Schema' => 0,
        'Catalyst::Plugin::ConfigLoader' => 0,
        'Catalyst::Plugin::Static::Simple' => 0,
        'Catalyst::Plugin::Session' => 0,
        'Catalyst::Plugin::Session::Store::FastMmap' => 0,
        'Catalyst::Plugin::Session::State::Cookie' => 0,
        'Catalyst::Plugin::Authorization::Roles' => 0,
        'Catalyst::Plugin::StackTrace' => 0,
        'Catalyst::Authentication::Store::DBIx::Class' => 0,
        'Catalyst::View::TT' => '0.35',
        'Catalyst::Controller::HTML::FormFu' => 0,
        'Config::JFDI' => 0,
        'DateTime::Format::SQLite' => 0,
        'DBIx::Class' => 0,
        'DBIx::Class::DeploymentHandler' => 0,
        'DBIx::Class::TimeStamp' => 0.08111,
        'Digest' => 0,
        'HTML::Scrubber' => 0.08,
        'LWPx::ParanoidAgent' => 0,
        'Template::Stash::AutoEscaping' => '0.0301',
        'YAML' => 0,
    },
    license => "mit",
    # Commenting out so we'll have the catalyst.pl-generated M::I-base
    # Makefile.PL for safe-keeping.
    # create_makefile_pl => 'traditional',
    script_files => glob("script/*.pl"),
);

$build->create_build_script;

