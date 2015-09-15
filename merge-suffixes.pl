#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $last = '';
my @parts = ();

print "my \%suffixes = (\n";

while (<>) {
	chomp;
	my ($prop, $part) = split /: /, $_;
	if ($last eq '') {
		$last = $prop;
	}
	if ($prop eq $last) {
		push @parts, $part;
	} else {
		print "\t\"$last\" => [\"" . join('", "', @parts) . "\"],\n";
		@parts = ();
		push @parts, $part;
		$last = $prop;
	}
}
print ");\n";
