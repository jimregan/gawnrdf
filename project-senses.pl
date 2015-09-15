#!/usr/bin/perl

use warnings;
use strict;
use utf8;

open (LINKS, "<$ARGV[0]") or die "$!\n";
open (EN, "<$ARGV[1]") or die "$!\n";
open (ALIGNONE, ">$ARGV[1]-proj-single.ttl") or die "$!\n";
open (ALIGNMULT, ">$ARGV[1]-proj-mult.ttl") or die "$!\n";
open (ALIGNFILT, ">$ARGV[1]-proj-filt.ttl") or die "$!\n";

binmode LINKS, ":utf8";
binmode EN, ":utf8";
binmode ALIGNONE, ":utf8";
binmode ALIGNMULT, ":utf8";
binmode ALIGNFILT, ":utf8";

my %tomatch = ();

sub delenite {
	my $w = $_[0];
	if ($w =~ /([bcdfgmnpst])h(.*)/) {
		$w = $1 . $2;
	}
	$w;
}

my %prefixes = (
	'antonymOf' => ['neamh', 'neamh-', 'mí', 'éa', 'éi', 'dios'],
);

while (<LINKS>) {
	if (m!<([^>]*)> <http://lexvo.org/ontology#nearlySameAs> <([^>]*)>!) {
		my $ga = $1;
		my $en = $2;
		push(@{$tomatch{$en}}, $ga);
	}
}

while (<EN>) {
	if (m!<([^>]*)> <([^>]*)> <([^>]*)>!) {
		my $s = $1;
		my $p = $2;
		my $o = $3;
		my $key = '';
		my $pfx = '';
		if ($p =~ m!http://www.w3.org/2006/03/wn/wn20/schema/(.*)!) {
			$key = $1;
		}
		if (exists $tomatch{$s} && exists $tomatch{$o}) {
			if ($#{$tomatch{$s}} == 0 && $#{$tomatch{$p}} == 0) {
				print ALIGNONE "<@{$tomatch{$s}}> <$p> <@{$tomatch{$o}}> .\n";
			} else {
				foreach my $ms (@{$tomatch{$s}}) {
					foreach my $mo (@{$tomatch{$o}}) {
						print ALIGNMULT "<$ms> <$p> <$mo> .\n";
						if (exists $prefixes{$key}) {
							$pfx = join('|', @{$prefixes{$key}});
							my $long = '';
							my $short = '';
							if ($mo =~ m!/wordsense\-(.*)\-(noun|adjective|verb|adverb)!) {
								$long = $1;
							}
							if ($ms =~ m!/wordsense\-(.*)\-(noun|adjective|verb|adverb)!) {
								$short = $1;
							}
							if (length $short > length $long) {
								my $tmp = $short;
								$short = $long;
								$long = $tmp;
							}
							if ($long =~ /^($pfx)(.*)/) {
								my $wd = $2;
								my $dlwd = delenite($wd);
print STDERR "$dlwd\n";
								if ($short eq delenite($wd)) {
									print ALIGNFILT "<$ms> <$p> <$mo> .\n";
									# TODO: here, do decomposition
								}
							}
						}
					}
				}
				print ALIGNMULT "\n\n";
			}
		}
	}
}
