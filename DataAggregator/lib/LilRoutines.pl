#!/usr/bin/perl

use strict;
use warnings;

sub min{
	my $v1 = $_[0];
	my $v2 = $_[1];
	my $min = $v1;
	if($v1>$v2){
		$min = $v2;
	}
	return $min;
}

sub max{
	my $v1 = $_[0];
	my $v2 = $_[1];
	my $max = $v1;
	if($v1<$v2){
		$max = $v2;
	}
	return $max;
}

sub isInside{
    my $value = $_[0];
    my @array = @{$_[1]};
    return grep( /^$value$/, @array );
}

sub isSContained{
    my $value = $_[0];
    my @array = @{$_[1]};
    my $contained = 0;
    foreach my $v(@array){
        if("$v" eq "$value"){
            $contained = 1;
        }
    }
    return $contained;
}

sub isNContained{
    my $value = $_[0];
    my @array = @{$_[1]};
    my $contained = 0;
    foreach my $v(@array){
        if($v == $value){
            $contained = 1;
        }
    }
    return $contained;
}

sub strInArray{
    my $value = $_[0];
    my @array = @{$_[1]};
    my $index = -1;
    for(my $i = 0;$i < $#array;$i++){
        if("$array[$i]" eq "$value"){
            $index = $i;
        }
    }
    return $index;
}

sub numInArray{
    my $value = $_[0];
    my @array = @{$_[1]};
    my $index = -1;
    for(my $i = 0;$i < $#array;$i++){
        if($array[$i] == $value){
            $index = $i;
        }
    }
    return $index;
}

sub emptyToZero{
	my $v = $_[0];
	if($v eq ""){
		$v = 0;
	}
	return $v;
}

# Takes in the values and locations arrays as parameters
# Values is the averages for each province, and locations is the province names
# These two arrays are written into a file
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

# Takes in the location array as a parameter
# Checks that the corresponding location is one of the 13 provinces in Canada
sub isRelevant{
    my $value = $_[0];
    my @array = @{$_[1]};
    return grep( /^$value$/, @array );
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

# Takes in the values and locations arrays as parameters
# Accumulates an array of all the top three provinces for each question answered with 'yes'
sub verdict{
    my @values = @{$_[0]};
    my @location = @{$_[1]};
    my @topThree = @{$_[2]};
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

1;