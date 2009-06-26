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
        "Test::Trap" => 0,
    },
    requires => 
    {
        'Catalyst' => '5.80005',
        'Catalyst::Plugin::ConfigLoader' => 0,
        'Catalyst::Plugin::Static::Simple' => 0,
        'Catalyst::Action::RenderView' => 0,
        'YAML' => 0,
    },
    license => "mit",
    create_makefile_pl => 'traditional',
    script_files => glob("script/*.pl"),
);

$build->create_build_script;

