package JSON::Mask;
use Moo;

use JSON::Mask::Parser;
use JSON::Mask::Object;

has spec => (
	is => 'ro',
);

has filter => (
	is => 'ro',
	lazy => 1,
	default => sub {
		JSON::Mask::Parser->parse(shift->spec)
	},
);

# Allow JSON::Mask->new("a,b(c/d)")
sub BUILDARGS {
	my ($class, @args) = @_;
	unshift @args, "spec" if @args % 2;
	return { @args };
}

sub has_spec {
	my ($self) = @_;
	my $spec = $self->spec;
	return defined $spec && length $spec;
}

sub BUILD {
	my ($self) = @_;
	$self->filter if $self->has_spec;
}

sub mask {
	my ($self, $obj) = @_;
	if ($self->has_spec) {
		return $self->filter->mask($obj);
	} else {
		return $obj;
	}
}

1;
