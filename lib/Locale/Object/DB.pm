package Locale::Object::DB;

use strict;
use warnings::register;
use Carp qw(croak);
use vars qw($VERSION);

use DBI;
use File::Spec;

$VERSION = "0.31";

# The database should be in the same directory as this file. Get the location.
my (undef, $path) = File::Spec->splitpath(__FILE__);
my $db = $path . 'locale.db';

# Check it's a binary file in the right location.
croak "FATAL ERROR: The Locale::Object database was not in '$path', where I expected it. Please check your installation." unless -B $db;

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


# Method to return all values of 'result_column' in 'table' in rows that 
# have 'value' in 'search_column'.

sub lookup
{
  my ($self, %params) = @_;

  # There are four required parameters to this method.
  my @required = qw(table result_column search_column value);
  
  # Croak if any of them are missing.
  for (0..$#required)
  {
    croak "Error: could not do lookup: no '$required[$_]' specified." unless defined($params{$required[$_]});
  }

  # Validate parameters.
  _check_search_params($params{table}, $params{result_column}, $params{search_column});
  
  # Prepare the SQL statement. 
  my $sth = $dbh->prepare(
    "SELECT $params{result_column} from $params{table} WHERE $params{search_column}=?"
  ) or croak "Error: Couldn't prepare SQL statement: " . DBI::errstr;

  # Execute it.
  $sth->execute($params{value}) or croak "Error: Couldn't execute SQL statement: " . DBI::errstr;
  
  # Return a reference to an array of hashes.
  return $sth->fetchall_arrayref({});
}

# Get a value for a cell in a row which matches 2 columns and their values specified.
sub lookup_dual
{
  my ($self, %params) = @_;

  # Required parameters for this method.
  my @required = qw(table result_col col_1 val_1 col_2 val_2);
  
  # Croak if any of them are missing.
  for (0..$#required)
  {
    croak "Error: could not do lookup_dual: no '$required[$_]' specified." unless defined($params{$required[$_]});
  }

  # Validate parameters.
  _check_search_params($params{table}, $params{result_col}, $params{col_1}, $params{val_1}, $params{col_2}, $params{val_2});
  
  # Prepare the SQL statement. 
  my $sth = $dbh->prepare(
    "SELECT $params{result_col} from $params{table} WHERE $params{col_1}=? AND $params{col_2}=?"
  ) or croak "Error: Couldn't prepare SQL statement: " . DBI::errstr;

  # Execute it.
  $sth->execute($params{val_1}, $params{val_2})
    or croak "Error: Couldn't execute SQL statement: " . DBI::errstr;
  
  # Return a reference to an array of hashes.
  return $sth->fetchall_arrayref({});
}


# Make a hash of allowed table names for searches.
my %allowed_tables = map { $_ => 1 }
  qw(continent country currency language language_mappings);
  
# Make a hash of allowed column names for searches.
my %allowed_columns = map { $_ => 1 }
  qw(country_code name name_native primary_language main_timezone 
  uses_daylight_savings code code_numeric symbol subunit subunit_amount 
  code_alpha2 code_alpha3 id country language official *);  

# Sub for sanity check on search parameters. Does nothing except croak if an error is encountered.
sub _check_search_params
{
  my ($table, $result_column, $search_column) = @_;
  
  # You can only specify a valid table name.
  croak "Error: $table is not a valid table."
  unless $allowed_tables{$table};
    
  # Check parameters.
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

0.31 - this refers also to the accompanying database file, and will be incremented if that is updated.

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
    
    my $results = $db->lookup(
                              table         => $table, 
                              result_column => $result_column, 
                              search_column => $what, 
                              value         => $value
                             );
                                           
    foreach my $item (@{$results})
    {
      print $item->{$result_column};
    }

    $result = $db->lookup_dual(
                               table      => $table, 
                               result_col => $result_column, 
                               col_1      => $first_search_column, 
                               val_1      => $first_search_value,
                               col_2      => $second_search_column,
                               val_2      => $second_search_value
                              );
    
=head1 METHODS

=head2 C<lookup()>

    $db->lookup(
                table         => $table,
                result_column => $result_column,
                search_column => $search_column,
                value         => $value
               );
    
C<lookup> will return a reference to an anonymous array of hashes. The hashes will contain the results for a query of the database for cells in $result_column in $table that are in a row that has $value in $search_column. Use '*' as a value for result_column if you want to retrieve whole rows.

For information on what db tables are available and where the data came from, see L<Locale::Object::DB::Schemata>.

IMPORTANT: The way of using this method has changed as of version 0.2, and in addition it supersedes the place formerly taken by C<lookup_all()>. Apologies for any inconvenience.

=head2 C<lookup_dual()>

    my $result = $db->lookup_dual(
                                  table      => $table, 
                                  result_col => $result_column, 
                                  col_1      => $first_search_column, 
                                  val_1      => $first_search_value,
                                  col_2      => $second_search_column,
                                  val_2      => $second_search_value
                                 );

C<lookup_dual> will return a reference to an anonymous array of hashes. The hashes will contain the results for a query of the database for cells in C<$result_column> in C<$table> that are in a row that has two specified values in two specified columns. Use '*' as a value for C<$result_column> if you want to retrieve whole rows.
                                 
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

