#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 10;

use Locale::Object::Currency;

my $usd = Locale::Object::Currency->new( country_code => 'us' );
                                      
#1
ok( defined $usd, 'new() returned something;');

#2
ok( $usd->isa('Locale::Object::Currency'), "it's the right class");

#3
is( $usd->name, 'dollar', 'it has the right name');

#4
is( $usd->code, 'USD', 'it has the right code');

#5
is( $usd->code_numeric, '840', 'it has the right numeric code');

#6
is( $usd->symbol, '$', 'it has the right symbol');

#7
is( $usd->subunit, 'cents', 'it has the right subunit');

#8
is( $usd->subunit_amount, '100', 'it has the right subunit amount');

my @countries = @{$usd->countries};

my $count = scalar @countries;

#9
is( $count, 12, 'the number of countries sharing it is correct');

# The code/name mapping of objects in %countries should be consistent with this.
my %names = (
             as => "American Samoa",
             gu => "Guam",
             pw => "Palau",
             pr => "Puerto Rico",
             tc => "Turks and Caicos Islands",
             us => "United States",
             vi => "Virgin Islands, U.S.",
             vg => "Virgin Islands, British"
            );
            
my @places = keys %names;
my $where = $places[rand @places];

my $copy = Locale::Object::Currency->new( country_code => 'us' );

#10
ok( $copy eq $usd, 'the object is a singleton');

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $usd;
