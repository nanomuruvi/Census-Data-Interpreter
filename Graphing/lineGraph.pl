#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Statistics::R;

my $infilename;
my $pdffilename;

#
#   Check that you have the right number of parameters
#
if ($#ARGV != 1 ) {
   print "Usage: plotNames.pl <input file name> <pdf file name>\n" or
      die "Print failure\n";
   exit;
} else {
   $infilename = $ARGV[0];
   $pdffilename = $ARGV[1];
}  

print "input file = $infilename\n";
print "pdf file = $pdffilename\n";

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Name the PDF output file for the plot  
#my $Rplots_file = "./Rplots_file.pdf";

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename")`);

# plot the data as a line plot with each point outlined
$R->run(q`ggplot(data, aes(x=Year, y=Score, colour=Name, group=Name)) + geom_line() + geom_point(size=2) + ggtitle("Popularity of Names") + ylab("Ranking") + scale_y_continuous(breaks=c(0,1,2,3,4,5,6,7,8), labels=c("None", "> 2000", "1000-2000", "500-999", "200-499", "100-199", "50-99", "11-49", "1-10")) `);
# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();
