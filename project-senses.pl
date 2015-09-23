#!/usr/bin/perl

use warnings;
use strict;
use utf8;

open (LINKS, "<$ARGV[0]") or die "$!\n";
open (EN, "<$ARGV[1]") or die "$!\n";
open (ALIGNONE, ">$ARGV[1]-proj-single.ttl") or die "$!\n";
open (ALIGNMULT, ">$ARGV[1]-proj-mult.ttl") or die "$!\n";
open (ALIGNFILT, ">$ARGV[1]-proj-filt.ttl") or die "$!\n";
open (DECOMP, ">$ARGV[1]-proj-decomp.ttl") or die "$!\n";

binmode LINKS, ":utf8";
binmode EN, ":utf8";
binmode ALIGNONE, ":utf8";
binmode ALIGNMULT, ":utf8";
binmode ALIGNFILT, ":utf8";
binmode DECOMP, ":utf8";
binmode STDERR, ":utf8";

my %tomatch = ();

sub delenite {
	my $w = $_[0];
	if ($w =~ /([bcdfgmnpst])h(.*)/) {
		$w = $1 . $2;
	}
	$w;
}

my %prefixes = (
	'antonymOf' => ['neamh', 'neamh-', 'mí', 'éa', 'éi', 'dios', 'dis', 'dí', 'droch', 'droch-', 'dí', 'frith', 'iar'],
);

my %affixsense = (
	'antonymOf_neamh' => 'neamh1',
	'antonymOf_neamh-' => 'neamh-1',
	'antonymOf_mí' => 'mí1',
	'antonymOf_éa' => 'éa1',
	'antonymOf_éi' => 'éi1',
	'antonymOf_dios' => 'dios1',
	'antonymOf_dis' => 'dis1',
	'antonymOf_dí' => 'dí1',
	'antonymOf_droch' => 'droch1',
	'antonymOf_droch-' => 'droch-1',
	'antonymOf_dí' => 'dí1',
	'antonymOf_frith' => 'frith1',
	'antonymOf_iar' => 'iar1',
);

while (<LINKS>) {
	if (m!<([^>]*)> <http://lexvo.org/ontology#nearlySameAs> <([^>]*)>!) {
		my $ga = $1;
		my $en = $2;
		push(@{$tomatch{$en}}, $ga);
	}
}

print DECOMP "\@prefix lemon: <http://lemon-model.net/lemon#> .\n\n";

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
							my $luri = $mo;
							my $suri = $ms;
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
								$luri = $mo;
								$suri = $ms;
							}
							if ($long =~ /^($pfx)(.*)/) {
								my $prefix = $1;
								my $wd = $2;
								my $dlwd = delenite($wd);
								if ($short eq delenite($wd)) {
									print ALIGNFILT "<$ms> <$p> <$mo> .\n";
									# TODO: introduce intermediate nodes, which can be aligned
									my $decompl = $luri;
									$decompl =~ s!wordsense!decomposition!;
									print DECOMP "<$decompl> lemon:decomposition (\n";
#									print DECOMP " [ lemon:element affix:$affixmap{$wd} ]\n";
									print DECOMP " [ lemon:element affix:$prefix ]\n";
									print DECOMP " [ lemon:element <$suri> ] ) .\n\n";
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
