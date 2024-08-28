use strict;
use warnings;
use DBI;
use Expect;
my $undef=undef;


###################################################################
# $delim defined to capture correct prompt which was previously
# hardcoded to '#:' and which failed for vApps
###################################################################

#my $delim = `echo \$PS1`;
#chomp($delim);
#$delim = substr($delim,-2);
my $delim = "#";

###################################################################

my $exp = new Expect;

my $epfgPkg = $ARGV[0];
my $RT_inputFile = $ARGV[1];

print "$epfgPkg $RT_inputFile\n\n";

$exp->spawn("/usr/bin/bash");

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/su - dcuser\r");}]);
$exp->expect(2);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("bash\r");}]);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/rm -rf epfg\r");}]);
$exp->expect(5);
	
#Upzip the EPFG zip taken down earlier as dcuser
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/unzip $epfgPkg\r");}]); 
$exp->expect(10);

#Change permissions of efgf and all the subdirectories under it 
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/chmod -R 777 epfg\r");}]);
$exp->expect(2);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("cd /eniq/home/dcuser/epfg/\r");}]);
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("./epfg_preconfig_for_ft.sh\r");}]);
$exp->expect(10);
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("cd /eniq/home/dcuser/\r");}]);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/chmod +x rt_script.sh\r");}]);
$exp->expect(2);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("source /eniq/sql_anywhere/bin64/sa_config.sh\r");}]);
$exp->expect(2);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("env\r");}]);
$exp->expect(2);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/nohup ./rt_script.sh $RT_inputFile & /usr/bin/nohup ./Log.sh &\r");}]);
$exp->expect(5);
