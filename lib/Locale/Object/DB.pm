package Locale::Object::DB;

use strict;
use warnings::register;
use Carp qw(croak);
use vars qw($VERSION);

use DBI;
use File::Spec;

$VERSION = "0.11";

# The database should be in the same directory as this file. Get the location.
my (undef, $path) = File::Spec->splitpath(__FILE__);
my $db = $path . 'locale.db';

# Check it's a binary file in the right location.
croak "FATAL ERROR: The Locale::Object database was not in '$path', where I expected it. Please check your installation." unless -B $db;

# Make a hash of allowed table names for searches.
my %allowed_tables = map { $_ => 1 }
  qw(continent country currency language);
  
# Make a hash of allowed column names for searches.
my %allowed_columns = map { $_ => 1 }
  qw(country_code name name_native primary_language main_timezone uses_daylight_savings
  code code_numeric symbol subunit subunit_amount code_alpha2 code_alpha3);  

# Make a new object.
sub new
{
  my $class = shift;
  my $self = bless {} => ref($class) || $class;
  
  return $self;  
}

# Connect to our database.
my $dbh = DBI->connect("dbi:SQLite:dbname=$db", "", "", 
{ 
  PrintError => 1, RaiseError => 1, AutoCommit => 1
} ) or croak DBI::errstr;


# Database lookup routine.
sub lookup
{  
  my ($self, $table, $what, $value) = @_;

  # Sanity check for table parameter.
  _check_search_params($table);
  
  # Return an array of the stuff returned from an SQL query for rows with the $what 
  # column matching $value.
  
  my @results = $dbh->selectrow_array("SELECT * FROM $table WHERE $what=?", {}, $value);

  # Croak if no match.
  croak "Error: No result when looking in '$table' for a '$what' of '$value'." unless @results;
  
  return @results;
}

# Method to return all values of 'result_column' in 'table' in rows that 
# have 'value' in 'search_column'.
sub lookup_all
{
  my ($self, %params) = @_;

  # There are four required parameters to this method.
  my @required = qw(table result_column search_column value);
  
  # Croak if any of them are missing.
  for (0..$#required)
  {
    croak "Error: could not do lookup_all: no '$required[$_]' specified." unless defined($params{$required[$_]});
  }

  # Validate parameters.
  _check_search_params($params{table}, $params{result_column}, $params{search_column});
  
  # Prepare the SQL statement. 
  my $sth = $dbh->prepare(
    "SELECT $params{result_column} from $params{table} WHERE $params{search_column}=?"
  ) or croak "Error: Couldn't prepare SQL statement: " . DBI::errstr;

  # Execute it.
  $sth->execute($params{value}) or croak "Error: Couldn't execute SQL statement: " . DBI::errstr;
  
  my @results;
  
  # Put each result into @results.
  while ( my @rows = $sth->fetchrow_array() ) {
    push @results, $rows[0] or croak "Error: Couldn't fetch database row: " . DBI::errstr;
  }
    
  return @results;
}

# Sub for sanity check on search parameters. Does nothing except croak if an error is encountered.
sub _check_search_params
{
  my ($table, $result_column, $search_column) = @_;
  
  # You can only specify a valid table name.
  croak "Error: $table is not a valid table."
  unless $allowed_tables{$table};
    
  # Check parameters for lookup_all().
  if ($result_column)
  {
    # You can only specify a valid column name.  
    croak "Error: $result_column is not a valid result column."
      unless $allowed_columns{$result_column};

    croak "Error: $search_column is not a valid search column." 
      unless $allowed_columns{$search_column};
  }
}

1;

__END__

=head1 NAME

Locale::Object::DB - do database lookups for Locale::Object modules

=head1 VERSION

0.11

=head1 DESCRIPTION

This module provides common functionality for the Locale::Object modules by doing lookups in the database that comes with them (which uses L<DBD::SQLite>).

=head1 SYNOPSIS

    use Locale::Object::DB;
    
    my $db = Locale::Object::DB->new();
    
    my $table = 'country';
    my $what  = 'name';
    my $value = 'Afghanistan';
    
    my @results = $db->lookup($table, $what, $value);

    my %countries;
    
    $table = 'continent';
    my $result_column = 'country_code';
    
    foreach my $result ( $db->lookup_all(
                                         table => $table, 
                                         result_column => $result_column, 
                                         search_column => $what, 
                                         value => $value) ) {
                                           
      # fill up %countries with countries in the same continent as $value
      $countries{$result} = 1; 
    }
    
=head1 METHODS

=head2 lookup()

    $db->lookup($table, $what, $value);
    
C<lookup> will return an array of results from a query of the database for a row matching the table name, column name and cell value that you specify. If no match was found, a message saying so will be returned. Any NULL values in matching rows will be returned in the results as UNDEF.

=head2 lookup_all()

    $db->lookup_all( table => $table, result_column => $result_column,
                     search_column => $search_column, value => $value );
    
C<lookup_all> will return an array of results for a query of the database for cells in $result_column in $table that are in a row that has $value in $search_column.

For information on what db tables are available and where the data came from, see L<Locale::Object::DB::Schemata>.

=head1 NOTES

The database file itself is named C<locale.db> and must reside in the same directory as this module. If it's not present, the module will croak with a fatal error.

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

