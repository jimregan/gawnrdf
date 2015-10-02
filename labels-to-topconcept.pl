#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use Unicode::Escape;
use List::MoreUtils qw(uniq);

open (LABEL, "</tmp/noun-labels") or die "$!\n";
open (CONCEPT, "</tmp/topConcept.nt") or die "$!\n";
open (OUT, ">/tmp/labels.txt") or die "$!\n";

#binmode OUT, ":utf8";

my %tomatch = ();
my %labels = ();

while (<LABEL>) {
	if (m!<([^>]*)> <http://www.w3.org/2000/01/rdf-schema#label> "([^"]*)"!) {
		my $syn = $1;
		my $lbl = $2;
		$labels{$syn} = Unicode::Escape::unescape($lbl);
	}
}

while (<CONCEPT>) {
	if (m!<([^>]*)> <http://lodserver.iula.upf.edu/euroWordNetMCR/topConcept> <http://lodserver.iula.upf.edu/euroWordNetMCR/([^>]*)!) {
		my $syn = $1;
		my $con = $2;
		if (exists $labels{$syn}) {
			push(@{$tomatch{$con}}, $labels{$syn});
		}
	}
}

foreach my $key (keys %tomatch) {
	my @out = uniq @{$tomatch{$key}};
	print OUT "LIST " . uc($key) . " = \"" . join ('" "', @out) . "\" ;\n";
}
