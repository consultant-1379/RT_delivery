#!/usr/bin/perl
use warnings;
use strict;

#
#-- get current directory
use Cwd;

if ( $< != 0 ) {
	print "\n\tThis script must be executed as root user\n\n";
        exit (0);
}

if (@ARGV < 3) {
	print STDERR "\n\tUsage: perl $0 <CPAN_Modules.zip> <epfg_package.zip> <RT_inputFile>\n\n";
	exit 1;
}

my $cpanPkg = $ARGV[0];
my $epfgPkg = $ARGV[1];
my $RT_inputFile = $ARGV[2];

chdir("/eniq/home/dcuser") or die "cannot change: $!\n";
print(cwd);
print "\n\n";

system("/usr/bin/rm -rf CPAN_Modules");
sleep(2);

if ( $^O ne "linux") {
	system("perl cpanInstallerScript.pl $cpanPkg");
	sleep(15);
}
else {
	system("perl cpanInstallerRHEL.pl $cpanPkg");
	sleep(15);
}


system("perl executeRT.pl $epfgPkg $RT_inputFile");
