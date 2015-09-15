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
	"wnschema:agent" => ["ate", "ation", "e", "ee", "eer", "er", "ion", "ior", "ise", "ize", "ker", "or", "r", "yer"],
	"wnschema:body-part" => ["ate", "er", "or", "r"],
	"wnschema:by_means_of" => ["ance", "ate", "ation", "ence", "er", "fy", "ify", "ion", "ise", "ition", "ize", "ment", "or", "r"],
	"wnschema:destination" => ["e", "ee", "ify"],
	"wnschema:event" => ["al", "ament", "ance", "ate", "ation", "eate", "ee", "ence", "ent", "er", "ify", "ing", "ion", "isation", "ise", "ition", "ization", "ize", "ment", "nce", "or", "r", "sion"],
	"wnschema:instrument" => ["ator", "er", "ise", "ize", "ment", "or", "r"],
	"wnschema:location" => ["alise", "alize", "er", "ize", "ment", "r"],
	"wnschema:material" => ["ate", "eate", "er", "ify", "ise", "ize", "or", "r"],
	"wnschema:property" => ["ance", "ate", "ation", "ence", "ion", "ment", "nce"],
	"wnschema:result" => ["al", "alize", "ance", "ate", "ation", "der", "er", "ify", "ion", "ise", "ize", "ment", "nce", "r", "sion"],
	"wnschema:state" => ["ance", "ation", "ence", "ion", "ise", "ize", "ment", "nce", "or"],
	"wnschema:undergoer" => ["al", "ance", "ation", "e", "ee", "ence", "er", "ify", "ion", "ize", "ment", "nce", "r"],
	"wnschema:uses" => ["alize", "ament", "ance", "ate", "ation", "ify", "ing", "ise", "ize", "ment"],
);

my %affixsense = (
);

print DECOMP "\@prefix lemon: <http://lemon-model.net/lemon#> .\n\n";

while (<EN>) {
	chomp;
	my @parts = split / /, $_;
	if (
}
