#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 9;

use Locale::Object::Country;

my $afghanistan = Locale::Object::Country->new( code_alpha2 => 'af' );
                                      
#1
ok( defined $afghanistan, 'new() returned something');

#2
ok( $afghanistan->isa('Locale::Object::Country'), "it's the right class");

#3
is( $afghanistan->name, 'Afghanistan', 'it has the correct country name');

#4
is( $afghanistan->code_alpha3, 'afg', 'it has the correct 3-letter code');

#5
is( $afghanistan->currency->name, 'afghani', 'it has the correct currency');

#6
is( $afghanistan->continent->name, 'Asia',   "it's on the correct continent");

my %countries;

# Fill up a hash with the alpha2 codes of countries in the same continent
foreach my $where ($afghanistan->continent->countries)
{
  # Get the alpha2 code of the country we're looking at.
  my $where_code = $where->code_alpha2;
  $countries{$where_code} = undef;
}

#7
ok( exists $countries{'tj'}, 'it has a correct neighbor on its continent');

my $copy = Locale::Object::Country->new( code_alpha2 => 'af' );

#8
ok( $copy eq $afghanistan, 'the object is a singleton');

#9
is( ($afghanistan->languages)[0]->name, 'Pushto', 'a correct language is spoken in it');

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $afghanistan;
