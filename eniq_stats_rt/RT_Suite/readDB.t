use strict;
use warnings;
use File::Slurp;
use DBI;
use DBIx::Connection;
use Test::DBUnit::Generator;

my $dbname = "dwhdb";
my $port = "2640";
my $cre = "dc";

my $connstr = "ENG=$dbname;CommLinks=tcpip{port=$port};;UID=$cre;PWD=$cre";
my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );

my $connection = DBIx::Connection->new(
	name     => 'test',
	dbh   => $dbh,
);

my @FILE_NAME = glob "SCALAR*";
unlink @FILE_NAME;

my @lines = read_file($ARGV[0]);

my %query = ();

foreach (@lines) {
	my @fields = split ":" , $_;
	$query{$fields[0]} = $fields[1];
}

my $generator = Test::DBUnit::Generator->new(
	connection      => $connection,
        datasets => 
	{
	%query,
	},
);
    
print $generator->xml_dataset;

my @FILE_LIST = glob "DB_XML*";
my $DB_FILE = $FILE_LIST[$#FILE_LIST];
my $DB_FILE_INDEX = substr($DB_FILE, 6 ,index($DB_FILE, ".xml")-6);
my $DB_XML;

if ($DB_FILE_INDEX eq '' or $DB_FILE_INDEX == 0) {
	$DB_XML = "DB_XML1.xml"; 
}
else
{
	$DB_FILE_INDEX = $DB_FILE_INDEX+1;
	$DB_XML = "DB_XML$DB_FILE_INDEX.xml";
}

my $scalar = glob "SCALAR*";
rename $scalar,$DB_XML;



