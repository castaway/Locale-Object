package Locale::Object;

use strict;
use warnings::register;
use vars qw($VERSION);

$VERSION = "0.52";

sub new
{
  my $class = shift;
  my %params = @_;

  my $self = bless {}, $class;
  
  # Initialize the new object or return an existing one.
  $self->init(%params);
}

1;

__END__

=head1 NAME

Locale::Object - OO locale information

=head1 VERSION

0.51

=head1 DESCRIPTION

The C<Locale::Object> group of modules attempts to provide locale-related information in an object-oriented fashion. The information is collated from several sources and provided in an accompanying L<DBD::SQLite> database.

At present, the modules are:

=over 4

* L<Locale::Object> - contains some common functionality for the other modules

* L<Locale::Object::Country> - objects representing countries

* L<Locale::Object::Continent> - objects representing continents

* L<Locale::Object::Currency> - objects representing currencies

* L<Locale::Object::Currency::Converter>  - convert between currencies

* L<Locale::Object::DB> - does lookups for the modules in the database

* L<Locale::Object::DB::Schemata> - documents the database, including all data sources.

* L<Locale::Object::Language> - objects representing languages

=back

For more information, see the documentation for those modules. Forthcoming releases will include  C<Locale::Object::Timezone>.

=head1 KNOWN BUGS

The database of currency information is not perfect by a long stretch. If you find mistakes or missing information, please send them to the author.

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
