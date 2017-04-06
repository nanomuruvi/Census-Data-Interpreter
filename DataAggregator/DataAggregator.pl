#!/usr/bin/perl

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

use lib 'lib';
use Location;
use ArrayList;

require 'lib/LilRoutines.pl';

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

my @relevantYears = (2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005);
my @provinces = ("Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island",
    "Saskatchewan","Alberta","Newfoundland and Labrador","Yukon","Northwest Territories","Nunavut");


print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated.";

print "\n\nPlease answer the following questions with either 'yes' or 'no': ";

my $dataInfo = "";

questions("questions");

# File Input Subroutine
sub parseFile{

    my @records;
    my @year;
    my @value;
    my @location;

    my $recordCount = 0;
    my $filename = $_[0];

    # Open, close file, load contents into record array
    open my $crimeData, '<', $filename
        or die "Unable to open data file: $filename\n";
    @records = <$crimeData>;
    close $crimeData
        or die "Unable to close: $filename\n";

    $recordCount = 0;

    my $v;
    foreach my $counter (@records) {
        if ($csv->parse($counter)) {
            my @fields = $csv->fields();
            $year[$recordCount]     = $fields[0];
            $v = $fields[1];
            if($v eq ".."){
                $v = "";
            }
            $value[$recordCount]    = $v;
            $location[$recordCount] = $fields[2];
            $recordCount++;
        } else {
            warn "Line/record could not be parsed: $records[$recordCount]\n";
        }
    }
    dataFinder(\@year, \@value, \@location);
}

#Question asking subroutine
#Takes in a file path as the parameter and asks all the questions in the file
sub questions{
    my $dataFile = $_[0];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records+1;
    my $record;
    my $fp;
    my $recordNum = 0;
    
    my @prompts;
    my @results;
    my @files;
    my @userInput;
    
    print "There are $recordAmnt questions.\n";
    for(my $i = 0;$i < $recordAmnt;$i++){
        $recordNum++;
        $record = $records[$i];
        if($csv->parse($record)){
            my @fields = $csv->fields();
            
            $prompts[$i] = $fields[0];
            $results[$i] = $fields[1];
            $files[$i] = $fields[2];
            $dataInfo = $fields[3];
 
            print "\n$recordNum. $prompts[$i]\n";          
            $userInput[$i] = <>;
            chomp $userInput[$i];

            if(lc($userInput[$i]) eq "yes"){
                print $results[$i]."\n";
                parseFile($files[$i]);
            }elsif(lc($userInput[$i]) eq "x"){
                $i = $recordAmnt;
            }
        }else{
            warn "Failed to parse question #".(1+$i)."\n";
        }
    }
}



sub dataFinder{
    my @year = @{$_[0]};
    my @values = @{$_[1]};
    my @locations = @{$_[2]};

    my $locationList = new ArrayList();

    my @relevantValues;
    my @relevantLocations;

    my $counter = 0;
    my $recordAmount = $#year+1;

    my @yearValueStrings;
    my $yearValueString = "";
    my $header = "Year";
    
    my @addedLocations;
    my @addedYears;

    my $i =0;
    my $s = 0;
    my $t = 0;
    my $ls = 0;

    for($i = 0; $i < ($recordAmount/2); $i++){
        if(isInside( $year[$i], \@relevantYears)){
            if(isInside( $locations[$i], \@provinces)){
                
                $relevantValues[$counter] = $values[$i];
                $relevantLocations[$counter] = $locations[$i];
                if(!isSContained($relevantLocations[$counter],\@addedLocations)){
                    $addedLocations[$s] = $relevantLocations[$counter];
                    $header = $header.",\"".$addedLocations[$s]."\"";
                    $s++;
                }

                if(isNContained($year[$i],\@addedYears)==0){
                    $yearValueStrings[$t] = $year[$i];
                    $addedYears[$t] = $year[$i];
                    $t++;
                }
                my $row = $counter % $t;
                my $col = strInArray($locations[$i],\@provinces);
                $yearValueStrings[$row] = $yearValueStrings[$row].",".$values[$i];
                $counter++;
            }
        }
    }
    
    print "$dataInfo\n";
    my $graphFilePath = "GI-$dataInfo.csv";
    open my $gFile,'>',"$graphFilePath"
    or die "Unable to open: $graphFilePath";

    $i=0;
    my $strAmnt = $#yearValueStrings;
    foreach my $str(@yearValueStrings){
        if(($strAmnt - $i) == 0){
            $yearValueString = "$yearValueString$str";
        }else{
            $yearValueString = "$yearValueString$str\n";
        }
        
        $i++;
    }
    print $gFile "$header\n$yearValueString\n";

    close $gFile or die "Unable to close: $graphFilePath";

    #print "$header\n$yearValueString\n";

    populationAdjust(\@relevantValues, \@relevantLocations);
}

sub populationAdjust{
    my @values = @{$_[0]};
    my @location = @{$_[1]};
    my @population;
    my @province;
    my @popNum;
    my $filename = "population.csv";

    open my $populationFh, '<', "$filename" 
        or die "Unable to open $filename\n";
    @population = <$populationFh>;
    close $populationFh, or die "Unable to close population.csv\n";

    my $k = 0;
    foreach my $location ( @population ){
        if ( $csv->parse($location) ) {
            my @infoFields = $csv->fields();
            $province[$k] = $infoFields[0];
            $popNum[$k] = $infoFields[1];
            $k++;
        } else {
            warn "Line/record could not be parsed: $population[$k]\n";
        }
    }

    $k = 0;
    my $j = 0;
    for($k = 0; $k < $#location; $k++){
        for($j = 0; $j < $#province; $j++){
            if($location[$k] eq $province[$j]){
                $values[$k] = emptyToZero($values[$k]) / max((emptyToZero($popNum[$j]) * 10),1);
                $values[$k] = sprintf "%.2f", $values[$k];
            }
        }
    }
}

