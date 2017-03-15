#!/usr/bin/perl

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

#
# markham.pl
# Authors: Mitchell Knauer, Jovana Kusic, Kelsey Kirkland, Nano Muruvi
# Date of Last Update: March 15, 2017
# Functional Summary:
#     This program takes in a number of csv files from Stats Canada (dependant on the users input), and asks them
#     questions about themselves in order to help the user determine which province in Canada would suit them best.
#     It will display a bar graph depicting the top provinces.
#

#
# Variables to be Used
#
my $EMPTY = q{};
my $SPACE = q{ };
my $COMMA = q{,};
my $BAR = q{|};
my $bar = Text::CSV->new({ sep_char => $BAR});
my $csv = Text::CSV->new({ sep_char => $COMMA});

my $input;
my $filename;

#
# Get input from user
#
print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated.";

print "\n\nPlease answer the following questions with either 'yes' or 'no': ";

#question("questions");

print "\nDo you own a car?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
    print "\nYou answered 'yes' to owning a car, so we will look through the 'Total impaired driving' data.";
    $filename = "Data/Total impaired driving/Actual incidents.csv";
    ParseFile($filename);
}

print "\nDo you own property, or are you going to own property?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
    print "\nYou answered 'yes' to owning property, so we will look through the 'Total property crime violations' data.";
    $filename = "Data/Total property crime violations/Actual incidents.csv";
    ParseFile($filename);
}

print "\nDo you have kids?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
    print "\nYou answered 'yes' to having kids, so we will look through the 'Total sexual violations against children' data.";
    $filename = "Data/Total sexual violations against children/Actual incidents.csv";
    ParseFile($filename);
}

print "\nIs the presence of drugs a concern?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
}

print "\nIs the presence of weapons a concern?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
}

print "\nIs theft and robbery a concern?: ";
$input = <>;
chomp $input;
if ($input eq "yes") {
}


#
# File Input Subroutine
#
sub ParseFile{
    my @records;
    my $record_count = 0;
    my @year;
    my @value;
    my @location;
    my $filename = $_[0];

    #
    # Open, close file, load contents into record array
    #
    open my $crime_data_fh, '<', $filename
        or die "Unable to open data file: $filename\n";
    @records = <$crime_data_fh>;
    close $crime_data_fh
        or die "Unable to close: $filename\n";

    $record_count = 0;
    foreach my $counter (@records) {
        if ($bar->parse($counter)) {
            my @master_fields = $bar->fields();
            $record_count++;
            $year[$record_count]     = $master_fields[0];
            $value[$record_count]    = $master_fields[1];
            $location[$record_count] = $master_fields[2];
            print  $year[$record_count]." ".$value[$record_count]."\n";
            #print $year[$record_count]."\n".$value[$record_count]."\n".$location[$record_count]."\n";
        } else {
            warn "Line/record could not be parsed: $records[$record_count]\n";
        }
    }
}
sub question{
    my $dataFile = $_[0];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records;
    my $record;
    
    my @prompts;
    my @results;
    my @files;
    my @userInput;
    
    print "There are $recordAmnt records\n";
    for(my $i = 0;$i < $recordAmnt;$i++){
        $record = $records[$i];
        if($csv->parse($record)){
            my @fields = $csv->fields();
            
            $prompts[$i] = $fields[0];
            $results[$i] = $fields[1];
            $files[$i] = $fields[2];
            
            print $prompts[$i]."\n";
            $userInput[$i] = <>;
            chomp $userInput[$i];

            if(lc($userInput[$i]) eq "yes"){
                print $results[$i]."\n";
                ParseFile($files[$i]);
            }
        }else{
            warn "Failed to parse question $i.";
        }
    }
}
