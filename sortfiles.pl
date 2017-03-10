#!/usr/bin/perl

#The given file's format is :
#     {Year,Location,Violation,Statistic,Vector,Coordinate,Value}
#The output file will be in "Violation/Statistic.csv" in the format:
#     {Year,Value,Location,Coordinate,Vector}
#
#

use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32;
use Data::ArrayList;

my $EMPTY      = q{};
my $SPACE      = q{ };
my $COMMA      = q{,};
my $SLASH      = q{/};

my $folders    = Text::CSV->new({ sep_char => $SLASH });
my $csv        = Text::CSV->new({ sep_char => $COMMA });

my $filename = $EMPTY;
my @records;

my $violation;
my $location;
my $year;
my $value;
my $coordinate;
my $vector;

if ($#ARGV != 0 ) {
   print "Usage: sortfiles.pl <names file>\n" or
      die "Print failure\n";
   exit;
} else {
   $filename = $ARGV[0];
}

open my $names_fh, '<', $filename
   or die "Unable to open names file: $filename\n";
print "File: $filename\n";
@records = <$names_fh>;
close $names_fh or
   die "Unable to close: $ARGV[0]\n";

my $line = 0;

my $folder;
my $file;
foreach my $record ( @records ) {
   if ( $csv->parse($record) ) {
      my @fields = $csv->fields();
      $folder = $fields[2];
      $file = $fields[3];
      makeFile( $folder, $file);
      print "$fields[0],$fields[6],$fields[1],$fields[5],$fields[4]\n";
   } else {
      warn "Line/record \'$line\' could not be parsed.\n";
   }
   $line++;
}

sub makeFile{
   my $path = stringConsoleSafe($_[0]);
   my $file = stringConsoleSafe($_[1]);

   system("mkdir $path; touch $path/$file");
}

#Makes a string console safe by adding "\" infront of any spaces that are present
#TODO: populate arraylsit with every character of the string then add '\' characters infront of spaces then send all the characters back to the string.
sub stringConsoleSafe{
   my $string = stringConsoleSafe($_[0]);
   my $i=0;
   my $charArray = Data::ArrayList->new(my $initialSize = 5);

   for($i = 0;$i<length $string;$i++){
   }
   return $string;
}