package JSON::Mask;
use Moo;

use JSON::Mask::Parser;
use JSON::Mask::Object;

has spec => (
	is => 'ro',
	required => 1,
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

sub BUILD {
	my ($self) = @_;
	$self->filter;
}

sub mask {
	return shift->filter->mask(@_);
}

1;
