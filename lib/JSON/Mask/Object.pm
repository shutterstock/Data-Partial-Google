package JSON::Mask::Object;
use Moo;

has 'properties' => (
	is => 'ro',
	predicate => 'has_properties',
);

1;
