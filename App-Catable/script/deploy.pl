#!/usr/bin/perl

use lib 'lib';

require App::Catable;
App::Catable->model('BlogDB')->schema->deploy;
