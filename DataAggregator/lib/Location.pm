package Location;

sub new{
	my $class = shift;
	my $self = {
		name => shift,
		values => shift,
	};

	bless $self, $class;
	return $self;
}

sub getName{
	my ($self) = @_;
	return $self->{name};
}

sub getValues{
	my ($self) = @_;
	return $self->{values};
}

sub getValue{
	my ($self) = @_;
	%hash = $self->{values};
	return $hash{'$_[0]'};
}

sub getYearValue{

}

sub setName{
	my ( $self, $name ) = @_;
    $self->{name} = $name if defined($name);
    return $self->{name};
}

sub setValues{

}

sub setValue{

}

sub addValue{

}

sub removeValue{

}

1;