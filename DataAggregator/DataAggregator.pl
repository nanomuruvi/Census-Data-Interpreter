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


my $EMPTY = q{};
my $SPACE = q{ };
my $COMMA = q{,};
my $BAR   = q{|};
my $bar   = Text::CSV->new({ sep_char => $BAR});
my $csv   = Text::CSV->new({ sep_char => $COMMA});

my @relevantYears = (2014,2015);
my @provinces = ("Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island","Saskatchewan","Alberta","Newfoundland and Labrador","Yukon","Northwest Territories","Nunavut");

print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated.";

print "\n\nPlease answer the following questions with either 'yes' or 'no': ";

question("questions");

# File Input Subroutine
sub ParseFile{

    my @records;
    my @year;
    my @value;
    my @location;

    my $recordCount = 0;
    my $filename = $_[0];

    # Open, close file, load contents into record array
    open my $crime_data_fh, '<', $filename
        or die "Unable to open data file: $filename\n";
    @records = <$crime_data_fh>;
    close $crime_data_fh
        or die "Unable to close: $filename\n";

    $recordCount = 0;
    foreach my $counter (@records) {
        if ($csv->parse($counter)) {
            my @fields = $csv->fields();
            $year[$recordCount]     = $fields[0];
            $value[$recordCount]    = $fields[1];
            $location[$recordCount] = $fields[2];
            print  "Year: (".$year[$recordCount].") Value: (".$value[$recordCount].") Location: (".$location[$recordCount].")\n";
        $recordCount++;
        } else {
            warn "Line/record could not be parsed: $records[$recordCount]\n";
        }
    }
    dataFinder(\@year, \@value, \@location);
}

#Question asking subroutine
#Takes in a file path as the parameter and asks all the questions in the file
sub question{
    my $dataFile = $_[0];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records;
    my $record;
    my $recordNum = 0;
    
    my @prompts;
    my @results;
    my @files;
    my @userInput;
    
    print "There are $recordAmnt records\n";
    for(my $i = 0;$i < $recordAmnt;$i++){
        $recordNum++;
        $record = $records[$i];
        if($csv->parse($record)){
            my @fields = $csv->fields();
            
            $prompts[$i] = $fields[0];

            $results[$i] = $fields[1];
            $files[$i] = $fields[2];
           
            print $recordNum.". $prompts[$i]\n";
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
sub isRelevant{
    my $value = $_[0];
    my @array = @{$_[1]};
    return grep( /^$value$/, @array );
}


sub dataFinder{

    my @values;
    my @year = @{$_[0]};
    my @value = @{$_[1]};
    my @location = @{$_[2]};

    my $counter = 0;
    my $recordAmount = $#year;

    for(my $i = 0; $i < $recordAmount+1; $i++){
        print $i.". ".$year[$i]." - ";
        if( isRelevant($year[$i], \@relevantYears) ){
            print $location[$i]." - ";
            if( isRelevant($location[$i], \@provinces) ){
                $values[$counter] = $value[$i];
                $location[$counter] = $location[$i];
                print $values[$counter];
                $counter++;
            }

        }
        print "\n";

    }
    


}
