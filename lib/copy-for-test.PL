#!/usr/bin/perl

use warnings;
use strict;

use File::Copy;

my @dirs = ('blib', '/lib', '/Locale', '/Object');

my $where = '';

foreach my $dir (@dirs)
{
  $where = $where . $dir;

  mkdir $where;
  die "Couldn't make $where directory: $!" unless $! =~ /File exists/;
}

copy('lib/Locale/Object/locale.db', 'blib/lib/Locale/Object/locale.db') or die "Couldn't copy locale database: $!";

=head1 What this script does

The L<Locale::Object> modules come with a L<DBD::SQLite> database of information that they consult. That file needs to be in the same directory as L<Locale::Object::DB>. This script copies it into C<blib/lib/Locale/Object/> (creating those directories, if need be) when you run the Build script, in order that L<Locale::Object::DB> will be able to find it when you do a C<./Build test>.

=cut
