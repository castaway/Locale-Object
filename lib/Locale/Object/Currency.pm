package Locale::Object::Currency;

use strict;
use warnings::register;
use Carp qw(croak);
use vars qw($VERSION);

use Locale::Object::Country;
use Locale::Object::DB;

$VERSION = "0.11";

my $db = Locale::Object::DB->new();

# Initialize the hash where we'll keep our singleton currency objects.
my $existing = {};

my $class;

sub new
{
  my $class = shift;
  my %params = @_;

  my $self = bless {}, $class;
  
  # Initialize the new object or return an existing one.
  $self->init(%params);
}

# Initialize the object.
sub init
{
  my $self   = shift;
  my %params = @_;

  # One parameter is allowed.
  croak "Error: You must specify a single parameter for initialization."
    unless scalar(keys %params) == 1;

  # It's the only key in %params.    
  my $parameter = (keys %params)[0];
  
  # Make a hash of valid parameters.
  my %allowed_params = map { $_ => undef }
    qw(country_code code code_numeric);
  
  # Go no further if the specified parameter wasn't one.
  croak "Error: You can only specify a country code, currency code or numeric code for initialization." unless exists $allowed_params{$parameter};

  # Get the value given for the parameter.
  my $value = $params{$parameter};

  # Look in the database for a match.
  my @attributes = $db->lookup('currency', $parameter, $value);

  croak "Error: Unknown $parameter given for initialization: $value" unless @attributes;
  
  # The third attribute we get is the currency code.
  my $code = $attributes[2]; 
  
  # Check for pre-existing objects. Return it if there is one.
  my $currency = $self->exists($code);
  return $currency if $currency;

  # If not, make a new object.
  _make_currency($self, @attributes);
  
  # Register the new object.
  $self->register();

  # Return the object.
  $self;
}

# Check if objects exist.
sub exists {
  my $self = shift;
  
  # Check existence of a object with the given parameter or with
  # the code of the current object.
  my $code = shift || $self->code;
  
  # Return the singleton object, if it exists.
  $existing->{$code};
}

# Register the object in our hash of existing objects.
sub register {
  my $self = shift;
  
  # Do nothing unless the object exists.
  my $code = $self->code or return;
  
  # Put the current object into the singleton hash.
  $existing->{$code} = $self;
}

sub _make_currency
{
  my $self       = shift;
  my @attributes = @_;

  # The third attribute we get is the currency code.
  my $currency_code = $attributes[2];
  
  # The attributes we want to set.
  my @attr_names = qw(_name _code _code_numeric _symbol _subunit _subunit_amount);
  
  # Initialize a loop counter.
  my $counter = 1;
  
  foreach my $current_attribute (@attr_names)
  {
    # Set the attributes of the entry for this currency code in the singleton hash.
    
    $self->{$current_attribute} = $attributes[$counter];
    
    $counter++; 
  }

}

# Method for retrieving all countries using this currency.
sub countries
{
    my $self = shift;
    
    # Check for countries attribute. Set it if we don't have it.
    _set_countries($self) if $self->{_name};
    
    return $self->{_countries};
}

# Private method to set an attribute with a hash of objects for all countries using this currency.
sub _set_countries
{
    my $self = shift;

    my $code = $self->{_code};
    
    # Do nothing if the list already exists.
    return if $existing->{$code}->{'_countries'};
    
    # If it doesn't, find all countries using this currency and put them in a hash.
    my (%country_codes, %countries);
    
    foreach my $result ( $db->lookup_all(
                                        table => "currency", 
                                        result_column => "country_code", 
                                        search_column => "code", 
                                        value => $existing->{$code}->{'_code'} ) )
    {
      $country_codes{$result} = 1;
    }
    
    # Create new country objects and put them into a hash.
    foreach my $where (keys %country_codes)
    {
      my $obj = Locale::Object::Country->new( code_alpha2 => $where );
      $countries{$where} = $obj;
    }
    
    # Set a reference to that hash as an attribute.
    $existing->{$code}->{'_countries'} = \%countries;       
}

# Small methods that return object attributes.
# Will refactor these into an AUTOLOAD later.

sub code
{
  my $self = shift;  
  $self->{_code};
}

sub name
{
  my $self = shift;  
  $self->{_name};
}

sub code_numeric
{
  my $self = shift;  
  $self->{_code_numeric};
}  

sub symbol
{
  my $self = shift;  
  $self->{_symbol};
}

sub subunit
{
  my $self = shift;  
  $self->{_subunit};
}

sub subunit_amount
{
  my $self = shift;  
  $self->{_subunit_amount};
}

1;

__END__

=head1 NAME

Locale::Object::Currency - currency information objects

=head1 VERSION

0.11

=head1 DESCRIPTION

C<Locale::Object::Country> allows you to create objects containing information about countries such as their ISO codes, currencies and so on.

=head1 SYNOPSIS

    use Locale::Object::Currency;

    my $usd = Locale::Object::Currency->new( country_code => 'us' );

    my $name           = $usd->name;
    my $code           = $usd->code;
    my $code_numeric   = $usd->code_numeric;
    my $symbol         = $usd->symbol;
    my $subunit        = $usd->subunit;
    my $subunit_amount = $usd->subunit_amount;
    
    my %countries = %{$usd->countries};

=head1 METHODS

=head2 C<new()>

    my $usd = Locale::Object::Currency->new( country_code => 'us' );

The C<new> method creates an object. It takes a single-item hash as an argument - valid options to pass are ISO 3166 values - 'code', 'code_numeric' and 'name', and also 'country_code', which is an alpha2 country code (see L<Locale::Object::DB::Schemata> for details on these). If you give a country code, a currency object will be created representing the currency of the country you specified.

The objects created are singletons; if you try and create a currency object when one matching your specification already exists, C<new()> will return the original one.

=head2 C<name, code, code_numeric, symbol, subunit, subunit_amount>

    my $name = $country->name;
    
These methods retrieve the values of the attributes in the object whose name they share.

=head2 C<countries>

    my %countries = %{$usd->countries};

Returns a hash of L<Locale::Object::Country> objects with their ISO 3166 alpha2 codes as keys (see L<Locale::Object::DB::Schemata> for more details on those) for all countries using this currency. These have their own attribute methods, so you can do things like this for example:

    foreach my $country (sort keys %countries)
    {
      print "- ", $countries{$country}->name, "\n";
    }
    
    # prints:
    # - American Samoa
    # - Guam
    # - Palau
    # - Puerto Rico 
    # - Turks and Caicos Islands
    # - United States 
    # - Virgin Islands, British
    # - Virgin Islands, U.S.
    
See the documentation for L<Locale::Object::Country> for a listing of country attributes.

=head1 KNOWN BUGS

The database of currency information is not perfect by a long stretch. If you find mistakes or missing information, please send them to the author.

=head1 AUTHOR

Earle Martin <EMARTIN@cpan.org>

=over 4 

=item L<http://purl.oclc.org/net/earlemartin/>

=back

=head1 CREDITS

See the credits for L<Locale::Object>.

=head1 LEGAL

Copyright 2003 Fotango Ltd. All rights reserved. L<http://opensource.fotango.com/>

This module is released under the same license as Perl itself, and is provided on an "as is" basis. The author and Fotango Ltd make no warranties of any kind, either expressed or implied, as to the accuracy and/or utility of any results obtained from its use. However, if you do find something wrong with the results, please let the author know. Thanks.

=cut

