#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 9;

use Locale::Object::Currency;
use Locale::Object::Currency::Converter;

my $usd = Locale::Object::Currency->new( code => 'USD' );
my $gbp = Locale::Object::Currency->new( code => 'GBP' );
my $eur = Locale::Object::Currency->new( code => 'EUR' );
my $jpy = Locale::Object::Currency->new( code => 'JPY' );

my $converter = Locale::Object::Currency::Converter->new(
                                                         from    => $usd,
                                                         to      => $gbp,
                                                         service => 'XE'
                                                        );

#1
ok( defined $converter, 'new() with params returned something');

#2
ok( $converter->isa('Locale::Object::Currency::Converter'), "it's the right class");

my $amount = 5;
my $result = $converter->convert($amount);

#3
ok( defined $result, 'An XE conversion worked');

eval {
  $converter->service('Yahoo');
};

#4
is( $!, '', 'Resetting currency service worked');

eval {
  $converter->from($eur);
};

#5
is( $!, '', "Resetting 'from' currency worked");

eval {
  $converter->to($jpy);
};

#6
is( $!, '', "Resetting 'to' currency worked");

$result = $converter->convert($amount);

#7
ok( defined $result, 'A Yahoo! conversion worked');

my $rate = $converter->rate;

#8
ok( $rate =~ /^[\d\.]+$/, 'a conversion rate was found');

my $timestamp = $converter->timestamp;

#8
ok( $timestamp =~ /^\d{10}$/, 'a rate timestamp was found');

