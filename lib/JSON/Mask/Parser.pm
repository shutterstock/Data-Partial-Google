package JSON::Mask::Parser;
use Marpa::R2;

my $rules = q{
lexeme default = latm => 1
:default ::= action => [values]

TopLevel ::= Props action => objectify

Props    ::= Prop+ separator => [,] action => props

Prop     ::= Object action => ::first bless => ::undef
           | Array  action => ::first bless => ::undef

Object   ::= NAME              action => object
           | NAME ('/') Object action => object

Array    ::= NAME ('(') Props (')') action => array

NAME ~ [^,/()]+
};

my $grammar = Marpa::R2::Scanless::G->new({
	source => \$rules,
	bless_package => 'JSON::Mask',
});

sub parse {
	my ($class, $input) = @_;

	my $recognizer = Marpa::R2::Scanless::R->new({
		semantics_package => $class,
		grammar => $grammar,
	});

	$recognizer->read(\$input);
	my $value = $recognizer->value;
	if ($value) {
		return $$value;
	} else {
		return undef;
	}
}

sub array {
	[
		$_[1],
		bless { properties => $_[2] }, 'JSON::Mask::Object',
	]
}

sub object {
	[
		$_[1],
		bless {
			($_[2] 
				? (properties => props({}, $_[2])) 
				: ()
			),
		}, 'JSON::Mask::Object',
	]
}

sub props {
	shift; # Unused global object
	# Turn [[a, Object], [b, Object], [c, Array]]
	# into { a => Object, b => Object, c => Array }
	my $ret = {};
	for my $object (@_) {
		$ret->{ $object->[0] } = $object->[1];
	}
	return $ret;
}

sub objectify {
	bless { properties => $_[1] }, 'JSON::Mask::Object';
}

1;
