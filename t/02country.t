#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 8;

use Locale::Object::Country;

my $afghanistan = Locale::Object::Country->new( code_alpha2 => 'af' );
                                      
#1
ok( defined $afghanistan, 'new() returned something');

#2
ok( $afghanistan->isa('Locale::Object::Country'), 'it was the right class');

#3
is( $afghanistan->name, 'Afghanistan', 'it had the correct country name');

#4
is( $afghanistan->code_alpha3, 'afg', 'it had the correct 3-letter code');

#5
is( $afghanistan->currency->name, 'afghani', 'it had the correct currency');

#6
is( $afghanistan->continent->name, 'Asia',   'its was on the correct continent');

my $countries = \%{$afghanistan->continent->countries};

#7
is( $countries->{'tj'}->name, 'Tajikistan', 'it has a correct neighbor on its continent');

my $copy = Locale::Object::Country->new( code_alpha2 => 'af' );

#8
ok( $copy eq $afghanistan, 'the object is a singleton');

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $afghanistan;
