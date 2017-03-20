use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Statistics::R;
use Text::CSV  1.32;

my $EMPTY      = q{};
my $SPACE      = q{ };
my $COMMA      = q{,};

my $csv        = Text::CSV->new({ sep_char => $COMMA });

my $infilename;
my $pdffilename;


#possibly make it so if there are more than 2 command line arguments then the ones after the input file name are the other datasets to use for a comparison or split
if ($#ARGV < 1 ) {
   print "Usage: plotNames.pl <input file name> <pdf file name>\n" or
      die "Print failure\n";
   exit;
} else {
   $infilename = $ARGV[0];
   $pdffilename = $ARGV[1];
}

my $R = Statistics::R->new();

$R -> run(qq`pdf("$pdffilename" , paper="letter")`);
$R -> run(q`library(ggplot2)`);

#TODO: Need to add takign of input and allow for multiple datasets
$R -> run(q`boxplot(c(1,2,3,4))`);

$R -> run(q`dev.off()`);
$R -> stop();