#!/usr/bin/perl

use warnings;
use strict;
use utf8;

open (EN, "<$ARGV[0]") or die "$!\n";
open (ALIGN, "<ga-vuen-alignments.ttl") or die "$!\n";
open (OUT, ">$ARGV[0]-ga.ttl") or die "$!\n";

my %snsposposmap = (
	'n' => '1',
	'a' => '3',
	'adv' => '4',
	'v' => '2',
);

my @rels = qw/hyponymOf memberMeronymOf partMeronymOf sameVerbGroupAs similarTo attribute entails/;
my $mrel = join("|", @rels);

my %tomatch = ();

while (<ALIGN>) {
	if (m!<([^>]*)> <http://lexvo.org/ontology#nearlySameAs> <([^>]*)>!) {
		$tomatch{$2} = $1
	}
}

while (<EN>) {
	if (m!<([^>]*)> <http://www.w3.org/2006/03/wn/wn20/schema/($mrel)> <([^>]*)>!) {
		my $s = $1;
		my $p = $2;
		my $o = $3;
		if (exists $tomatch{$s} && exists $tomatch{$o}) {
			my $gas = $tomatch{$s};
			my $gao = $tomatch{$o};
			print OUT "<$gas> <http://www.w3.org/2006/03/wn/wn20/schema/$p> <$gao> .\n";
		}
	}
}
