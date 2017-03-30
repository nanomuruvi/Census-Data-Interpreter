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

sub remove{
	my ($self, $index) = @_;
	splice $self->{array}, $index, 1;
	return $self->{array};
}

1;