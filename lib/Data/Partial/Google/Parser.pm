package Data::Partial::Google::Parser;
# VERSION
# AUTHORITY
use Marpa::R2;

my $rules = q{
lexeme default = latm => 1
:default ::= action => [values]

TopLevel ::= Props action => toplevel

Props    ::= Prop+ separator => [,] action => props

Prop     ::= Object action => ::first bless => ::undef
           | Array  action => ::first bless => ::undef

Object   ::= NAME              action => leaf
           | NAME ('/') Prop   action => object

Array    ::= NAME ('(') Props (')') action => array

NAME ~ [^,/()]+
};

my $grammar = Marpa::R2::Scanless::G->new({
	source => \$rules,
	bless_package => 'Data::Partial::Google',
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

sub make_filter {
	my ($properties) = @_;
	return bless {
		($properties
			? (properties => $properties)
			: ()
		)
	}, 'Data::Partial::Google::Filter';
}

sub merge_props {
	# Turn [[a, Filter], [b, Filter], [c, Filter]]
	# into { a => Filter, b => Filter, c => Filter }
	
	return +{
		map { @$_ } @_
	};
}

sub toplevel {
	make_filter($_[1]);
}

sub props {
	shift; # Unused global object
	merge_props(@_);
}

sub object {
	my $props = $_[2] ? merge_props($_[2]) : undef;

	[ $_[1], make_filter($props) ]
}

sub leaf {
	[ $_[1], undef ]
}

sub array {
	[ $_[1], make_filter($_[2]) ]
}

1;
