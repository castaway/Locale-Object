#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 8;

use Locale::Object::Country;
use Locale::Object::Language;

my $eng = Locale::Object::Language->new( code_alpha2 => 'en' );
                                      
#1
ok( defined $eng, 'new() returned something');

#2
ok( $eng->isa('Locale::Object::Language'), "it's the right class");

#3
is( $eng->name, 'English', 'it has the right name');

#4
is( $eng->code_alpha3, 'eng', 'it has the right alpha3 code');

my @countries = @{$eng->countries};

my $count = scalar @countries;

#5
is( $count, 86, 'the number of countries sharing it is correct');

my $copy = Locale::Object::Language->new( code_alpha3 => 'eng' );

#6
ok( $copy eq $eng, 'the object is a singleton');

my $gb  = Locale::Object::Country->new(  code_alpha2 => 'gb'  );
my $wel = Locale::Object::Language->new( code_alpha3 => 'wel' );

#7
is( $eng->official($gb), 'true', "it's official in the correct country" );

#8
is( $wel->official($gb), 'false', "a secondary language isn't official" );

# Remove __END__ to get a dump of the data structures created by this test.
__END__
print "\n==========================\n";
print "| DATA STRUCTURE FOLLOWS |\n";
print "==========================\n\n";

use Data::Dumper;
print Dumper $eng;
