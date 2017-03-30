package Location;

sub new{
	my $class = shift;
	my $self = {
		name => shift,
		values => {},
	};
	bless $self, $class;
	return $self;
}

sub getName{
	my ($self) = @_;
	return $self->{name};
}
sub setName{
	my ( $self, $name ) = @_;
    $self->{name} = $name if defined($name);
    return $self->{name};
}

sub getValue{
	my ($self, $key) = @_;
	my $value = $self->{values}->{$key};
	return $value;
}

sub setValue{
	my ($self, $key, $value) = @_;
	$self->{name}->{$key} = $value if defined($value);
	return $hash{'$_[0]'};
}

sub addValue{
	my ($self, $key, $value) = @_;
	$self->{values}->{$key} = $value if defined($value);
	return $hash{'$_[0]'};
}

sub removeValue{
	my ($self, $key) = @_;
	delete $self->{values}->{$key};
	return $self->{values}->{$key};
}

1;