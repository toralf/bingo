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
#	TODO: "Bingo! Die Umweltlotterie" uses a 2-tier drawing algorithm
#	which will be implemented as soon as the details are available
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
#	TODO:
#	pre-analyze %Drawings wrt to "min 5 numbers in a column"
#	and "at least one number in each column" could speed up
#	things - but at the cost of code readability
#
sub AnalyzeTicket ($$$)	{
	my ($Ticket, $Drawing, $Stats) = @_;

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
		if ($Hit[0][$Row] && $Hit[1][$Row] && $Hit[2][$Row] && $Hit[3][$Row] && $Hit[4][$Row])	{
			$Bingo++;
			$Stats->{row}->{$Row}++;
		}
	}

	#	vertical line == a column
	#
	foreach my $Col (0..4)	{
		if ($Hit[$Col][0] && $Hit[$Col][1] && $Hit[$Col][2] && $Hit[$Col][3] && $Hit[$Col][4])	{
			$Bingo++;
			$Stats->{col}->{$Col}++;
		}
	}

	#	upper left to lower right
	#
	if ($Hit[0][0] && $Hit[1][1] && $Hit[2][2] && $Hit[3][3] && $Hit[4][4])	{
		$Bingo++;
		$Stats->{ullr}++;
	}

	#	upper right to lower left
	#
	if ($Hit[4][0] && $Hit[3][1] && $Hit[2][2] && $Hit[1][3] && $Hit[0][4])	{
		$Bingo++;
		$Stats->{urll}++;
	}

	#	parameter -b controls if a single or a multi-Bingo triggers the output
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
	
	$Stats->{nBingo}->{$Bingo}++;
	
	return $Bingo;
}


sub PrintStats ($$$)	{
	my ($Bingo, $Stats, $IsLast) = @_;

	if (($Bingo > 1 && $main::Verbose) || $IsLast )	{
		foreach my $k (sort { $a <=> $b } keys %{$Stats->{nBingo}})	{
			printf ("%9d", $Stats->{nBingo}->{$k});
		}
		
		if ($IsLast)	{
			print	"\n",
				"    col B    col I    col N    col G    col O",
				"    row 1    row 2    row 3    row 4    row 5",
				"     ullr     urll\n"
				;
			
			foreach my $i (0..4)	{
				printf ("%9d", $Stats->{col}->{$i});
			}
			foreach my $i (0..4)	{
				printf ("%9d", $Stats->{row}->{$i});
			}
			printf ("%9d%9d\n", $Stats->{ullr}, $Stats->{urll});
			
		} else	{
			print "\r" ;
		}
	}
}


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
