#!/usr/bin/perl

#	Toralf Förster
#	Hamburg
#	Germany

use strict;
use diagnostics;
$diagnostics::PRETTY = 1;

use Getopt::Std;
# use Math::Random::Secure qw(rand);

$| = 1;

#############################################################################
#
#############################################################################

#	draw N numbers of the intervall (1..75)
#
sub CreateDrawing ($)	{
	my ($Drawing) = @_;

	my @M = (1..75);
	my $N = 22;
	
	%{$Drawing} = (
			map { $_ => 1 }
			map { splice (@M, int rand (scalar @M), 1) }
			1..$N
	);
}


#	prettify output of drawn numbers a little bit
#
sub PrintDrawing ($)	{
	my ($Drawing) = @_;

	print "drawn: ";
	my @n = sort { $a <=> $b } keys %{$Drawing};
	foreach my $i (0..$#n-1)	{
		print $n[$i], " ";
		if (int (($n[$i]-1)/15) != int (($n[$i+1]-1)/15) )	{
			print "- ";
		}
	}
	print $n[$#n];
	
	print "\n";
}


#	the Ticket is a 5x5 matrix containing 25 numbers in the intervall 1-75; each column c contains
#	5 numbers in an arbitrary row of the intervall [1+15c, 1+15(i+c)] with c=0-4
#
#	a typical Ticket :
#
# 	 B  I  N  G  O
# 	 9 21 33 57 75
# 	 8 27 44 55 71
# 	 5 16 31 48 74
# 	15 29 37 60 68
# 	11 20 40 53 62
#
sub CreateTicket ($)	{
	my ($Ticket) = @_;
	
	my @B = ( 1..15);
	my @I = (16..30);
	my @N = (31..45);
	my @G = (46..60);
	my @O = (61..75);
	
	@{$Ticket} = (
		[ map { splice (@B, int rand (scalar @B), 1) } 1..5 ],
		[ map { splice (@I, int rand (scalar @I), 1) } 1..5 ],
		[ map { splice (@N, int rand (scalar @N), 1) } 1..5 ],
		[ map { splice (@G, int rand (scalar @G), 1) } 1..5 ],
		[ map { splice (@O, int rand (scalar @O), 1) } 1..5 ],
	);
}


sub PrintTicket ($)	{
	my ($Ticket) = @_;

	print "  B  I  N  G  O\n";	
	foreach my $Row (0..4) {
		foreach my $Col (0..4) {
			printf ("%3s", $Ticket->[$Col]->[$Row]);
		}
		print "\n";
	}
}


#	count the amount of bingo's (bingo == 5 hits in a line)
#	lines are horizontal, vertical or diagonal
#	lines are allowed to cross each other
#
sub AnalyzeTicket ($$)	{
	my ($Ticket, $Drawing) = @_;

	#	create a 5x5 array and mark all positions where a number is drawn
	#	we use 'x' == TRUE, '' == FALSE
	#
	#	the initialization is not really necessary, but just be on the safe side
	#
	my @Hit = (
		[ '', '', '', '', '' ],
		[ '', '', '', '', '' ],
		[ '', '', '', '', '' ],
		[ '', '', '', '', '' ],
		[ '', '', '', '', '' ],
	);
	
	#	using map() is faster but too much people don't like to read such code
	#
	foreach my $Row (0..4)	{
		foreach my $Col (0..4)	{
			my $d = $Ticket->[$Col]->[$Row];
			if (exists $Drawing->{$d})	{
				$Hit[$Col][$Row] = 'x';
			}
		}
	}

	#	now check how often we do have 5 marks in a line
	#
	my $Bingo = 0;

	#	horizontal line == a row
	#
	foreach my $Row (0..4)	{
		$Bingo++ if ($Hit[0][$Row] && $Hit[1][$Row] && $Hit[2][$Row] && $Hit[3][$Row] && $Hit[4][$Row]);
	}

	#	vertical line == a column
	#
	foreach my $Col (0..4)	{
		$Bingo++ if ($Hit[$Col][0] && $Hit[$Col][1] && $Hit[$Col][2] && $Hit[$Col][3] && $Hit[$Col][4]);
	}

	#	upper left to lower right
	#
	$Bingo++ if ($Hit[0][0] && $Hit[1][1] && $Hit[2][2] && $Hit[3][3] && $Hit[4][4]);

	#	upper right to lower left
	#
	$Bingo++ if ($Hit[4][0] && $Hit[3][1] && $Hit[2][2] && $Hit[1][3] && $Hit[0][4]);

	#	debug, see above for an example output
	#
	if ($Bingo >= $main::Debug)	{
		print "\n==================\n";
		PrintTicket ($Ticket);
		print "\n";
		PrintDrawing ($Drawing);
		print "\n";
		PrintTicket (\@Hit);
		print "\n";
		print "bingo(s): $Bingo\n";
		print "==================\n\n";
	}
	
	return $Bingo;
}


sub CountResult ($$$$)	{
	my ($Ticket, $Drawing, $Result, $IsLast) = @_;

	my $Bingo = AnalyzeTicket ($Ticket, $Drawing);
	$Result->{$Bingo}++;

	#	print current state after each multi-bingoand finally
	#
	if ($Bingo > 1 || $IsLast)	{
		print "  results:";
		foreach my $Bingo (sort { $a <=> $b } keys %{$Result})	{
			print "     ", $Bingo, "x-Bingo: ", $Result->{$Bingo};
		}
		print "\r";
	
		if ($IsLast)	{
			print "\n";
		}
	}
}


#############################################################################
#
#	MAIN
#
#############################################################################
$main::Debug = 99;	#	with eg. "2" debug "double Bingo" and above

my $Rounds = 10 * 1000 * 1000;	#	10 millions gives a quick overview

my @Ticket = ();
my %Drawing = ();
my %Result;		# count here all Bingos, the hash key is usually in range of 0-3, rarely 4

my %h_Opt = ();
getopts ('b:h?n:', \%h_Opt) or exit (1);

if (defined $h_Opt{h} || defined $h_Opt{'?'})	{
	print <<HERE;

	$0 [-n <rounds>] [-b <0-8>]
	
	if nothing is specified then 2 times $Rounds rounds were made (~10 min runtime each)
	
	1st round creates $Rounds tickets for 1 drawing, 2nd rounds creates $Rounds drawing for 1 ticket
	
	to debug this program just set b to the number of bingos you want to verify
	typical calls:
	$0
		runs 2x $Rounds
	
	$0 -n 1 -b 0
		debug for 1 ticket / 1 drawing
	
	$0 - n 100000000
		fund 100 million times each of both round
	
	$0 -n 1000 -b 1
		debug every bingo
		
	$0 -n 100000 -b 2
		debug double bingo and above

HERE
	exit (0);
}

if (defined $h_Opt{n})	{
	$Rounds = $h_Opt{n};
}

if (defined $h_Opt{b})	{
	$main::Debug = $h_Opt{b};
}

#############################################################################
#
#	do it now
#
print "create $Rounds tickets for 1 drawing\n";
CreateDrawing (\%Drawing);
%Result = ();
foreach (1..$Rounds)	{
	CreateTicket (\@Ticket);
	CountResult (\@Ticket, \%Drawing, \%Result, $_ == $Rounds);
}

print "create $Rounds drawings for 1 ticket\n";
CreateTicket (\@Ticket);
%Result = ();
foreach (1..$Rounds)	{
	CreateDrawing (\%Drawing);
	CountResult (\@Ticket, \%Drawing, \%Result, $_ == $Rounds);
}


print "\n";
exit (0);
