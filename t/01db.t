#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 4;

use Locale::Object::DB;

my $db = Locale::Object::DB->new();
                                      
#1
ok( defined $db, 'new() returned something');

#2
ok( $db->isa('Locale::Object::DB'), "it's the right class");

my $result = $db->lookup(
                         table         => 'country', 
                         result_column => '*',
                         search_column => 'code_alpha2',
                         value         => 'uz'
                        );

my $code_alpha2           = @{$result}[0]->{'code_alpha2'}; 
my $code_alpha3           = @{$result}[0]->{'code_alpha3'}; 
my $code_numeric          = @{$result}[0]->{'code_numeric'}; 
my $name                  = @{$result}[0]->{'name'};
my $name_native           = @{$result}[0]->{'name_native'};
my $main_timezone         = @{$result}[0]->{'main_timezone'};
my $uses_daylight_savings = @{$result}[0]->{'uses_daylight_savings'};
  
#3
is( $name, 'Uzbekistan', 'country lookup was OK');

   
$result = $db->lookup_dual(
                           table      => 'language_mappings', 
                           result_col => 'official', 
                           col_1      => 'country', 
                           val_1      => 'gb',
                           col_2      => 'language',
                           val_2      => 'eng'
                          );

#4
is( @{$result}[0]->{'official'}, 'true', 'dual lookup was OK');

