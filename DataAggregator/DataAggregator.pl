#!/usr/bin/perl

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

use lib 'lib';
use Location;
use ArrayList;

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

my @relevantYears = (2015,2014,2013,2012,2011,2010);
my @provinces = ("Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island",
    "Saskatchewan","Alberta","Newfoundland and Labrador","Yukon","Northwest Territories","Nunavut");


print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated.";

print "\n\nPlease answer the following questions with either 'yes' or 'no': ";

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
sub questions{
    my $dataFile = $_[0];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records+1;
    my $record;
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
 
            print $recordNum.". $prompts[$i]\n";          
            $userInput[$i] = <>;
            chomp $userInput[$i];

            if(lc($userInput[$i]) eq "yes"){
                print $results[$i]."\n";
                parseFile($files[$i]);
            }elsif(lc($userInput[$i]) eq "x"){
                $i=$recordAmnt;
            }
        }else{
            warn "Failed to parse question $i.";
        }
    }
}
sub isInside{
    my $value = $_[0];
    my @array = @{$_[1]};
    return (grep{/^$value$/} @array );
}
sub isValueIn{
    my ($v,@array)=@_;
    my $isThere;
    my $i = 0;
    foreach my $value(@array){
        $isThere = $isThere || $value == $v;
        $i++;
    }
    return $isThere;
}


sub dataFinder{
    my @years = @{$_[0]};
    my @values = @{$_[1]};
    my @locations = @{$_[2]};

    my @relevantYears;
    my @relevantValues;
    my @relevantLocations;

    my $counter = 0;
    my $recordAmount = $#years;

    #Removed the /2 because not sure why it was even there
    for(my $i = 0; $i < ($recordAmount/2)+1; $i++){

        if(isInside( $years[$i], \@relevantYears)){
            print ("Hello World 2\n");
            if(isInside( $locations[$i], \@provinces)){

                $relevantYears[$counter] = $years[$i];
                $relevantValues[$counter] = $values[$i];
                $relevantLocations[$counter] = $locations[$i];
                
                print "Location: ".$relevantLocations[$counter]." Value: ".$relevantValues[$counter]." Year: ".$years[$i]."\n";
                $counter++;
            }
        }
    }
    makeGraphInput(\@relevantValues, \@relevantLocations, \@relevantYears);
    #sortData(\@relevantValues, \@relevantLocations, \@relevantYears);
    #populationAdjust(\@relevantValues, \@relevantLocations);
}

sub makeGraphInput{
    my @values = @{$_[0]};
    my @locations = @{$_[1]};
    my @years = @{$_[2]};
    my $datafile = "graphinput.csv";
    my @printedLocations = ();

     # Open, close file, load contents into record array
    open my $datainput, '>', "$datafile"
        or die "Unable to open data file: $datafile\n";

    print $datainput "Years,";
    for(my $i = 0; $i < $#locations; $i++){
        if(!isInside($locations[$i],\@printedLocations)){
            print "Not currently inside $locations[$i]\n";
            if($i == $#locations-1){
                print $datainput $locations[$i]
            } else {
                print $datainput $locations[$i].","
            }
        }
        $printedLocations[$i] = $locations[$i];
    }

    print $datainput "\n";

    for(my $j = 0; $j < $#locations; $j++){
        if($values[$j] eq '..'){
            print $datainput ","

        } else {
            if($j == $#locations-1){
                print $datainput $values[$j]
            } else {
                print $datainput $values[$j].","
            }
        }

    }
    close $datainput
        or die "Unable to close: $datafile\n";
}

sub sortData{
#
# bubble sort the location and value by the value
#

    my @values = @{$_[0]};
    my @locations = @{$_[1]};
    my @years = @{$_[2]};
    for my $j (0 .. $#locations-1) {
        for my $i (0 .. $#locations-2) {
            if($values[$i] > $values[$i+1]) {
                my $tempLoc = $locations[$i];
                my $tempVal = $values[$i];
                $locations[$i] = $locations[$i+1];
                $values[$i] = $values[$i+1];
                $locations[$i+1] = $tempLoc;
                $values[$i+1] = $tempVal;
            }
        }
    }
    for(my $p=0; $p < $#locations ; $p++ ){
        #print $locations[$p]."-".$values[$p]."\n";
    }                
    makeGraphInput(\@values, \@locations);
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
            # print "province: ".$province[$k]." population: ".$popNum[$k]."\n";
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
                $values[$k] = ($values[$k] / ($popNum[$j] * 1000)) *100;
                $values[$k] = sprintf "%.2f", $values[$k];
                print $location[$k]." (".$values[$k]."%)\n";

            }
        }
    }
    sortData(\@values, \@location);
}
