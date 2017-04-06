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
1;