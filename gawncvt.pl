#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $start = 0;

my $galist = '';
my $comment = '';
my $en = '';
my $counter = 0;
my $last = '';
my $wnid = '';
my $skipline = 0;


open(LEMON, '>>gawn-lemon.ttl') or die "$!\n";
open(VUWN, '>>gawn-vu.ttl') or die "$!\n";
open(LINKS, '>>gawn-lemon-vu-links.tsv') or die "$!\n";
# index.sense from http://wordnetcode.princeton.edu/3.0/WNdb-3.0.tar.gz
open(SENSES, '<index.sense') or die "$!\n";

my %posmap = (
	'n' => 'noun',
	'a' => 'adjective',
	'adv' => 'adverb',
	'v' => 'verb',
);

my %lexvomap = (
	'1' => 'noun',
	'2' => 'verb',
	'3' => 'adj',
	'4' => 'adv',
	'5' => 'adj',
);

my %w3tmap = (
	'1' => 'noun',
	'2' => 'verb',
	'3' => 'adjective',
	'4' => 'adverb',
	'5' => 'adjectivesatellite',
);

my %w3wsmap = (
	'1' => 'Noun',
	'2' => 'Verb',
	'3' => 'Adjective',
	'4' => 'Adverb',
	'5' => 'AdjectiveSatellite',
);

my %mcrposmap = (
	'1' => 'n',
	'2' => 'v',
	'3' => 'a',
	'4' => 'r',
	'5' => 'a',
);

my %snsposposmap = (
	'n' => '1',
	'a' => '3',
	'adv' => '4',
	'v' => '2',
);

my %seen = ();

sub trimmer {
	my $in = $_[0];
	$in =~ s/^ *//;
	$in =~ s/ *$//;
	$in;
}

sub idmangler {
	my $in = $_[0];
	$in =~ s/::$//;
	$in =~ s/%/_/g;
	$in =~ s/:/_/g;
	$in;
}

print LEMON <<_END_;
\@prefix lemon: <http://lemon-model.net/lemon#> .
\@prefix lvont: <http://lexvo.org/ontology#> .
\@prefix wordnet-ontology: <http://wordnet-rdf.princeton.edu/ontology#> .
\@prefix mcren: <http://lodserver.iula.upf.edu/id/WordNetLemon/EN/> .
\@prefix mcrgl: <http://lodserver.iula.upf.edu/id/WordNetLemon/GL/> .
\@prefix mcres: <http://lodserver.iula.upf.edu/id/WordNetLemon/ES/> .
\@prefix mcrca: <http://lodserver.iula.upf.edu/id/WordNetLemon/CAT/> .
\@prefix mcreu: <http://lodserver.iula.upf.edu/id/WordNetLemon/EU/> .
\@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
\@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
\@prefix gawnl: <gawn-lemon/> .

_END_

print VUWN <<_END_;
\@prefix wn30schema: <http://purl.org/vocabularies/princeton/wordnet/schema#> .
\@prefix wn30: <http://purl.org/vocabularies/princeton/wn30/> .
\@prefix lvont: <http://lexvo.org/ontology#> .
\@prefix wn20schema: <http://www.w3.org/2006/03/wn/wn20/schema/> .
\@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
\@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
\@prefix gawn: <gawn/> .

_END_

my %idxsns = ();
my %idxsnsvu = ();

while (<SENSES>) {
	chomp;
	my @l = split / /, $_;
	$idxsns{$l[0]} = $l[1];
	# We need the sense number to get wordsense links to VU
	$idxsnsvu{$l[0]} = $l[2];
}

# wordnet-gaeilge/en2wn.po
while (<>) {
	chomp;
	if (/^#~ /) {
		$skipline = 1;
	}
	if (/^#\./) {
		if ($start == 0) {
			$start = 1;
		} else {
			$counter++;
		}
		if (/^#\. IG; N=(.*)/) {
			$comment = $1;
		}
		if (/^#\. ga=(.*)/) {
			$galist = $1;
		}
	}
	if (/^msgid "(.*)"$/) {
		next if ($start == 0);
		$en = $1;
		$last = 'g';
	}
	if (/^msgstr "(.*)"$/) {
		next if ($start == 0);
		$wnid = $1;
		$last = 's';
	}
	if (/^"(.*)"$/) {
		my $ctd = $1;
		if ($last eq 'g') {
			$en .= $ctd;
		} else {
			$wnid .= $ctd;
		}
	}
	if (/^$/) {
		next if ($start == 0);
		if ($skipline == 1) {
			$skipline = 0;
			next;
		}
		my $pos = '';
		if ($en =~ /  (n|a|v|adv) /) {
			$pos = $1;
		} elsif ($en =~ /  (n|a|v|adv)$/) {
			$pos = $1;
		} else {
			print STDERR "No PoS seen: $en\n";
		}
		my $syn = sprintf("%08d-%s", $counter, $pos);
		my @gawords = map(trimmer($_), split(/,/, $galist));
		$comment =~ s/"/\\"/g;

		my $snspos = '';
		if ($wnid =~ /%([1-5]):/) {
			$snspos = $1;
		} else {
			# print STDERR "Broken sense key: $wnid\n";
		}
		my $vusnspos = ($snspos ne '') ? $snspos : $snsposposmap{$pos};

		print LEMON "<$syn> a wordnet-ontology:Synset ;\n";
		print LEMON "    rdfs:comment \"$comment\" ; \n" if ($comment ne '');
		print LEMON "    rdfs:label \"$en\"\@eng ;\n" if ($en ne 'DUMMY');
		print LEMON "    rdfs:label \"$gawords[0]\"\@gle ;\n" if ($galist ne 'DUMMY');
		print LEMON "    wordnet-ontology:part_of_speech wordnet-ontology:$posmap{$pos} .\n\n";

		if ($gawords[0] ne 'DUMMY') {
			print VUWN "<synset-$syn> a wn20schema:$w3wsmap{$vusnspos}Synset ;\n";
			print VUWN "    wn20schema:synsetId $idxsns{$wnid} ;\n" if (exists $idxsns{$wnid});
			print VUWN "    rdfs:label \"$gawords[0]\"\@ga .\n\n";
		} else {
			print VUWN "<synset-$syn> a wn20schema:$w3wsmap{$vusnspos}Synset .\n";
			print VUWN "<synset-$syn> wn20schema:synsetId $idxsns{$wnid} .\n" if (exists $idxsns{$wnid});
		}

		print LINKS "$syn\tsynset-$syn\n";

		for my $wrd (@gawords) {
			my $wrdid = $wrd;
			next if ($wrd eq 'DUMMY');
			$wrdid =~ s/ /_/g;
			if (!exists $seen{$wrdid}) {
				$seen{$wrdid} = 1;
				print LEMON "<${wrdid}-$pos> a lemon:LexicalEntry ;\n";
				print LEMON "    lemon:canonicalForm <${wrdid}-$pos#CanonicalForm> ;\n";
				print LEMON "    wordnet-ontology:part_of_speech wordnet-ontology:$posmap{$pos} .\n\n";
				print LEMON "<${wrdid}-$pos#CanonicalForm> a lemon:Form ;\n";
				print LEMON "    lemon:writtenRep \"$wrd\"\@gle .\n";

				if ($wrd =~ / /) {
					print VUWN "<word-$wrdid> a wn20schema:Collocation ;\n";
				} else {
					print VUWN "<word-$wrdid> a wn20schema:Word ;\n";
				}
				print VUWN "    wn20schema:lexicalForm \"$wrd\"\@ga .\n\n";

				print LINKS "${wrdid}-$pos\tword-$wrdid\n";
			} else {
				$seen{$wrdid}++;
			}
			print VUWN "<wordsense-${wrdid}-$w3tmap{$vusnspos}-$seen{$wrdid}> a wn20schema:$w3wsmap{$vusnspos}Sense ;\n";
			print VUWN "    rdfs:label \"$wrd\"\@ga ;\n";
			if ($wnid =~ /([^%]*)%([1-5]):/ && exists $idxsnsvu{$wnid}) {
				print VUWN "    lvont:nearlySameAs wn30:wordsense-$1-$w3tmap{$2}-$idxsnsvu{$wnid} ;\n";
			}
			print VUWN "    wn20schema:word <word-${wrdid}> .\n\n";
			print VUWN "<synset-$syn> wn20schema:containsWordSense <wordsense-${wrdid}-$w3tmap{$vusnspos}-$seen{$wrdid}> .\n";

			print LINKS "${wrdid}-$pos#$seen{$wrdid}-$pos\twordsense-${wrdid}-$w3tmap{$vusnspos}-$seen{$wrdid}\n";

			print LEMON "<${wrdid}-$pos> lemon:sense <${wrdid}-$pos#$seen{$wrdid}-$pos> .\n\n";
			print LEMON "<${wrdid}-$pos#$seen{$wrdid}-$pos> a lemon:LexicalSense ;\n";
			print LEMON "    wordnet-ontology:sense_number $seen{$wrdid} ;\n";
			if ($wnid ne 'NULL' && $wnid ne '') {
				print LEMON "    wordnet-ontology:old_sense_key \"$wnid\" ;\n";
				my $lvwnid = idmangler($wnid);
				my $lvwntxt = $lexvomap{$snspos};
				print LEMON "    lvont:nearlySameAs <http://lexvo.org/id/wordnet/30/$lvwntxt/$lvwnid> ;\n";
				if (exists $idxsns{$wnid}) {
					# FIXME: check that these actually exists. But that takes memory.
					print LEMON "    lvont:nearlySameAs mcreu:eus-30-$idxsns{$wnid}-$mcrposmap{$snspos} ,\n";
					print LEMON "                       mcrca:cat-30-$idxsns{$wnid}-$mcrposmap{$snspos} ,\n";
					print LEMON "                       mcres:spa-30-$idxsns{$wnid}-$mcrposmap{$snspos} ,\n";
					print LEMON "                       mcrgl:glg-30-$idxsns{$wnid}-$mcrposmap{$snspos} ,\n";
					print LEMON "                       mcren:eng-30-$idxsns{$wnid}-$mcrposmap{$snspos} ;\n";
				}
			}
			print LEMON "    lemon:reference <$syn> .\n\n";
			# This is what the Princeton RDF has, but... that can't be right.
			# print LEMON "<$syn> wordnet-ontology:synset_member <${wrdid}-$pos> .\n\n";
			# i.e., the member of the synset should be the sense, not the word
			print LEMON "<$syn> wordnet-ontology:synset_member <${wrdid}-$pos#$seen{$wrdid}-$pos> .\n\n";
		}
		$comment = '';
	}
}


