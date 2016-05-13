#!/usr/bin/perl

use utf8;
use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Math::BigSym',
    license           => 'artistic_2',
    dist_author       => q{Daniel Șuteu <trizenx@gmail.com>},
    dist_version_from => 'lib/Math/BigSym.pm',
    release_status    => 'stable',                               # with some known limitations (see `perldoc Math::BigSym`)
    configure_requires => {
                           'Module::Build' => 0,
                          },
    build_requires => {
                       'Test::More' => 0,
                      },
    meta_merge => {
                   resources => {
                                 repository => 'https://github.com/trizen/Math-BigSym'
                                }
                  },
    requires => {
                 'perl'                   => '5.14.0',
                 'Carp'                   => 0,
                 'Math::GMPq'             => 0.39,
                 'Math::GMPz'             => 0,
                 'Math::Algebra::Symbols' => 1.27,
                },
    add_to_cleanup     => ['Math-BigSym-*'],
    create_makefile_pl => 'traditional',
                                );

$builder->create_build_script();
