#!/usr/bin/perl

use warnings;
use strict;
use utf8;

open (EN, "<$ARGV[0]") or die "$!\n";
open (DECOMP, ">$ARGV[0]-decomp.ttl") or die "$!\n";

binmode LINKS, ":utf8";
binmode EN, ":utf8";
binmode ALIGNONE, ":utf8";
binmode ALIGNMULT, ":utf8";
binmode ALIGNFILT, ":utf8";
binmode DECOMP, ":utf8";
binmode STDERR, ":utf8";

my %tomatch = ();

my $CNS = '[bcdfghjklmnpqrstvwxyz]';

sub dedouble {
	my $word = $_[0];
	if ($word =~ /(.*)($CNS)($CNS)$/) {
		my $st = $1;
		if ($2 eq $3) {
			$word = $st . $2;
		}
	}
	$word;
}

my %prefixes = (
	'antonymOf' => ['un', 'non', 'a', 'in'],
);

my %suffixes = (
	'adjectivePertainsTo' => ['ical', 'ish', 'ural', 'ic', 'ine', 'ate', 'ly', 'an', 'n', 'nical', 'atic', 'ine'],
	'adverbPertainsTo' => ['ly', 'erly', 'y', 'ally'],
);

my %affixsense = (
);

print DECOMP "\@prefix lemon: <http://lemon-model.net/lemon#> .\n\n";

while (<EN>) {
	chomp;
	my @parts = split / /, $_;
	if (
}
