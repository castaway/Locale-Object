#!/usr/bin/perl

use warnings::register;
use strict;

use Test::More tests => 1;

use Locale::Object::Currency;

my $gbp = Locale::Object::Currency->new( country_code => 'gb' );

#1 - missing pound symbol in 0.75
is($gbp->symbol, '£');
