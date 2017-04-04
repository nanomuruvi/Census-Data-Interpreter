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
my $minYear;
my $maxYear;
my $flag = 0;

my @topThree;
my @relevantYears;
#my @relevantYears = (2015,2014,2013,2012,2011,2010);
my @provinces = ("Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island","Saskatchewan","Alberta","Newfoundland and Labrador","Yukon","Northwest Territories","Nunavut");

print "                                Welcome to Province Guide!!
 With this program we can help you decide which province in Canada would suit you best to live in!
 We will ask you a series of yes or no questions and display your results once they have been calculated."."\n\n";

print "Please select a range of years to display the data (1998 - 2015)
- Note that some questions will not be available depending on years given"."\n";

while($flag == 0){
    print "Minimum year: ";
    $minYear = <>;
    chomp $minYear;
    print "Maximum year: ";
    $maxYear = <>;
    chomp $maxYear;

    if($minYear =~ /[^0-9]/){
        print "Incorrect input, try again\n";
        $flag = 0;
    } 
    elsif($maxYear =~ /[^0-9]/){
        print "Incorrect input, try again\n";
        $flag = 0;
    } else {
        if($minYear >= 1998 && $minYear <= 2015 && $maxYear >= 1998 && $maxYear <= 2015 && $maxYear > $minYear){
            $flag = 1;
        }
    }
}

my $difference = $maxYear - $minYear;

for(my $i = 0; $i <= $difference; $i++){
    $relevantYears[$i] = $minYear;
    $minYear++;
}
$minYear = $minYear - $difference - 1;

print "\nPlease answer the following questions with either 'yes' or anything else for 'no': \n";

question("questions", $minYear, $maxYear);

#Question asking subroutine
#Takes in a file path as the parameter and asks all the questions in the file
sub question{
    my $dataFile = $_[0];
    my $minYear = $_[1];
    my $maxYear = $_[2];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records;
    my $record;
    my $recordNum = 0;
    my $flag = 0;
    
    my @prompts;
    my @results;
    my @files;
    my @userInput;
    
    for(my $i = 0;$i <= $recordAmnt;$i++){
        $recordNum++;
        $record = $records[$i];
        if($csv->parse($record)){
            my @fields = $csv->fields();
            
            $prompts[$i] = $fields[0];

            $results[$i] = $fields[1];
            $files[$i] = $fields[2];

            if($i == 2 && $minYear < 2008){
                #No Data Present
            } else {
                print $recordNum.". $prompts[$i]\n";          
                $userInput[$i] = <>;
                chomp $userInput[$i];
                if(lc($userInput[$i]) eq "yes"){
                    print $results[$i]."\n";
                    parseFile($files[$i], $minYear);
                }
            }

        }else{
            warn "Failed to parse question $i.";
        }
    }

    verdictCheck();

}
# File Input Subroutine
sub parseFile{

    my @records;
    my @year;
    my @value;
    my @location;

    my $recordCount = 0;
    my $filename = $_[0];
    my $minYear = $_[1];

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
            if($fields[1] eq '..'){
                $value[$recordCount] = 0;
            } else {
                $value[$recordCount]    = $fields[1];
            }
            $location[$recordCount] = $fields[2];
            $recordCount++;
        } else {
            warn "Line/record could not be parsed: $records[$recordCount]\n";
        }
    }
    dataFinder(\@year, \@value, \@location, $minYear);
}

sub isRelevant{
    my $value = $_[0];
    my @array = @{$_[1]};
    return grep( /^$value$/, @array );
}


sub dataFinder{ 
    my @year = @{$_[0]};
    my @value = @{$_[1]};
    my @location = @{$_[2]};
    my $minYear = $_[3];

    my @relevantValues;
    my @relevantLocations;

    my $counter = 0;
    my $recordAmount = $#year;

    for(my $i = 0; $i < ($recordAmount/2)+1; $i++){
        if( isRelevant($year[$i], \@relevantYears) ){
            if( isRelevant($location[$i], \@provinces) ){
                $relevantValues[$counter] = $value[$i];
                $relevantLocations[$counter] = $location[$i];
                $counter++;
            }
        }
    }
    populationAdjust(\@relevantValues, \@relevantLocations, $minYear);
}

sub populationAdjust{
    my @values = @{$_[0]};
    my @location = @{$_[1]};
    my $minYear = $_[2];
    my @population;
    my @province;
    my @popNum;
    my @pop2006;
    my @pop2011;
    my @averages;
    my $total = 0;
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
            $pop2006[$k] = $infoFields[1];
            $pop2011[$k] = $infoFields[2];
            $k++;
        } else {
            warn "Line/record could not be parsed: $population[$k]\n";
        }
    }

    $k = 0;
    foreach my $pop ( @province ){
        if($minYear <= 2006){
            $popNum[$k] = $pop2006[$k];
        } else {
            $popNum[$k] = $pop2011[$k];
        }
        $k++;
    }
    
    $k = 0;
    my $j = 0;
    my $x = 0;
    for($k = 0; $k < $#location; $k++){
        foreach my $a ( @province ){
            if($location[$k] eq $province[$j]){
                $values[$k] = ($values[$k] / $popNum[$j]) *100;
                $total = $total + $values[$k];
                if(($k + 1) % ($#relevantYears + 1) == 0 && $k ne 0 || $k == $#location-1){
                    $total = ($total / ($#relevantYears+1));
                    $total = sprintf "%.2f", $total;
                    #print "Province: ".$province[$j]." Average: ".$total."\n";   
                    $averages[$x] = $total; 
                    $total = 0;
                    $x++;
                }
            }
            $j++;
        }
        $j = 0;
    }

    sortData(\@averages, \@province);
}

sub dataFile{
    my @values = @{$_[0]};
    my @locations = @{$_[1]};

     # Open, close file, load contents into record array
    open my $datainput_fh, '>', "graphinput"
        or die "Unable to open data file: graphinput\n";

    for(my $i = 0; $i < $#locations; $i++){
        if($i == $#locations-1){
            print $datainput_fh $locations[$i]
        } else {
            print $datainput_fh $locations[$i].","
        }
    }

    print $datainput_fh "\n";

    for(my $j = 0; $j < $#locations; $j++){
        if($values[$j] eq '..'){
            print $datainput_fh " ,"

        } else {
            if($j == $#locations-1){
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
    my @locations = @{$_[1]};

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
    dataFile(\@values, \@locations);
    verdict(\@values, \@locations);
}

sub verdict{
    my @values = @{$_[0]};
    my @location = @{$_[1]};
    my $numSaved = 0;
    my $j = 0;

    foreach my $p ( @topThree ){
        $numSaved++;
        $j++;
    }

    for(my $i = 0; $i < 3; $i++){
        $topThree[$numSaved] = $location[$i];
        $numSaved++;
    }
    
}

sub verdictCheck{
    my $numOntario = 0;
    my $numQuebec = 0;
    my $numNovaScotia = 0;
    my $numNewBrunswick = 0;
    my $numManitoba = 0;
    my $numBritishColumbia = 0;
    my $numPEI = 0;
    my $numSaskatchewan = 0;
    my $numAlberta = 0;
    my $numNewfoundland = 0;
    my $numYukon = 0;
    my $numNorthwest = 0;
    my $numNunavut = 0;
    my $greatestNum = 0;
    my $displayMessage = "\nCongratulations! Based on the questions you have answered, we have determined that best province(s) for you is: ";
    my $flag = 0;
    my $k = 0;

    foreach my $count ( @topThree ){
        if($topThree[$k] eq "Ontario"){
            $numOntario++;
            $greatestNum = sortTopProvinces($numOntario, $greatestNum);
        }
        elsif($topThree[$k] eq "Quebec"){
            $numQuebec++;
            $greatestNum = sortTopProvinces($numQuebec, $greatestNum);
        }
        elsif($topThree[$k] eq "Nova Scotia"){
            $numNovaScotia++;
            $greatestNum = sortTopProvinces($numNovaScotia, $greatestNum);
        }
        elsif($topThree[$k] eq "New Brunswick"){
            $numNewBrunswick++;
            $greatestNum = sortTopProvinces($numNewBrunswick, $greatestNum);
        }
        elsif($topThree[$k] eq "Manitoba"){
            $numManitoba++;
            $greatestNum = sortTopProvinces($numManitoba, $greatestNum);
        }
        elsif($topThree[$k] eq "British Columbia"){
            $numBritishColumbia++;
            $greatestNum = sortTopProvinces($numBritishColumbia, $greatestNum);
        }
        elsif($topThree[$k] eq "Prince Edward Island"){
            $numPEI++;
            $greatestNum = sortTopProvinces($numPEI, $greatestNum);
        }
        elsif($topThree[$k] eq "Saskatchewan"){
            $numSaskatchewan++;
            $greatestNum = sortTopProvinces($numSaskatchewan, $greatestNum);
        }
        elsif($topThree[$k] eq "Alberta"){
            $numAlberta++;
            $greatestNum = sortTopProvinces($numAlberta, $greatestNum);
        }
        elsif($topThree[$k] eq "Newfoundland and Labrador"){
            $numNewfoundland++;
            $greatestNum = sortTopProvinces($numNewfoundland, $greatestNum);
        }
        elsif($topThree[$k] eq "Yukon"){
            $numYukon++;
            $greatestNum = sortTopProvinces($numYukon, $greatestNum);
        }
        elsif($topThree[$k] eq "Northwest Territories"){
            $numNorthwest++;
            $greatestNum = sortTopProvinces($numNorthwest, $greatestNum);
        }
        elsif($topThree[$k] eq "Nunavut"){
            $numNunavut++;
            $greatestNum = sortTopProvinces($numNunavut, $greatestNum);
        }
        $k++;
    }
    my $input;
        
    if($greatestNum != 0){
        if($greatestNum == $numOntario){
            if($flag == 1){
                print " and Ontario";
            } else {
                print $displayMessage."Ontario";
            }
            $flag = 1;
        }
        if($greatestNum == $numQuebec){
            if($flag == 1){
                print " and Quebec";
            } else {
                print $displayMessage."Quebec";
            }
            $flag = 1;
        }
        if($greatestNum == $numNovaScotia){
            if($flag == 1){
                print " and Nova Scotia";
            } else {
                print $displayMessage."Nova Scotia";
            }
            $flag = 1;
        }
        if($greatestNum == $numNewBrunswick){
            if($flag == 1){
                print " and New Brunswick";
            } else {
                print $displayMessage."New Brunswick";
            }
            $flag = 1;
        }
        if($greatestNum == $numManitoba){
            if($flag == 1){
                print " and Manitoba";
            } else {
                print $displayMessage."Manitoba";
            }
            $flag = 1;
        }
        if($greatestNum == $numBritishColumbia){
            if($flag == 1){
                print " and British Columbia";
            } else {
                print $displayMessage."British Columbia";
            }
            $flag = 1;
        }
        if($greatestNum == $numPEI){
            if($flag == 1){
                print " and Prince Edward Island";
            } else {
                print $displayMessage."Prince Edward Island";
            }
            $flag = 1;
        }
        if($greatestNum == $numSaskatchewan){
            if($flag == 1){
                print " and Saskatchewan";
            } else {
                print $displayMessage."Saskatchewan";
            }
            $flag = 1;
        }
        if($greatestNum == $numAlberta){
            if($flag == 1){
                print " and Alberta";
            } else {
                print $displayMessage."Alberta";
            }
            $flag = 1;
        }
        if($greatestNum == $numNewfoundland){
            if($flag == 1){
                print " and Newfoundland and Labrador";
            } else {
                print $displayMessage."Newfoundland and Labrador";
            }
            $flag = 1;
        }
        if($greatestNum == $numYukon){
            if($flag == 1){
                print " and Yukon";
            } else {
                print $displayMessage."Yukon";
            }
            $flag = 1;
        }
        if($greatestNum == $numNorthwest){
            if($flag == 1){
                print " and Northwest Territories";
            } else {
                print $displayMessage."Northwest Territories";
            }
            $flag = 1;
        }
        if($greatestNum == $numNunavut){
            if($flag == 1){
                print " and Nunavut";
            } else {
                print $displayMessage."Nunavut";
            }
            $flag = 1;
        }
        print "!\n";
    } else {
        print "In order for this program to run as intended, and for us to help you,
                 at least one 'yes' answer is necessary next time for us to access the relevant data!\n";
        print "\nWant to try again? Type yes! ";
        $input = <>;
        chomp $input;
        if(lc($input) eq "yes"){
            question("questions", $minYear, $maxYear);
        } 
    }
}

sub sortTopProvinces{
    my $numProvince = $_[0];
    my $greatestNum = $_[1];

    if($numProvince > $greatestNum){
        return $numProvince
    } else {
        return $greatestNum;
    }

}



