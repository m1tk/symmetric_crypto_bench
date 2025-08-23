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
	print "[".$key."], [".$hash{"Decrypt"}{$key}{"100B"}{time}."\\ (".$hash{"Decrypt"}{$key}{"100B"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"10KB"}{time}."\\ (".$hash{"Decrypt"}{$key}{"10KB"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"1MB"}{time}."\\ (".$hash{"Decrypt"}{$key}{"1MB"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"100MB"}{time}."\\ (".$hash{"Decrypt"}{$key}{"100MB"}{th}.")], [".
	$hash{"Decrypt"}{$key}{"1GB"}{time}."\\ (".$hash{"Decrypt"}{$key}{"1GB"}{th}.")],\n";
}

# generate plot data

my %units = (
    'B'  => 1,
    'KIB'=> 1024,
    'MIB'=> 1024 * 1024,
    'GIB'=> 1024 * 1024 * 1024,
);

sub convert_to_mb {
    my ($value) = @_;
    return '-' unless defined $value;

    # accept formats like "1.23 MiB/s" or "123 KiB/s"
    if ($value =~ /^\s*(\d+(?:\.\d+)?)\s*(B|KiB|MiB|GiB)\/.*$/i) {
        my ($size, $unit) = ($1, uc $2);
        unless (exists $units{$unit}) {
            warn "Unknown unit '$unit' in value '$value'\n";
            return '-';
        }
        my $bytes = $size * $units{$unit};
        # convert bytes to decimal megabytes (MB = 10^6 bytes)
        my $mb = $bytes / 1_000_000;
        return sprintf("%.4f", $mb);
    } else {
        print "Unrecognized size format: '$value'\n";
        return '-';
    }
}

sub bytes_to_mb {
    my ($value) = @_;
    return '-' unless defined $value;
    return sprintf("%.4f", $value / 1_000_000);
}

print "-------------------\n";

foreach my $key (keys %{$hash{"Encrypt"}}) {
    print "'results/encrypt_$key.txt' using 2:1 with linespoints title '".$key."', \\\n";
}

foreach my $key (keys %{$hash{"Encrypt"}}) {
	my $row = convert_to_mb($hash{"Encrypt"}{$key}{"100B"}{th})." ".bytes_to_mb(100)."\n";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"10KB"}{th})." ".bytes_to_mb(10240)."\n";
    $row .= convert_to_mb($hash{"Encrypt"}{$key}{"1MB"}{th})." ".bytes_to_mb(1048576)."\n";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"100MB"}{th})." ".bytes_to_mb(104857600)."\n";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"1GB"}{th})." ".bytes_to_mb(1073741824)."\n";
    qx{echo "$row" > "results/encrypt_$key.txt"}
}

print "-------------------\n";

foreach my $key (keys %{$hash{"Decrypt"}}) {
    print "'results/decrypt_$key.txt' using 2:1 with linespoints title '".$key."', \\\n";
}

foreach my $key (keys %{$hash{"Decrypt"}}) {
	my $row = convert_to_mb($hash{"Decrypt"}{$key}{"100B"}{th})." ".bytes_to_mb(100)."\n";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"10KB"}{th})." ".bytes_to_mb(10240)."\n";
    $row .= convert_to_mb($hash{"Decrypt"}{$key}{"1MB"}{th})." ".bytes_to_mb(1048576)."\n";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"100MB"}{th})." ".bytes_to_mb(104857600)."\n";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"1GB"}{th})." ".bytes_to_mb(1073741824)."\n";
    qx{echo "$row" > "results/decrypt_$key.txt"}
}
