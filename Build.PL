#!/usr/bin/perl

use warnings;

use Module::Build;
use FindBin qw( $Bin );

my $mb = Module::Build->new(
                   module_name    => 'Locale::Object',
                   license        => 'perl',
                   requires       => {
                                      perl                              => '5.6.0',
                                      'DateTime::TimeZone'              => 0.4,
                                      DateTime                          => 0.3,
                                      DBI                               => 0,
                                      DBD::SQLite                       => 0,
                                      Scalar::Util                      => 1.10
                                     },
                   build_requires => {
                                      Module::Build => '0.21',
                                      Test::More    => 0,
                                      Test::Pod     => 0
                                     }
                  );

eval { require DBI; require DBD::SQLite; 1 }
  or die "requires DBD::SQLite";
unlink("$Bin/lib/Locale/Object/locale.db");
my $dbh = DBI->connect("dbi:SQLite:$Bin/lib/Locale/Object/locale.db");
open DUMP, "$Bin/locale.sql" or die $!;
{ local $/ = ";\n"; $dbh->do($_) while <DUMP> }
close DUMP;


$mb->create_build_script;
