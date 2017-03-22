#!/user/bin/perl

use strict;
#
# bubble sort the location and value by the value
#
    my @location = @{$_[0]};
    my @value = @{$_[1]};
    my $m = $#location;

    print "Sort"."\n";

    for my $j (0 .. $m) {
        for my $i (0 .. $m - 1) {
            if($value[$i] > $value[$i+1]) {
                my $tempLoc = $location[$i];
                my $tempVal = $value[$i];
                $location[$i] = $location[$i+1];
                $value[$i] = $value[$i+1];
                $location[$i+1] = $tempLoc;
                $value[$i+1] = $tempVal;
             }
         }
    }
     
    for my $p (0..$m) {
        print $location[$p]."-".$value[$p]."\n";
    }                
 
