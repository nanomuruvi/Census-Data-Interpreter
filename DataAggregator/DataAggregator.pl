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


#
# Get input from user
#
print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated.";

print "\n\nPlease answer the following questions with either 'yes' or 'no': ";

question("questions");

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
            $year[$record_count]     = $master_fields[0];
            $value[$record_count]    = $master_fields[1];
            $location[$record_count] = $master_fields[2];
            print  $year[$record_count]." ".$value[$record_count]."\n";
            #print $year[$record_count]."\n".$value[$record_count]."\n".$location[$record_count]."\n";
	    $record_count++;
        } else {
            warn "Line/record could not be parsed: $records[$record_count]\n";
        }
    }
    dataFinder(\@year, \@value, \@location);
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
sub isRelevant{
    my @provinces = ("Canada","Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island","Saskatchewan","Alberta","Newfoundland and Labrador");
    my $location = $_[0];
    
    if($location~~ @provinces){
        return 1;
    } else {
        return 0;
    }

}
sub dataFinder{
    my @values;
    my $counter = 0;
    my @year = @{$_[0]};
    my @value = @{$_[1]};
    my @location = @{$_[2]};
    my $record_count = $#year;

    for(my $i = 0; $i < $record_count+1; $i++){
        if($year[$i] eq 2015){
            print "match";
            if(isRelevant($location[$i])){
                $values[$counter] = $value[$i];
                print $values[$counter]."WOOHOO\n";
                $counter++;
            }

        }

    }
    


}
