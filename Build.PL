#!/usr/bin/perl

use warnings;

use Module::Build;

Module::Build->new(
                   module_name    => 'Locale::Object',
                   license        => 'perl',
                   requires       => {
                                      perl                              => '5.6.0',
                                      DBI                               => 0,
                                      DBD::SQLite                       => 0,
                                      Finance::Currency::Convert::XE    => 0,
                                      Finance::Currency::Convert::Yahoo => 0,
                                      Scalar::Util                      => 0.10
                                     },
                   build_requires => {
                                      Module::Build => '0.21',
                                      Test::More    => 0,
                                      Test::Pod     => 0
                                     }
                  )->create_build_script;
