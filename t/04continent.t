#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 6;

use Locale::Object::Continent;
use Locale::Object::Country;

my $asia = Locale::Object::Continent->new( name => 'Asia' );

#1
ok( defined $asia, 'new() returned something');

#2
ok( $asia->isa('Locale::Object::Continent'), 'it was the right class');

my $cont_name = $asia->name;

#3
is( $cont_name, 'Asia', 'it had the correct name');

my %countries = %{$asia->countries};

my $count = scalar keys %countries; 

#4
is( $count, 46, 'it had the correct number of countries in it');

my $country_code = 'af';

my $country_name = $countries{$country_code}->name;

#5
is( $country_name, 'Afghanistan', 'a country in it had the right name');

my $copy = Locale::Object::Continent->new( name => 'Asia' );

#6
ok( $copy eq $asia, 'the object is a singleton');

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $asia;
