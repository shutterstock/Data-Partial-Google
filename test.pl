#!perl
use strict;
use warnings;
use Data::Printer { class => { expand => 'all', show_methods => 'none' } };
use JSON::Mask;

while (<>) {
	chomp;
	my $mask = JSON::Mask->new($_);
	&p($mask);
}
