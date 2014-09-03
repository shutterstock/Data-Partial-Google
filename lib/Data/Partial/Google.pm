package Data::Partial::Google;
use Moo;

use Data::Partial::Google::Parser;
use Data::Partial::Google::Filter;

has rule => (
	is => 'ro',
);

has filter => (
	is => 'ro',
	lazy => 1,
	default => sub {
		Data::Partial::Google::Parser->parse(shift->rule)
	},
);

# Allow Data::Partial::Google->new("a,b(c/d)")
sub BUILDARGS {
	my ($class, @args) = @_;
	unshift @args, "rule" if @args % 2;
	return { @args };
}

sub has_rule {
	my ($self) = @_;
	my $rule = $self->rule;
	return defined $rule && length $rule;
}

sub BUILD {
	my ($self) = @_;
	$self->filter if $self->has_rule;
}

sub mask {
	my ($self, $obj) = @_;
	if ($self->has_rule) {
		return $self->filter->mask($obj);
	} else {
		return $obj;
	}
}

1;
