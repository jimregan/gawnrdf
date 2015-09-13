#!/usr/bin/perl

use warnings;
use strict;
use utf8;

open (MCR, "</tmp/mcruniq.nt") or die "$!\n";
open (ALIGN, "</tmp/mcr-links.nt") or die "$!\n";
open (OUT, ">mcr-projections.ttl") or die "$!\n";

my %snsposposmap = (
	'n' => '1',
	'a' => '3',
	'adv' => '4',
	'v' => '2',
);

my @rels = qw/be_in_state category category_term causes has_derived 
has_holo_madeof has_holo_member has_holo_part has_hyperonym has_hyponym
has_mero_madeof has_mero_member has_mero_part has_subevent is_caused_by
is_derived_from is_subevent_of near_antonym near_synonym region 
region_term related_to see_also_wn15 state_of usage usage_term verb_group/;
my $mrel = join("|", @rels);

my @links = qw/sumo_at sumo_equal sumo_plus topConcept/;
my $mlinks = join("|", @links);

my %tomatch = ();

while (<ALIGN>) {
	if (m!<([^>]*)> <http://lexvo.org/ontology#nearlySameAs> <([^>]*)>!) {
		my $ga = $1;
		my $en = $2;
		$en =~ s!/EN/eng!/ILI/ili!;
		$tomatch{$en} = $ga
	}
}

while (<MCR>) {
	if (m!<([^>]*)> <http://lodserver.iula.upf.edu/euroWordNetMCR/($mrel)> <(http://lodserver.iula.upf.edu/id/WordNetLemon/ILI/[^>]*)>!) {
		my $s = $1;
		my $p = $2;
		my $o = $3;
		if (exists $tomatch{$s} && exists $tomatch{$o}) {
			my $gas = $tomatch{$s};
			my $gao = $tomatch{$o};
			print OUT "<$gas> <http://lodserver.iula.upf.edu/euroWordNetMCR/$p> <$gao> .\n";
		}
	}
	if (m!<([^>]*)> <http://lodserver.iula.upf.edu/euroWordNetMCR/($mlinks)> <([^>]*)>!) {
		my $s = $1;
		my $p = $2;
		my $o = $3;
		if (exists $tomatch{$s}) {
			my $gas = $tomatch{$s};
			print OUT "<$gas> <http://lodserver.iula.upf.edu/euroWordNetMCR/$p> <$o> .\n";
		}
	}
}
