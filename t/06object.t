#!/usr/bin/perl

use warnings::register;
use strict;

use Test::More tests => 14;

use Locale::Object;

my $obj = Locale::Object->new(
                              country_code_alpha2  => 'af',
                              currency_code        => 'GBP',
                              language_code_alpha2 => 'en'
                             );

#1
isa_ok( $obj, 'Locale::Object' );

# Country tests
###############

#2
is( $obj->{_country}->name, 'Afghanistan', 'Set a country attribute with code_alpha2' );

$obj->country_code_alpha3('kaz');

#3
is( $obj->{_country}->name, 'Kazakhstan', 'Reset country attribute with code_alpha3' );

$obj->country_code_numeric(860);

#4
is( $obj->{_country}->name, 'Uzbekistan', 'Reset country attribute with code_numeric' );

$obj->country_name('Kyrgyzstan');

#5
is( $obj->{_country}->code_numeric, 417, 'Reset country attribute with name' );

# Currency tests
################

#6
is( $obj->{_currency}->name, 'pound', 'Set currency attribute with code' );

$obj->currency_code_numeric('004');

#7
is( $obj->{_currency}->name, 'afghani', 'Reset currency attribute with code_numeric' );

# Language tests
################

#8
is( $obj->{_language}->name, 'English', 'Set language attribute with code_alpha2' );

$obj->language_code_alpha3('ara');

#9
is( $obj->{_language}->name, 'Arabic', 'Reset language attribute with code_alpha3' );

$obj->language_name('Swedish');

#10
is( $obj->{_language}->code_alpha3, 'sve', 'Reset language attribute with name' );

# Sanity checks
###############

#11
is( $obj->sane('country'), 0, 'Object is addled according to country' );

#12
is( $obj->sane('currency'), 0, 'Object is addled according to currency' );

#13
is( $obj->sane('language'), 0, 'Object is addled according to language' );

$obj->make_sane(
                attribute => 'country',
                populate  => 1
               );

#14
is( $obj->sane('country'), 1, 'Object was made sane by country' );

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $obj;
