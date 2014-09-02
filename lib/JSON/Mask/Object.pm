package JSON::Mask::Object;
use Moo;
use Scalar::Util 'reftype';
use Carp;

has 'properties' => (
	is => 'ro',
	predicate => 'has_properties',
);

sub mask {
	my ($self, $thing) = @_;

	if (!$self->has_properties) {
		return $thing;
	}

	my $type = reftype $thing;

	if ($type eq 'ARRAY') {
		return $self->mask_array($thing);
	} elsif ($type eq 'HASH') {
		return $self->mask_hash($thing);
	} else {
		croak "Don't know how to mask a '$type' with properties!";
	}
}

sub mask_hash {
	my ($self, $hash) = @_;

	my $props = $self->properties;
	my $out = {};

	for my $key (keys %$props) {
		my $filter = $props->{$key};
		my @hash_keys = ($key eq '*' ? keys %$hash : $key);
		for my $hash_key (@hash_keys) {
			my $masked = $filter->mask($hash->{$hash_key});
			$out->{$hash_key} = $masked if defined $masked;
		}
	}
	return $out if keys %$out;
	return;
}

sub mask_array {
	my ($self, $array) = @_;

	my $props = $self->properties;
	my @out = map { $self->mask($_) } @$array;
	return \@out if @out;
	return;
}

1;
