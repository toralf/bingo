#!/usr/bin/perl

#	Toralf Förster
#	Hamburg
#	Germany

use strict;
use diagnostics;
$diagnostics::PRETTY = 1;

use Getopt::Std;
use func;

# $| = 1;

#############################################################################
#
#	MAIN
#
#############################################################################
my $Debug = 0;
my %Stats = ();

my %Options = ();
getopts ('d:h?', \%Options) or exit (1);

if (defined $Options{h} || defined $Options{'?'})	{
	print <<HERE;

	$0 [-d <1,2>]
	
	counts for every possible drawing pattern of a 5x5 Bingo matrix
	the amount of 1x-Bingo, 2x-Bingo, 3x-Bingo and so on
	
	Typical calls:
	
	$0
	
	$0 -d 1
		debug output with counter from 1..2^25

	$0 -d 2
		debug output with all 2^25 patterns 

HERE
	exit (0);
}

if (defined $Options{d})	{
	$Debug = $Options{d};
}

#############################################################################
#
#	do it now
#

if ($Debug)	{
	print "\e[2J";
}

#	be paranoid : do not rely on auto-vivication here
#
#	initialize a hash with keys 1..22, each key is reference
#	to a subhash with keys either '' or 1..8
#	the values are the appropriate amounts of Bingo's
#
%{$Stats{Hits}} = (map { $_ => {map { $_ => "" } 0..8} } 1..22);

#	the idea is to abuse a 2^25 big integer as a bit field
#	where each "1" means "marked" and each "0" means "not marked"
#
HITS: foreach my $i (1..2**25)	{
	my @Hit = (				#		$pos
		[ '', '', '', '', '' ],		# col B		 0.. 4
		[ '', '', '', '', '' ],		# col I		 5.. 9
		[ '', '', '', '', '' ],		# col N		10..14
		[ '', '', '', '', '' ],		# col G		15..19
		[ '', '', '', '', '' ],		# col O		20..24
	);
	
	my $Hits = 0;					# amount of bits set to "1"
	foreach my $pos (0..24)	{
		my $Col = $pos / 5;
		my $Row = $pos % 5;
		
		my $Bit = ($i >> $pos) & 0x1;
		if ($Bit)	{
			$Hits++;
			next HITS if ($Hits > 22);	# max amount of drawn numbers exceeded
			
			$Hit[$Col][$Row] = 'x';
		}
	}
	
	my $Bingo = AnalyzeHits (\@Hit, \%Stats);
	$Stats{Hits}->{$Hits}->{$Bingo}++;

	if ($Debug)	{
		if ($Debug > 1)	{
			PrintTicket (\@Hit);
			print "bingo=$Bingo\n";
		} else	{
			print "\e[0;0H\ni=$i";
		}
		print "\n";
	}	
}

print "\nHits 0-Bingo 1-Bingo 2-Bingo 3-Bingo 4-Bingo 5-Bingo 6-Bingo 7-Bingo 8-Bingo\n";
foreach my $Hits (1..22)	{
	printf ("%4i", $Hits);
	foreach my $Bingo (0..8)	{
		 printf ("%8s", $Stats{Hits}->{$Hits}->{$Bingo});
	}
	print "\n"
}
print "\n";

exit (0);
