=for comment
	This script makes a plot given an input file
=cut

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Statistics::R;
use Text::CSV  1.32;

my $EMPTY	= q{};
my $SPACE	= q{ };
my $COMMA	= q{,};

my $R = Statistics::R->new();
my $csv		= Text::CSV->new({ sep_char => $COMMA });

=for comment
	The outputPDF and inputData files are pretty self explanatory.
	The plotType refers to the specific plot which shall be made, these include: "boxplot"
	The inputData must be columns of data with a location as the column header with the 
	location data underneath in a numerical format. If there is no value it should be left empty
	Data values should remain in their respective columns
=cut
my $outputPDF;
my $inputData;
my $plotType;
my $xLab;
my $yLab;

if ($#ARGV != 2 ) {
   print "Usage: plotNames.pl <input file name> <pdf file name> <plot type>\n" or
      die "Print failure\n";
   exit;
} else {
	$inputData	= $ARGV[0];
	$outputPDF 	= $ARGV[1];
	$plotType	= $ARGV[2];
}

$R -> run(qq`pdf("$outputPDF" , paper="letter")`);
$R -> run(q`library(ggplot2)`);

if($plotType eq"boxplot"){
	boxplot($inputData);
}elsif("bargraph"){
	barGraph($inputData);
}

$R -> run(q`dev.off()`);

$R -> stop();

sub boxplot{
	my $file = $_[0];
	$R -> run(qq`data <- read.csv("$file")`);
	$R -> run(q`attach(data)`);
	$R -> run(q`boxplot(data)`);
}

sub barGraph{
	my $file = $_[0];
	$R -> run(qq`data <- read.csv("$file")`);
	$R -> run(q`attach(data)`);
	$R -> run(q`barplot(data)`);
}

sub lineGraph{
	$R -> run(qq`data <- read.csv("$file")`);
	$R -> run(q`attach(data)`);
	$R -> run(q`ggplot(data, aes(x=Year, y=Score, colour=Name, group=Name)) + geom_line() + geom_point(size=2) + ggtitle("Popularity of Names") + ylab("Ranking") + scale_y_continuous(breaks=c(0,1,2,3,4,5,6,7,8), labels=c("None", "> 2000", "1000-2000", "500-999", "200-499", "100-199", "50-99", "11-49", "1-10")) `);
}