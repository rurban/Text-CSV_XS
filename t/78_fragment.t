#!/pro/bin/perl

use strict;
use warnings;
$| = 1;

use Config;
use Test::More;

BEGIN {
    unless (exists  $Config{useperlio} &&
            defined $Config{useperlio} &&
            $] >= 5.008                && # perlio was experimental in 5.6.2, but not reliable
            $Config{useperlio} eq "define") {
        plan skip_all => "No reliable perlIO available";
        }
    else {
        plan tests => 20;
        }
    }

use Text::CSV_XS;
my $csv = Text::CSV_XS->new ();

my @test = (
    "row=1"         => [[ 11,12,13,14,15,16,17,18,19 ]],
    "row=2-3"       => [[ 21,22,23,24,25,26,27,28,29 ],
			[ 31,32,33,34,35,36,37,38,39 ]],
    "row=2;4;6"     => [[ 21,22,23,24,25,26,27,28,29 ],
			[ 41,42,43,44,45,46,47,48,49 ],
			[ 61,62,63,64,65,66,67,68,69 ]],
    "row=1-2;4;6-*" => [[ 11,12,13,14,15,16,17,18,19 ],
			[ 21,22,23,24,25,26,27,28,29 ],
			[ 41,42,43,44,45,46,47,48,49 ],
			[ 61,62,63,64,65,66,67,68,69 ],
			[ 71,72,73,74,75,76,77,78,79 ],
			[ 81,82,83,84,85,86,87,88,89 ],
			[ 91,92,93,94,95,96,97,98,99 ]],
    "col=1"         => [[11],[21],[31],[41],[51],[61],[71],[81],[91]],
    "col=2-3"       => [[12,13],[22,23],[32,33],[42,43],[52,53],
			[62,63],[72,73],[82,83],[92,93]],
    "col=2;4;6"     => [[12,14,16],[22,24,26],[32,34,36],[42,44,46],[52,54,56],
			[62,64,66],[72,74,76],[82,84,86],[92,94,96]],
    "col=1-2;4;6-*" => [[11,12,14,16,17,18,19], [21,22,24,26,27,28,29],
			[31,32,34,36,37,38,39], [41,42,44,46,47,48,49],
			[51,52,54,56,57,58,59], [61,62,64,66,67,68,69],
			[71,72,74,76,77,78,79], [81,82,84,86,87,88,89],
			[91,92,94,96,97,98,99]],
    #cell=R,C
    "cell=7,7"      => [[ 77 ]],
    "cell=7,7-8,8"  => [[ 77,78 ], [ 87,88 ]],
    "cell=7,7-*,8"  => [[ 77,78 ], [ 87,88 ], [ 97,98 ]],
    "cell=7,7-8,*"  => [[ 77,78,79 ], [ 87,88,89 ]],
    "cell=7,7-*,*"  => [[ 77,78,79 ], [ 87,88,89 ], [ 97,98,99 ]],

    "cell=7,7;7,8;8,7;8,8"	=> [[ 77,78 ], [ 87,88 ]],
    "cell=8,8;8,7;7,8;7,7"	=> [[ 77,78 ], [ 87,88 ]],

    "cell=1,1-2,2;3,3-4,4"	=> [
	[11,12],
	[21,22],
		[33,34],
		[43,44]],
    "cell=1,1-3,3;2,3-4,4"	=> [
	[11,12,13],
	[21,22,23,24],
	[31,32,33,34],
	      [43,44]],
    "cell=1,1-3,3;2,2-4,4;2,3;4,2"	=> [
	[11,12,13],
	[21,22,23,24],
	[31,32,33,34],
	   [42,43,44]],
    "cell=1,1-2,2;3,3-4,4;1,4;4,1"	=> [
	[11,12,     14],
	[21,22],
		[33,34],
	[41,     43,44]],
    );
my $todo = "";
my $data = join "" => <DATA>;
while (my ($spec, $expect) = splice @test, 0, 2) {
    open my $io, "<", \$data;
    my $aoa = $csv->fragment ($io, $spec);
    is_deeply ($aoa, $expect, "${todo}Fragment $spec");
    }

$csv->column_names ("c3","c4");
open my $io, "<", \$data;
is_deeply ($csv->fragment ($io, "cell=3,2-4,3"),
    [ { c3 => 32, c4 =>33 }, { c3 => 42, c4 => 43 }], "Fragment to AoH");

#$csv->eol ("\n");
#foreach my $r (1..9){$csv->print(*STDOUT,[map{$r.$_}1..9])}
__END__
11,12,13,14,15,16,17,18,19
21,22,23,24,25,26,27,28,29
31,32,33,34,35,36,37,38,39
41,42,43,44,45,46,47,48,49
51,52,53,54,55,56,57,58,59
61,62,63,64,65,66,67,68,69
71,72,73,74,75,76,77,78,79
81,82,83,84,85,86,87,88,89
91,92,93,94,95,96,97,98,99
