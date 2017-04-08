#!/usr/bin/perl

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

use lib 'lib';

require 'lib/LilRoutines.pl';

#
# markham.pl
# Authors: Mitchell Knauer, Jovana Kusic, Kelsey Kirkland, Nano Muruvi
# Date of Last Update: April 7, 2017
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
my @provinces = ("Ontario","Quebec","Nova Scotia","New Brunswick","Manitoba","British Columbia","Prince Edward Island","Saskatchewan","Alberta","Newfoundland and Labrador","Yukon","Northwest Territories","Nunavut");
my $difference;


my $dataInfo = "";




print "                                   Welcome to Province Guide\n   With this program we can help you decide which province in Canada would suit you best to live in!\nWe will ask you a series of yes or no questions and display your results once they have been calculated.\n\n";

print "First we need a range of years to work with. Please enter 2 different years.\n";
yearRangeCalculation();

print"\n       Please answer the following questions with 'x' to exit and 'yes' or 'no' to continue.\n";

questions("questions", $minYear, $maxYear);

#Question asking subroutine
#Takes in a file path as the parameter, as well as the minimum and maximum year, and asks all the questions in the file
sub questions{
    my $dataFile = $_[0];
    my $minYear = $_[1];
    my $maxYear = $_[2];

    my @records;
    
    open my $questions, '<', $dataFile 
    or die "Unable to open $dataFile\n";
    @records = <$questions>;
    close $questions, or die "Unable to close $dataFile\n";
    
    my $recordAmnt = $#records+1;
    my $record;
    my $fp;
    my $recordNum = 0;
    my $flag = 0;
    my $str;
    
    my @prompts;
    my @results;
    my @files;
    my @userInput;

    print "                                    There are $recordAmnt questions.\n";
    for(my $i = 0;$i < $recordAmnt;$i++){
        $recordNum++;
        $record = $records[$i];
        if($csv->parse($record)){
            my @fields = $csv->fields();
            
            $prompts[$i] = $fields[0];
            $results[$i] = $fields[1];
            $files[$i] = $fields[2];
            $dataInfo = $fields[3];

            if($i == 2 && $minYear < 2008){
                #No Data Present
            } else {
                #prints questions in order
                print $recordNum.". $prompts[$i]\n";          
                $userInput[$i] = <>;
                chomp $userInput[$i];
                $str = lc($userInput[$i]);
                if($str eq "yes"){
                    print $results[$i]."\n";
                    parseFile($files[$i]);
                }elsif($str eq "x"){
                    $i = $recordAmnt;
                }
            }

        }else{
            warn "Failed to parse question #".(1+$i)."\n";
        }
    }
    verdictCheck();
}

sub yearRangeCalculation{
    #Asks user to input a minimum and maximum year to obtain values for
    #Also checks to make sure the input is accurate
    while($flag == 0){
        print "Minimum year: ";
        $minYear = <>;
        if($minYear eq "\n"){
            $flag = 0;
        } else {
            chomp $minYear;
        }
        print "Maximum year: ";
        $maxYear = <>;
        if($maxYear eq "\n"){
            $flag = 0;
        } else {
            chomp $maxYear;
        }

        #Checks that each year is only digits
        if($minYear =~ /[^0-9]/){
            print "Incorrect input, try again\n";
            $flag = 0;
        }elsif($maxYear =~ /[^0-9]/){
            print "Incorrect input, try again\n";
            $flag = 0;
        }else {
            #Checks that the years are within the correct range
            if($minYear >= 1998 && $minYear <= 2015 && $maxYear >= 1998 && $maxYear <= 2015 && $maxYear > $minYear){
                $flag = 1;
            }
        }
    }

    $difference = $maxYear - $minYear;
    #Populates array with the relevant years within the range given by the user
    for(my $i = 0; $i <= $difference; $i++){
        $relevantYears[$i] = $minYear;
        $minYear++;
    }
    $minYear = $minYear - $difference - 1;
    print "\nWe'll get the data for the years from $minYear to $maxYear.\n";
}

# File Input Subroutine
# Take in the file name and minimum year as parameters
# Parses the file and inputs the locations and the number of crimes accordingly into two different arrays
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



# Takes in the value and location arrays, as well as the minimum year as parameters
# Inputs all values needed into new arrays, only for the 13 provinces of Canada, and only for the range of years required
sub dataFinder{
    my @year = @{$_[0]};
    my @values = @{$_[1]};
    my @locations = @{$_[2]};

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
    
    my $graphFilePath = "GI-".$dataInfo.".csv";
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

    system("perl graphData.pl $graphFilePath $dataInfo.pdf boxplot");

    populationAdjust(\@relevantValues, \@relevantLocations, $minYear);
}

# Takes in the values and locations arrays as parameters
# The subroutine bubble sorts both arrays based on the values (ascending)
sub sortData{
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

# Takes in the values and location arrays, as well as the minimum year as parameters
# Opens the census data and adjusts the value numbers based on the population for each province
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
    #Decides which census data to use
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
    #Averages the total values for each province, in accordance to its population, and moves them into a new array
    for($k = 0; $k < $#location; $k++){
        foreach my $a ( @province ){
            if($location[$k] eq $province[$j]){
                $values[$k] = (emptyToZero($values[$k]) / min(1,emptyToZero($popNum[$j]))) *10;
                $total = $total + $values[$k];
                if(($k + 1) % ($#relevantYears + 1) == 0 && $k ne 0 || $k == $#location-1){
                    $total = ($total / ($#relevantYears+1));
                    $total = sprintf "%.2f", $total; 
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
# Takes in the values and locations arrays as parameters
# Accumulates an array of all the top three provinces for each question answered with 'yes'
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
# Displays the final provinces chosen for the user based on how many times it occurs in the array 
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
        print "
            In order for this program to run as intended, and for us to help you,
            at least one 'yes' answer is necessary next time for us to access the relevant data!\n";
        print "\nWant to try again? Type yes! ";
        $input = <>;
        chomp $input;
        if(lc($input) eq "yes"){
            questions("questions", $minYear, $maxYear);
        } 
    }
}

# Takes in the number each province occurs and the current greatest number variables as parameters
# Determines which number is greater and returns it accordingly
sub sortTopProvinces{
    my $numProvince = $_[0];
    my $greatestNum = $_[1];
    
    if($numProvince > $greatestNum){
        return $numProvince
    } else {
        return $greatestNum;
    }
}