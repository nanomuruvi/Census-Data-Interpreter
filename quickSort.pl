#!/usr/bin/perl

sub quicksort
{
    my @records = @_;
    if($#list < 1){
        return @list;
    }
    my $pivot = pop(@records);
    my @smaller;
    my @bigger;

    foreach my $amount (@records){
        if ($amount < pivot) {
            push(@smaller, $amount);
        }
        else{
            push(@bigger, $amount);
        }
     }
     return quicksort(@smaller), $pivot, quicksort(@bigger);
}
