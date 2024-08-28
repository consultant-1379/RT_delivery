#!/usr/bin/perl -C0
use MCE::Grep Sereal => 1;
	use MCE::Loop;
	use MCE::Util;
	use File::Slurp;
		 MCE::Grep::init {
      chunk_size => '100M', max_workers => MCE::Util::get_ncpu,

      user_begin => sub {
         #print "## ", MCE->wid, " started\n";
      },

      user_end => sub {
         #print "## ", MCE->wid, " completed\n";
      }
   };
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
  $mon++;
  $year=1900+$year;
my $datenew =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);
my $LOGPATH="/eniq/home/dcuser/RegressionLogs";
print "Log Script Sleeping for 60Min\n";
	
sub checkLogs {
	my $result="";
	my $report="";
	my @files = @{$_[0]};
	my @logfilters = undef;
	@logfilters = @{$_[1]};
	my $filterList = join('|',@logfilters);
	open(FH,"<readfile.txt") or die "Couldn't open file file.txt, $!";;
	my $string= do {local $/; <FH> };
	close (FILE); 
	my @ignoreLogFilters=split(',',$string);
	my $ignoreList = join('|',@ignoreLogFilters);
	my @errData=undef;
	for my $file (@files) {
		next if($file eq "");
		print "\nNew File : $file\n";
		if (@logfilters != undef)
		{
			@errData = mce_grep_f { /$filterList/i && not /$ignoreList/i } $file;
		}
		else {
			@errData = mce_grep_f { not /$ignoreList/i } $file;
			my $cnt1 = $#errData + 1;
			print "Type 2 : $cnt1\n";
		}
		chomp(@errData);
		#@errData = `egrep -v \"(FINEST| succesfully |Partition created|permissions to |.LOG_AggregationStatus_|inflating|_ERROR)\" @errData | sed \"s/[0-9][0-9].[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] //\" | sed \"s/:[0-9]* /:/\" | sed \"s/[0-9][0-9].[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]. //\" | sed \"s/ 00000..... Exception Thrown/ Exception Thrown/\" | sed \"s/.* O.S Err/ Err/\"  | sort -u`; 
		my $cnt = $#errData + 1;
		print "Matched Lines : $cnt\n";
		$report.=qq{<tr><td font size = 2> $file </td> <td font size = 2> $cnt </td></tr>};
		#$report.="<h3>FILE : $file</h3> <h3><b>   No.of error lines : $cnt </b></h3>";
		if (@errData != 0) {
			$result.="<h3><b>FILE : $file</b></h3>";
			for my $line (@errData) {
				$_=$line;
                if(/java.lang.|ASA Error|SEVERE|reactivated/) {
                    $result.= "<font color=660000><b>$line</b></font><br>"; 
                    #print "FAIL $line"; 
                }   
				else {
                    $result.="$line<br>"; 
                    #print "$line"; 
                }
			}
		}
		print "Done for $file\n";
	}
	my @Logv=();
	push(@Logv,($result,$report));
	return @Logv; 
}

sub verifyLogs{
	my $result="";
	my $report="";
	my $report1="";
	my $report2="";
	my $result1="";
	my $result2="";
	my @Logv=();
	
	$report.=qq{<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="70%" >
				<tr><th> <font size = 3 > Under Log verification the below 3 different tables can be referred 1.Eniq Logs 2.Engine subdirectory Logs 3.tp_installer Logs verification. </th></table>
				<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 3 > For detailed Information Check Log Verification File in Regression Logs Folder</th></table>
				<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 2 > Path</th>
					<th> <font size = 2 > Number of Skips/Errors/Exceptions/Fails/Severes/Warnings</th></tr>};
	$report1.=qq{<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 3 > For detailed Information Check Engine_subdirs Log Verification File in Regression Logs Folder</th></table>
				<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 2 > Path</th>
					<th> <font size = 2 > Number of Skips/Errors/Exceptions/Fails/Severes/Warnings</th></tr>};
	$report2.=qq{<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 3 > For detailed Information Check TP_Installer Log Verification File in Regression Logs Folder</th></table>
				<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
				<tr><th> <font size = 2 > Path</th>
					<th> <font size = 2 > Number of Skips/Errors/Exceptions/Fails/Severes/Warnings</th></tr>};
	

	my @enginelogFilters=("error","exception","fatal","severe","warning","not found","cannot","not supported","reactivated","Altering column","fail");
	my @svclogFilters=("error","exception","fatal","severe","warning","not found","cannot","not supported","reactivated","Unknown Source","NoClassDefFoundError","fail"); 
	my @iqmsgLogFilters=("Dump all thread stacks at","Abort","fatal","Error","Please report this to SAP IQ support","^E.");
	my @featureLogFilters=("Exception","Fail","Skip","Severe","Error","Warning","ERROR","WARNING","SKIP","SEVERE","FAIL","EXCEPTION","fail");
	
	my @Upgrade = glob "/eniq/local_logs/upgrade/*sw.log";
	my @feature_Only_Upgrade = glob "/eniq/local_logs/upgrade_feature_only/*.log";
	my @manage= glob "/eniq/log/feature_management_log/*_features.log";
	my @fileList=();
	push(@fileList,(@manage,@Upgrade,@feature_Only_Upgrade));
	@Logv=checkLogs(\@fileList,\@featureLogFilters);
	$result.=$Logv[0];
	$report.=$Logv[1];
	@fileList= glob "/eniq/log/sw_log/tp_installer/*.log";
	#print "@fileList";
	@Logv=checkLogs(\@fileList,\@enginelogFilters);
	$result2.=$Logv[0];
	$report2.=$Logv[1];
	my %basedirList;
	if ( $^O ne "linux" ) {
		$basedirList{'/var/svc/log'} = [ @svclogFilters ];
	}
	
	$basedirList{'/eniq/local_logs/iq'} = [ @iqmsgLogFilters ];
	$basedirList{'/eniq/log/sw_log'} = [ @enginelogFilters ];

	my @filters;
	@fileList=();
	for my $dirPath (keys %basedirList) {

		if ( $dirPath eq '/eniq/local_logs/iq' ) {
			@fileList = glob "$dirPath/*.*";
		}
		else {
			@fileList = glob "$dirPath/*.log";
		}
		#print "List : @fileList";
		@fileList = grep { -M $_ < 1 } @fileList;
		chomp(@fileList);
		print "File List : @fileList\n";
		if (exists $basedirList{$dirPath}) {
			@filters = @{$basedirList{$dirPath}};
			$result.="<h3><b>PATH : $dirPath</b></h3>";
			print "PATH : $dirPath\n";
#			@filters = undef;
			@Logv=checkLogs(\@fileList,\@filters);
			$result.=$Logv[0];
			$report.=$Logv[1];
		}

		my @subDirs = read_dir( $dirPath, prefix => 1 ) ;
		for my $subDir (@subDirs) {
			if ( (-d $subDir) && (index($subDir, '.') eq -1) && $subDir ne '/eniq/log/sw_log/tp_installer') {
				$result.="<h3><b>PATH : $subDir</b></h3>";
				@fileList = glob "$subDir/*.log";
				@fileList = grep { -M $_ < 1 } @fileList;
				chomp(@fileList);
				print "SubDir : $subDir   File List : @fileList\n";
				for my $key (keys %basedirList) {
					if (index($subDir, $key) ne -1) {
						@filters = @{$basedirList{$key}};
						last;
					}
				}
				@Logv=checkLogs(\@fileList,\@filters);
				$result.=$Logv[0];
				$report.=$Logv[1];
			}
			if ( $subDir eq '/eniq/log/sw_log/engine' ) {
				my @sub = read_dir( $subDir, prefix => 1 ) ;
				for my $dir (@sub) {
					if ( (-d $dir) && (index($dir, '.') eq -1) ) {
						$result1.="<h3><b>PATH : $dir</b></h3>";
						@fileList = glob "$dir/*.log";
						@fileList = grep { -M $_ < 1 } @fileList;
						chomp(@fileList);
						print "SubDir : $dir   File List : @fileList\n";
						for my $key (keys %basedirList) {
							if (index($dir, $key) ne -1) {
								@filters = @{$basedirList{$key}};
								last;
							}
						}
						@Logv=checkLogs(\@fileList,\@filters);
						$result1.=$Logv[0];
						$report1.=$Logv[1];
					}
				}
			}
		}
		$result.="<br>\n";
		$result1.="<br>\n";
		#$report.="<br>\n";
	}
	@Logv=();
	$report.=qq{</table>};
	$report1.=qq{</table>};
	$report2.=qq{</table>};
	$report.=$report1;
	$report.=$report2;
	push(@Logv,($result,$report,$result1,$result2));
	return @Logv; 
}

sub getHtmlHeader{

return qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>
$testCase
</title>
<STYLE TYPE="text/css">
<!--
h3{font-family:tahoma;font-size:12px}
body,td,tr,p,h{font-family:tahoma;font-size:11px}
.pre{font-family:Courier;font-size:9px;color:#000}
.h{font-size:9px}
.td{font-size:9px}
.tr{font-size:9px}
.h{color:#3366cc}
.q{color:#00c}
table{
border:0;
cellspacing:0;
cellpadding:0;
}
-->
</STYLE>
</head>
<body>
};

}
sub getStartTimeHeader
{
	my $testCase = shift;
	my %testCaseHeading = (
		"verifyLogs","Log Verification",
		"server","Sanity Directory Scripts Check",
		"verifyUniverses","Universe and Alarm Report Verification",
		"adminUI","ADMINUI PLATFORM CHECKS",
		"OVERALL","ENIQ Regression Feature Test",
#		"dbspace","DATABASE SIZE AND FILESYSTEM VERIFICATION",
		"compareBaseline","COMPAREBASELINE VERIFICATION",
		"verifyTopologyTables","VERIFY TOPOLOGY TABLES",
		"verifyLoadings","VERIFY DATA LOADING",
		"verifyAggregations","VERIFY DATA AGGREGATIONS",
		"Counter_keys","COUNTER AND KEYS VALIDATION",
		"pretest","VERIFICATION OF ETL baseDir's",
		);
	my $testCaseHead = $testCaseHeading{$testCase};
	my $rep .= getHtmlHeader($testCaseHead);
	$rep .= "<h1> <font color=MidnightBlue><center> <u> $testCaseHead </u> </font> </h1>";
	$rep .= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
	my $stime = getTime();
	$rep .= "$stime";
#	$rep .= "<tr>";
	return $rep;
}
sub getTime{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  return sprintf "%4d-%02d-%02d %02d:%02d:%02d\n", $year+1900,$mon+1,$mday,$hour,$min,$sec;
}


############################################################
# getEndTimeHeader
# this subroutine returns the end time of each test case
# in a standard format

sub getEndTimeHeader
{
	my $pass = shift;
	my $fail = shift;
	my $rep .= "<tr>";
	$rep .= qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td><font size = 2 ><b>};
	my $etime = getTime();
	my $server= getHostName();
	$rep .= "$etime";
	$rep .= "<tr>";
	$rep .=qq{<tr>
				<th> <font size = 2 > RESULT SUMMARY </th>
				<td><font size = 2 ><b>};
	$rep .= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)";
	$rep .= qq{<tr>
				<th> <font size = 2 > DETAILED RESULT </th>
				<td><font size = 2 ><b>};
	$rep .= "<a href=\"$server\_$datenew.html\" target=\"_blank\">Click here</a>";
	$rep .= "</table>";
	$rep .= "<br>";
	$rep .= "<h3><font size=4 color=\"Blue\"><b><u>Note:</u> Only Failed TestCases shown, refer link above for Detailed Results</b></font></h3><br>";
	return $rep;
}

sub getEndTimeHeader_Log
{
	my $rep .= "<tr>";
	$rep .= qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td><font size = 2 ><b>};
	my $etime = getTime();
#	my $server= getHostName();
	$rep .= "$etime";
	$rep .= "<tr>";
	$rep .= "</table>";
	$rep .= "<br>";
	return $rep;
}

sub getHtmlTail{
return qq{
</table>
<br>
</body>
</html>
};

}

sub writeHtml{
my $server = shift;
my $out    = shift;
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
# $mon++;
#  $year=1900+$year;
#my $date =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);
open(OUT," > $LOGPATH/$server\_$datenew.html");
print  OUT $out;
close(OUT);
return "$LOGPATH/$server\_$datenew.html\n";
}

sleep(60*60);


	my $contents .=	qq{<tr>
				<td></td>
				<td><a href="#READLOG_">LOG VERIFICATION</a></td>
				};
    my $report =getStartTimeHeader("verifyLogs");
	my $report1 =getStartTimeHeader("verifyLogs");
	my $report2 =getStartTimeHeader("verifyLogs");
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
$result.= "<h2><font color=Black><a name=\"READLOG_\">$DATE LOG VERIFICATION</a></font></h2><br>";
print $DATE;
print " LOG VERIFICATION\n";
my @Logv=verifyLogs();
     $result.=$Logv[1];
	 my $fail =()= $Logv[0] =~ /_FAIL_+/g;
	 my $pass =()= $Logv[0]=~ /_PASS_+/g;
	 $contents .=	qq{<td><a href="#READLOG_">Verify Logs</a></td>
					</tr>
						};
	 $report.= getEndTimeHeader_Log();
	 $report.= $Logv[0];
	 $report1.= getEndTimeHeader_Log();
	 $report1.= $Logv[2];
	 $report2.= getEndTimeHeader_Log();
	 $report2.= $Logv[3];
#	 $report.= "<h2>ENDTIME:";
#     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("Log_Verification",$report);
	 print "Log_Verification: PASS- $pass FAIL- $fail\n";
	 print "PARTIAL FILE: $file\n";
	 $report1.= getHtmlTail(); 
     my $file = writeHtml("Engine_Subdirs_Log_Verification",$report1);
	 print "Engine_Subdirs_Log_Verification: PASS- $pass FAIL- $fail\n";
	 print "PARTIAL FILE: $file\n";
	 $report2.= getHtmlTail(); 
     my $file = writeHtml("TP_Installer_Log_Verification",$report2);
	 print "TP_Installer_Log_Verification: PASS- $pass FAIL- $fail\n";
	 print "PARTIAL FILE: $file\n";
	 MCE::Grep::finish;
	 $verifyLogs="false"; 
