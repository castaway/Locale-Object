package Locale::Object::Continent;

use strict;
use warnings::register;
use Carp qw(croak);
use vars qw($VERSION);

use Locale::Object::Country;
use Locale::Object::DB;

$VERSION = "0.11";

my $db = Locale::Object::DB->new();

# Initialize the hash where we'll keep our singleton continent objects.
my $existing = {};

# Yours is the hash, and everything that's in it.
my %continents = map { $_ => undef }
  ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America');
  
# Call init() with the parameters we got.
sub new
{
  my $class = shift;
  my %params = @_;
  
  # New Continent object.
  my $self = bless {}, $class;
  
  # Check for pre-existing objects. Return it if there is one.
  my $continent = $self->exists($params{name});
  return $continent if $continent;
  
  # If not, initialize a new one.
  $self->init(%params);
}

# Initialize the object.
sub init
{
  my $self = shift;
  my %params = @_;
  return unless %params;
  
  # Two's a crowd.
  my $num_params = keys %params;
  
  croak "Error: No continent name specified for initialization." unless $params{name};
  croak "Error: You can only specify a single continent name for initialization."
      if $num_params > 1;
      
  # Check for pre-existing objects. Return it if there is one.  
  my $continent = $self->exists($params{name});
  return $continent if $continent;
  
  # Initialize with a continent name.
  my $name = $params{name};
  $self->{_name} = $name;

  # Register the new object.
  $self->register();
  
  # Return the object.
  $self;
}

# Check if objects exist in the singletons hash.
sub exists {
  my $self = shift;
  
  # Check existence of a object with the given parameter or with
  # the name of the current object.
  my $name = shift;
  
  # Return the singleton object, if it exists.
  $existing->{$name};
}

# Register the object as a singleton.
sub register {
  my $self = shift;
  
  # Do nothing unless the object has a name.  
  my $name = $self->name or return;
  
  # Put the current object into the singleton hash.
  $existing->{$name} = $self;
}

sub name
{
  my $self = shift;
  my $name = shift;
  
  # If no arguments were given, return the name attribute of the current object. 
  # Otherwise, carry on and set one on the current object.
  return $self->{_name} unless defined $name;
  
  # Check we didn't fall off the edge of the world.
  # http://www.maphist.nl/extra/herebedragons.html
  croak "Error: unknown continent name given for initialization: '$name'" unless exists $continents{$name};
  
  # Set the name.
  $self->{_name} = $name;
  
  # If a Continent object with that name exists, return it. 
  if (my $continent = $self->exists( $name ))
  {
    return $continent;
  }
  # Otherwise, register the current object as a singleton.
  else
  {
    $self->register();
  }
  
  # Return the current object.
  $self;
}

# Method for retrieving all countries in this continent.
sub countries
{
    my $self = shift;
    
    # Check for countries attribute. Set it if we don't have it.
    _set_countries($self) if $self->{_name};
    
    return $self->{_countries};
}

# Private method to set an attribute with a hash of objects for all countries in this continent.
sub _set_countries
{
    my $self = shift;

    # Do nothing if the list already exists.
    return if $self->{_countries};

    my (%country_codes, %countries);
    
    # If it doesn't, find all countries in this continent and put them in a hash.
    foreach my $result ( $db->lookup_all(
                                        table => "continent", 
                                        result_column => "country_code", 
                                        search_column => "name", 
                                        value => $self->{'_name'} ) )
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
    $self->{'_countries'} = \%countries;
}

1;

__END__

=head1 NAME

Locale::Object::Continent - continent information objects

=head1 VERSION

0.11

=head1 DESCRIPTION

C<Locale::Object::Continent> allows you to create objects representing continents, that contain other objects representing the continent in question's countries.

=head1 SYNOPSIS

    my $asia                     = Locale::Object::Continent->new( name => 'Asia' );

    my $name                     = $asia->name;
    my %countries                = %{$asia->countries};
    my $currency_of_afghanistan  = $countries{'af'}->currency->name;

=head1 METHODS

=head2 C<new()>

    my $asia = Locale::Object::Continent->new( name => 'Asia' );
    
The C<new> method creates an object. It takes a single-item hash as an argument - the only valid options to it is 'name', which must be one of 'Africa', 'Asia', 'Europe', 'North America', 'Oceania' or 'South America'. Support for Antarctic territories is not currently provided.

The objects created are singletons; if you try and create a continent object when one matching your specification already exists, C<new()> will return the original one.

=head2 C<name>

    my $name = $asia->name;
    
Retrieves the value of the continent object's name.

=head2 C<countries>

Returns a hash of L<Locale::Object::Country> objects with their ISO 3166 alpha2 codes as keys (see L<Locale::Object::DB::Schemata> for more details on those). These have their own attribute methods, so you can do things like this:

    my %countries                = %{$asia->countries};
    my $currency_of_afghanistan  = $countries{'af'}->currency->name;

See the documentation for L<Locale::Object::Country> for a listing of country attributes.

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
