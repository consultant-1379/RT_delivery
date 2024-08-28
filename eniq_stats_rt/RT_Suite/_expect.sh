#!/usr/bin/perl

my $Result = "";
if (@ARGV < 1) {
	print STDERR "\n\tUsage: ./$0 <Command>\n\n";
	exit 1;
}

my $command = $ARGV[0];

if ( $^O eq "linux") {
	$Result = `./_expectRHEL '$command'`;
}
else{
	$Result = `./_expectSolaris '$command'`;
}
print $Result