package Locale::Object;

use strict;
use warnings::register;
use vars qw($VERSION);
use Carp qw(croak);

use Locale::Object::Continent;
use Locale::Object::Country;
use Locale::Object::Currency;
use Locale::Object::Language;

$VERSION = "0.54_01";

sub new
{
  my $class = shift;
  my %params = @_;

  my $self = bless {}, $class;
  
  # Initialize the new object or return an existing one.
  $self->init(%params);
}

sub init
{
  my $self   = shift;
  my %params = @_;

  # Make a hash of valid parameters.
  my %allowed_params = map { $_ => undef }
    qw( country_code_alpha2 country_code_alpha3 country_code_numeric 
        currency_code currency_code_numeric currency_name
        language_code_alpha2 language_code_alpha3 language_name );

  foreach my $parameter (keys %params)
  {
    # Go no further if the specified parameter wasn't one.
    croak "Error: Initialization parameter $parameter unrecognized." unless exists $allowed_params{$parameter};
    
    $self->$parameter( $params{$parameter} );
  }
  
  $self;
}  

sub _check_currency_countries
{
  my $self = shift;
  my $sane;
  
  foreach my $place ($self->{_currency}->countries)
  {
    # Test will pass if one of the countries using this currency matches our country attribute.
    $sane = 1 if $place->code_alpha2 eq $self->{_country}->code_alpha2
  }
  
  $sane;
}

sub _check_language_countries
{
  my $self = shift;
  my $sane;
  
  foreach my $place ($self->{_language}->countries)
  {
    # Test will pass if one of the countries using this currency matches our country attribute.
    $sane = 1 if $place->code_alpha2 eq $self->{_country}->code_alpha2;
  }      

  $sane;
}

sub _check_currency_languages
{
  my $self = shift;
  my $sane;
  
  # For each of the countries that use this currency,
  foreach my $place ($self->{_currency}->countries)
  {
    # For each of the languages that country uses;
    foreach my $language ($place->languages)
    {
      # Pass test if the language matches our language attribute.
      $sane = 1 if $language->code_alpha2 eq $self->{_language}->code_alpha2;
    }
  }
  
  $sane;
}

# Check 'sanity' of object - that is, whether attributes correspond with each other
# (no mixing of, say, currency from one country with language from another).
# Probably eminently refactorable.

sub sane
{
  my $self      = shift;
  my $attribute = shift;
  
  # Make a hash of valid attributes
  my %allowed_attribs = map { $_ => undef } qw( country currency language );

  my ($country_sane, $currency_sane, $language_sane, $sane);
  
  croak "ERROR: attribute to check sanity against ($attribute) unrecognized, must be one of 'country', 'currency', 'language'." unless exists $allowed_attribs{$attribute};
 
  # Sanity checks against country attribute
  #########################################
  
  if ($attribute eq 'country')
  {
    # Check currency attribute if it exists.
    if ($self->{_currency})
    {    
      $currency_sane = $self->_check_currency_countries;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $currency_sane = 1;
    }

    # Check language attribute if it exists.
    if ($self->{_language})
    {
      $language_sane = $self->_check_language_countries;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $language_sane = 1;
    }
    
    # If both tests pass, the object is sane.
    $sane = 1 if $currency_sane == 1 && $language_sane == 1;
  }
  
  # Sanity checks against currency attribute
  ##########################################
  
  elsif ($attribute eq 'currency')
  {    
    # Check country attribute if it exists.
    if ($self->{_country})
    {    
      $country_sane = $self->_check_currency_countries;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $country_sane = 1;
    }

    # Check language attribute if it exists.
    if ($self->{_language})
    {
      $language_sane = $self->_check_currency_languages;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $language_sane = 1;
    }
    
    # If both tests pass, the object is sane.
    $sane = 1 if $country_sane == 1 && $language_sane == 1;

  }
  
  # Sanity checks against language attribute
  ##########################################

  elsif ($attribute eq 'language')
  {
    # Check country attribute if it exists.
    if ($self->{_country})
    {
      $language_sane = $self->_check_language_countries;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $language_sane = 1;
    }

    # Check currency attribute if it exists.
    if ($self->{_currency})
    {    
      $currency_sane = $self->_check_currency_languages;
    }
    else
    {
      # If it doesn't it can't be wrong, so that's OK.
      $currency_sane = 1;
    }

    # If both tests pass, the object is sane.
    $sane = 1 if $country_sane == 1 && $currency_sane == 1;

  }

  return 0 unless $sane == 1;
}

# Make all the attributes kinsmen.
#
# UNFINISHED CODE: use at your own risk!
#
sub make_sane
{
  my $self      = shift;
  my $attribute = shift;

  # Make a hash of valid attributes.
  my %allowed_attribs = map { $_ => undef } qw( country currency language );
  
  croak "ERROR: attribute to make sane with ($attribute) unrecognized, must be one of 'country', 'currency', 'language'." unless exists $allowed_attribs{$attribute};

  my $attribute_to_check = '_' . $attribute;
  
  croak "ERROR: Can not make sane against $attribute, none has been set." unless $self->{$attribute_to_check};

  # Make sane by country.
  if ($attribute eq 'country')
  {
    $self->currency_code($self->{_country}->currency->code);

    my @languages = $self->{_country}->languages;
    
    # Get the official language of the country in the country attribute, and set
    # the language attribute to that.
    foreach my $spoken (@languages)
    {
      $self->language_code_alpha3($spoken->code_alpha3) if $spoken->official($self->{_country}) eq 'true';
    }
  }
   
  # Make sane by currency.
  elsif ($attribute eq 'currency')
  {
    # TBD
  }
  
  # Make sane by language.
  elsif ($attribute eq 'language')
  {
    # TBD
  }
}

# Small methods that set object attributes.
# Will refactor these into an AUTOLOAD later.

sub country_code_alpha2
{
  my $self = shift;  

  croak "No value given for country_code_alpha2" unless @_;

  $self->{_country} = Locale::Object::Country->new( code_alpha2 => shift );
}

sub country_code_alpha3
{
  my $self = shift;  
  
  croak "No value given for country_code_alpha3" unless @_;

  $self->{_country} = Locale::Object::Country->new( code_alpha3 => shift );
}

sub country_code_numeric
{
  my $self = shift;  
  
  croak "No value given for country_code_numeric" unless @_;

  $self->{_country} = Locale::Object::Country->new( code_numeric => shift );
}

sub country_name
{
  my $self = shift;  

  croak "No value given for country_name" unless @_;
  
  $self->{_country} = Locale::Object::Country->new( name => shift );
}

sub currency_code
{
  my $self = shift;  
  
  croak 'No value given for currency_code' unless @_;

  $self->{_currency} = Locale::Object::Currency->new( code => shift );
}

sub currency_code_numeric
{
  my $self = shift;  
  
  croak 'No value given for currency_code_numeric' unless @_;

  $self->{_currency} = Locale::Object::Currency->new( code_numeric => shift );
}

sub language_code_alpha2
{
  my $self = shift;  
  
  croak 'No value given for language_code' unless @_;

  $self->{_language} = Locale::Object::Language->new( code_alpha2 => shift );
}

sub language_code_alpha3
{
  my $self = shift;  
  
  croak 'No value given for language_code_alpha3' unless @_;

  $self->{_language} = Locale::Object::Language->new( code_alpha3 => shift );
}

sub language_name
{
  my $self = shift;  
  
  croak 'No value given for language_name' unless @_;

  $self->{_language} = Locale::Object::Language->new( name => shift );
}

1;

__END__

=head1 NAME

Locale::Object - OO locale information

=head1 VERSION

0.54_01

=head1 DESCRIPTION

The C<Locale::Object> group of modules attempts to provide locale-related information in an object-oriented fashion. The information is collated from several sources and provided in an accompanying L<DBD::SQLite> database.

At present, the modules are:

=over 4

* L<Locale::Object> - make compound objects containing country, currency and language objects

* L<Locale::Object::Country> - objects representing countries

* L<Locale::Object::Continent> - objects representing continents

* L<Locale::Object::Currency> - objects representing currencies

* L<Locale::Object::Currency::Converter>  - convert between currencies

* L<Locale::Object::DB> - does lookups for the modules in the database

* L<Locale::Object::DB::Schemata> - documents the database, including all data sources.

* L<Locale::Object::Language> - objects representing languages

=back

For more information, see the documentation for those modules.

=head1 SYNOPSIS

    use Locale::Object;
    
    my $obj = Locale::Object->new(
                                  country_code_alpha2  => 'gb',
                                  currency_code        => 'GBP',
                                  language_code_alpha2 => 'en'
                                 );

    $obj->country_code_alpha2('af');
    $obj->country_code_alpha3('afg');

    $obj->currency_code('AFA');
    $obj->currency_code_numeric('004');
    
    $obj->language_code_alpha2('ps');
    $obj->language_code_alpha3('pus');
    $obj->language_name('Pushto');
    
=head1 METHODS

=head2 C<new()>

    my $obj = Locale::Object->new(
                                  country_code_alpha2  => 'gb',
                                  currency_code        => 'GBP',
                                  language_code_alpha2 => 'en'
                                 );


This documentation is all TBD as of 0.54_01. Stay tuned.

=head2 C<country_code_alpha2(), country_code_alpha3()>

=head2 C<country_code(), currency_code_numeric()>

=head2 C<language_code_alpha2(), language_code_alpha3(), language_name()>

=head1 AUTHOR

Earle Martin <EMARTIN@cpan.org>

=over 4 

=item L<http://purl.oclc.org/net/earlemartin/>

=back

=head1 CREDITS

Original concept: Pierre Denis (PDENIS). I had much useful assistance from Pierre, Tom Insam (TOMI) - who contributed to my knowledge of DBI - and James Duncan (JDUNCAN). Most of the OO concepts involved I learnt from Damian Conway (DCONWAY)'s excellent book "Object Oriented Perl" (ISBN 1-884777-79-1).

=head1 COPYRIGHT

Copyright 2003 Fotango Ltd. All rights reserved. L<http://opensource.fotango.com/>

This module is released under the same license as Perl itself, and is provided on an "as is" basis. The author and Fotango Ltd make no warranties of any kind, either expressed or implied, as to the accuracy and/or utility of any results obtained from its use. However, if you do find something wrong with the results, please let the author know. Thanks.

=head1 SEE ALSO

L<Locale::Codes>, for simple conversions between names and ISO codes.

=cut
