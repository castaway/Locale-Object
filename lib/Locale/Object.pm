package Locale::Object;

use strict;
use warnings::register;
use vars qw($VERSION);
use Carp;

use Locale::Object::Continent;
use Locale::Object::Country;
use Locale::Object::Currency;
use Locale::Object::Language;

$VERSION = "0.6";

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
# There's a bit of ArrowAntiPattern here. Refactoring needed.

sub make_sane
{
  my $self   = shift;
  my %params = @_;

  # Internal attributes start with underscores.
  my $internal_attribute = '_' . $params{attribute} if $params{attribute};

  if ($params{attribute})
  {
    $self->_make_sane_by_attribute($params{attribute});
  }
  else
  {
    # ...
  }
  
  if ($params{populate} == 1)
  {
    croak 'ERROR: cannot populate without an attribute to seed from.' unless $params{attribute};

    croak 'ERROR: cannot populate against ', $params{attribute}, ' none has not been set.' unless $self->{$internal_attribute};

    if ($params{attribute} eq 'country')
    {
      $self->_populate_currency;
    }
  }
}

# See warning above about unfinished code.
sub _make_sane_by_attribute
{
  my $self = shift;
  my $attribute = shift;

  # Make a hash of valid attributes.
  my %allowed_attribs = map { $_ => undef } qw( country currency language );

  croak "ERROR: attribute to make sane with ($attribute) unrecognized, must be one of 'country', 'currency', 'language'." unless exists $allowed_attribs{$attribute};

  # Internal attributes start with underscores.
  my $internal_attribute = '_' . $attribute;
      
  croak 'ERROR: can not make sane against ', $attribute, ' none has been set.' unless $self->{$internal_attribute};
  
  # Make sane by country.
  if ($attribute eq 'country')
  {
    # Reset our currency if there is one.
    $self->_populate_currency if $self->{_currency};
  
    # Reset our language if there is one.
    $self->_populate_language if $self->{_language};
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

  $self;
}

sub _populate_currency
{
  my $self = shift;

  $self->{_currency} = $self->{_country}->currency;
  
  $self;
}

sub _populate_language
{
  my $self = shift;
  
  my @languages = $self->{_country}->languages;
        
  # Get the official language of the country in the country attribute, and set
  # the language attribute to that.
  foreach my $spoken (@languages)
  {
    $self->language_code_alpha3($spoken->code_alpha3) if $spoken->official($self->{_country}) eq 'true';
  }

}

# Small methods that set or get object attributes.
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

sub language
{
  my $self = shift;
  
  return $self->{_language};
}

sub country
{
  my $self = shift;
  
  return $self->{_country};
}

sub currency
{
  my $self = shift;
  
  return $self->{_currency};
}

1;

__END__

=head1 NAME

Locale::Object - OO locale information

=head1 VERSION

0.6

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

* L<Locale::Object::Language> - objects representing languages

=back

For more information, see the documentation for those modules. The database is documented in docs/database.pod. Locale::Object itself can be used to create compound objects containing country, currency and language objects.

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

Creates a new object. With no parameters, the object will be blank. Valid parameters match the method names that follow.

=head2 C<country_code_alpha2(), country_code_alpha3()>

    $obj->country_code_alpha2('af');
    $obj->country_code_alpha3('afg');

Sets the country attribute in the object by alpha2 and alpha3 codes. Will create a new L<Locale::Object::Country> object and set that as the attribute. Because Locale::Object::Country objects all have single instances, if one has already been created by that code, it will be reused when you do this.
 
=head2 C<country_code(), currency_code_numeric()>

    $obj->currency_code('AFA');
    $obj->currency_code_numeric('004');

Serves the same purpose as the previous methods, only for the currency attribute, a L<Locale::Object::Currency> object.

=head2 C<language_code_alpha2(), language_code_alpha3(), language_name()>

    $obj->language_code_alpha2('ps');
    $obj->language_code_alpha3('pus');
    $obj->language_name('Pushto');

Serves the same purpose as the previous methods, only for the language attribute, a L<Locale::Object::Language> object.

=head1 Retrieving Attributes

=head2 C<country(), language(), currency()>

While the foregoing methods can be used to set attribute objects, to retrieve those objects' own attributes you will have to use their own methods. The C<country()>, C<language()> and C<currency()> methods return the objects stored as those attributes, if they exist.

    my $country_tzone = $country->timezone->name;
    my $language_name = $obj->language->name;
    my $currency_code = $obj->currency->code;
    
See L<Locale::Object::Country>, L<Locale::Object::Language> and L<Locale::Object::Currency> for more details on the subordinate methods.

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
