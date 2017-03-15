#!/usr/bin/perl

#The given file's format is :
#     {Year,Location,Violation,Statistic,Vector,Coordinate,Value}
#The output file will be in "Violation/Statistic.csv" in the format:
#     {Year,Value,Location,Coordinate,Vector}
#

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

my $EMPTY      = q{};
my $SPACE      = q{ };
my $COMMA      = q{,};
my $SLASH      = q{/};

my $folders    = Text::CSV->new({ sep_char => $SLASH });
my $csv        = Text::CSV->new({ sep_char => $COMMA });

my $filename = $EMPTY;
my $containingFolder = $EMPTY;
my @records;
my $limit = 0;
my $initialPosition = 0;

print "$#ARGV\n";
if ($#ARGV >= 5 ) {
   print "Usage: sortfiles.pl <records file> <containing folder> <limit>? <starting position>? <remove containing folder(yes or no)>?\n" or
      die "Print failure\n";
   exit;
}elsif ($#ARGV == 4){
   $filename = $ARGV[0];
   $containingFolder = $ARGV[1];
   $limit = $ARGV[2];
   $initialPosition = $ARGV[3];
   if($ARGV[4] eq "yes"){
      removeFolder($containingFolder);
   }
}elsif ($#ARGV == 3){
   $filename = $ARGV[0];
   $containingFolder = $ARGV[1];
   $limit = $ARGV[2];
   $initialPosition = $ARGV[3];
}elsif ($#ARGV == 2){
   $filename = $ARGV[0];
   $containingFolder = $ARGV[1];
   $limit = $ARGV[2];
} else {
   $filename = $ARGV[0];
   $containingFolder = $ARGV[1];
}

#removeFolder($containingFolder);

open my $fh, '<', $filename
   or die "Unable to open names file: $filename\n";
print "Input file: $filename\n";
@records = <$fh>;
close $fh or
   die "Unable to close: $ARGV[0]\n";

my $violation;
my $statistic;
my $location;
my $year;
my $value;
my $coordinate;
my $vector;

my $folder;
my $file;

my $line;
my $i;
my $recordAmt = $#records;

#Makes the maximum record number to be searched the maximum record number
$limit = (($limit>0)&&($limit<$recordAmt))?$limit:$recordAmt;

my $seperator = ',';

print "Records: $recordAmt, Initial Position: $initialPosition, Limit: $limit\n";

for($i=$initialPosition+1;$i<=$limit;$i++){

   my $record = $records[$i];
   if ( $csv->parse($record) ) {
      my @fields = $csv->fields();

      $year = $fields[0];
      $location = $fields[1];
      $violation = $fields[2];
      $statistic = $fields[3];
      $vector = $fields[4];
      $coordinate = $fields[5];
      $value = $fields[6];

      $folder = $violation;

      $folder = replaceString($folder,"/","or");
      $folder = replaceString($folder,"\$","");

      $file = "$statistic.csv";
      $file = replaceString($file,"/","or");
      $file = replaceString($file,"\$","");

      makeFolders( makeStringConsoleSafe($folder), makeStringConsoleSafe($containingFolder),makeStringConsoleSafe($file));
      
      $line = "$year$seperator$value$seperator\"$location\"$seperator$coordinate$seperator$vector";
      writeToFile( makeFileSystemSafe("$containingFolder/$folder/$file"),$line);

      print "#$i Coordinate: ($coordinate)\n";
   } else {
      warn "Line/record \'$line\' could not be parsed.\n";
   }
}

sub makeFolders{
   my $path = $_[0];
   my $container = $_[1];
   my $file = $_[2];
   my $fileFolder = "$container/$path";

   my $ce = -e $container;
   my $fe = -e $fileFolder;
   
   if(!$ce){
      system("mkdir $container");
      system("mkdir $fileFolder");
   }else{
      if(!$fe){
         system("mkdir $fileFolder");
      }
   }
   system("touch $fileFolder/$file");
}

sub makeStringConsoleSafe{
   my $string = $_[0];

   $string = replaceString($string," ","\\ ");
   $string = makeFileSystemSafe($string);

   return $string;
}

sub makeFileSystemSafe{
   my $string = $_[0];

   $string = replaceString($string,"(","[");
   $string = replaceString($string,")","]");

   return $string;
}
sub writeToFile{
   my $filePath = $_[0];
   my $data = $_[1];

   open(my $fh, '>>', "$filePath")
   or die "Could not open file \"$filePath\" $!";

   say $fh "$data";

   close $fh;
}

sub replaceString{
   my $i=0;
   my $string = $_[0];
   my $unwantedWord = $_[1];
   my $replacementString = $_[2];

   for($i = 0;$i<length $string;$i++){

      my $z = substr $string, $i, 1;

      if($z eq $unwantedWord){

         $z = substr $string, $i, 1, $replacementString;
         $i++;
      }
   }
   return $string;
}

sub removeFolder{
   system("rm -fr $_[0]");
}
