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
my $numLocations = 13;

my @relevantYears = (2015);
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

    for(my $i = 0; $i < ($recordAmount/2)+1; $i++){
        #print $i.". ".$year[$i]." - ";
        if( isRelevant($year[$i], \@relevantYears) ){
           # print $location[$i]." - ";
            if( isRelevant($location[$i], \@provinces) ){
                $values[$counter] = $value[$i];
                $location[$counter] = $location[$i];
                print "Location: ".$location[$i]." Value: ".$values[$counter]." Year: ".$year[$i]."\n";
                $counter++;

            }

        }
       # print "\n";

    }

    sortData(\@values, \@location);
    
}

sub dataFile{
    my @values = @{$_[0]};
    my @location = @{$_[1]};

     # Open, close file, load contents into record array
    open my $datainput_fh, '>', "graphinput"
        or die "Unable to open data file: graphinput\n";

    for(my $i = 0; $i < $numLocations; $i++){
        if($i == $numLocations-1){
            print $datainput_fh $location[$i]
        } else {
            print $datainput_fh $location[$i].","
        }
    }

    print $datainput_fh "\n";

    for(my $j = 0; $j < $numLocations; $j++){
        if($values[$j] eq '..'){
            print $datainput_fh " ,"

        } else {
            if($j == $numLocations-1){
                print $datainput_fh $values[$j]
            } else {
                print $datainput_fh $values[$j].","
            }
        }

    }
    close $datainput_fh
        or die "Unable to close: graphinput\n";
    
}

sub sortData{
#
# bubble sort the location and value by the value
#
    my @values = @{$_[0]};
    my @location = @{$_[1]};
    my $m = $numLocations-1;

    print "Sort"."\n";

    for my $j (0 .. $m) {
        for my $i (0 .. $m - 1) {
            if($values[$i] > $values[$i+1]) {
                my $tempLoc = $location[$i];
                my $tempVal = $values[$i];
                $location[$i] = $location[$i+1];
                $values[$i] = $values[$i+1];
                $location[$i+1] = $tempLoc;
                $values[$i+1] = $tempVal;
             }
         }
    }
     
    for my $p (0..$m) {
        print $location[$p]."-".$values[$p]."\n";
    }                
    dataFile(\@values, \@location);
    populationAdjust();


}

sub populationAdjust{
    my @population;
    my @province;
    my @popNum;

    open my $population_fh, '<', "population.csv" 
        or die "Unable to open population.csv\n";
    @population = <$population_fh>;
    close $population_fh, or die "Unable to close population.csv\n";

    my $k = 0;
      foreach my $l ( @population ){
         if ( $csv->parse($l) ) {
            my @info_fields = $csv->fields();
            $province[$k] = $info_fields[0];
            $popNum[$k] = $info_fields[1];
            print "province: ".$province[$k]." population: ".$popNum[$k]."\n";
            $k++;
         } else {
            warn "Line/record could not be parsed: $population[$k]\n";
         }
      }

}
