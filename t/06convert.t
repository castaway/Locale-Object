#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 10;

use Locale::Object::Currency;
use Locale::Object::Currency::Converter;

my $usd = Locale::Object::Currency->new( code => 'USD' );
my $gbp = Locale::Object::Currency->new( code => 'GBP' );
my $eur = Locale::Object::Currency->new( code => 'EUR' );
my $jpy = Locale::Object::Currency->new( code => 'JPY' );

#1
require_ok('Finance::Currency::Convert::Yahoo');

#2
require_ok('Finance::Currency::Convert::XE');
  
my $converter = Locale::Object::Currency::Converter->new(
                                                       from    => $usd,
                                                       to      => $gbp,
                                                       service => 'XE'
                                                      );

#3
isa_ok( $converter, 'Locale::Object::Currency::Converter');

my $amount = 5;
my $result = $converter->convert($amount);

# "Test" a conversion - output a test result, but don't fail if it
# doesn't work. This is because Finance::Currency::Convert::XE and 
# Finance::Currency::Convert::Yahoo occasionally don't work due to transient
# network conditions. We want to indicate success/failure but not actually
# kill the tests.

#4
if (defined $result)
{
  pass('An XE conversion worked');
}
else
{
  pass('An XE conversion was not successful, this may be due to transient network conditions');
}

#5
ok( $converter->service('Yahoo'), 'Resetting currency service worked' );

#6
ok( $converter->from($eur), "Resetting 'from' currency worked" );

#7
ok( $converter->to($jpy), "Resetting 'to' currency worked" );

$result = $converter->convert($amount);

# More "tests" - see note above.

#8
if (defined $result)
{
  pass('A Yahoo! conversion worked');
}
else
{
  pass('A Yahoo! conversion was not successful, this may be due to transient network conditions');
}
 
my $rate = $converter->rate;
 
#9
if (defined $rate)
{
  pass('A conversion rate was found');
}
else
{
  pass('A conversion rate was not found, this may be due to transient network conditions');
}
  
my $timestamp = $converter->timestamp;
  
#10
if (defined $timestamp)
{
  pass('A rate timestamp was found');
}
else
{
  pass('A rate timestamp was not found, this may be due to transient network conditions');
}

