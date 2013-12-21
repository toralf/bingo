#!/usr/bin/perl

#	Toralf Förster
#	Hamburg
#	Germany


use strict;
use diagnostics;
$diagnostics::PRETTY = 1;

my @Data = <DATA>;
chomp (@Data);

my $Sum = 0;
foreach my $Line (@Data)	{
	next unless ($Line);
	my ($Tickets, $Patterns) = split (/\s+/, $Line);
	my $Prod = $Tickets * $Patterns;
	printf ("%22.0f\n", $Prod);			# verify these numbers too
	$Sum += $Prod;
}
printf ("----------------------\n%22.0f\n", $Sum);

exit (0);


__END__
9847379391150	12
4923689695575	240
2250829575120	2280
937845656300	13680
354860518600	58048
121399651100	184536
37353738800	453480
10272278170	874664
2505433700	1328328
536878650	1575736
99884400	1430612
15890700	958328
2118760	445644
230300	129888
19600	19788
1225	1064

