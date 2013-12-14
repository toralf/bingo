
#	Toralf Förster
#	Hamburg
#	Germany

package func;

use strict;
use diagnostics;
$diagnostics::PRETTY = 1;
use Exporter;

our @ISA= qw( Exporter );

our @EXPORT = qw( CreateDrawing PrintDrawing CreateTicket PrintTicket AnalyzeTicket PrintStats);


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


#	mark all positions where a number is drawn, 'x' == TRUE, '' == FALSE
#
sub MarkHits ($$$)	 {
	my ($Ticket, $Drawing, $Hit) = @_;

	#	the initialization might not be necessary, but be just on the safe side
	#
	@{$Hit} = (
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
				$Hit->[$Col]->[$Row] = 'x';
			}
		}
	}
}


sub AnalyzeHits ($$)	{
	my ($Hit, $Stats) = @_;
	
	my $Bingo = 0;

	#	horizontal line == a row
	#
	foreach my $Row (0..4)	{
		if ($Hit->[0]->[$Row] && $Hit->[1]->[$Row] && $Hit->[2]->[$Row] && $Hit->[3]->[$Row] && $Hit->[4]->[$Row])	{
			$Bingo++;
			$Stats->{row}->{$Row}++;
		}
	}

	#	vertical line == a column
	#
	foreach my $Col (0..4)	{
		if ($Hit->[$Col]->[0] && $Hit->[$Col]->[1] && $Hit->[$Col]->[2] && $Hit->[$Col]->[3] && $Hit->[$Col]->[4])	{
			$Bingo++;
			$Stats->{col}->{$Col}++;
		}
	}

	#	upper left to lower right
	#
	if ($Hit->[0]->[0] && $Hit->[1]->[1] && $Hit->[2]->[2] && $Hit->[3]->[3] && $Hit->[4]->[4])	{
		$Bingo++;
		$Stats->{ullr}++;
	}

	#	upper right to lower left
	#
	if ($Hit->[4]->[0] && $Hit->[3]->[1] && $Hit->[2]->[2] && $Hit->[1]->[3] && $Hit->[0]->[4])	{
		$Bingo++;
		$Stats->{urll}++;
	}

	$Stats->{nBingo}->{$Bingo}++;
	
	return $Bingo;
}


#	count the amount of bingo's (bingo == 5 hits in a line)
#	lines are horizontal, vertical or diagonal
#	lines are allowed to cross each other
#
#	pre-analyze %Drawing wrt to "min 5 numbers in a column"
#	or "at least one number in each column" would speed up
#	things - but at the cost of code readability
#
sub AnalyzeTicket ($$$$)	{
	my ($Ticket, $Drawing, $Stats, $Debug) = @_;

	my @Hit = ();
	MarkHits ($Ticket, $Drawing, \@Hit);
	my $Bingo = AnalyzeHits (\@Hit, $Stats);
	
	#	parameter -b controls if a single or a multi-Bingo triggers the output
	#
	if ($Bingo >= $Debug)	{
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
}


sub PrintStats ($)	{
	my ($Stats) = @_;
	
	foreach my $k (sort { $a <=> $b } keys %{$Stats->{nBingo}})	{
		printf ("%9d", $Stats->{nBingo}->{$k});
	}
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
}


