=for comment
	This script makes sure the data is in a format which the graphing script will understand
=cut
use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Statistics::R;
use Text::CSV  1.32;

my $EMPTY	= q{};
my $SPACE	= q{ };
my $COMMA	= q{,};

my $csv		= Text::CSV->new({ sep_char => $COMMA });

#The outputPDF and inputData files are pretty self explanatory.
#The plotType refers to the specific plot which shall be made, these include: "boxplot"
my $outputPDF;
my $inputData;
my $plotType;


if ($#ARGV != 2 ) {
   print "Usage: plotNames.pl <input file name> <pdf file name> <plot type>\n" or
      die "Print failure\n";
   exit;
} else {
	$inputData	= $ARGV[0];
	$outputPDF 	= $ARGV[1];
	$plotType	= $ARGV[2];
}