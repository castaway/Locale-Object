#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 4;

use Locale::Object::DB;

my $db = Locale::Object::DB->new();
                                      
#1
ok( defined $db, 'new() returned something');

#2
ok( $db->isa('Locale::Object::DB'), 'it was the right class');

my ($code_alpha2, $code_alpha3, $code_numeric, $name, $name_native, $primary_language, $main_timezone, $uses_daylight_savings) = $db->lookup('country', 'code_alpha2', 'uz');

#3
is( $name, 'Uzbekistan', 'it had the correct country name' );

my %countries;
    
foreach my $result ( $db->lookup_all(
                                     table => "continent", 
                                     result_column => "country_code", 
                                     search_column => "name", 
                                     value => 'Asia' ) )
{
  $countries{$result} = 1;
}

my $count = scalar keys %countries;

#4
is( $count, 46, "query for all a continent's countries returned right num. of results");

