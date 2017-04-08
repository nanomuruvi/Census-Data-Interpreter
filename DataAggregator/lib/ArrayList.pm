#!/usr/bin/perl

package ArrayList;

sub new{
	my $class = shift;
	my $self = {
		array => ()
	};
	bless $self, $class;
	return $self;
}

sub get{
	my ($self, $index) = @_;
	return $self->{array}[$index];
}

sub size{
	my ($self) = @_;
	return $#self->{array};
}

sub add{
	my ( $self, $value ) = @_;
	my $size = $#self->{array};
	$self->{array}[size] = $value;
	return $self->{array};
}

sub set{
	my ($self, $index, $value) = @_;
	$self->{array}[$index] = $value;
}

sub indexExists{
	my ($self, $index) = @_;
	my $exists = ($#self>$index);
}

sub removeIndex{
	my ($self, $index) = @_;
	splice $self->{array}, $index, 1;
	return $self->{array};
}

sub removeValue{
	my ($self, $value) = @_;
	for(my $i=0 ; $i<$#self->{array} ; $i++){
		if($i == $#self->{array}){
			splice $self->{array}, $i, 1;
			$i--;
		}
	}
	return $self->{array};
}

#Returns the first instance of the value
sub indexOf{
	my ($self, $value) = @_;
	my $index = -1;
	for(my $i = 0; $i<$#self->{array}; $i++){
		if($self->{array}[$index] == $value && $index == -1){
			$index = $i;
		}
	}
}

1;