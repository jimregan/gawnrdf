#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my %seen = ();

my $CNS = '[bcdfghjklmnpqrstvwxyz]';

my %str = ();

while (<>) {
	chomp;
	next unless (/wn30:wordsense/);
	my @parts = split / /, $_;
	my $left = '';
	my $right = '';
	if ($parts[0] =~ /wn30:wordsense\-(.*)-(noun|verb|adjective|adverb|adjectivesatellite)-([0-9]*)/) {
		$left = $1;
	} else {
		print STDERR "Line $. does not match: $_\n";
	}

	if ($parts[2] =~ /wn30:wordsense\-(.*)-(noun|verb|adjective|adverb|adjectivesatellite)-([0-9]*)/) {
		$right = $1;
	} else {
		print STDERR "Line $. does not match: $_\n";
	}

	if (length $left > length $right) {
		my $tmp = $right;
		$right = $left;
		$left = $tmp;
	}

	my $aff = '';
	if ($right =~ /$left/) {
		$aff = $right;
		$aff =~ s/$left/~/;
		next if ($aff eq '~');
		my $lastleft = '';

		if (!exists $seen{$parts[1] . $aff}) {
			$str{$parts[1] . $aff} = "$parts[1]: $aff\t$left\t$right";
			$seen{$parts[1] . $aff} = 1;
		} else {
			$seen{$parts[1] . $aff}++;
		}
	} else {
		my @lch = split //, $left;
		my @rch = split //, $right;

		my $lcommon = 0;
		my $common = 0;
		for (my $i = 0; $i <= $#lch; $i++) {
			if (lc($lch[$i]) eq lc($rch[$i])) {
				$lcommon++;
			}
		}
		if ($lcommon > (length ($left) / 2)) {
			$aff .= substr($left, $lcommon, length($left));
			$aff .= "/";
			$aff .= substr($right, $lcommon, length($right));
		}

		if (!exists $seen{$parts[1] . $aff}) {
			$str{$parts[1] . $aff} = "$parts[1]: $aff\t$left\t$right";
			$seen{$parts[1] . $aff} = 1;
		} else {
			$seen{$parts[1] . $aff}++;
		}
	}
}

foreach my $v (keys %seen) {
	print $seen{$v} . "\t" . $str{$v} . "\n";
}
