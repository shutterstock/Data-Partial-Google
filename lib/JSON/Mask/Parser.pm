package JSON::Mask::Parser;
use Moo;
use Marpa::R2;

my $rules = q{
lexeme default = latm => 1

Props  ::= Prop+ separator => [,] action => [values]

Prop   ::= Object action => ::first bless => ::undef
         | Array  action => ::first bless => ::undef

Object ::= NAME              action => object
         | NAME ('/') Object action => object

Array  ::= NAME ('(') Props (')') action => array

NAME ~ [^,/()]+
};

my $grammar = Marpa::R2::Scanless::G->new({
	source => \$rules,
	bless_package => 'JSON::Mask',
});

sub parse {
	my ($self, $input) = @_;

	my $recognizer = Marpa::R2::Scanless::R->new({
		semantics_package => ref($self),
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
	bless {
		name => $_[1],
		properties => $_[2]
	}, 'JSON::Mask::Array';
}

sub object {
	bless {
		name => $_[1],
		($_[2] 
			? (properties => $_[2]) 
			: ()
		),
	}, 'JSON::Mask::Object';
}

1;
