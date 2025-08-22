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
    "B" => 1024*1024,
    "KIB" => 1024,
    "MIB" => 1,
    "GIB" => 1024
);

sub convert_to_mb {
    my ($value) = @_;

    my ($type, $size);
    if ($value =~ /^(\d+\.\d+)\s*(MiB|KiB|GiB)\/.*?$/) {
        $size = $1;
        $type = uc($2);
    }

    if (!exists $units{$type}) {
        print "Invalid unit: $type\n";
        exit 1;
    }

    if ($type eq "GIB") {
        return $size * $units{$type};
    } else {
        return $size / $units{$type};
    }
}

sub bytes_to_mb {
    my ($value) = @_;
    return $value/$units{"B"};
}

qx{echo "Algorithm\t100B\t10KB\t1MB\t100MB\t1GB" > "results/encrypt_data.dat"};

foreach my $key (keys %{$hash{"Encrypt"}}) {
	my $row = "$key";
    $row =~ s/\s/\./g;
    $row .= "\t";
    $row .= convert_to_mb($hash{"Encrypt"}{$key}{"100B"}{th})."\t";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"10KB"}{th})."\t";
    $row .= convert_to_mb($hash{"Encrypt"}{$key}{"1MB"}{th})."\t";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"100MB"}{th})."\t";
	$row .= convert_to_mb($hash{"Encrypt"}{$key}{"1GB"}{th})."\t";
    qx{echo "$row" >> "results/encrypt_data.dat"}
}

qx{echo "Algorithm\t100B\t10KB\t1MB\t100MB\t1GB" > "results/decrypt_data.dat"};
foreach my $key (keys %{$hash{"Decrypt"}}) {
	my $row = "$key";
    $row =~ s/\s/\./g;
    $row .= "\t";
    $row .= convert_to_mb($hash{"Decrypt"}{$key}{"100B"}{th})."\t";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"10KB"}{th})."\t";
    $row .= convert_to_mb($hash{"Decrypt"}{$key}{"1MB"}{th})."\t";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"100MB"}{th})."\t";
	$row .= convert_to_mb($hash{"Decrypt"}{$key}{"1GB"}{th})."\t";
    qx{echo "$row" >> "results/decrypt_data.dat"}
}
