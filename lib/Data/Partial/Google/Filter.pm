package Data::Partial::Google::Filter;
# VERSION
# AUTHORITY
use Moo;
use Scalar::Util 'reftype';
use Carp;

has 'properties' => (
	is => 'ro',
);

sub mask {
	my ($self, $thing) = @_;

	my $type = reftype $thing || '';

	if ($type eq 'ARRAY') {
		return $self->mask_array($thing);
	} elsif ($type eq 'HASH') {
		return $self->mask_hash($thing);
	} else {
		# If we're looking for properties on a thing with no internal structure,
		# don't return it at all. So for example, if we have a/*/b, a might contain
		# some scalars, we don't want them, we only want things that have bs.
		return;
	}
}

sub mask_hash {
	my ($self, $hash) = @_;

	my $props = $self->properties;
	my $out = {};

	for my $key (keys %$props) {
		my $filter = $props->{$key};
		if ($key eq '*') {
			# For * go over all keys in the object, but only produce output keys if the
			# mask returned something useful.
			for my $hash_key (keys %$hash) {
				my $masked = $filter ? $filter->mask($hash->{$hash_key}) : $hash->{$hash_key};
				$out->{$hash_key} = $masked if defined $masked;
			}
		} elsif (exists $hash->{$key}) {
			if ($filter) {
				my $masked = $filter->mask($hash->{$key});
				$out->{$key} = $masked if defined $masked;
			} else {
				$out->{$key} = $hash->{$key};
			}
		}
	}
	return $out if keys %$out;
	return;
}

sub mask_array {
	my ($self, $array) = @_;

	my @out = map { $self->mask($_) } @$array;
	return \@out if @out;
	return;
}

1;
