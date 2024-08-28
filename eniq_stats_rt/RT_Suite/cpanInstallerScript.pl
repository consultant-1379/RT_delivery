#!/usr/bin/perl
#
#-- get current directory
use Cwd;
use Cwd 'abs_path','realpath','fast_abs_path';

if ( $< != 0 ) {
	print "\n\tThis script must be executed as root user\n\n";
        exit (0);
}

if (@ARGV < 1) {
	print STDERR "\n\tUsage: perl $0 <CPAN_Modules.zip>\n\n";
	exit 1;
}

my $cpanPkg = $ARGV[0];

$ENV{'PATH'} = '/usr/sbin:/usr/bin:/usr/sfw/bin';
print $ENV{'PATH'};

my $cpanDir = "CPAN_Modules";

if ( -d "$cpanDir" ) {
	system("/usr/bin/rm -rf $cpanDir");
}

system("/usr/bin/unzip $cpanPkg");
sleep(3);

chdir("$cpanDir") or die "cannot change: $!\n";

my @modules = ();
$modules[0]="XML-Writer";
$modules[1]="ExtUtils-MakeMaker";
$modules[2]="XML-NamespaceSupport";
$modules[3]="Devel-Symdump";
$modules[4]="Pod-Coverage";
$modules[5]="Test-Pod-Coverage";
$modules[6]="Pod-Escapes";
$modules[7]="Test";
$modules[8]="Pod-Simple";
$modules[9]="Sub-Uplevel";
$modules[10]="Test-Simple";
$modules[11]="Test-Pod";
$modules[12]="Abstract-Meta-Class";
$modules[13]="DBIx-Connection";
$modules[14]="XML-SAX-Base";
$modules[15]="XML-SAX";
$modules[16]="Simple-SAX-Serializer";
$modules[17]="Test-DBUnit";
$modules[18]="Text-CSV";
$modules[19]="File-Slurp";
$modules[20]="DBD-SQLAnywhere";
$modules[21]="Test-Exception";
$modules[22]="IO-Tty";
$modules[23]="Expect";
$modules[24]="MCE";

foreach my $module (@modules)
{
	my $tar_fname;
	my @FILE_LIST = glob "$module*gz";
	if (($#FILE_LIST + 1) != 0)
	{
		my $gz_fname = $FILE_LIST[$#FILE_LIST];
		system("gunzip $gz_fname");
		$tar_fname = substr($gz_fname,0,index($gz_fname,".gz"));
	}
	else
	{
		my @FILE_LIST = glob "$module*tar";
		$tar_fname = $FILE_LIST[$#FILE_LIST];
	}	
	system("tar xvf $tar_fname");
	my $dir_name = substr($tar_fname,0,index($tar_fname,".tar"));
	print "Module Name : $dir_name\n";

	if ( -d "$dir_name" ) {
		system("chmod -R 750 $dir_name");
		chdir($dir_name);
		system("/usr/perl5/bin/perlgcc Makefile.PL");
		system("/usr/sfw/bin/gmake");
		system("/usr/sfw/bin/gmake test");
		system("/usr/sfw/bin/gmake install");
		chdir("..");
	}
}

chdir("..");
