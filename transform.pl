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
	$hash{"Encrypt"}{$key}{"10KB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"10KB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"1MB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"1MB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"100MB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"100MB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"1GB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"1GB"}{th}.")],\n";
}

print "-------------------\n";


foreach my $key (keys %{$hash{"Decrypt"}}) {
	print "[".$key."], [".$hash{"Encrypt"}{$key}{"100B"}{time}."\\ (".$hash{"Encrypt"}{$key}{"100B"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"10KB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"10KB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"1MB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"1MB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"100MB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"100MB"}{th}.")], [".
	$hash{"Encrypt"}{$key}{"1GB"}{time}."\\ (".$hash{"Encrypt"}{$key}{"1GB"}{th}.")],\n";
}

# generate plot data

my %units = {
    "B" => 1024*1024,
    "KB" => 1024,
    "MB" => 1,
    "GB" => 1024
};

sub convert_to_mb {
    my ($value) = @_;
    
    my ($type, $size);
    if ($value =~ /^([-+]?\d*\.?\d+)\s*(\w+)\/$/) {
        $size = $1;
        $type = uc($2);
    }
    print "$value $type\n";

    if (!exists $units{$type}) {
        print "Invalid unit: $type\n";
        exit 1;
    }

    if ($type eq "GB") {
        return $size * $units{$type};
    } else {
        return $size / $units{$type};
    }
}

foreach my $key (keys %{$hash{"Encrypt"}}) {
	print convert_to_mb($hash{"Encrypt"}{$key}{"100B"}{th})."\n";
	print convert_to_mb($hash{"Encrypt"}{$key}{"10KB"}{th})."\n";
	print convert_to_mb($hash{"Encrypt"}{$key}{"1MB"}{th})."\n";
	print convert_to_mb($hash{"Encrypt"}{$key}{"100MB"}{th})."\n";
	print convert_to_mb($hash{"Encrypt"}{$key}{"1GB"}{th})."\n";
}
