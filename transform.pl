use strict;
use warnings;
use Tie::IxHash;

open(my $fh, '<', $ARGV[0]) or die "Cannot open file: $!";

tie my %hash, 'Tie::IxHash';
tie my %encr, 'Tie::IxHash';
tie my %decr, 'Tie::IxHash';
$hash{"Encrypt"} = \%encr;
$hash{"Decrypt"} = \%decr;

my $enc  = "";
my $curr = "";
my $type = "";
my $time = "";
# Read the file line by line
while (my $line = <$fh>) {
    chomp($line);  # Remove newline character from the end of the line
    # Process the line here
    if ($curr ne "") {
	if ($line =~ /.*time:.*\[.*? .*? (.*? .*?) .*? .*?\]$/) {
		continue if $1 =~ /\%/;
		$time = $1;
		$hash{$enc}{$curr}{$type}{time} = $time;
	} elsif ($line =~ /.*thrpt:.*\[.*? .*? (.*? .*?) .*? .*?\]$/) {
		continue if $1 =~ /\%/;
		$hash{$enc}{$curr}{$type}{th} = $1;
		$curr = "";
	}
    } elsif ($line =~ /^(Encrypt|Decrypt)\s(.*?)\/(.*?)$/) {
	$enc  = $1;
	$curr = $3;
	$type = $2;
    }
}
# Close the file
close($fh);

foreach my $key (keys %{$hash{"Encrypt"}}) {
	print "[".$key."], [".$hash{"Encrypt"}{$key}{"100B"}{time}."\\ (".$hash{"Encrypt"}{$key}{"100B"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"1Mb"}{time}."\\ (".$hash{"Encrypt"}{$key}{"1Mb"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"100Mb"}{time}."\\ (".$hash{"Encrypt"}{$key}{"100Mb"}{th}.")],\n";
}

print "-------------------\n";


foreach my $key (keys %{$hash{"Decrypt"}}) {
	print "[".$key."], [".$hash{"Decrypt"}{$key}{"100B"}{time}."\\ (".$hash{"Decrypt"}{$key}{"100B"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"1Mb"}{time}."\\ (".$hash{"Decrypt"}{$key}{"1Mb"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"100Mb"}{time}."\\ (".$hash{"Decrypt"}{$key}{"100Mb"}{th}.")],\n";
}
