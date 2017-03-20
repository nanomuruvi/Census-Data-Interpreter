use strict;
use warnings;
use Switch;
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
   print "Usage: plotNames.pl <input file name> <pdf file name>\n" or
      die "Print failure\n";
   exit;
} else () {
	$inputData	= $ARGV[0];
	$outPDF 	= $ARGV[1];
	$plotType	= $ARGV[2];
}

my $R = Statistics::R->new();

my $RCommand;

$R -> run(qq`pdf("$pdffilename" , paper="letter")`);
$R -> run(q`library(ggplot2)`);

switch($plotType){
	case "boxplot"	{ $RCommand = boxplot() }
	case "bargraph"	{ $RCommand = bargraph() }
	else { $RCommand = q`boxplot(c(1,2,3,4,4,4,4,4,4,5,5,5,6))` }
}

#TODO: Need to add takign of input and allow for multiple datasets
$R -> run($RCommand);

$R -> run(q`dev.off()`);
$R -> stop();

sub boxplot{
	my $command;
	return $command;
}

sub barGraph{
	my $command;
	return $command;
}