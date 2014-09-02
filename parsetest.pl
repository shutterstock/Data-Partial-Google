#!perl
use strict;
use warnings;
use Data::Printer { class => { expand => 'all', show_methods => 'none' } };
use JSON::Mask::Parser;

my $parser = JSON::Mask::Parser->new;
while (<>) {
	chomp;
	my $val = $parser->parse($_);
	&p($val);
}
