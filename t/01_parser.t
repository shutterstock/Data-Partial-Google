#!perl
use strict;
use warnings;
use Test::Most;
use Data::Partial::Google::Parser;

my $cases = {
	'a' => {
		properties => {
			a => {},
		}
	},
	'a,b,c' => {
		properties => {
			a => {},
			b => {},
			c => {},
		}
	},
	'a,b(d/*/g,b),c' => {
		properties => {
			a => {},
			b => {
				properties => {
					d => {
						properties => {
							'*' => {
								properties => {
									g => {},
								}
							}
						}
					},
					b => {},
				}
			},
			c => {},
		}
	},
};

while (my ($rule, $filter) = each %$cases) {
	cmp_deeply(
		Data::Partial::Google::Parser->parse($rule),
		noclass($filter),
		$rule,
	);
}

done_testing;
