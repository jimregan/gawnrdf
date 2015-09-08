#!/usr/bin/perl

use warnings;
use strict;
use utf8;

# I tried to do this the "proper" way, by loading the triples into a store, 
# and running a SPARQL query... I got fed up of waiting, wrote this crappy
# script, and ran it in a fraction of the time it had already spent just
# loading the English triples.
open (GA, "<$ARGV[0]") or die "$!\n";
open (EN, "<$ARGV[1]") or die "$!\n";
open (ALIGN, ">ga-vuen-alignments.ttl") or die "$!\n";

my %snsposposmap = (
	'n' => '1',
	'a' => '3',
	'adv' => '4',
	'v' => '2',
);

my %tomatch = ();

while (<GA>) {
	if (m!<([^>]*)> <http://www.w3.org/2006/03/wn/wn20/schema/synsetId> "([^"]*)"!) {
		my $gauri = $1;
		my $gaid = $2;
		if ($gauri =~ /\-(n|a|v|adv)$/) {
			$tomatch{$snsposposmap{$1} . $gaid} = $gauri
		}
	}
}

while (<EN>) {
	if (m!<([^>]*)> <http://www.w3.org/2006/03/wn/wn20/schema/synsetId> "([^"]*)"!) {
		my $enuri = $1;
		my $enid = $2;
		if (exists $tomatch{$enid}) {
			my $gamatch = $tomatch{$enid};
			$gamatch =~ s!file:///tmp/!!;
			print ALIGN "<$gamatch> <http://lexvo.org/ontology#nearlySameAs> <$enuri> .\n";
		}
	}
}
