#!/usr/bin/perl

#	Toralf Förster
#	Hamburg
#	Germany

use strict;
use diagnostics;
$diagnostics::PRETTY = 1;

use Getopt::Std;
# use Math::Random::Secure qw(rand);
use func;

$| = 1;

#############################################################################
#
#	MAIN
#
#############################################################################
$main::Debug = 99;
$main::Verbose = 0;
%main::Stats = ();

my $Rounds = 10 * 1000 * 1000;

my @Ticket = ();
my %Drawing = ();

my %Options = ();
getopts ('b:h?n:v:', \%Options) or exit (1);

if (defined $Options{h} || defined $Options{'?'})	{
	print <<HERE;

	$0 [-n <rounds>] [-b <n>] [-v <0|1>]
	
	If nothing is specified then 2 times <rounds> drawings are made:
	first <rounds> tickets for 1 drawing, then <rounds> drawing for 1 ticket are created.
	The default for <rounds> is $Rounds.
	
	Just set b to 1, 2 or higher for a detailed output of every n-Bingo and above.
	Set your terminal column size to 120 for a better look.
	
	Typical calls are :
	
	$0
		runs 2x $Rounds
	
	$0 -n 10 -b 0
		10 dreawings each, debug everything
	
	$0 -n 100000000 -v 1
		run 2 times 100 million drawings with verbose output
	
	$0 -n 1000 -b 1
		debug every Bingo
		
	$0 -n 100000 -b 2
		debug 2x-Bingo and above

HERE
	exit (0);
}

if (defined $Options{n})	{
	$Rounds = $Options{n};
}

if (defined $Options{b})	{
	$main::Debug = $Options{b};
}

if (defined $Options{v})	{
	$main::Verbose = $Options{v};
}


#############################################################################
#
#	do it now
#
my $HeaderLine = " 0x-Bingo 1x-Bingo 2x-Bingo 3x-Bingo 4x-Bingo 5x-Bingo";

print "create $Rounds tickets for 1 drawing:\n$HeaderLine\n";
CreateDrawing (\%Drawing);
%{$main::Stats{nT1D}} = (
	col => { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0 },
	row => { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0 },
	ullr => 0, urll => 0,
);
foreach (1..$Rounds)	{
	CreateTicket (\@Ticket);
	my $Bingo = AnalyzeTicket (\@Ticket, \%Drawing, $main::Stats{nT1D});
	PrintStats ($Bingo, $main::Stats{nT1D}, $_ == $Rounds);
}

print "\n";

print "create $Rounds drawings for 1 ticket:\n$HeaderLine\n";
CreateTicket (\@Ticket);
%{$main::Stats{nD1T}} = (
	col => { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0 },
	row => { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0 },
	ullr => 0, urll => 0,
);
foreach (1..$Rounds)	{
	CreateDrawing (\%Drawing);
	my $Bingo = AnalyzeTicket (\@Ticket, \%Drawing, $main::Stats{nD1T});
	PrintStats ($Bingo, $main::Stats{nD1T}, $_ == $Rounds);
}

print "\n";
exit (0);
