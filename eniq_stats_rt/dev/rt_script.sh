#!/usr/bin/perl -C0
##############################
#Script updated on 19-03-2011
##############################
use strict;
my $LOGPATH="/eniq/home/dcuser/RegressionLogs";
my %hash=();
#########################
my %epfg_tps=(
"EBA-EBSW","ebawRnc",
"EBA-EBSG","ebagBsc",
"SASN","sasn",
"SASN-SARA","sasnSara",
"GGSN","ggsn",
"CUDB","cudb",
"MSC-APG","mscApg",
"MSC-IOG","mscIog",
"MSC-BC","mscBc",
"MSC-APGOMS","mscApgOms",
"MSC-IOGOMS","mscIogOms",
"MSC-BCOMS","mscBcOms",
"HLR-APG","hlrApg",
"HLR-IOG","hlrIog",
"EBSS-SGSN","ebssSgsn",
"SGSN","sgsn",
"MGW","mgw",
"WRAN-LTE","wranLte",
"RNC","rnc",
"Wran-RBS","wranRBS",
"Wran-RXI","wranRXI",
"BSC-APG","bscApg",
"BSC-IOG","bscIog",
"STN-PICO","stnPico",
"STN-SIU","stnSiu",
"IPWORKS","ipworks",
"SAPC","sapc",
"MLPPP","mlppp",
"EDGE-ROUTER","edgeRtr",
"CPG","cpg",
"SNMP-NTP","snmpNtp",
"SNMP-Mgc","snmpMgc",
"SNMP-LANSwitch","snmpLanSwitch",
"SNMP-IpRouter","snmpIpRouter",
"SNMP-HpMrfp","snmpHpMrfp",
"SNMP-GGSN","snmpGgsn",
"SNMP-DNSServer","snmpDnsServer",
"SNMP_DHCPServer","snmpDhcpServer",
"SNMP_Cs_CMS","snmpCsMs",
"SNMP_CS_DS","snmpCsDs",
"SNMP_Cs_As","snmpCsAs",
"SNMP_ACME","snmpAcme",
"SNMP_HOTSIP","snmpHotsip",
"SNMP_Firewall","snmpFirewall",
"SBG","sbg",
"MGW2.0FD","mgw2fd",
"MTAS","mtas",
"CSCF","cscf",
"HSS","hss",
"MRFC","mrfc",
"SGSN-MME","sgsnMme",
"TSS-TGC","tssTgc",
"IMS","ims",
"IMS-M","imsM",
"TDRBS","tdRBS",
"TDRNC","tdRNC",
"DSC","dsc"
);
###########################################
############################################################
# THIS ENV VARIABLE IS NEEDED FOR CRONTAB
$ENV{'SYBASE'}='/eniq/sybase_iq';

#Path of old sybase version
my $sybase_dir_12_7="/eniq/sybase_iq/OCS-15_0/bin/isql";

#Path of new sybase version
my $sybase_dir_15_2="/eniq/sybase_iq/IQ-15_2/bin64/iqisql";

#Store the currently sybase version
my @sybase_version;
#Store the sybase dir path
my $sybase_dir;
my $syb_edition_unchanged;

############################################################
#################################Check the Sybase Version###############################
  @sybase_version=`cat /eniq/sybase_iq/version/iq_version`;
    
  if ($sybase_version[0] =~m/VERSION::12.7.0/)
  {
	$syb_edition_unchanged="true";
	$sybase_dir=$sybase_dir_12_7;
	print "$sybase_dir\n";
  }
  else
  {
	$syb_edition_unchanged="false";
	$sybase_dir=$sybase_dir_15_2;
	print "$sybase_dir\n";
  }

###########################################
############################################################
# THIS ENV VARIABLE IS NEEDED FOR CRONTAB
$ENV{'SYBASE'}='/eniq/sybase_iq';
############################################################
# ENGINE 
# this subroutine is in charge of Start any set using cli engine tests, the 
# parameter are:
# tp = techpack for example any techpack or DWH_MONITOR, DWH_BASE
# process= for example UpdateMonitoringTypes
# It executes the process and checks the output,
# if the process throws an error or exception or fail then the test is failed
# else passed.
sub engineProcess{
my $tp= shift;
my $process= shift;
my $result = "";
  print "engine -e  startSet $tp $process Start\n";
  my @process=executeThis("engine -e  startSet $tp $process Start");
  print "@process\n"; 
  my $out=0;
  foreach my $process (@process)
   {
     $_=$process;
     if(/Exception|Error|Fail/i)
      {
        print $process;
        print " FAIL\n";
        $result.="$process"; 
        $result.=" FAIL\n";
        $out++;
      }
     
   }
   if($out==0)
     {
       print " PASS\n";

     }
     
  return $result;
}

############################################################
# CHECK PARTITIONING      [ Updated :: ]
# this subroutine executes a query to check is the 
# partitioning has run recently, if not the test is failed.

sub checkPartitioning
{
	my $time= getTime();
	my @dt=split(/\s/,$time);
	my $date=$dt[0]." 00:00:00";
      my $sql;
    $_=$date;
    $date =~s/-/\//g;
    $date =~s/\s//g;
 if ($syb_edition_unchanged=~m/true/)
 {
      $sql=qq{
select 
CONVERT(CHAR(10),ENDTIME,111)||' '||CONVERT(CHAR(2),ENDTIME,108)||':00:00'  as 'DATE'
from dwhrep.dwhpartition
where storageid like '%LOG_SESSION_LOADER%';
go
EOF
};
 open(PART,"$sybase_dir_12_7 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
 }

	else
	{
      my $sql=qq{
 select
 CONVERT(CHAR(10),ENDTIME,111)||' '||CONVERT(CHAR(8),ENDTIME,108)  as 'DATE'
 from dwhrep.dwhpartition
 where storageid like '%LOG_SESSION_LOADER%';
 go
 EOF
 };
############# This query "$sql_sybase15" shall be used in place of $sql in the next line if Horizontal scalabilty ##########
############# is implemented with rightstring truncation property set to "ON"   ############################################ 
     open(PART,"$sybase_dir_15_2 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
    }
    my $result=undef;
	my @part=<PART>;
	chomp(@part);
	close(PART);
 
	my $status=0;
	
	foreach my $part (@part)
	{
		$_=$part;
		$part=~s/\s//g;
		
		next if(/^$/);
		next if(/affected/);
   
		if($date gt $part)
		{ 
			$status=1;
		}
		
		$part=~s/ //g;
	}
	
	if($status!=0)
    {
		$result.= "\t<font color=006600><b>PASS</b><br>\n";
		print "PASS\n";
    }
	else
    {
		$result.= "\t<font color=ff0000><b>FAIL</b> NEED TO RUN PARTITIONING<br>\n";
		print "FAIL\n";
    }
 
	return $result;
}

############################################################
# EMPTY MOM
# this test basically creates a small xml file with a format called 'empty MOM'
# then puts the file in /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs<TYPE>
# and runs PM_E_EBS Distributor Start
# then it checks that the file is not anymore in the former directory
# then runs upgrade for the specific EBS and if the upgrade finishes successfully the test is passed.
sub emptyMOM{
 my $result="";
 my $type= shift;
 my $ebsType= uc $type;
 my $testEbs= lc $type;
 my $path;
 my $mom;
 if($type eq "S" )
  {
    $mom =qq{<?xml version="1.0" encoding="UTF-8"?>
<pm xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='PM-MOM.xsd'>
<pmMimVersion>1.0</pmMimVersion>
<applicationVersion>6</applicationVersion>
<measurements>
<measObjClass name="cell">
</measObjClass>
</measurements>
</pm>
};
  $path="/eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebss";
  }
 elsif( $type eq "W")
  {
    $mom =qq{<?xml version="1.0" encoding="UTF-8"?>
<pm xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='PM-MOM.xsd'>
<pmMimVersion>1.0</pmMimVersion>
<applicationVersion>6</applicationVersion>
<measurements>
<measObjClass name="cell">
</measObjClass>
</measurements>
</pm>
};
  $path="/eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebsw";
  }
 elsif($type eq "G")
  {
    $mom =qq{<?xml version="1.0" encoding="UTF-8"?>
<pm xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='PM-MOM.xsd'>
<pmMimVersion>1.0</pmMimVersion>
<applicationVersion>6</applicationVersion>
<measurements>
<measObjClass name="cell">
</measObjClass>
<measObjClass name="trx">
</measObjClass>
</measurements>
</pm>
};
  $path="/eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebsg";
  }
 system("mkdir $path");
 open(EMPTY,"> $path/EMPTY_EBS$type.xml");
 print EMPTY $mom;
 close(EMPTY);
####
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  
  sleep(20);
# RUN DISTRIBUTOR
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  
  sleep(20);
# RUN DISTRIBUTOR
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
  sleep(20);
# RUN DISTRIBUTOR
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");


  print "INTF_PM_E_EBS$ebsType-eniq_oss_1 Distributor_MOM_EBS$ebsType Start\n";
  sleep(20);
  print "sleep 20 sec\n";
  sleep(20);

# GET COOKIES  AND JSESSIONID NOTHING ELSE
  my $t1=getSeconds();
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  https://localhost:8443/adminui/servlet/EbsUpgradeManager");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

# UPGRADE EBS
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=action_run_upgrade&upgradeId=PM_E_EBS$ebsType&submit='Upgrade now!'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");

sleep(20);
# WAIT UNTIL IS UPGRADED
my $status=0;
my $found=0;
# DELETE PREVIOUS RUNS
do{
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @ebs=executeThis("/usr/sfw/bin/wget --quiet --no-check-certificate -O  /eniq/home/dcuser/ebs_upgrade.html  --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt   --post-data \"action=action_get_upgrade_status&submit='refresh status'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");
  open(EBS,"<  /eniq/home/dcuser/ebs_upgrade.html");
  my @ebsresult=<EBS>; 
  close(EBS);
  foreach my $ebsresult (@ebsresult) 
  {
    $_=$ebsresult;
    if(/PM_E_EBS$ebsType/)                                
       {$found=1;};
    if($found==1 && /Running\.\.\./)                      
       {
          print "EBS upgrade running...sleep 1min\n";
          sleep(60);
       }
    if($found==1 && /Previous run finished successfully|Previous status not available/) 
       {
          print "EBS run finished succesfully.\n";
          $result.="EBS$ebsType run finished succesfully.<br>\n";
          $status=1;
          last;
        }
    if($found==1 && /<.form>/) 
       {$found=0; last;};
  }
}while($status==0);
  my $t2=getSeconds();
  my $ebsUpgradeTime=$t2-$t1;
  print "Upgrade time: $ebsUpgradeTime sec\n";
  $result.= "Upgrade time: $ebsUpgradeTime sec<br>";
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @out2=executeThis("ls /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/*xml| wc -l ");
  $result.= "Verify if xml file exists in /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/<br>\n";

  if($out2[0] == "0")
    {
      $result.= "\t<font color=006600><b>PASS</b></font> EBS$ebsType MOM file has been processed<br>\n";
      print "PASS\n";
      $result.= checkEBSCounters();
      $result.= checkEBSColumns();
    }
  else
    {
      $result.= "\t<font color=ff0000><b>FAIL</b></font> EBS$ebsType MOM file has not been processed<br>\n";
      print "FAIL\n";
    }
#LOGOUT 
 system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;
}
############################################################
# BUILD POST COMMAND
# this is a util subroutine
# gets parameters date, reference and a list of techpacks
# it iterates the list and appends a string to be used in a URL for other wget request 
# this is normally handled by the browsers.
sub build_post{
  my $date=shift;
  my $ref= shift;
  my @tps= @{$ref};
  chomp(@tps);
  my $result="";
  foreach my $tps (@tps)
   { 
     $_=$tps;
     next if (/_RAW/); 
     #next if (/_RANK/); 
     #next if (/RANKBH/); 
     next if (/SELECT_/); 
     next if (!/DC_E_/); 
     if($date ne "")
      {
       $result.="aggregated=$tps\%26$date&";
      }
    else
      {
       $tps=~s/\&/%26/;
       $result.="aggregated=$tps&";
      }
   }
  return $result;
}
############################################################
# REAGGREGATION
# This subroutine is in charge or running ALL possible reaggregations
# WARNING: when this test is run it creates a huge queue of reaggregations!!!
sub Reaggregation{
my $level= shift;
my $result= "";
my @tps=getAllTechPacksAgg();
#my @tps=("DC_E_SNMP:((4)):&DC_E_SNMP");
chomp(@tps);
my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);

  $year=$year+1900;
  my $month= sprintf("%02d",$mon+1);
  my $day  = sprintf("%02d",$mday);
  my $week = int($yday / 7) + 1;
 if($level eq "DAY")
  { 
     foreach my $tp (@tps)
     {
        $_=$tp;
        my $oops=$tp;
        $oops=~s/:.*//;
        $tp=~s/:&/&/g;
        $tp=~s/:/\\%3A/g;
        $tp=~s/&/\%26/g;
        $tp=~s/\(/\\%28/g;
        $tp=~s/\)/\\%29/g;
        print "$oops $level\n";
        my @alltables=getAllTables4TP($oops);
        my $cmd=build_post("$year-$month-$day", \@alltables);
        #print "$cmd\n";
        
         # SAVE FIRST COOKIES
        system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&batch_name=$tp&checkall=on&$cmd\" \"https://localhost:8443/adminui/servlet/Aggregation\"");
        
        # SEND USR AND PASSWORD and SAVE second COOKIE
        system("/usr/sfw/bin/wget  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
        # post Information
        system("/usr/sfw/bin/wget  --quiet --no-check-certificate -O /eniq/home/dcuser/dayagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&batch_name=$tp&checkall=on&$cmd\" \"https://localhost:8443/adminui/servlet/Aggregation\"");
        my @status=executeThis("grep -c 'window.location=.ShowAggregations'  /eniq/home/dcuser/dayagg.html");
        if($status[0] eq "1") 
         {
           print "PASS\n";
         }
        else
         {
           print "FAIL\n";
         }
     }
      
  }
 elsif( $level eq "WEEK")
  {
       # SAVE FIRST COOKIES
        system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"timelevel_changed=yes&level=$level&\" https://localhost:8443/adminui/servlet/Aggregation");
        
        # SEND USR AND PASSWORD
        system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/listtpsweekagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
        my @listtps=executeThis("grep '		  				    <option value=.' /eniq/home/dcuser/listtpsweekagg.html ");
        chomp(@listtps);
        my @tps=();
        foreach my $tps (@listtps)
          { 
             $_=$tps; 
             $tps=~s/.*="//;
             $tps=~s/">.*//;
             $tps=~s/<.option>//;
             push @tps, $tps;
          }
        #print "\nGOT TPS: @tps\n";
        foreach my $tp (@tps)
        {
           $_=$tp;
           my $oops=$tp;
           $oops=~s/:.*//;
           $tp=~s/:&/&/g;
           $tp=~s/:/%3A/g;
           $tp=~s/&/%26/g;
           $tp=~s/\(/%28/g;
           $tp=~s/\)/%29/g;
           print "$oops $level\n";
           # get table names
           system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/listweekagg0.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"list=List&timelevel_changed=&level=$level&year_1=$year&week_1=1&year_2=$year&week_2=53&batch_name=$tp&\" https://localhost:8443/adminui/servlet/Aggregation");

           # post Information
           my @list=executeThis("grep '      	.td class=.white_row_10...input type=.checkbox. name..aggregated. value=.' /eniq/home/dcuser/listweekagg0.html "); 
           my @alltables=();
           foreach my $list (@list)
             { 
                $_=$list; 
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/">.*//;
                $list=~s/<.option>//;
                push @alltables, $list;
             }
           print "ALL TABLES: @alltables\n";
           my $cmd=build_post("", \@alltables);
           
           # DO REAGGREGATIONS PLEASE
           system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/weekagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&week_1=$week&year_2=$year&week_2=$week&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation");
           
           my @status=executeThis("grep -c 'window.location=.ShowAggregations'  /eniq/home/dcuser/weekagg.html");
           if($status[0] eq "1") 
            {
              print "PASS\n";
            }
           else
            {
              print "FAIL\n";
            }   
       }

  }
 elsif($level eq "MONTH")
  {
        system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"timelevel_changed=yes&level=$level&\" https://localhost:8443/adminui/servlet/Aggregation");
        
        # SEND USR AND PASSWORD
        system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/listtpsmonthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
        my @listtps=executeThis("grep '		  				    <option value=.' /eniq/home/dcuser/listtpsmonthagg.html ");
        chomp(@listtps);
        my @tps=();
        foreach my $tps (@listtps)
          { 
             $_=$tps; 
             $tps=~s/.*="//;
             $tps=~s/">.*//;
             $tps=~s/<.option>//;
             push @tps, $tps;
          }
        #print "\nGOT TPS: @tps\n";
        foreach my $tp (@tps)
        {
           $_=$tp;
           my $oops=$tp;
           $oops=~s/:.*//;
           $tp=~s/:&/&/g;
           $tp=~s/:/%3A/g;
           $tp=~s/&/%26/g;
           $tp=~s/\(/%28/g;
           $tp=~s/\)/%29/g;
           print "$oops $level\n";
           # get table names
           system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/listmonthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"list=List&timelevel_changed=&level=$level&year_1=$year&month_1=1&year_2=$year&month_2=12&batch_name=$tp&\" https://localhost:8443/adminui/servlet/Aggregation");

           # post Information
           my @list=executeThis("grep '      	.td class=.white_row_10...input type=.checkbox. name..aggregated. value=.' /eniq/home/dcuser/listmonthagg.html "); 
           my @alltables=();
           foreach my $list (@list)
             { 
                $_=$list; 
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/.*="//;
                $list=~s/">.*//;
                $list=~s/<.option>//;
                push @alltables, $list;
             }
           print "ALL TABLES: @alltables\n";
           my $cmd=build_post("", \@alltables);
           
           # DO REAGGREGATIONS PLEASE
           system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/monthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&year_2=$year&month_2=$month&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation");
           print("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/monthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&year_2=$year&month_2=$month&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation\n");
           my @status=executeThis("grep -c 'window.location=.ShowAggregations'  /eniq/home/dcuser/monthagg.html");
           if($status[0] eq "1") 
            {
              print "PASS\n";
            }
           else
            {
              print "FAIL\n";
            }   
       }
  }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

  return $result;
}
############################################################
# SYSTEMSTATUS
# This subroutine goes to admin UI and checks the System status, greps if there are RED bulbs or status NOLOADS
# If that's the case it fails the test case.
sub SystemStatus{

# http://eniq21.lmf.ericsson.se:8080/servlet/LoaderStatusServlet
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/status.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  
   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/status.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");
  my @status=executeThis("egrep -c '(red_bulp|NoLoads)' /eniq/home/dcuser/status.html");
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
# LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# DWHSTATUS
# this subroutine goes to AdminUI and verifies the DWHSatus, 
# greps DWH_DBSPACES_MAIN, if present it will pass the test
sub DwhStatus{

#http://eniq21.lmf.ericsson.se:8080/servlet/StatusDetails?ds=rockDwhDba
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/dwhstatus.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockDwhDba\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/dwhstatus.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockDwhDba\"");
  my @status=executeThis("grep -c DWH_DBSPACES_MAIN /eniq/home/dcuser/dwhstatus.html");
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# REPSTATUS
# This subroutine checks AdminUI and Repstatus 
# greps the webpage for IQ.Server, if present it passes the test
sub RepStatus{

#http://eniq21.lmf.ericsson.se:8080/servlet/StatusDetails?ds=rockEtlRepDba
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/repstatus.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockEtlRepDba\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/repstatus.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockEtlRepDba\"");
    my @status=executeThis("grep -c IQ.Server /eniq/home/dcuser/repstatus.html");
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# ENGINESTATUS
# This subroutine goes to AdminUI and checks that engine status is Normal
sub EngineStatus{

#http://eniq21.lmf.ericsson.se:8080/servlet/EngineStatusDetails
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/enginestatus.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/EngineStatusDetails\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt-- save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/enginestatus.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/EngineStatusDetails\"");
    my @status=executeThis("grep -c Normal /eniq/home/dcuser/enginestatus.html");
    
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# SCHEDULESTATUS
# This subroutine goes to AdminUI and checks that scheduler status is active
sub SchedulerStatus{

#http://eniq21.lmf.ericsson.se:8080/servlet/SchedulerStatusDetails
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/schedulestatus.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/SchedulerStatusDetails\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/schedulestatus.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/SchedulerStatusDetails\"");
    my @status=executeThis("grep -c active /eniq/home/dcuser/schedulerstatus.html");
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# LICSERVSTATUS
# This subroutine goes to AdminUI and checks that the licenserver lists the FAJ or CXC
# is number is higher than 40 the test is passed.
sub LicservStatus{

#http://eniq21.lmf.ericsson.se:8080/servlet/ShowInstalledLicenses
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/licserv.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"command='Disk space information'&submit=Start\" \"https://localhost:8443/adminui/servlet/ShowInstalledLicenses\"");
 
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/licserv.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ShowInstalledLicenses\"");

    my @status=executeThis("egrep -c '(FAJ|CXC)' /eniq/home/dcuser/licserv.html");
  if($status[0] == 0)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     { 
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     } 
# LOGOUT
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# LICMGR STATUS 
# This subroutine goes to AdminUI and checks licmgr and verifies that is 'running OK'
# is so the test is passed.
sub LicmgrStatus{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);

  $year=$year+1900; 
  my $month= sprintf("%02d",$mon+1);
  my $day  = sprintf("%02d",$mday);

#http://eniq21.lmf.ericsson.se:8080/servlet/LicenseLogsViewer
 # system("/usr/sfw/bin/wget --no-check-certificate -O  /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&submit=Search&action=ReadLicenseLog\" \"https://localhost:8443/adminui/servlet/ReadLicenseLog\"");
    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.
html") ;

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&submit=Search&action=ReadLicenseLog\" \"https://localhost:8443/adminui/servlet/ReadLicenseLog\"");

    my @status=executeThis("egrep -c '(is&nbsp;running&nbsp;OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# SESSIONLOGS
# This subroutine goes to AdminUI and checks that the Session logs do not display /ERROR|EXCEPTION|FAILED|NOT FOUND/i
# else the test is failed, is so then is passed
sub SessionLogs{
 my $st=0;
 my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);

  $year=$year+1900; 
  my $month= sprintf("%02d",$mon+1);
  my $day  = sprintf("%02d",$mday);
  my @selectedtable=("Adapter","Loader","Aggregator");
  foreach my $selectedtable (@selectedtable) 
  {
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O test0.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  --post-data \"selectedpack=&action=ETLSessionLog&search=Search&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&start_hour=0&end_hour=23&a_status=OK&selectedtable=$selectedtable&source=&a_filename=\" https://localhost:8443/adminui/servlet/ETLSessionLog");
   
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O test.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/sessionlog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"selectedpack=&action=ETLSessionLog&search=Search&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&start_hour=0&end_hour=23&a_status=OK&selectedtable=$selectedtable&source=&a_filename=\"  https://localhost:8443/adminui/servlet/ETLSessionLog");
   
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O test.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

    my @status=executeThis("cat /eniq/home/dcuser/sessionlog.html") ;
    chomp(@status);
    my $ptr=0; 
    foreach my $status (@status) 
    {
      $_=$status;
 
      if(/<table border=.1. width=.800. cellpadding=.1. cellspacing=.1.>/)
       {
           $ptr=1;
       }
      if(/			<.table>/) 
       {
          $ptr=0;
       }
      
      if($ptr==1) 
       {
         $status=~s/\s+//g;
         $status=~s/<td.*><.*>//g;
         $status=~s/<.font><.td>//g;
         if(/ERROR|EXCEPTION|FAILED|NOT FOUND/i)
          {$st++;}
         print $status;
       }
    }
  }
  if($st ==0 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# DATAROWINFO
# This test is not finished.
# This subroutine should go to AdminUI and verify each of the DataRow Info tables for certain dates.
# Currently is just a stub
sub DataRowInfo{

#http://eniq21.lmf.ericsson.se:8080/servlet/DataRowInfo
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# SHOWREFTABLES
# This test is not finished.
# Currently is just a stub
sub ShowRefTables{

#http://eniq21.lmf.ericsson.se:8080/servlet/ShowRefType
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# RANKBH
# This test is not finished.
# Currently is just a stub
sub RankBh{

#http://eniq21.lmf.ericsson.se:8080/servlet/ViewRankBH
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# MONITORINGRULES
# This test is not finished.
# Currently is just a stub

sub MonitoringRules{

#http://eniq21.lmf.ericsson.se:8080/servlet/MonitoringRules
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");
    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# TYPECONFIG
# This test is not finished.
# Currently is just a stub

sub TypeConfig{

#http://eniq21.lmf.ericsson.se:8080/servlet/TypeActivation
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# DWHCONFIG
# This subroutine goes to AdminUI, to DWH Configuration
# just checks that the different partitions exist, but does not configure anything 
# because can result in data loss or database failure
sub DWHConfig{

#http://eniq21.lmf.ericsson.se:8080/servlet/ShowPartitionPlan
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ShowPartitionPlan\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/partplan.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/ShowPartitionPlan\"");
 
 my @status=executeThis("egrep '(EditPartitionPlan| days| hours)' /eniq/home/dcuser/partplan.html") ;
 foreach my $status (@status)
 { 
  $_=$status;
  $status=~s/.*<font size.*><a.*">//;
  $status=~s/.*<font size.*">//;
  $status=~s/<.a><.font>//;
  $status=~s/<.font>//;
  print $status;
  if(/extralarge_count|extralarge_day|extralarge_daybh|extralarge_plain|extralarge_rankbh|extralarge_raw|extrasmall_count|extrasmall_day|extrasmall_daybh|extrasmall_plain|extrasmall_rankbh|extrasmall_raw|large_count|large_day|large_daybh|large_plain|large_rankbh|large_raw|medium_count|medium_day|medium_daybh|medium_plain|medium_rankbh|medium_raw|small_count|small_day|small_daybh|small_plain|small_rankbh|small_raw|days|hours/)
     {
       print "PASS\n";
	   #$result.="PASS<br>\n";
     }
  else
     {
       print "FAIL\n";
	   #$result.="FAIL<br>\n";
     }
 }

#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}

############################################################
# VERIFY_DIRECTORIES
# This test only checks that the directories do not exceed 90% 
# os space, is every thing is below that the test is passed.
sub VerifyDirectories{
my  $result=qq{
<h3>VERIFY DIRECTORY SPACE</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>STATUS</th>
   </tr>
};

 my @dir=executeThis("df -lk | grep eniq "); 
 chomp(@dir);
 foreach my $dir (@dir)
  {
   my @line = split(/\s+/,$dir);
   print "$line[4] $line[5]";
   $line[4]=~s/%//;
   if($line[4]< 90)
   {
     $result.="<tr><td>$line[4] $line[5]</td><td align=center><font color=006600><b>PASS</b></font></td></tr>\n";
     print "    PASS\n";
   }
   else
   {
     $result.="<tr><td>$line[4] $line[5]</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
     print "    FAIL\n";
   }
  }
 $result.="</table>";
 return $result;
}
############################################################
# VERIFY ADMIN SCRIPTS
# This test executes each of the scripts below and expects a result 
# from the console, if the output includes words like 
# /Exception|Execute failed|cannot execute/i
# if so the test is failed
# else is passed.
sub VerifyAdminScripts{
  my @cmds=(
  "manage_eniq_oss.bsh",
  "manage_eniq_services.bsh"
  );
my  $result=qq{
<h3>RUN CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd ( @cmds )
 {
   my $script=qq{ 
(
 sleep 2 ;
 echo "root\n" ; sleep 2
 echo "shroot\n"; sleep 2 ;
 echo "cd /eniq/admin/bin/";
 echo "pwd";
 echo "bash $cmd" ; sleep 2 ;
 echo "exit\n";
) | telnet localhost
};
     my @res=executeThis($script); 
     print $script;
     my @result=map {$_."<br>"} @res; 
     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        print $res;
        
         
      }
      if((@result)==0)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
  } 
  $result.=qq{</table>};
  return $result;

}
############################################################
# ENIQVERSION
# This subroutine goes to AdminUI and checks the version, if the 
# string starts with ENIQ_STATUS ENIQ the test is passed.
# else is failed
# NOTE: when the version file is not available another string is displayed like 'version not available'
sub eniqVersion{

#https://localhost:8443/servlet/CommandLine
system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=ENIQ+software+version&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/version.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=ENIQ+software+version&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 my @status=executeThis("egrep  '(ENIQ_STATUS)' /eniq/home/dcuser/version.html") ;
  if($status[0] =~"ENIQ_STATUS ENIQ" )
     {
       print "$status[0] PASS\n";
     }
  else
     {
       print "FAIL\n";
     }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}

############################################################
# DISKSPACE
# This subroutine goes to AdminUI and checks that the DiskSpace information
# displayed in Monitoring Commands has the right header, and displays info for eniq_sp 
sub DiskSpace{

#https://localhost:8443/servlet/CommandLine
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Disk+space+information&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/dsk.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Disk+space+information&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
 my @status=executeThis("egrep  '(Filesystem\s*size   used  avail capacity  Mounted on|eniq_sp)' /eniq/home/dcuser/dsk.html");
  foreach my $status (@status)
    {
       $_=$status;
       if(/Filesystem\s*size\s*used\savail\scapacity\s*Mounted\son|eniq_sp|admin|archive|data|dwh_main|dwh_temp_|rep_main|rep_temp|fmdata|home|log|sw|installation|sentinel|sybase_iq|upgrade|devices|ctfs|proc|mnttab|swap|objfs|sharefs|libc_hwcap|fd/)
       { 
         print $status;
         print "PASS\n";
       }
       else
       {
         print "FAIL\n";
       }
    }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# INSTALLED_MODULES
# This subroutine goes to AdminUI and verifies that the installed modules exist
# NOTE: it has to be updated when new modules are added
sub InstalledModules{

#https://localhost:8443/servlet/CommandLine
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"command=Installed+modules&submit=Start&action=/adminui/servlet/CommandLine\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/modules.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"command=Installed+modules&submit=Start&action=/adminui/servlet/CommandLine\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

 my @status=executeThis("cat /eniq/home/dcuser/modules.html");
 
 foreach my $status (@status)
 { 
  $_=$status;
  next if(!/>module/); 
  $status =~ s/<td><font size..-1. face..Courier.>//g; 
  $status =~ s/<br .>/\n/g;
  $status =~ s/<.font><.td>//g;
  if(/3GPP32435|AdminUI|MDC|alarm|alarmcfg|ascii|asn1|common|csexport|ct|dbbaseline|diskmanager|dwhmanager|ebs|ebsmanager|engine|export|installer|libs|licensing|mediation|monitoring|nascii|nossdb|omes2|omes|parser|raml|redback|repository|runtime|sasn|scheduler|stfiop|uncompress|xml/)
     {
       print "$status PASS\n";
     }
  else
     {
       print "FAIL\n";
     }
 }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# INSTALLED_TPS
# This subroutine goes to AdminUI and verifies that the techpacks display the columns
# Note: this module does not check if the right version is installed, that is handled in
# the BASELINE checker
sub InstalledTps{

#https://localhost:8443/servlet/CommandLine
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/tps.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
 my @status=executeThis("egrep '(					<tr>|						<td class=.basic.>)'  /eniq/home/dcuser/tps.html");
 chomp(@status);
 my $tpname="";
 my $tpcoa="";
 my $tprev="";
 my $tp="";
 my $tpactive="";
 my $tpdate="";
 my $finalresult=0;
 foreach my $status (@status)
 {
  $_=$status;
  $status =~ s/                                                <td class=.basic.>//;
  $status =~ s/<.td>//;
  $status =~ s/.*">//;
  if(/<tr>|<.tr>/)
  { 
    print "\n";
  }
  if(/Active|COA 252|PM|\w_\w|Topology|20..-\d\d-\d\d|n.a|BASE/i)
     {
          print "$status	";
     }
  elsif(/ERROR|Exception|Fail|Not found/i)
     {
         $finalresult++;
     }
 }

  if($finalresult>0)
   {
     print "FAIL\n";
   }
  else
   {
     print "\nPASS\n";
   }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

}
############################################################
# ACTIVE PROCS
# This subroutine goes to AdminUI and verifies that the Monitoring Commands displays active processes
sub ActiveProcs{

#https://localhost:8443/servlet/CommandLine
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Most+active+processes&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/active.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Most+active+processes&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
 my @status=executeThis("cat  /eniq/home/dcuser/active.html");
 foreach my $status (@status)
 {
   $_=$status;
   next if(!/^<td><font size=.-1. face=.Courier.>   /);
   $status =~ s/<td>|<.td>/\n/g;
   $status =~ s/<br .>/\n/g;
   if(/dcuser|root|Total|USERNAME/)
    {
     print "$status";
      print "PASS\n";
    }
   else
    {
      print "FAIL\n";
    }
  } 

#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");


}
############################################################
# LOGGING_INFO
# TODO
sub LoggingInfo{
#https://localhost:8443/servlet/EditLogging
}
############################################################
# LOGGING_SEVERE
# TODO
sub LoggingSevere{
#https://localhost:8443/servlet/EditLogging
}

############################################################
# LOGGING_WARNING
# TODO
sub LoggingWarning{
#https://localhost:8443/servlet/EditLogging
}

############################################################
# LOGGING_CONFIG
# TODO
sub LoggingConfig{
#https://localhost:8443/servlet/EditLogging
}

############################################################
# LOGGING_FINE
# TODO
sub LoggingFine{
#https://localhost:8443/servlet/EditLogging
}

############################################################
# LOGGING_FINER
# TODO
sub LoggingFiner{
#https://localhost:8443/servlet/EditLogging
}
############################################################
# LOGGING_FINEST
# TODO
sub LoggingFinest{
#https://localhost:8443/servlet/EditLogging
}

############################################################
# NEG_ENGINE
# TODO
sub NegEngine{
}

############################################################
# NEG_SCHEDULER
# TODO
sub NegScheduler{
}

############################################################
# NEG_LICMGR
# TODO
sub NegLicMgr{
}

############################################################
# MAX_USERS_ADMINUI
# NOTE: this subroutine exceedes the MAX number of users and produces a total fault in the system
# After executing this process all services are restarted because the servers is not usable.

sub MaxUsersAdminui{
for (my $i=0;$i<30;$i++)
 {
 print "TRIAL: $i\n";
system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/max.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
   # GET Information
   system("/usr/sfw/bin/wget  --quiet --no-check-certificate -O /eniq/home/dcuser/max.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");
 }
 my @status=executeThis("grep -c 'Max connection reached' /eniq/home/dcuser/max.html");
 
  if($status[0] >= 1 )
     {
       print "PASS\n";
     }
  else
     {
       print "FAIL\n";
     } 
system("/eniq/admin/bin/eniq_service_start_stop.bsh -s engine -a clear");
system("dwhdb restart");
system("repdb restart");
system("webserver restart");
system("engine restart");
print "Sleep 2 min to allow processes to recover...\n";
sleep(2*60);
}

############################################################
# ADMINUI WRONG USER
# Checks in AdminUI if a user tries to enter with a wrong user or password
# then the user is redirected again to the login screen
sub wrongUser{

#http://eniq21.lmf.ericsson.se:8080/servlet/adminui
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/wrong.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=wrong&j_password=wrong' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/wrong.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui\"");
my $result="";

 open(WO,"< /eniq/home/dcuser/wrong.html ");
 my @wo=<WO>;
 close(WO);
 my $found=0;
 foreach my $wo (@wo)
  {
    $_=$wo;
    if(/window.location.href = ..adminui.servlet.LoaderStatusServlet/)
     {
       $found++;
     }
  }
 if($found == 1)
  {
     print "PASS\n";
     $result.= "<font color=006600><b>PASS</b></font><br>\n";
  }
 else
  {
     print "FAIL\n";
     $result.= "<font color=660000><b>FAIL</b></font><br>\n";
  }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;
}

############################################################
# UNV_INSTALL_WITHOUT_LOGIN
# This test tries to reach the EBS universe upgrade manager webpage without logging in
# if is reachalbe then is failed
# else passed
sub UnvInstallWithoutLogin{
my $result="";
#http://eniq21.lmf.ericsson.se:8080/servlet/EbsUpgradeManager
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/without.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/EbsUpgradeManager\"");
 open(WO,"< /eniq/home/dcuser/without.html ");
 my @wo=<WO>;
 close(WO);
 my $found=0;
 foreach my $wo (@wo)
  {
    $_=$wo;
    if(/Please, type your username/)
     { 
       $found++;
     }
  }
 if($found == 1)
  {
     print "PASS\n";
     $result.= "<font color=006600><b>PASS</b></font><br>\n";
  }
 else
  {
     print "FAIL\n";
     $result.= "<font color=660000><b>FAIL</b></font><br>\n";
  }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");
 
 return $result;
}

############################################################
# SHOW LOADING FUTURE DATES
# Show loadings with future dates should display  XXXXXXXXXXXX for the dates, 
# if not is failed
# if so is passed.
sub ShowLoadingFutureDates{
   my $year   =getYearTimewarp();
   my $month  ="12"; 
   my $day    ="31";
   my $tp     ="-";
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/future.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET LOADING
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/future.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");

my $result="";

 open(WO,"< /eniq/home/dcuser/future.html ");
 my @wo=<WO>;
 close(WO);
 my $found=0;
 foreach my $wo (@wo)
  {
    $_=$wo;
    if(/&nbsp;X&nbsp;/)
     {
       $found++;
     }
  }
 if($found == 24)
  {
     print "PASS\n";
     $result.= "<font color=006600><b>PASS</b></font><br>\n";
  }
 else
  {
     print "FAIL\n";
     $result.= "<font color=660000><b>FAIL</b></font><br>\n";
  }
#LOGOUT
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;
 
   
}

############################################################
# ETLC_SCHEDULE
# TODO
sub ETLCSchedule{
#http://eniq21.lmf.ericsson.se:8080/servlet/ETLRunSetOnce
}

############################################################
# ETLC_MONITORING
# TODO
sub ETLCMonitoring{
#http://eniq21.lmf.ericsson.se:8080/servlet/ETLShow
}

############################################################
# ETLC_HISTORY
# TODO
sub ETLCHistory{
#http://eniq21.lmf.ericsson.se:8080/servlet/ETLHistory
}

############################################################
# SHOW AGG FUTURE DATES
# This test checks that AdminUI in ShowAggregation for future dates 
# displays 'No Day Data'
sub ShowAggFutureDates{
   my $year   =getYearTimewarp();
   my $month  ="12";
   my $day    ="31";
   my $tp     ="-";
   
   $year=$year+1;    # Always check for the last date of next year.
                     # If we are checking for the last date of current year it will FAIL, if we run the RT
                     # in the month of Dec.	

#http://eniq21.lmf.ericsson.se:8080/servlet/ShowAggregations
   # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&action=/servlet/ShowAggregations&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET AGGREGATION
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/futagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
my $result="";

 open(WO,"< /eniq/home/dcuser/futagg.html ");
 my @wo=<WO>;
 close(WO);
 my $found=0;
 foreach my $wo (@wo)
  {
    $_=$wo;
    if(/No Day Data/)
     {
       $found++;
     }
  }
 if($found == 1)
  {
     print "PASS\n";
     $result.= "<font color=006600><b>PASS</b></font><br>\n";
  }
 else
  {
     print "FAIL\n";
     $result.= "<font color=660000><b>FAIL</b></font><br>\n";
  }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;

}

############################################################
# SHOW PROBLEMATIC
# This is to be coded, still this part of AdminUI does not work properly
sub ShowProblematic{
#http://eniq21.lmf.ericsson.se:8080/servlet/ShowLoadStatus
}

############################################################
# LICMGR DOWN SHOW LICENSES
# licmgr stop
# Then go to adminui and check license information
# should display a message saying that lic manager is down
# Currently no message is displayed a TR to be written.
sub LicMgrDownShowLicenses{
}

############################################################
# LICSERV DOWN SHOW LICENSES
# licsrv stop
# Then go to adminui and check license logs
sub LicServDownShowLicenses{
 system("licsrv stop");
 
 system("licsrv start");

}

############################################################
# LICMGR DOWN RESTART ENGINE
# 
sub LicMgrDownRestartEngine{
 system("licmgr stop");
 my @status = executeThis("engine restart");
 system("licmgr start");
 system("engine restart");
}
############################################################
# LICMGR DOWN RESTART SCHEDULER
sub LicMgrDownRestartScheduler{
 system("licmgr stop");
 my @status = executeThis("scheduler restart "); 
 system("licmgr start");
 system("scheduler restart");
}
############################################################
# LICMGR DOWN RESTART ENGINE
sub LicServDownRestartEngine{
 system("licsrv stop");
 my @status = executeThis("scheduler restart "); 
 system("licsrv start");
 system("scheduler restart");
}
############################################################
# LICMGR DOWN RESTART SCHEDULER
sub LicServDownRestartScheduler{
 system("licsrv stop");
 my @status = executeThis("scheduler restart "); 
 system("licsrv start");
 system("scheduler restart");
}

############################################################
# BUSYHOUR 
# This process was coded with Liam Burke
# It goes to AdminUI and checks the Busyhour results
# if the techpack has BH information it passes the tc.
sub busyhour{
  my $result;
  my $year     =getYearTimewarp();
  my $month_2  =getMonthTimewarp();
  my $day      =getDayTimewarp();
  my $year_2   =getYearTimewarp();
  my $month    =sprintf("%02d",getMonthTimewarp()-1);
  my $day_2    ="01";
  system("rm /eniq/home/dcuser/cookies.txt");
 
     # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/bh.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # GET BUSYHOUR Information
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/bh.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");
   
  open(BHTABLES," < bh.html");
  my @bhtablesRAW=<BHTABLES>;
  chomp(@bhtablesRAW);
  close(BHTABLES);
  #system("rm /eniq/home/dcuser/bh.html");
  my @bhtables=undef;
  foreach my $bhtables (@bhtablesRAW)
  {
    $_=$bhtables;
    if(/																						<option value=/)
    {
      $bhtables =~s/																						<option value=.//;
      $bhtables =~s/".*//;
      push @bhtables, $bhtables;
    } 
  }
 $result.=qq{
 <h3>ADMINUI: SHOW BUSY HOUR STATUS </h3>
 <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLENAME</th>
     <th >DESCRIPTION</th>
     <th >RESULT</th>
   </tr>
};

  foreach my $tp (@bhtables)
  {
   $_=$tp;
   next if(/^$/);
   #$result.="<br><h3>$tp</h3><BR>\n"; 
 
   # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/bh_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month_2&day_2=$day&search_string=$tp&search_done=true&submit='Get BH Information'\"  \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");
   #sleep(1);

   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);

   # GET BUSYHOUR Information
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/bh_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month_2&day_2=$day&search_string=$tp&search_done=true&submit='Get BH Information'\"  \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");

   open(BHTable,"< /eniq/home/dcuser/bh_$tp.html");
   my @BHTables=<BHTable>;
   chomp(@BHTables);
   close(BHTable); 
   system("rm /eniq/home/dcuser/bh_$tp.html");
 
   my $tpack=0;
   my $found=0;

   foreach my $BHTables (@BHTables)
   {
    $_=$BHTables;
    $BHTables=~ s/	//g;
    if(/Day Busyhour|Month Busyhour/i) 
       {
         $result.="<tr><td>$tp</td><td>$BHTables</td><td align=center><font color=006600><b>PASS</b></font></td></tr>";
         print "	$tp	$BHTables	PASS\n";
         $found=1;
       }
   }
   if($found==0) 
     {
        $result.="<tr><td>$tp</td><td></td><td align=center><font color=660000><b>FAIL</b></font></td></tr>";
        print "        $tp     FAIL\n";
      }

  }
 $result.="</table>\n";
#LOGOUT
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;
}

############################################################
# ADD ALARM REPORT
# This subroutine logs in to alarmcfg
# then logs in to the webserver using eniq_alarm/eniq_alarm
# and creates an alarm using:
# DC_E_RAN
# DC_E_RAN_UCELL
# 15 min
# DC_E_RAN_UCELL_RAW
# NOTE: the webserver needs to have the report configured and tested in BO, otherwise
# the alarm will fail
sub addAlarmReport{
 my $minutes             = shift;
 my $webserver	         = "eniqweb8d.lmf.ericsson.se:6400";
 my $user		 = "eniq_alarm";
 my $password		 = "eniq_alarm";
 my $reportnum	         = 15;
 my $select_techpacks    = "DC_E_RAN";
 my $select_types	 = "DC_E_RAN_UCELL";
 my $select_levels 	 = "RAW";
 my $select_basetables   = "DC_E_RAN_UCELL_RAW"; 

# GET COOKIES AND JSESSIONID NOTHING ELSE
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --server-response --keep-session-cookies --save-cookies cookies.txt https://localhost:8443/alarmcfg/LoginPage  ");

# SEND SERVER, USER, PASSWORD AND AUTH METHOD
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=LoginPage&cms=$webserver:6400&username=$user&password=$password&authtype=secEnterprise&submit=Login\" https://localhost:8443/alarmcfg/LoginPage  ");

# CHECK EXISTING ALARMS $MINUTES MIN
#system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\"  ");

system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\"  ");

# ADD REPORT $MINUTES
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --referer=\"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\" \"https://localhost:8443/alarmcfg/AddReport?add=$reportnum\"  ");

# ADD REPORT $MINUTES
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/AddReport?add=$reportnum\"  ");

# ADD ALARM
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers  --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=AddAalarm&reportid=$reportnum&select_techpacks=$select_techpacks&select_types=$select_types&select_levels=$select_levels&select_basetables=$select_basetables&submit='Add report'\" \"https://localhost:8443/alarmcfg/AddAlarm\"  ");

# ADD REPORT FOR ALARM $MINUTES MIN
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/AddReport\"  ");

# LOG OUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/Logout\"  ");
if($! ==0)  
   {
     print "PASS\n";
   }
   else
   {
     print "FAIL\n";
   }
#LOGOUT
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");
}
############################################################
# EDIT NIQ.INI AND RUN RESIZEDB -V DWH
# This subroutine is in charge of editing the niq.ini file 
# by creating DBspaces from 10 to 15 
# or if it is present already then create from 16 to 20
# and then executing the resizedb -v DWH
sub editNIQ{
 
 my $result="";
 
 open(CHECK,"grep -c DWH_DBSPACES_MAIN_15 /eniq/sw/conf/niq.ini |"); 
 my @check_15=<CHECK>;
 close(CHECK); 
	
 open(CHECK,"grep -c DWH_DBSPACES_MAIN_16 /eniq/sw/conf/niq.ini |"); 
 my @check_16=<CHECK>;
 close(CHECK); 
 
 if($check_15[0]==0)
	{
		open(NIQ,"< /eniq/sw/conf/niq.ini  ");
		my @niq=<NIQ>;
		close(NIQ);
 
		open(EDT,"> /eniq/sw/conf/niq.ini.tmp "); 
 
		my $dbspaces=qq{
DWH_DBSPACES_MAIN_11
DWH_DBSPACES_MAIN_12
DWH_DBSPACES_MAIN_13
DWH_DBSPACES_MAIN_14
DWH_DBSPACES_MAIN_15
};
		
		my $dbsp=qq{
[DWH_DBSPACES_MAIN_11]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_11/main_11.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_12]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_12/main_12.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_13]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_13/main_13.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_14]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_14/main_14.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_15]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_15/main_15.iq
Size=30000
Type=fs

};
		my $count=0;
 
		foreach my $edt (@niq)
		{
			$_=$edt;
			
			if(/^DWH_DBSPACES_MAIN_10/)
			{
				print EDT $edt;
				print EDT $dbspaces; 
			}
			elsif(/^\[DWH_DBSPACES_MAIN_10\]$/)
			{
				print EDT $edt;
				$count++;
			} 
			elsif( $count ==1 && /Path=.eniq.database.dwh_main_dbspace.dbspace_dir_10.main_10.iq/)
			{
				print EDT $edt;
				$count++;
			}
			elsif( $count ==2 )
			{ 
				print EDT $edt;
				$count++; 
			}
			elsif( $count ==3 && /Type=fs/)
			{
				print EDT $edt;
				$count++;
			}
			elsif ($count==4)
			{
				print EDT $edt;
				print EDT $dbsp;
				$count=0;
			}
			else
			{
				print EDT  $edt;   
			} 
		}
  
		close(EDT);
		
		system("mv /eniq/sw/conf/niq.ini /eniq/sw/conf/niq.ini.bak");
		system("mv /eniq/sw/conf/niq.ini.tmp /eniq/sw/conf/niq.ini");
		system("mkdir /eniq/database/dwh_main_dbspace/dbspace_dir_11 /eniq/database/dwh_main_dbspace/dbspace_dir_12 /eniq/database/dwh_main_dbspace/dbspace_dir_13 /eniq/database/dwh_main_dbspace/dbspace_dir_14 /eniq/database/dwh_main_dbspace/dbspace_dir_15 ");

		system("/eniq/sw/bin/resizedb -v DWH");
		system("/eniq/sw/bin/engine start");
		system("/eniq/admin/bin/eniq_service_start_stop.bsh -s engine -a clear");
		system("/eniq/sw/bin/engine -e changeProfile Normal");
	} 
	elsif($check_16[0]==0)
	{
    	open(NIQ,"< /eniq/sw/conf/niq.ini  ");
		my @niq=<NIQ>;
		close(NIQ);
 
		open(EDT,"> /eniq/sw/conf/niq.ini.tmp "); 
 
		my $dbspaces=qq{
DWH_DBSPACES_MAIN_16
DWH_DBSPACES_MAIN_17
DWH_DBSPACES_MAIN_18
DWH_DBSPACES_MAIN_19
DWH_DBSPACES_MAIN_20
};
		
		my $dbsp=qq{
[DWH_DBSPACES_MAIN_16]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_16/main_16.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_17]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_17/main_17.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_18]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_18/main_18.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_19]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_19/main_19.iq
Size=30000
Type=fs

[DWH_DBSPACES_MAIN_20]
Path=/eniq/database/dwh_main_dbspace/dbspace_dir_20/main_20.iq
Size=30000
Type=fs

};
		my $count=0;
 
		foreach my $edt (@niq)
		{
			$_=$edt;
			
			if(/^DWH_DBSPACES_MAIN_15/)
			{
				print EDT $edt;
				print EDT $dbspaces; 
			}
			elsif(/^\[DWH_DBSPACES_MAIN_15\]$/)
			{
				print EDT $edt;
				$count++;
			} 
			elsif( $count ==1 && /Path=.eniq.database.dwh_main_dbspace.dbspace_dir_15.main_15.iq/)
			{
				print EDT $edt;
				$count++;
			}
			elsif( $count ==2 )
			{ 
				print EDT $edt;
				$count++; 
			}
			elsif( $count ==3 && /Type=fs/)
			{
				print EDT $edt;
				$count++;
			}
			elsif ( $count==4)
			{
				print EDT $edt;
				print EDT $dbsp;
				$count=0;
			}
			else
			{
				print EDT  $edt;   
			} 
		}
  
		close(EDT);
		
		system("mv /eniq/sw/conf/niq.ini /eniq/sw/conf/niq.ini.bak");
		system("mv /eniq/sw/conf/niq.ini.tmp /eniq/sw/conf/niq.ini");
		system("mkdir /eniq/database/dwh_main_dbspace/dbspace_dir_16 /eniq/database/dwh_main_dbspace/dbspace_dir_17 /eniq/database/dwh_main_dbspace/dbspace_dir_18 /eniq/database/dwh_main_dbspace/dbspace_dir_19 /eniq/database/dwh_main_dbspace/dbspace_dir_20 ");

		system("/eniq/sw/bin/resizedb -v DWH");
		system("/eniq/sw/bin/engine start");
		system("/eniq/admin/bin/eniq_service_start_stop.bsh -s engine -a clear");
		system("/eniq/sw/bin/engine -e changeProfile Normal");
	
	}
	else
	{
		print "/eniq/sw/conf/niq.ini is already updated.\n";
	}
 
   if($!==0)  
   {
     print "PASS\n";
   }
   else
   {
     print "FAIL\n";
   }
 $result.="<h3>RESIZEDB DONE</h3>"; 

 return $result;

 }

############################################################
# WAIT UNTIL NO PROCESSES ARE IN EXECUTION OR IN QUEUE 
# This test case only runs 2 commands:
# engine -e  showSetsInExecutionSlots 
# engine -e  showSetsInQueue 
# and counts the output , if both are 0 then it finishes, and the test is passed.
# This is very helpful to check is the regression is finished loading and aggregating.

sub waitUntilProcessesDone{
  my $processesExecution=1;
  my $processesQueue    =1;
  do{
    my @execution=executeThis("/eniq/sw/bin/engine -e  showSetsInExecutionSlots | egrep -v '(----|TechPack|Version|SetName|Finished|Querying sets|Connecting engine|\+ )' | wc -l");
    chomp(@execution);
    $processesExecution=$execution[0];
    my @queue    =executeThis("/eniq/sw/bin/engine -e  showSetsInQueue | egrep -v '(----|TechPack|SetName|Finished|Querying sets|Connecting engine )' | wc -l");
    chomp(@queue);
    $processesQueue    =$queue[0];
    print "ProcessesinExecutionQueue: $processesExecution  ProcessesInQueue: $processesQueue sleep 1min\n";
    sleep(60);
  }while(!($processesExecution==0 && $processesQueue==0));
  print "PASS\n";
}
############################################################
# GET DOMAIN
# This is a utility, just checks and returns the domain
sub getDomain{
  open(DOMAIN,"grep domain /etc/resolv.conf |  cut -d ' ' -f 2 | ");
  my @domain=<DOMAIN>;
  chomp(@domain);
  close(DOMAIN);
  return $domain[0];
}
############################################################
# HELP
# This subroutine logs in to adminUI and 
# cuts the help links and puts them in a table
# the tester must read the help links to ensure they are OK
# This test should be considered passed when the links are tested
# if no links are displayed the test must be failed
sub help{
   my $result="";
   my $host=getHostName();
   my $domain=getDomain();
   
   # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt https://localhost:8443/adminui/servlet/LoaderStatusServlet");
   
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/help.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
  open(HELP, "< help.html");
  my @help=<HELP>;
  chomp(@help);
  my $title="manual";
  $result=qq{
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>HELP TITLE</th>
     <th>LINK</th>
     <th>RESULT</th>
   </tr>
}; 
  foreach my $help (@help)
  {
   $_=$help;
   $help =~ s/<tr><td><a class="menulink" href=.servlet.\w>//;
   $help =~ s/<tr><td><a class="menulink" href=.adminui.servlet.\w>//;
   $help =~ s/.*href=.//; 
   $help =~ s/. onClick.*//; 
   $help =~ s/<.a>//; 
   $help =~ s/.*\">//; 
   $help =~ s/.*>//; 
   next if(/Logout/); 
   if(/User Manual/)
     {
       $result.= "<tr><td>User Manual</td>";
       $help= "http://$host.$domain:8080".$help;
       $result.= "<td align=center><a href=$help>$help<a/></td><td align=center><font color=006600><b>PASS</b></td></tr>\n";
     }
   elsif(/adminui.manual/)
     {
       $help =~ s/adminui.manual/manual/;
       $help= "http://$host.$domain:8080".$help;
       $result.= "<td align=center><a href=$help>$help<a/></td><td align=center><font color=006600><b>PASS</b></td></tr>\n";
     } 
   elsif(/menulink/)
     {
       $title=$help;
       #$title=~s/ /_/g;
       $result.= "<tr><td>$title</td>";
     }
  }
  close(HELP);
  $result.=qq{
</table>
};
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

  return $result;
}
#####################################
# GET TP VERSION FROM DB
# This subroutine queries the DB to get 
# the techpack versions,
# it is not a test case, is a utility
sub getTPversion{
my $sql=qq{
select 
   t.techpack_name||'_'||
   v.techpack_version
from 
   dwhrep.versioning v, 
   dwhrep.tpactivation t, 
   dwhrep.dwhtechpacks d 
where 
   v.versionid = t.versionid 
and v.versionid = d.versionid 
and t.status = 'ACTIVE';
go
EOF
};
my @result=undef;
open(VERSION,"$sybase_dir -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
my @version=<VERSION>;
chomp(@version);
close(VERSION);
 my @result=undef;
 foreach my $version (@version)
 {
   $_=$version;
   next if(/affected/);
   $version=~s/ //g;
   push @result, $version;
 }
 return @result;
}
###############################
# GET BASE LINE MODULES
# This subroutine is a utility
# is in charge of getting a list of modules from the input path
sub getBLmodules{
 my $path=shift;
 $_=$path;
 $path=~s/\s//;
 open(BSLN,"cd $path/eniq_sw;ls *.zip  |");
 my @bsln=<BSLN>;
 chomp(@bsln);
 close(BSLN);
 my @result=undef;
 foreach my $bsln (@bsln)
 {
   $_=$bsln;
   $bsln=~s/.zip//;
   $bsln=~s/_/-/;
   push @result, $bsln;
 }
 return @result;
}
###############################
# GET BASE LINE TECH PACKS
# This subroutine is a utility
# is in charge of getting a list of techpacks from the installation path
sub getBLTPs{
 my $path=shift;
 $_=$path;
 $path=~s/\s//;
 open(BLTP,"cd $path/eniq_techpacks; ls *.tpi | awk -F. '{print \$0}' | grep -v INTF | sed 's/.tpi//' |");
 my @bltp=<BLTP>;
 chomp(@bltp);
 close(BSTP);
 return @bltp;
}
################################
#GET BASE LINE INTERFACES
# This subroutine is a utility
# is in charge of getting a list of interfaces from the installation path
sub getINTFs{
 my $path=shift;
 $_=$path;
 $path=~s/\s//;
 open(BLINTF,"cd $path/eniq_techpacks;cat feature_techpacks | cut -c 13- |sort|uniq|");
 my @blintf=<BLINTF>;
 chomp(@blintf);
 close(BLINTF);
 print "thisis:@blintf\n";
 return @blintf;
}
###############################
# GET INSTALLED TECHPACKS
# This subroutine is a utility
# is in charge of getting the installed techpacks from AdminUI (Monitoring Commands)
sub getInstalledTechpacks{

 system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

 # SEND USR AND PASSWORD
 system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

 # post Information
 system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/tps.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
 my @status=executeThis("egrep '(Not active Tech Packs|					<tr>|						<td class=.basic.>)'  /eniq/home/dcuser/tps.html");
 chomp(@status);
 close(status);
 my @result=();
 my $finalresult=0;
 my $line="";
 foreach my $status (@status)
 {
  $_=$status;
  $status =~ s/                                                <td class=.basic.>//;
  $status =~ s/<.td>//;
  $status =~ s/\s//;
  $status =~ s/.*">//;

  if(/<tr>|Not active Tech Packs/)
     { 
          push @result, $line;
          $line="";
     }
  last if(/Not active Tech Packs/);
  if(/.._._.*|\w_\w|R.*_\w/i)
     {
          if ($line eq "")
           { 
             $line=$status;
           }
          else
           { 
             $line.="_$status";
           }
   
     }
 } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

return @result;
}
###############################
# GET INSTALLED MODULES
# This subroutine is a utility
# is in charge of getting the installed modules using
# grep module /eniq/sw/installer/versiondb.properties | sed 's/module.//'  | sed 's/=/-/'
sub getInstalledModules{
open(MODULES,"grep module /eniq/sw/installer/versiondb.properties | sed 's/module.//'  | sed 's/=/-/' |");
my @modules=<MODULES>;
close(MODULES);
chomp(@modules);
return @modules;
}
##############################
#GET Active Interfaces
sub getActiveInterfaces{
#print `cd /eniq/sw/installer;./get_active_interfaces | cut -d" " -f1 | sort | uniq`;
open(INTF,"cd /eniq/sw/installer;./get_active_interfaces | cut -d\" \" -f1 | sort | uniq |" );
my @intf=<INTF>;
close(INTF);
chomp(@intf);
return @intf;

}
###################################################3
# COMPARE BASE AND INSTALLED MODULES OR TECHPACKS OR INTERFACE
# This subroutine is a utility
# is in charge of comparing a couple of arrays
# if the arrays contain equal values, then they are inserted in a
# hash, if equal the value is updated to 10
# if different then the value remains 3

sub compareBase{
 my ( $ref_1,$ref_2)=@_;
 my @baseline =@{$ref_1};
 my @installed=@{$ref_2};
 my %result=undef;
 
 foreach my $baseline (@baseline)
  {
    if($baseline=~m/^afj|^helpset/)
	{ 
	  $_=$baseline;	  
	  $_=~s/[_]/-/;
	  $baseline=$_;	  
	}
		
	$result{$baseline}=3; 
  }
 
 foreach my $installed (@installed)
  {
    if($installed=~m/^afj|^helpset/)
	{ 
	  
	  $_=$installed;	  
	  $_=~s/[_]/-/;
	  $installed=$_;	  
	}
		
	$result{$installed}+=7;
  }
 return %result; 
}
############################################################################
#This subroutine compares baseline interfaces 
#with the one in get_active_interfaces
############################################################################
sub compareBaselineInterfaces{
my $path=shift;
my @bi=getINTFs($path);
my @interfaces=getActiveInterfaces();
my %modres=compareBase(\@bi,\@interfaces);
 my $result.=qq{
 <h3>Compared with: $path</h3>
 <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>INTERFACE</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
 };
 
 foreach my $interface (sort keys %modres)
 {
    $_=$interface;
    
	next if(/^$/);
	
	if($modres{$interface}== 3)
    {
		my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>FAIL</b></font></td></tr>\n";
    } 
    
	if($modres{$interface}== 7)
    {
		my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td> </tr>\n";
	}

	if($modres{$interface}== 10)
	{
		my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>PASS</b></font></td></tr>\n";
	}
 }

 $result.="</table> <br>\n";
 return $result;
}





############################################################################
#    [ Updated on 11-03-2011 ]
# This subroutine is in charge of comparing the installation path modules 
# and the modules installed in the server if equal then PASS, else FAIL.
############################################################################

sub compareBaselineModules 
{
 my $path = shift;
 my @bl=getBLmodules($path);
 my @modules=getInstalledModules();
 my %modres=compareBase(\@bl,\@modules);
 my $result.=qq{
 <h3>Compared with: $path</h3>
 <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>MODULE</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
 };
 
 foreach my $module (sort keys %modres)
 {
    $_=$module;
    
	next if(/^$/);
	
	if($modres{$module}== 3)
    {
		my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>FAIL</b></font></td></tr>\n";
    } 
    
	if($modres{$module}== 7)
    {
		my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td> </tr>\n";
	}

	if($modres{$module}== 10)
	{
		my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>PASS</b></font></td></tr>\n";
	}
 }

 $result.="</table> <br>\n";
 return $result;
}
############################################################################

############################################################################
# COMPARE BASELINE
# This subroutine is in charge or comparing 
# the installation path techpacks and the techpacks displayed in adminUI
# if equal then PASS, else FAIL
sub compareBaselineTechpacks{
my $path = shift;
my @bt=getBLTPs($path);
my @tps=getInstalledTechpacks();
#my @tps=getTPversion();
my %modres=compareBase(\@bt,\@tps);
my $result.=qq{
<h3>Compared with: $path</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
<tr>
<th>TECHPACK STATUS</th>
<th>DESCRIPTION</th>
<th>STATUS</th>
</tr>
};
foreach my $module (sort keys %modres)
{
$_=$module;
next if(/^$/);
if($modres{$module}== 3)
{
     my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td> FOUND IN BASELINE, NOT INSTALLED</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
}
if($modres{$module}== 7)
{
     my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
}
if($modres{$module}== 10)
{
     my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>PASS</b></font></td></tr>\n";
}
}
$result.="</table> <br>\n";
return $result;
}
############################################################
# Sub routine used for EBS, this is a utility
sub getNEID{
my $ebsType=shift;
if($ebsType eq "S")
{
return "SubNetwork=ONRM_ROOT_MO,SubNetwork=SGSN,ManagedElement=GSN16";
}
if($ebsType eq "G")
{
return "ONRM_ROOT_MO,ManagedElement=AXE0";
}
if($ebsType eq "W")
{
return "SubNetwork=NRO_RootMo_R,SubNetwork=RNC01,MeContext=RNC01";
}
}
############################################################
# MAKE DATE
# this is a utility
sub makeDate{
my $year =shift;
my $mon  =shift;
my $mday =shift;
my $hour =shift;
my $min =shift;
return sprintf "%4d%02d%02d%02d%02d%02d", $year,$mon,$mday,$hour,$min,"00";
}

################################
# CONSTANTS NEEDED FOR EBS FILES
# These constanst are used for construction of EBS files
my @ebss=("sgsn","ra","cell","sa","hni","apn","ggsn","hlr","hzi","tac","tacsvn");
#my @ebss=("sgsn","ra","cell","sa","hni","apn");
my @ebsg=("cell","trx");
my @ebsw=("cell");
sub getEBSType{
my $type=shift;
if($type eq "S") {return @ebss;}
if($type eq "G") {return @ebsg;}
if($type eq "W") {return @ebsw;}
}
################################
# This is the data header for EBS files
# This subroutine is a utility
sub data_header{
my $start_time = shift;
my $neid       = shift;
return qq{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mdc SYSTEM "MeasDataCollection.dtd">
<mdc><mfh><ffv>32.401 V6.2</ffv>
<sn>$neid</sn>
<st>OSS</st>
<vn>Ericsson AB</vn>
<cbt>$start_time</cbt>
</mfh>
<md><neid><neun>RNC01</neun>
<nedn>$neid</nedn>
</neid>
};
}
################################
# 
# This subroutine is a utility for EBS 
sub mi_start{
my $end_time           = shift;
my $mon                = shift;
my $counter_group_name = shift;
return qq{<mi measInfoId="$mon.CG0001 $counter_group_name"><mts>$end_time</mts>
<jobid>19</jobid>
<gp>900</gp>
<rp>900</rp>
};
}
################################
# This subroutine is a utility for EBS
sub mi_end{return qq{</mi>
};}
################################ 
# This subroutine is a utility for EBS
sub mt{
my $counter_name     = shift;
my $counter_index    = shift;
return qq{<mt p="$counter_index">c$counter_name</mt>
};
}
################################
# This subroutine is a utility for EBS 
sub mv_start{
my $moid            = shift;
if($moid eq "sgsn"){return "<mv><moid></moid>\n";}
return qq{<mv><moid>$moid</moid>
};
}
################################
# This subroutine is a utility for EBS
sub mv_end{
return qq{</mv>
};
}
################################
# This subroutine is a utility for EBS
sub r_value{
my $counter_value   = shift;
my $counter_index   = shift;
return qq{<r p="$counter_index">$counter_value</r>
};
}
################################
# This subroutine is a utility for EBS
sub data_tail{
my $end_time= shift;
return qq{</md>
<mff><ts>$end_time</ts>
</mff>
</mdc>
};
}
################################
# This subroutine is a utility for EBS
# list of cells 
my @cellw=(
"ManagedElement=1,RncFunction=1,UtranCell=RNC01-0-1",
"ManagedElement=1,RncFunction=1,UtranCell=RNC01-0-2",
"ManagedElement=1,RncFunction=1,UtranCell=RNC01-0-3",
"ManagedElement=1,RncFunction=1,UtranCell=RNC01-0-4",
"ManagedElement=1,RncFunction=1,UtranCell=RNC01-0-5"
);
# list of trx
my @trx=(
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1234,Trx=TRX-23-1",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1234,Trx=TRX-23-2",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1234,Trx=TRX-23-3",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1234,Trx=TRX-23-4"
);
# list of apns
my @apn=(
"APN=ap1",
"APN=ap2",
"APN=ap3",
"APN=ap4",
"APN=ap5"
);
# list of cells 
my @cells=(
"CELL=1001202373841253",
"CELL=1001202373841254",
"CELL=1001202373841255",
"CELL=1001202373841256",
"CELL=1001202373841257"
);
# list of hni
my @hni=(
"HNI=888888",
"HNI=888887",
"HNI=888886",
"HNI=888885",
"HNI=888884"
);
# list of ra
my @ra=(
"RA=10012023738012",
"RA=10012023738013",
"RA=10012023738014",
"RA=10012023738015",
"RA=10012023738016"
);
# list of sa
my @sa=(
"SA=1001202373847118",
"SA=1001202373847119",
"SA=1001202373847117",
"SA=1001202373847116",
"SA=1001202373847115"
);
# list of cell used in EBSG
my @cellg=(
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1111",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1112",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1113",
"BssFunction=BSS_ManagedFunction,BtsSiteMgr=ABCDEG,GsmCell=1234"
);
# NEW EBSS COUNTERS
# list of ggsn
my @ggsn   =(
"GGSN=123"
);
# list of hlr 
my @hlr    =(
"HLR=123"
);
# list of hzi
my @hzi    =(
"HZI=123"
);
# list of tac
my @tac    =(
"TAC=123"
);
# list of tcsvn
my @tacsvn =(
"TACSVN=123"
);
# END OF NEW COUNTERS FOR EBSS
################################
# This subroutine is a utility used for EBS XML data files
sub ebs_data{
my $ebsType   = shift;
my $groups    = shift;
my $counters  = shift;
my $empty     = shift;
my $null      = shift;
my $year      = shift;
my $mon       = shift;
my $mday      = shift;
my $hour      = shift;
my $min       = shift;
my $data=data_header(makeDate( $year,$mon,$mday,$hour ,$min),getNEID($ebsType));
my @meaObject=getEBSType($ebsType);
my @mox=undef;
foreach my $mo_name (@meaObject)
{
	for (my $cg=0; $cg<$groups; $cg++)
	{			
	      #my $timestamp=makeDate($year,$mon,$mday,$hour , "15"); 
              my $HOUR=0;
              if($min == 45)
              {
                  $HOUR=$hour+1;
              }
              else
              {
                  $HOUR=$hour;
              }
              my $timestamp=makeDate($year,$mon,$mday,$HOUR , ($min + 15)%60);
		$data.=mi_start($timestamp,$mo_name,$cg);
		for(my $i=0; $i<$counters; $i++)
		{
			my $counter_i=$i + ($counters*$cg);
			$data.=mt($counter_i,$counter_i);
		}
		if($mo_name eq "cell" && $ebsType eq "S"){ @mox=@cells;}
		if($mo_name eq "cell" && $ebsType eq "G"){ @mox=@cellg;}
		if($mo_name eq "cell" && $ebsType eq "W"){ @mox=@cellw;}
		if($mo_name eq "trx"){ @mox=@trx;}
		if($mo_name eq "ra") { @mox=@ra;}
		if($mo_name eq "sa") { @mox=@sa;}
		if($mo_name eq "hni"){ @mox=@hni;}
		if($mo_name eq "apn"){ @mox=@apn;}
                # NEW COUNTERS
		if($mo_name eq "ggsn"){ @mox=@ggsn;}
		if($mo_name eq "hlr") { @mox=@hlr;}
		if($mo_name eq "hzi") { @mox=@hzi;}
		if($mo_name eq "tac") { @mox=@tac;}
		if($mo_name eq "tacsvn"){ @mox=@tacsvn;}
                # END OF NEW COUNTERS
		if($mo_name eq "sgsn") { @mox=("sgsn"); }
		foreach my $mox (@mox)
		{
		      $data.=	mv_start($mox);
		      for(my $i=0; $i<$counters; $i++)
		      {
			my $counter_j = $i + $counters*$cg;
			if ( $empty > 0 && $null == 0)
			{
				if ($counter_j % $empty != 0)
				{
				$data.=r_value($counter_j,$counter_j);
				}
				else
				{
				$data.=r_value("","");
				}
			}
			elsif ( $empty == 0 && $null > 0)
			{
				if ($counter_j % $null != 0)
				{
				 $data.=r_value($counter_j,$counter_j);
				}
				else
				{
				$data.=r_value("","");
				}
			}						
			else
			{
			      $data.=r_value($counter_j,$counter_j);
			}
		     }
		     $data.=   mv_end();
	       }
	       $data.=   mi_end();
	}
}
my $HOUR=0;
 if($min==45)
     {
       $HOUR=$hour+1;
     }
  else
     {
        $HOUR=$hour;
     }
my $ts=makeDate( $year,$mon,$mday,$HOUR ,($min+15)%60);
#my $ts=makeDate( $year,$mon,$mday,$hour ,"15");
$data.=data_tail($ts);
open(EBSDATA,">EBS$ebsType\_data.xml");
print EBSDATA $data;
close(EBSDATA);

}
############################################################
# This was used for testing the generation of EBS data files
#sub test_ebs_data{
#ebs_data("S",3,2,0,0,2009,8,11,6);
#ebs_data("G",3,2,0,0,2009,8,11,6);
#ebs_data("W",3,2,0,0,2009,8,11,6);
#}
################################
# xml header  for EBS MOM files
#
sub header{
return qq{<?xml version="1.0" encoding="UTF-8"?>
<pm xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='PM-MOM.xsd'>

<pmMimVersion>1.0</pmMimVersion>
<applicationVersion>3</applicationVersion>
<measurements>
};
}
################################
# this is a utility used in EBS XML files
sub argument{
my $argument_index=shift;
my $counter_name  =shift;
return qq{
<argument seq="$argument_index">
<measName>$counter_name</measName>
</argument>
};
}
################################
# This is a utility used in EBS XML files
sub group{
my $countergroup_index = shift;
return qq{<group name="countergroup_basename $countergroup_index">
};
}
################################
# This is a utility used in EBS xml files
sub groupend{
return qq{</group>
};
}
################################
# This is a utility used in EBS xml files
sub meas{
my $measurement_object_name=shift;
return qq{<measObjClass name="$measurement_object_name">
};
}
################################
# This is a utility used in EBS xml files
sub measend{
return qq{</measObjClass>
};
}
################################
# This is a utility used in EBS xml files
sub formula{
return qq{
<description>Monitor Name: pmCnRabReleaseCs64;
Parameter:
Service Type=Cs64;
</description>
</formula>
};
}
################################
# This is a utility used in EBS xml files
sub identity{
my $counter_name =shift;
my $formula_index=shift;
return qq{<formula name="formula_basename c$counter_name $formula_index">
<function>IDENTITY</function>
<argument seq="1">
<measName>c$counter_name</measName>
</argument>
};
}
################################
# This is a utility used in EBS xml files
sub mean{
my $counter_name =shift;
my $formula_index=shift;
my $counter_name1 =shift;
my $counter_name2 =shift;

return qq{<formula name="formula_basename c$counter_name $formula_index">
<function>MEAN</function>
<argument seq="1">
<measName>c$counter_name1</measName>
</argument>
<argument seq="2">
<measName>c$counter_name2</measName>
</argument>
};
}
################################
# This is a utility used in EBS xml files
sub ffax_ind{
my $counter_name =shift;
my $formula_index=shift;
my $counter_name1 =shift;
my $counter_name2 =shift;
my $counter_name3 =shift;
my $counter_name4 =shift;

return qq{<formula name="formula_basename c$counter_name $formula_index">
<function>FFAX_INDICATION</function>
<argument seq="1">
<measName>c$counter_name1</measName>
</argument>
<argument seq="2">
<measName>c$counter_name2</measName>
</argument>
<argument seq="3">
<measName>c$counter_name3</measName>
</argument>
<argument seq="4">
<measName>c$counter_name4</measName>
</argument>
};
}
################################
# This is a utility used in EBS xml files
sub ffax_stddev{
my $counter_name =shift;
my $formula_index=shift;
my $counter_name1 =shift;
my $counter_name2 =shift;
my $counter_name3 =shift;

return qq{<formula name="formula_basename c$counter_name $formula_index">
<function>FFAX_STDDEV</function>
<argument seq="1">
<measName>c$counter_name1</measName>
</argument>
<argument seq="2">
<measName>c$counter_name2</measName>
</argument>
<argument seq="3">
<measName>c$counter_name3</measName>
</argument>
};
}

################################
# This is a utility used in EBS xml files
sub counter{
my $counter_name        = shift;
return qq{<counter>
<measType>
<measName>$counter_name</measName>
</measType>
<description>Monitor Name: pmCnRabReleaseCs64;
Parameter:
Service Type=Cs64;
</description>
<measResult>
<unit>Number of</unit>
</measResult>
<storage>
<size>numeric(18,0)</size>
<aggregation>AVERAGE</aggregation>
<type>PEG</type>
</storage>
</counter>
};
}
################################
# This is a utility used in EBS xml files
sub tail{
return qq{</measurements>
</pm>
};
}
################################
# These are constant values used for EBS xml files
#my @ebss=("sgsn","ra","cell","sa","hni","apn");
my @ebss=("sgsn","ra","cell","sa","hni","apn","ggsn","hlr","hzi","tac","tacsvn");
my @ebsg=("cell","trx");
my @ebsw=("cell");
sub getEBSType{
my $type=shift;
if($type eq "S") {return @ebss;} 
if($type eq "G") {return @ebsg;} 
if($type eq "W") {return @ebsw;} 
}
################################
# This is used to create an EBS MOM xml file
# Needs the following params:
# ebsType: S, G, W
# group: 3 for example
# counters: 2 for example
# This process is a double for so for each group it will create N counters, in the 
# example 3x2=6 counters
# This algorithm was created by Ge Liu in Finland, I just translated it into perl
# Basically uses each of the functions and when it reaches 4 it starts again
# this is controlled in the ifs
# if func==0  use mean
# if func==1  use ffax_stddev
# if func==2  use ffax_ind
# if func==3  use identity
# The output xml file is first generated in the DCUSER home directory
sub ebs_mom{
my $ebsType     = shift;
my $groups      = shift;
my $counters    = shift;
my $aggregation = "";
my $function    = "";
my $mom="";
$mom.=header();
my @type = getEBSType($ebsType);
foreach my $mea (@type)
{
my $counter_i = 0;
$mom.=meas($mea);	
for(my $n=0; $n<$groups; $n++)
{
    $mom.=group($n);
    for(my $i=0; $i<$counters; $i++)
    {
	$mom.=counter("c$counter_i");
	#for(my $f=0; $f<$NumOfFormulas; $f++)
	for(my $f=0; $f<$groups; $f++)
	{ 	
	  my  $func = $counter_i % 4;
	  #my  $form = getFormula($func);
	  #$mom.=formula($i); 
	   if($func==0)
		{
		   my $counter_ip1=$counter_i+1;
		   if($counter_ip1==$groups*$counters)
		   {
		      $counter_ip1=$counter_i;
		   }
		   $mom.=mean($counter_i,$f,$counter_i,$counter_ip1);
		   $mom.=formula();
		}
	   if($func==1)
		{
		   my $counter_ip1=$counter_i+1;
		   if($counter_ip1>=$groups*$counters)
		   {
		      $counter_ip1=$counter_i;
		   }
		   my $counter_ip2=$counter_i+2;
		   if($counter_ip2>=$groups*$counters)
		   {
		      $counter_ip2=$counter_i;
		   }

		   $mom.=ffax_stddev($counter_i,$f,$counter_i,$counter_ip1,$counter_ip2);
		   $mom.=formula();
		}
	   if($func==2)
		{
		   my $counter_ip1=$counter_i+1;
		   if($counter_ip1>=$groups*$counters)
		   {
		      $counter_ip1=$counter_i;
		   }
		   my $counter_ip2=$counter_i+2;
		   if($counter_ip2>=$groups*$counters)
		   {
		      $counter_ip2=$counter_i;
		   }
		   my $counter_ip3=$counter_i+3;
		   if($counter_ip3>=$groups*$counters)
		   {
		      $counter_ip3=$counter_i;
		   }

		   $mom.=ffax_ind($counter_i,$f,$counter_i,$counter_ip1,$counter_ip2,$counter_ip3);
		   $mom.=formula();
		}
	   if($func==3)
		{
		  $mom.=identity($counter_i,$f);
		  $mom.=formula();
		}

	}
	$counter_i++;
    }
    $mom.=groupend();
}
$mom.=measend();
}
$mom.=tail();
open(EBS,">/eniq/home/dcuser/EBS$ebsType.xml");
print EBS $mom;
close(EBS);
}
#####GENERATE MOMS#####
#sub test_mom{
#ebs_mom("S",3,2);
#ebs_mom("G",3,2);
#ebs_mom("W",3,2);
#}
############################################################
# GET THE HTML HEADER
# This is a utility for the log output file in HTML 
sub getHtmlHeader{
return qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>
ENIQ Regression Feature Test
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
############################################################
# GET HTML TAIL
# This is a utility for the log output file in HTML 

sub getHtmlTail{
return qq{
</table>
<br>
</body>
</html>
};

}

############################################################
# WRITE HTML
# This is a utility for the log output file in HTML 

sub writeHtml{
my $server = shift;
my $out    = shift;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
  $mon++;
  $year=1900+$year;
my $date =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);
open(OUT," > $LOGPATH/$server\_$date.html");
print  OUT $out;
close(OUT);
return "$LOGPATH/$server\_$date.html\n";
}

############################################################
# HELP INFO
# This is a utility, used in case the script is used without params
sub info{
return qq{
Wrong number of parameters.
eniqFT.sh <conf file>
};
}
sub getTechPacks{
open(TPS,"< techpacks");
my @tps = <TPS>;
close(TPS);
return @tps;
}
sub getepfg_TechPacks{
open(TPS1,"< epfg_techpacks");
my @tps = <TPS1>;
close(TPS1);
return @tps;
}
############################################################
# CALCULATE DIFFERENCE BETWEEN 2 ARRAYS
# This is a utility, actually not used anywhere in the code, can be discarded!! 

sub difference{
my @a          = shift;
my @b          = shift;
my %count=undef; 
my @diff= undef; 
foreach my $e (@a, @b) { $count{$e}++ }

foreach my $e (keys %count) 
{
#push(@union, $e);
if ($count{$e} == 2) 
{
#  push @isect, $e;
} 
else 
{
push @diff, $e;
}
}
return @diff;
}
############################################################
# GETS AL THE INSTALLED TECHPACKS FROM REPDB  [ Updated :: ]
# This is a utility runs a query to get all the techpacks 
# installed from REPDB

sub getAllTechPacks
{
  my $sql;
     if ($syb_edition_unchanged=~m/true/)
	{
		$sql=qq{
select 
distinct SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID))
from 
dwhrep.MeasurementCounter
where 
SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DWH_MONITOR'
and SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DC_Z_ALARM';
go
EOF
};  
	   open(ALLTP,"$sybase_dir_12_7 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
	   
	   print "sybase_dir_12_7 = $sybase_dir_12_7 \n";
	}
	else
	{
		  $sql=qq{
select
distinct SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1)
from  
dwhrep.MeasurementCounter
where 
SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1) <>'DWH_MONITOR'
and SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1) <>'DC_Z_ALARM';
go
EOF
};	
############# This query "$sql_sybase15" shall be used in place of $sql in the next line if Horizontal scalabilty ##########
############# is implemented with rightstring truncation property set to "ON"   ############################################ 

       open(ALLTP,"$sybase_dir_15_2 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
	   
	   print "sybase_dir_15_2 = $sybase_dir_15_2 \n";
	}

	my @allTechPacks=<ALLTP>;
    my @result=undef; 
    chomp(@allTechPacks);
	
	foreach my $allTechPacks (@allTechPacks)
    {
     $_=$allTechPacks;
     $allTechPacks=~s/ //g; 
     next if(/affected/);
     next if(/^$/);
	 print "$allTechPacks \n";
     push @result,$allTechPacks;
    }
  
  close(ALLTP);
  return @result;
}

#############################################################
# GETS AL THE INSTALLED TECHPACKS FROM REPDB   [ Updated : ]
# This is a utility
# This is used only in the re-aggregation process for DAY
sub getAllTechPacksAgg
{
  my $sql;
    if ($syb_edition_unchanged=~m/true/)
	{
		   $sql=qq{
select
 distinct SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID))||
 SUBSTR( SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20),  0,CHARINDEX(':',SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20)))||
 '&'||SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1)
from
dwhrep.MeasurementCounter
where
SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1) <>'DWH_MONITOR'
and SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)-1) <>'DC_Z_ALARM';
go
EOF
};
############# This query "$sql_sybase15" shall be used in place of $sql in the next line if Horizontal scalabilty ##########
############# is implemented with rightstring truncation property set to "ON"   ############################################ 

		open(ALLTP,"$sybase_dir_12_7 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql|");
    }
	
	else
	{
		my $sql=qq{
select 
 distinct SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)+1)||
 SUBSTR( SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20),  1,CHARINDEX(':',SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20)))|| 
 '&'||SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) 
 from 
 dwhrep.MeasurementCounter 
 where 
 SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DWH_MONITOR'
 and SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DC_Z_ALARM'
go
EOF
};


		open(ALLTP,"$sybase_dir_15_2 -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
	}

	my @allTechPacks=<ALLTP>;  
    my @result=undef;
   chomp(@allTechPacks);
   foreach my $allTechPacks (@allTechPacks)
   {
     $_=$allTechPacks;
     $allTechPacks=~s/ //g;
     next if(/affected/);
     next if(/^$/);
     push @result,$allTechPacks;
   }
 close(ALLTP);
 return @result;
}

############################################################
# START PARAM
# These parameters are used to set or unset a test
# if the test is set to true then the test is executed, else is not
# parameters without initial value are variables that get their input from 
# the configuration file
my $engineProcess     ="false";
my $epTp              ="";
my $epProcess         ="";
my $resizedb          ="false";
my $help              ="false";
my $verifyTables      ="false";
my $compareBaseline   ="false";
my $verifyLogs        ="false";
my $pathLogs          ="";
my $engine            ="false";
my $webserver         ="false";
my $scheduler         ="false";
my $licmgr            ="false";
my $licserv           ="false";
my $dwhdb             ="false";
my $repdb             ="false";
my $runCMDLine        ="false";
my $verifyExes        ="false";
my $verifyDAYBH       ="false";
my $verifyRANKBH      ="false";
my $loadTopology      ="false";
my $epfgloadTopology  ="false";
my $updateTopology    ="false";
my $epfgupdateTopology="false";
my $dataGeneration    ="false";
my $epfgdataGeneration = "false";
my $verifyLoadings    ="false";
my $verifyAggregations="false";
my $verifyEBS         ="false";
my $verifyUniverses   ="false";
my $verifyBOReports   ="false";
my $busyhour          ="false";
my $verifyBOfilter    ="*";
my $getSql            ="false";
my $runBOReports      ="false";
my $runBOfilter       =".";
my $verifyAlarms      ="false";
my $configWebportal   ="false";
my $webportal         ="";
my $preLoad           ="false";
my $pre               ="false";
my $addAlarmReport    ="false";
my $addAlarmMinutes   ="15min";
my $baselinePath      ="";
my $timeUpdate        = 0;
my $timeWarp          = -24;
my $numRops           = 0;
my $epfgstarttime     ="";
my $epfgstoptime      ="";
my $epfgnumberofnodes =1;
my $ebsBuild          ="";
my $ebsRefCounter     ="";
my $ebsCounterGroup   ="";
my $testEbs           ="false";
my $loadEbs           ="false";
my $ebsYear           ="";
my $ebsMonth          ="";
my $ebsDay            ="";
my $ebsHour           ="";
my $ebsMin            =0;
my $ebsSeconds        ="";
my $ebsUseGzip        ="false";
my $ebsNullValue      ="";
my $ebsEmptyValue     ="";
# This is a hardcoded list of techpacks used by datagenerator
# this will be obsolete when EPFG will be used as generator
my @techPacks         = (
"mdc/erbs",
"mdc/ims",
"mdc/mgw",
"mdc/rnc",
"mdc/sgsn",
"mdc/stn",
"mdc/ggsn",
"mdc/ipworks",
"mdc/rbs",
"mdc/rxi",
"mdc/smpc",
"mdc/tdrbs",
"mdc/tdrnc",
"mdc/ims-m",
"mdc/hss",
"mdc/mtas",
"asn1/bss",
"asn1/msc",
"sasn"
);
my @epfg_techPacks	  =  (
"EBA-EBSW",
"EBA-EBSG",
"SASN",
"SASN-SARA",
"GGSN",
"CUDB",
"MSC-APG",
"MSC-IOG",
"MSC-BC",
"MSC-APGOMS",
"MSC-IOGOMS",
"MSC-BCOMS",
"HLR-APG",
"HLR-IOG",
"EBSS-SGSN",
"SGSN",
"MGW",
"WRAN-LTE",
"RNC",
"Wran-RBS",
"Wran-RXI",
"BSC-APG",
"BSC-IOG",
"STN-PICO",
"STN-SIU",
"IPWORKS",
"SAPC",
"MLPPP",
"EDGE-ROUTER",
"CPG",
"SNMP-NTP",
"SNMP-Mgc",
"SNMP-LANSwitch",
"SNMP-IpRouter",
"SNMP-HpMrfp",
"SNMP-GGSN",
"SNMP-DNSServer",
"SNMP_DHCPServer",
"SNMP_Cs_CMS",
"SNMP_CS_DS",
"SNMP_Cs_As",
"SNMP_ACME",
"SNMP_HOTSIP",
"SNMP_Firewall",
"SBG",
"MGW2.0FD",
"MTAS",
"CSCF",
"HSS",
"MRFC",
"SGSN-MME",
"TSS-TGC",
"IMS",
"DSC",
"IMS-M",
"TDRBS",
"TDRNC"
);
  my $chkpart				="false";
  my $Reaggregation			="false";
  my $SystemStatus			="false";
  my $DwhStatus				="false";
  my $RepStatus				="false";
  my $EngineStatus			="false";
  my $SchedulerStatus			="false";
  my $LicservStatus			="false";
  my $LicmgrStatus			="false";
  my $SessionLogs			="false";
  my $DataRowInfo			="false";
  my $ShowRefTables			="false";
  my $RankBh				="false";
  my $MonitoringRules			="false";
  my $TypeConfig			="false";
  my $DWHConfig				="false";
  my $VerifyDirectories			="false";
  my $VerifyAdminScripts		="false";
  my $wrongUser			      	="false";
  my $eniqVersion			="false";
  my $DiskSpace				="false";
  my $InstalledModules			="false";
  my $InstalledTps			="false";
  my $ActiveProcs			="false";
  my $LoggingInfo			="false";
  my $LoggingSevere			="false";
  my $LoggingWarning			="false";
  my $LoggingConfig			="false";
  my $LoggingFine			="false";
  my $LoggingFiner			="false";
  my $LoggingFinest			="false";
  my $NegEngine				="false";
  my $NegScheduler			="false";
  my $NegLicMgr				="false";
  my $MaxUsersAdminui			="false";
  my $UnvInstallWithoutLogin		="false";
  my $ShowLoadingFutureDates		="false";
  my $ETLCSchedule			="false";
  my $ETLCMonitoring			="false";
  my $ETLCHistory			="false";
  my $ShowAggFutureDates		="false";
  my $ShowProblematic			="false";
  my $LicMgrDownShowLicenses		="false";
  my $LicServDownShowLicenses		="false";
  my $LicMgrDownRestartEngine		="false";
  my $LicMgrDownRestartScheduler	="false";
  my $LicServDownRestartEngine		="false";
  my $LicServDownRestartScheduler	="false";
  my $CreateSnapshots               ="false";
  my $CreateRackSnapshots           ="false";
  my $emptyMOM				="false";
  my $momType 				="";
  my $level 				="DAY";
  my $YEARTIMEWARP                 ="";
  my $MONTHTIMEWARP                ="";
  my $DAYTIMEWARP                  ="";
  my $DATETIMEWARP                 ="";
######################################################
# GET ALL TECHPACKS USED BY THE DATA GENERATOR, NOW IS HARDCODED
# This is a hardcoded list of techpacks used by datagenerator
# this will be obsolete when EPFG will be used as generator
sub getTechPacks{
@techPacks         = (
"mdc/erbs",
"mdc/ims",
"mdc/mgw",
"mdc/rnc",
"mdc/sgsn",
"mdc/stn",
"mdc/ggsn",
"mdc/ipworks",
"mdc/rbs",
"mdc/rxi",
"mdc/smpc",
"mdc/tdrbs",
"mdc/tdrnc",
"mdc/ims-m",
"asn1/bss",
"asn1/msc",
"sasn"
);
return @techPacks;
}
sub getepfg_TechPacks{
@epfg_techPacks         = (
"EBA-EBSW",
"EBA-EBSG",
"SASN",
"SASN-SARA",
"GGSN",
"CUDB",
"MSC-APG",
"MSC-IOG",
"MSC-BC",
"MSC-APGOMS",
"MSC-IOGOMS",
"MSC-BCOMS",
"HLR-APG",
"HLR-IOG",
"EBSS-SGSN",
"SGSN",
"MGW",
"WRAN-LTE",
"RNC",
"Wran-RBS",
"Wran-RXI",
"BSC-APG",
"BSC-IOG",
"STN-PICO",
"STN-SIU",
"IPWORKS",
"SAPC",
"MLPPP",
"EDGE-ROUTER",
"CPG",
"SNMP-NTP",
"SNMP-Mgc",
"SNMP-LANSwitch",
"SNMP-IpRouter",
"SNMP-HpMrfp",
"SNMP-GGSN",
"SNMP-DNSServer",
"SNMP_DHCPServer",
"SNMP_Cs_CMS",
"SNMP_CS_DS",
"SNMP_Cs_As",
"SNMP_ACME",
"SNMP_HOTSIP",
"SNMP_Firewall",
"SBG",
"MGW2.0FD",
"MTAS",
"CSCF",
"HSS",
"MRFC",
"SGSN-MME",
"TSS-TGC",
"IMS",
"DSC",
"IMS-M",
"TDRBS",
"TDRNC"
);
return @epfg_techPacks;
}
my @tpini            = getAllTechPacks();
my @aggini           = getAllTechPacks();
#######################################################
# METHOD IN CHARGE OF PARSING AND EXECUTING ALL THE CODE
# This is the main method that controls the regression
# the input is a configuration text file
# The file contains a set of tests in sequential order i.e:
#RESIZEDB
#HELP
#VERIFY_EXECUTABLES
#SCHEDULERCLI
#ENGINECLI
#WEBSERVERCLI
#READLOG
# The hash is used to comment out the line
# The algorithm is:
# read the file and check
# if for test labels
# if the label matches then the execution flag is turn to true
# the file is read from start to end and sets as many flags as needed
# then goes to the next section where it says  #############  NOW DO SOMETHING  ########## 
# and executes each test case if the flag was set 
# and once finished the flag is set to false
# each of the tests has a subroutine to execute, the results are given 
# and appended to the $result string, at the end of the execution the html log file is created

sub parseParam{
my $result="";
open(INPUT,"< $ARGV[0]");
my @input=<INPUT>;
chomp(@input);
close(INPUT);
foreach my $input (@input) 
{
$_=$input;
# SKIP IF THE LINE IS COMMENTED OUT
next if(/^#/);
   if(/^ENGINE_PROCESS/)
   {
    $engineProcess ="true";
    $input         =~ s/^ENGINE_PROCESS //;
    my @in         =split(/\s/,$input);
    $epTp          =$in[0];
    $epProcess     =$in[1];
    print "$epTp $epProcess\n";
   }

   if(/^CHECK_PARTITIONS/)
   {
    $chkpart  	                   ="true";
   }
   if(/^REAGGREGATION/) 
   {
    $Reaggregation                     ="true";
    $input=~s/REAGGREGATION //;
    $level   =$input;
   }
   if(/^SYSTEMSTATUS/) 
   {
   $SystemStatus                      ="true";
   }
   if(/^DWHDBSTATUS/) 
   {
   $DwhStatus                         ="true";
   }
   if(/^REPDBSTATUS/) 
   {
   $RepStatus                         ="true";
   }
   if(/^ENGINESTATUS/) 
   {
   $EngineStatus                      ="true";
   }
   if(/^SCHEDULERSTATUS/) 
   {
   $SchedulerStatus                    ="true";
   }
   if(/^LICSERVSTATUS/) 
   {
   $LicservStatus                     ="true";
   }
   if(/^LICMGRSTATUS/) 
   {
   $LicmgrStatus                      ="true";
   }
   if(/^SESSIONLOGS/) 
   {
   $SessionLogs                       ="true";
   }
   if(/^DATAROWINFO/) 
   {
   $DataRowInfo                       ="true";
   }
   if(/^SHOWREFTABLES/) 
   {
   $ShowRefTables                     ="true";
   }
   if(/^OLD_RANKBH/) 
   {
   $RankBh                            ="true";
   }
   if(/^MONITORINGRULES/) 
   {
   $MonitoringRules                   ="true";
   }
   if(/^TYPECONFIG/) 
   {
   $TypeConfig                        ="true";
   }
   if(/^DWHCONFIG/) 
   {
   $DWHConfig                         ="true";
   }
   if(/^VERIFY_DIRECTORIES/) 
   {
   $VerifyDirectories                 ="true";
   }
   if(/^VERIFY_ADMIN_SCRIPTS/) 
   {
   $VerifyAdminScripts                ="true";
   }
   if(/^ENIQVERSION/) 
   {
   $eniqVersion                       ="true";
   }
   if(/^DISKSPACE/) 
   {
   $DiskSpace                         ="true";
   }
   if(/^INSTALLED_MODULES/) 
   {
   $InstalledModules                  ="true";
   }
   if(/^INSTALLED_TPS/) 
   {
   $InstalledTps                      ="true";
   }
   if(/^ACTIVE_PROCS/) 
   {
   $ActiveProcs                       ="true";
   }
   if(/^LOGGING_INFO/) 
   {
   $LoggingInfo                       ="true";
   }
   if(/^LOGGING_SEVERE/) 
   {
   $LoggingSevere                     ="true";
   }
   if(/^LOGGING_WARNING/) 
   {
   $LoggingWarning                    ="true";
   }
   if(/^LOGGING_CONFIG/) 
   {
   $LoggingConfig                     ="true";
   }
   if(/^LOGGING_FINE/) 
   {
   $LoggingFine                       ="true";
   }
   if(/^LOGGING_FINER/) 
   {
   $LoggingFiner                      ="true";
   }
   if(/^LOGGING_FINEST/) 
   {
   $LoggingFinest                     ="true";
   }
   if(/^NEG_ENGINE/) 
   {
   $NegEngine                         ="true";
   }
   if(/^NEG_SCHEDULER/) 
   {
   $NegScheduler                      ="true";
   }
   if(/^NEG_LICMGR/) 
   {
   $NegLicMgr                         ="true";
   }
   if(/^MAX_USERS_ADMINUI/) 
   {
   $MaxUsersAdminui                   ="true";
   }
   if(/^ADMINUI_WRONG_USER/) 
   {
   $wrongUser       	               ="true";
   }
   if(/^UNV_INSTALL_WITHOUT_LOGIN/) 
   {
   $UnvInstallWithoutLogin            ="true";
   }
   if(/^SHOW_LOADING_FUTURE_DATES/) 
   {
   $ShowLoadingFutureDates            ="true";
   }
   if(/^ETLC_SCHEDULE/) 
   {
   $ETLCSchedule                      ="true";
   }
   if(/^ETLC_MONITORING/) 
   {
   $ETLCMonitoring                    ="true";
   }
   if(/^ETLC_HISTORY/) 
   {
   $ETLCHistory                       ="true";
   }
   if(/^SHOW_AGG_FUTURE_DATES/) 
   {
   $ShowAggFutureDates                ="true";
   }
   if(/^SHOW_PROBLEMATIC/) 
   {
   $ShowProblematic                   ="true";
   }
   if(/^LICMGR_DOWN_SHOWLIC/) 
   {
   $LicMgrDownShowLicenses            ="true";
   }
   if(/^LICSERV_DOWN_SHOWLIC/) 
   {
   $LicServDownShowLicenses           ="true";
   }
   if(/^LICMGR_DOWN_RESTART_ENGINE/) 
   {
   $LicMgrDownRestartEngine           ="true";
   }
   if(/^LICSERV_DOWN_RESTART_ENGINE/) 
   {
   $LicMgrDownRestartScheduler        ="true";
   }
   if(/^LICMGR_DOWN_RESTART_SCHEDULER/) 
   {
   $LicServDownRestartEngine          ="true";
   }
   if(/^LICSERV_DOWN_RESTART_SCHEDULER/) 
   {
   $LicServDownRestartScheduler       ="true";
   }
   if(/^Create_Snapshots/) 
   {
   $CreateSnapshots                   ="true";
   print "working";
   }
   if(/^Create_Rack_Snapshots/) 
   {
   $CreateRackSnapshots               ="true";
   print "working";
   }


if(/^ALARMCFG/)
{
$addAlarmReport    ="true";
$input=~s/ALARMCFG //;
$addAlarmMinutes   =$input;
}
if(/^BUSYHOUR/)
{
$busyhour          ="true";
}
if(/^RESIZEDB/)
{
$resizedb          ="true";
}
if(/^HELP/)
{
$help              ="true";
}
if(/^VERIFY_TABLES/)
{
$verifyTables      ="true";
}
if(/^COMPARE_BASELINE/)
{
$compareBaseline      ="true";
$input=~s/COMPARE_BASELINE //;
$baselinePath = $input;
}
if(/^VERIFY_EXECUTABLES/)
{
$verifyExes        ="true";
}
if(/^READLOG/)
{
  $verifyLogs      ="true";
  $input           =~s/READLOG //;
  $pathLogs        =$input;
}
if(/^RUNCMDLINE/)
{
$runCMDLine        ="true";
}
if(/^ENGINECLI/)
{
$engine        ="true";
}
if(/^WEBSERVERCLI/)
{
$webserver        ="true";
}
if(/^SCHEDULERCLI/)
{
$scheduler        ="true";
}
if(/^LICMGRCLI/)
{
$licmgr        ="true";
}
if(/^LICSERVCLI/)
{
$licserv        ="true";
}
if(/^DWHDBCLI/)
{
$dwhdb        ="true";
}
if(/^REPDBCLI/)
{
$repdb        ="true";
}
if(/^LOADTOPOLOGY/)
{
$loadTopology      ="true";
}
if(/^DAYBH-INFO/)
{
$verifyDAYBH       ="true";
}
if(/^RANKBH-INFO/)
{
$verifyRANKBH       ="true";
}
if(/^EPFGLOADTOPOLOGY/)
{
$epfgloadTopology      ="true";
}
if(/^UPDATE_TOPOLOGY/)
{
$updateTopology    ="true";
}
if(/^EPFGUPDATE_TOPOLOGY/)
{
$epfgupdateTopology    ="true";
}
if(/^CONFUPDATE DATAGENSET TIMEUPDATE /)
{
$input=~s/CONFUPDATE DATAGENSET TIMEUPDATE //;
$timeUpdate    =$input;
}
#==========================Commented=============================
#if(/^CONFUPDATE DATAGENSET TIMEWARP /)
#{
  #$input=~s/CONFUPDATE DATAGENSET TIMEWARP //;
  #$timeWarp      =$input;
    
  #$YEARTIMEWARP   =getYearTimewarp();
  #$MONTHTIMEWARP  =getMonthTimewarp();
  #$DAYTIMEWARP    =getDayTimewarp();
  #$DATETIMEWARP   =getDateTimewarp();
#}
#================================================================
#==========================Updated Code==========================
if(/^EPFG START TIME/)
{
  $input=~s/EPFG START TIME //;
  $timeWarp      =$input;
  $epfgstarttime   =$input;
  
  my ($TIME,$CURRENT_DAY,$CURRENT_MONTH,$CURRENT_YEAR,$DAYTIME,$MONTHTIME,$YEARTIME,$tmp);
  
  ($DAYTIME,$MONTHTIME,$YEARTIME,$TIME)=split('-',$timeWarp);
   
  ($CURRENT_DAY,$CURRENT_MONTH,$CURRENT_YEAR) = (localtime)[3,4,5];
  $CURRENT_YEAR+=1900;
  $CURRENT_MONTH+=1; 
 
  if(((($CURRENT_DAY-$DAYTIME)>2 || ($CURRENT_DAY-$DAYTIME)<=0)) || (($MONTHTIME-$CURRENT_MONTH)!=0) || (($YEARTIME-$CURRENT_YEAR)!=0))
  {
    $timeWarp=-24; 

    #Calculate Yesterday Date
    #if it is the first day of the month
    if($CURRENT_DAY == 1) 
    {
        # if it is the first month of the year
        if ($CURRENT_MONTH == 1)
        {
            # make the month as 12
            $CURRENT_MONTH=12;
 
            # deduct the year by one
            $CURRENT_YEAR=$CURRENT_YEAR - 1;
		}
		else
		{
            # deduct the month by one
            $CURRENT_MONTH=$CURRENT_MONTH - 1;
        }

        ($tmp,$tmp,$CURRENT_DAY,$tmp,$tmp)=split(' ',localtime(time()-86400));

        $CURRENT_DAY=sprintf "%02d",($CURRENT_DAY); 
    }
    else
    {
	  $CURRENT_DAY=sprintf "%02d",($CURRENT_DAY-1);
    }    
    
	$DAYTIMEWARP=$CURRENT_DAY;
	$MONTHTIMEWARP=sprintf "%02d",($CURRENT_MONTH);  
	$YEARTIMEWARP=$CURRENT_YEAR;   
	
	$epfgstarttime=sprintf "%02d",($CURRENT_DAY);
	$epfgstarttime=$epfgstarttime."-".$MONTHTIMEWARP."-".$YEARTIMEWARP."-".$TIME;
	
	$DATETIMEWARP=$YEARTIMEWARP.$MONTHTIMEWARP.$DAYTIMEWARP;
  }
  else
  {
    $timeWarp=(-24*($CURRENT_DAY-$DAYTIME));
		
	$DAYTIMEWARP=sprintf "%02d",($DAYTIME);
	$MONTHTIMEWARP=sprintf "%02d",($MONTHTIME);  
	$YEARTIMEWARP=$YEARTIME;   
		
	$epfgstarttime=sprintf "%02d",($DAYTIME);
	$epfgstarttime=$epfgstarttime."-".$MONTHTIMEWARP."-".$YEARTIMEWARP."-".$TIME;
	
	$DATETIMEWARP=$YEARTIMEWARP.$MONTHTIMEWARP.$DAYTIMEWARP;
  }
   
  #print "epfgstarttime = $epfgstarttime \n"; 
 
}
#==========================Commented==============================
#if(/^EPFG START TIME /)
#{
#$input=~s/EPFG START TIME //;
#$epfgstarttime   =$input;
#}
#==========================Updated Code==========================
if(/^EPFG STOP TIME /)
{
   $input=~s/EPFG STOP TIME //;
   $epfgstoptime   =$input;

   my ($TIME,$DAYTIME,$MONTHTIME,$YEARTIME);
  
  ($DAYTIME,$MONTHTIME,$YEARTIME,$TIME)=split('-',$epfgstoptime);
   
  if((($DAYTIME-$DAYTIMEWARP)!=0) || (($MONTHTIME-$MONTHTIMEWARP)!=0) || (($YEARTIME-$YEARTIMEWARP)!=0))
  {
    $DAYTIME=$DAYTIMEWARP;
	$MONTHTIME=$MONTHTIMEWARP;
	$YEARTIME=$YEARTIMEWARP;
	
	$epfgstoptime=$DAYTIME."-".$MONTHTIME."-".$YEARTIME."-".$TIME;	
  }
  else
  {
    $epfgstoptime=$DAYTIME."-".$MONTHTIME."-".$YEARTIME."-".$TIME;
  }
  
  #print "epfgstoptime = $epfgstoptime \n";
}
if(/^EPFG NUMBER OF NODES /)
{
$input=~s/EPFG NUMBER OF NODES //;
$epfgnumberofnodes   =$input;
}
if(/^CONFUPDATE DATAGENSET NUMROPS /)
{
$input=~s/CONFUPDATE DATAGENSET NUMROPS //;
$numRops       =$input;
}
################################################
if(/^LISTUPDATE DATAGENDT ENABLE ALL/)
{
#DEFINE ALL TECHPACKS SOMEWHERE
@techPacks    =getTechPacks();
}
elsif(/^LISTUPDATE DATAGENDT DISABLE ALL/)
{
@techPacks    =undef;
}
elsif(/^LISTUPDATE DATAGENDT ENABLE /)
{
$input=~s/LISTUPDATE DATAGENDT ENABLE //; 
$input=~s/ //g; 
@techPacks = split(/,/, $input);
} 
###################################################
if(/^EPFG DATAGENDT ENABLE ALL/)
{
#DEFINE ALL TECHPACKS SOMEWHERE
@epfg_techPacks    =getepfg_TechPacks();
}
elsif(/^EPFG DATAGENDT DISABLE ALL/)
{
@epfg_techPacks    =undef;
}
elsif(/^EPFG DATAGENDT ENABLE /)
{
$input=~s/EPFG DATAGENDT ENABLE //; 
$input=~s/ //g; 
@epfg_techPacks = split(/,/, $input);
}
###################################################### 
if(/^DATAGENMANAGER/)
{
$dataGeneration       ="true";
}
if(/^EPFGDATAGENMANAGER/)
{
$epfgdataGeneration       ="true";
}
if(/^WAIT /)
{
$input=~s/WAIT //;
my $sleep       =0;
# TRANSFORM TO MINUTES
$sleep       =$input*60;
print "SLEEP $sleep\n";
sleep($sleep);
}
if(/WAIT_UNTIL_PROCESSES_DONE/)
{
 waitUntilProcessesDone();
}
if(/^PRE_LOAD/)
{
$preLoad       ="true";
}
elsif(/^PRE/)
{
$pre       ="true";
}
if(/^LISTUPDATE TPINI DISABLE ALL/)
{
@tpini    = undef;
}
if(/^LISTUPDATE TPINI ENABLE ALL/)
{
# CHECK TP 
@tpini    = getAllTechPacks();
}
if(/^LISTUPDATE TPINI ENABLE /)
{
$input=~s/LISTUPDATE TPINI ENABLE //;
$input=~s/ //g;
@tpini = split(/,/, $input);
}
if(/^SHOW_LOADINGS/)
{
$verifyLoadings    ="true";
}
if(/^LISTUPDATE AGGINI ENABLE ALL/)
{
@aggini= getAllTechPacks();
}
if(/^LISTUPDATE AGGINI DISABLE ALL/)
{
@aggini= undef;
}
if(/^LISTUPDATE AGGINI ENABLE /)
{
$input=~s/LISTUPDATE AGGINI ENABLE //;
$input=~s/ //g;
@aggini = split(/,/, $input);
}
if(/^SHOW_AGGREGATION/)
{
$verifyAggregations="true";
}
if(/^VERIFY_UNIVERSES/)
{
$verifyUniverses   ="true";
}
if(/^VERIFY_BOREPORTS/)
{
$verifyBOReports   ="true";
  if(/GETSQL/)
   {
     $getSql="true";
   }
$input=~s/VERIFY_BOREPORTS//;
$input=~s/VERIFY_BOREPORTS //;
$input=~s/GETSQL //;
$verifyBOfilter    =$input;
}
if(/^RUN_BOREPORTS/)
{
$runBOReports   ="true";
$input=~s/RUN_BOREPORTS //;
$runBOfilter   =$input;
}
if(/^VERIFY_ALARMS/)
{
$verifyAlarms      ="true";
}
if(/^CONFIG_WEBPORTAL/)
{
$configWebportal   ="true";
$input =~s/CONFIG_WEBPORTAL //;
$webportal=$input;
}
if(/^CONFUPDATE EBSWUPDATE BUILD |CONFUPDATE EBSGUPDATE BUILD |CONFUPDATE EBSSUPDATE BUILD /)
{
$input=~s/CONFUPDATE EBSWUPDATE BUILD //;
$input=~s/CONFUPDATE EBSGUPDATE BUILD //;
$input=~s/CONFUPDATE EBSSUPDATE BUILD //;
$ebsBuild             =$input;
}
if(/^CONFUPDATE EBSWUPDATE REF_COUNTER |CONFUPDATE EBSGUPDATE REF_COUNTER |CONFUPDATE EBSSUPDATE REF_COUNTER /)
{
$input=~s/CONFUPDATE EBSWUPDATE REF_COUNTER //; 
$input=~s/CONFUPDATE EBSGUPDATE REF_COUNTER //; 
$input=~s/CONFUPDATE EBSSUPDATE REF_COUNTER //; 
$ebsRefCounter        =$input;
}
if(/^CONFUPDATE EBSWUPDATE COUNTER_GROUP |CONFUPDATE EBSGUPDATE COUNTER_GROUP |CONFUPDATE EBSSUPDATE COUNTER_GROUP /)
{
$input=~s/CONFUPDATE EBSWUPDATE COUNTER_GROUP //;
$input=~s/CONFUPDATE EBSGUPDATE COUNTER_GROUP //;
$input=~s/CONFUPDATE EBSSUPDATE COUNTER_GROUP //;
$ebsCounterGroup      =$input;
}
if(/^TEST_EBSW|TEST_EBSG|TEST_EBSS/)
{
$input=~s/TEST_EBS//;
$testEbs      =lc($input);
}
if(/^LOAD_EBS/)
{
$input=~s/LOAD_EBS//;
$loadEbs      =lc($input);
}
if(/^CONFUPDATE EBS.DATA TIMEWARP /)
{
$input=~s/CONFUPDATE EBS.DATA TIMEWARP //;
$timeWarp      =$input;
$ebsYear       =getYearTimewarp();
$ebsMonth      =getMonthTimewarp();
$ebsDay        =getDayTimewarp();
$ebsHour       =getHourTimewarp();
}
if(/^CONFUPDATE EBS.DATA NUMROPS /)
{
$input=~s/CONFUPDATE EBS.DATA NUMROPS //;
$numRops      =$input;
}
if(/^CONFUPDATE EBS.DATA YEAR /)
{
$input=~s/CONFUPDATE EBS.DATA YEAR //;
$ebsYear      =$input;
}
if(/^CONFUPDATE EBS.DATA MONTH /)
{
$input=~s/CONFUPDATE EBS.DATA MONTH //;
$ebsMonth      =$input;
}
if(/^CONFUPDATE EBS.DATA DAY /)
{
$input=~s/CONFUPDATE EBS.DATA DAY //;
$ebsDay      =$input;
}
if(/^CONFUPDATE EBS.DATA HOUR /)
{
$input=~s/CONFUPDATE EBS.DATA HOUR //;
$ebsHour      =$input;
}
if(/^CONFUPDATE EBS.DATA MINUTE /)
{
$input=~s/CONFUPDATE EBS.DATA MINUTE //;
$ebsMin       =$input;
}
if(/^CONFUPDATE EBS.DATA SECOND /)
{
$input=~s/CONFUPDATE EBS.DATA SECOND //;
$ebsSeconds      =$input;
}
if(/^CONFUPDATE EBS.DATA USEGZIP /)
{
$input=~s/CONFUPDATE EBS.DATA USEGZIP //;
$ebsUseGzip      =lc($input);
}
if(/^CONFUPDATE EBS.DATA NULL_VALUE_EVERY /)
{
$input=~s/CONFUPDATE EBS.DATA NULL_VALUE_EVERY //;
$ebsNullValue      =$input;
}
if(/^CONFUPDATE EBS.DATA EMPTY_VALUE_EVERY /)
{
$input=~s/CONFUPDATE EBS.DATA EMPTY_VALUE_EVERY //;
$ebsEmptyValue      =$input;
}
if(/^EMPTY_MOM /)
{
$input=~s/EMPTY_MOM //;
$momType      =$input;
$emptyMOM="true";
}

#############  NOW DO SOMETHING  ##########
my $DATE=getDate();
   if($engineProcess eq "true")
   {
       my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();

     $result.= "<h2>$DATE ENGINE_PROCESS $epTp $epProcess</h2><br>\n";
	 
     print $DATE;
     print " ENGINE_PROCESS $epTp $epProcess\n";
     my $result1.=engineProcess($epTp,$epProcess);
	 $result.=$result1;
	 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("engineProcess",$report);
	 print "PARTIAL FILE: $file\n";
     $engineProcess                ="false";
   }
   if($chkpart eq "true")
   {
          my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();

     $result.= "<h2>$DATE CHECK_PARTITIONS</h2><br>\n";
     print $DATE;
     print " CHECK_PARTITIONS \n";
     my $result1.=checkPartitioning();
	 	 $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("checkPartitioning",$report);
	 print "PARTIAL FILE: $file\n";
     $chkpart                     ="false";
   }
   if($Reaggregation eq "true") 
   {
   
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE REAGGREGATION</h2><br>\n";
     print $DATE;
     print " REAGGREGATION \n";
     my $result1.=Reaggregation($level);
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("Reaggregation",$report);
	 print "PARTIAL FILE: $file\n";
	 
    $Reaggregation                     ="false";
   }
   if($SystemStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SYSTEMSTATUS</h2><br>\n";
     print $DATE;
     print " SYSTEMSTATUS \n";
     my $result1.=SystemStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SYSTEMSTATUS",$report);
	 print "PARTIAL FILE: $file\n"; 
   $SystemStatus                      ="false";
   }
   if($DwhStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE DWHDBSTATUS</h2><br>\n";
     print $DATE;
     print " DWHDBSTATUS \n";
     my $result1.=DwhStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DWHSTATUS",$report);
	 print "PARTIAL FILE: $file\n"; 
   $DwhStatus                         ="false";
   }
   if($RepStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE REPDBSTATUS</h2><br>\n";
     print $DATE;
     print " REPDBSTATUS \n";
     my $result1.=RepStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("REPSTATUS",$report);
	 print "PARTIAL FILE: $file\n"; 
   $RepStatus                         ="false";
   }
   if($EngineStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE ENGINESTATUS</h2><br>\n";
     print $DATE;
     print " ENGINESTATUS \n";
     my $result1.=EngineStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ENGINESTATUS",$report);
	 print "PARTIAL FILE: $file\n"; 
   $EngineStatus                      ="false";
   }
   if($SchedulerStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SCHEDULERSTATUS</h2><br>\n";
     print $DATE;
     print " SCHEDULERSTATUS \n";
     my $result1.=SchedulerStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SCHEDULERSTATUS",$report);
	 print "PARTIAL FILE: $file\n";
   $SchedulerStatus                    ="false";
   }
   if($LicservStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE LICSERVSTATUS</h2><br>\n";
     print $DATE;
     print " LICSERVSTATUS \n";
     my $result1.=LicservStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LICSERVSTATUS",$report);
	 print "PARTIAL FILE: $file\n";
   $LicservStatus                     ="false";
   }
   if($LicmgrStatus eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE LICMGRSTATUS</h2><br>\n";
     print $DATE;
     print " LICMGRSTATUS \n";
     my $result1.=LicmgrStatus();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LICMGRSTATUS",$report);
	 print "PARTIAL FILE: $file\n";
   $LicmgrStatus                      ="false";
   }
   if($SessionLogs eq "true") 
   {    
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SESSIONLOGS</h2><br>\n";
     print $DATE;
     print " SESSIONLOGS \n";
     my $result1.=SessionLogs();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SESSIONLOGS",$report);
	 print "PARTIAL FILE: $file\n"; 
   $SessionLogs                       ="false";
   }
   if($DataRowInfo eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE DATAROWINFO</h2><br>\n";
     print $DATE;
     print " DATAROWINFO \n";
     my $result1.=DataRowInfo();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DATAROWINFO",$report);
	 print "PARTIAL FILE: $file\n"; 
   $DataRowInfo                       ="false";
   }
   if($ShowRefTables eq "true") 
   {    
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SHOWREFTABLES</h2><br>\n";
     print $DATE;
     print " SHOWREFTABLES \n";
     my $result1.=ShowRefTables();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SHOWREFTABLES",$report);
	 print "PARTIAL FILE: $file\n"; 
   $ShowRefTables                     ="false";
   }
   if($RankBh eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE RANKBH</h2><br>\n";
     print $DATE;
     print " RANKBH\n";
     my $result1.=RankBh();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("RANKBH",$report);
	 print "PARTIAL FILE: $file\n"; 
	 $RankBh                            ="false";
   }
   if($MonitoringRules eq "true") 
   {     
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE MONITORINGRULES</h2><br>\n";
     print $DATE;
     print " MONITORINGRULES\n";
     my $result1.=MonitoringRules();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("MONITORINGRULES",$report);
	 print "PARTIAL FILE: $file\n"; 
     $MonitoringRules                   ="false";
   }
   if($TypeConfig eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE TYPECONFIG</h2><br>\n";
     print $DATE;
     print " TYPECONFIG\n";
     my $result1.=TypeConfig();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("TYPECONFIG",$report);
	 print "PARTIAL FILE: $file\n"; 
   $TypeConfig                        ="false";
   }
   if($DWHConfig eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE DWHCONFIG</h2><br>\n";
     print $DATE;
     print " DWHCONFIG/\n";
     my $result1.=DWHConfig();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DWHCONFIG",$report);
	 print "PARTIAL FILE: $file\n";

   $DWHConfig                         ="false";
   }
   if($VerifyDirectories eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE VERIFY_DIRECTORIES</h2><br>\n";
     print $DATE;
     print " VERIFY_DIRECTORIES\n";
     my $result1.=VerifyDirectories();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFY_DIRECTORIES",$report);
	 print "PARTIAL FILE: $file\n";
   $VerifyDirectories                 ="false";
   }
   if($VerifyAdminScripts eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE VERIFY_ADMIN_SCRIPTS</h2><br>\n";
     print $DATE;
     print " VERIFY_ADMIN_SCRIPTS\n";
     my $result1.=VerifyAdminScripts();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFY_ADMIN_SCRIPTS",$report);
	 print "PARTIAL FILE: $file\n";
   $VerifyAdminScripts                ="false";
   }
    if($CreateSnapshots eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE Create_Snapshots</h2><br>\n";
     print $DATE;
     print " Create_Snapshots\n";
     my $result1.=CreateSnapshots();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("Create_Snapshots",$report);
	 print "PARTIAL FILE: $file\n";
   $CreateSnapshots               ="false";
   }
   
    if($CreateRackSnapshots eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE Create_Rack_Snapshots</h2><br>\n";
     print $DATE;
     print " Create_Rack_Snapshots\n";
     my $result1.=CreateRackSnapshots();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("Create_Snapshots",$report);
	 print "PARTIAL FILE: $file\n";
   $CreateRackSnapshots               ="false";
   }
   if($eniqVersion eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE ENIQVERSION</h2><br>\n";
     print $DATE;
     print " ENIQVERSION\n";
     my $result1.=eniqVersion();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ENIQVERSION",$report);
	 print "PARTIAL FILE: $file\n";
   $eniqVersion                       ="false";
   }
   if($DiskSpace eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE DISKSPACE</h2><br>\n";
     print $DATE;
     print " DISKSPACE\n";
     my $result1.=DiskSpace();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DISKSPACE",$report);
	 print "PARTIAL FILE: $file\n";
   $DiskSpace                         ="false";
   }
   if($InstalledModules eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE INSTALLED_MODULES ADMINUI</h2><br>\n";
     print $DATE;
     print " INSTALLED_MODULES ADMINUI\n";
     my $result1.=InstalledModules();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("INSTALLED_MODULES",$report);
	 print "PARTIAL FILE: $file\n";
   $InstalledModules                  ="false";
   }
   if($InstalledTps eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE INSTALLED_TPS IN ADMINUI</h2><br>\n";
     print $DATE;
     print " INSTALLED_TPS\n";
     my $result1.=InstalledTps();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("INSTALLED_TPS",$report);
	 print "PARTIAL FILE: $file\n";
   $InstalledTps                      ="false";
   }
   if($ActiveProcs eq "true") 
   {
       my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime(); 
     $result.= "<h2>$DATE ACTIVE_PROCS</h2><br>\n";
     print $DATE;
     print " ACTIVE_PROCS\n";
     my $result1.=ActiveProcs();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ACTIVE_PROCS",$report);
	 print "PARTIAL FILE: $file\n";
   $ActiveProcs                       ="false";
   }
   if($LoggingInfo eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_INFO</h2><br>\n";
     print $DATE;
     print " LOGGING_INFO\n";
     $result.=LoggingInfo();
   $LoggingInfo                       ="false";
   }
   if($LoggingSevere eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_SEVERE</h2><br>\n";
     print $DATE;
     print " LOGGING_SEVERE\n";
     $result.=LoggingSevere();
   $LoggingSevere                     ="false";
   }
   if($LoggingWarning eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_WARNING</h2><br>\n";
     print $DATE;
     print " LOGGING_WARNING\n";
     $result.=LoggingWarning();
   $LoggingWarning                    ="false";
   }
   if($LoggingConfig eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_CONFIG</h2><br>\n";
     print $DATE;
     print " LOGGING_CONFIG\n";
     $result.=LoggingConfig();
   $LoggingConfig                     ="false";
   }
   if($LoggingFine eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_FINE</h2><br>\n";
     print $DATE;
     print " LOGGING_FINE \n";
     $result.=LoggingFine();
   $LoggingFine                       ="false";
   }
   if($LoggingFiner eq "true" ) 
   {
     $result.= "<h2>$DATE LOGGING_FINER</h2><br>\n";
     print $DATE;
     print " LOGGING_FINER\n";
     $result.=LoggingFiner();
   $LoggingFiner                      ="false";
   }
   if($LoggingFinest eq "true") 
   {
     $result.= "<h2>$DATE LOGGING_FINEST</h2><br>\n";
     print $DATE;
     print " LOGGING_FINEST \n";
     $result.=LoggingFinest();
   $LoggingFinest                     ="false";
   }
   if($NegEngine eq "true") 
   {
     $result.= "<h2>$DATE NEG_ENGINE</h2><br>\n";
     print $DATE;
     print " NEG_ENGINE \n";
     $result.=NegEngine();
   $NegEngine                         ="false";
   }
   if($NegScheduler eq "true") 
   {
     $result.= "<h2>$DATE NEG_SCHEDULER</h2><br>\n";
     print $DATE;
     print " NEG_SCHEDULER \n";
     $result.=NegScheduler();
   $NegScheduler                      ="false";
   }
   if($NegLicMgr eq "true") 
   {
     $result.= "<h2>$DATE NEG_LICMGR</h2><br>\n";
     print $DATE;
     print " NEG_LICMGR \n";
     $result.=NegLicMgr();
   $NegLicMgr                         ="false";
   }
   if($MaxUsersAdminui eq "true") 
   {
     $result.= "<h2>$DATE MAX_USERS_ADMINUI</h2><br>\n";
     print $DATE;
     print " MAX_USERS_ADMINUI \n";
     $result.=MaxUsersAdminui();
   $MaxUsersAdminui                   ="false";
   }
   if($wrongUser eq "true") 
   {
     $result.= "<h2>$DATE ADMINUI_WRONG_USER</h2><br>\n";
     print $DATE;
     print " ADMINUI_WRONG_USER \n";
     $result.=wrongUser();
   $wrongUser                      ="false";
   }
   if($UnvInstallWithoutLogin eq "true") 
   {
     $result.= "<h2>$DATE UNV_INSTALL_WITHOUT_LOGIN</h2><br>\n";
     print $DATE;
     print " UNV_INSTALL_WITHOUT_LOGIN \n";
     $result.=UnvInstallWithoutLogin();
   $UnvInstallWithoutLogin            ="false";
   }
   if($ShowLoadingFutureDates eq "true") 
   {
     $result.= "<h2>$DATE SHOW_LOADING_FUTURE_DATES</h2><br>\n";
     print $DATE;
     print " SHOW_LOADING_FUTURE_DATES \n";
     $result.=ShowLoadingFutureDates();
   $ShowLoadingFutureDates            ="false";
   }
   if($ETLCSchedule  eq "true") 
   {
     $result.= "<h2>$DATE ETLC_SCHEDULE</h2><br>\n";
     print $DATE;
     print " ETLC_SCHEDULE \n";
     $result.=ETLCSchedule();
   $ETLCSchedule                      ="false";
   }
   if($ETLCMonitoring eq "true") 
   {
     $result.= "<h2>$DATE ETLC_MONITORING</h2><br>\n";
     print $DATE;
     print " ETLC_MONITORING \n";
     $result.=ETLCMonitoring();
   $ETLCMonitoring                    ="false";
   }
   if($ETLCHistory eq "true") 
   {
     $result.= "<h2>$DATE ETLC_HISTORY</h2><br>\n";
     print $DATE;
     print " ETLC_HISTORY \n";
     $result.=ETLCHistory();
   $ETLCHistory                       ="false";
   }
   if($ShowAggFutureDates eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SHOW_AGG_FUTURE_DATES</h2><br>\n";
     print $DATE;
     print " SHOW_AGG_FUTURE_DATES \n";
     my $result1.=ShowAggFutureDates();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SHOW_AGG_FUTURE_DATES",$report);
	 print "PARTIAL FILE: $file\n";
   $ShowAggFutureDates                ="false";
   }
   if($ShowProblematic eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE SHOW_PROBLEMATIC</h2><br>\n";
     print $DATE;
     print " SHOW_PROBLEMATIC \n";
     my $result1.=ShowProblematic();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SHOW_PROBLEMATIC",$report);
	 print "PARTIAL FILE: $file\n";
   $ShowProblematic                   ="false";
   }
   if($LicMgrDownShowLicenses eq "true") 
   {
     $result.= "<h2>$DATE LICMGR_DOWN_SHOWLIC</h2><br>\n";
     print $DATE;
     print " LICMGR_DOWN_SHOWLIC \n";
     $result.=LicMgrDownShowLicenses();
   $LicMgrDownShowLicenses            ="false";
   }
   if($LicServDownShowLicenses eq "true") 
   {
     $result.= "<h2>$DATE LICSERV_DOWN_SHOWLIC</h2><br>\n";
     print $DATE;
     print " LICSERV_DOWN_SHOWLIC \n";
     $result.=LicServDownShowLicenses();
   $LicServDownShowLicenses           ="false";
   }
   if($LicMgrDownRestartEngine eq "true") 
   {
     $result.= "<h2>$DATE LICMGR_DOWN_RESTART_ENGINE</h2><br>\n";
     print $DATE;
     print " LICMGR_DOWN_RESTART_ENGINE \n";
     $result.=LicMgrDownRestartEngine();
   $LicMgrDownRestartEngine           ="false";
   }
   if($LicMgrDownRestartScheduler eq "true") 
   {
     $result.= "<h2>$DATE LICSERV_DOWN_RESTART_ENGINE</h2><br>\n";
     print $DATE;
     print " LICSERV_DOWN_RESTART_ENGINE \n";
     $result.=LicMgrDownRestartScheduler();
   $LicMgrDownRestartScheduler        ="false";
   }
   if($LicServDownRestartEngine eq "true") 
   {
     $result.= "<h2>$DATE LICMGR_DOWN_RESTART_SCHEDULER</h2><br>\n";
     print $DATE;
     print " LICMGR_DOWN_RESTART_SCHEDULER \n";
     $result.=LicServDownRestartEngine();
   $LicServDownRestartEngine          ="false";
   }
   if($LicServDownRestartScheduler eq "true") 
   {
     $result.= "<h2>$DATE LICSERV_DOWN_RESTART_SCHEDULER</h2><br>\n";
     print $DATE;
     print " LICSERV_DOWN_RESTART_SCHEDULER \n";
     $result.=LicServDownRestartScheduler();
   $LicServDownRestartScheduler       ="false";
   }


if($emptyMOM        eq   "true")
{
  $result.= "<h2>LOAD EMPTY MOM EBS$momType</h2><br>\n";
  print $DATE;
  print " EMPTY_MOM EBS$momType \n";
  $result.=emptyMOM($momType);
  $emptyMOM="false";
}


if($addAlarmReport         eq   "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
  $result.= "<h2>ADD ALARM REPORT $addAlarmMinutes  TO ALARMCFG</h2><br>\n";
  print $DATE;
  print " ALARMCFG $addAlarmMinutes\n";
  my $result1.=addAlarmReport($addAlarmMinutes);
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ALARMCFG",$report);
	 print "PARTIAL FILE: $file\n"; 
  $addAlarmReport="false";
}

## BUSYHOUR
if($busyhour         eq   "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
  $result.= "<h2>$DATE BUSYHOUR</h2><br>\n";
  print $DATE;
  print " BUSYHOUR\n";
  my $result1.=busyhour();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("BUSYHOUR",$report);
	 print "PARTIAL FILE: $file\n"; 
  $busyhour="false";
}
if($resizedb          eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
  $result.= "<h2>$DATE RESIZE DB</h2>";
  print $DATE;
  print " RESIZEDB\n";
  my $result1.=editNIQ();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("RESIZEDB",$report);
	 print "PARTIAL FILE: $file\n";
  $resizedb="false";
}
if($help              eq "true")
{   
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
  $result.= "<h2>$DATE VERIFY HELP LINKS</h2>";
  print $DATE;
  print " VERIFY HELP LINKS\n";
  my $result1.=help();
         $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("HELP",$report);
	 print "PARTIAL FILE: $file\n"; 
  $help="false";
}
if($pre               eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
 $result.= "<h2>$DATE PRE TEST</h2>";
  print $DATE;
  print " PRE TEST\n";
  my $result1.=pre();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("PRETEST",$report);
	 print "PARTIAL FILE: $file\n"; 
  $pre="false";
}
if($compareBaseline  eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
        $report.= getTime();
$result.= "<h2>$DATE COMPARE BASELINE</h2>";
print $DATE;
print " COMPARE BASELINE\n";
my $result1.=compareBaselineModules($baselinePath);
my $result2.=compareBaselineTechpacks($baselinePath);
my $result3.=compareBaselineInterfaces($baselinePath);
       $result.=$result1;
	 $result.=$result2;
       $result.=$result3; 
	 $report.= $result1;
	 $report.= $result2;
       $report.= $result3;
      $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("COMPAREBASELINE",$report);
	 print "PARTIAL FILE: $file\n"; 
$compareBaseline="false";
}

if($verifyLogs        eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE LOG VERIFICATION</h2><br>";
print $DATE;
print " LOG VERIFICATION\n";
my $result1.=verifyLogs();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYLOGS",$report);
	 print "PARTIAL FILE: $file\n";
$verifyLogs="false"; 
}
if($verifyTables      eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE TABLE VERIFICATION</h2><br>\n";
print $DATE;
print " TABLE VERIFICATION\n";
my $result1.=verifyTables();
$result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYTABLES",$report);
	 print "PARTIAL FILE: $file\n";
$verifyTables="false"; 
}
if($verifyExes        eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE FIND WRONG EXEs(DOS style)</h2><br>\n";
print $DATE;
print " FIND WRONG EXEs(DOS style)\n";
my $result1.=verifyExecutables();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYEXECUTABLES",$report);
	 print "PARTIAL FILE: $file\n"; 
$verifyExes="false"; 
}
if($engine           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE ENGINE CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE ENGINE CMD LINE TESTS\n";
my $result1.=runEngine();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ENGINECLI",$report);
	 print "PARTIAL FILE: $file\n"; 
$engine="false";
}
if($webserver           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE WEBSERVER CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE WEBSERVER CMD LINE TESTS\n";
my $result1.=runWebserver();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("WEBSERVERCLI",$report);
	 print "PARTIAL FILE: $file\n"; 
$webserver="false";
}
if($scheduler           eq "true")
{   
     my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE SCHEDULER CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE SCHEDULER CMD LINE TESTS\n";
my $result1.=runScheduler();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SCHEDULERCLI",$report);
	 print "PARTIAL FILE: $file\n"; 
$scheduler="false";
}
if($licmgr           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE LICENSE MANAGER CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE LICENSE MANAGER CMD LINE TESTS\n";
my $result1.=runLicenseManager();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LICENSECLI",$report);
	 print "PARTIAL FILE: $file\n";
$licmgr="false";
}
if($licserv           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE LICENSE SERVER CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE LICENSE SERVER CMD LINE TESTS\n";
my $result1.=runLicserv();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LICENSESERVERCLI",$report);
	 print "PARTIAL FILE: $file\n";
$licserv="false";
}
if($dwhdb           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE DWHDB CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE DWHDB CMD LINE TESTS\n";
my $result1.=runDwhdb();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DWHDBCLI",$report);
	 print "PARTIAL FILE: $file\n"; 
$dwhdb="false";
}
if($repdb           eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE REPDB CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE REPDB CMD LINE TESTS\n";
my $result1.=runRepdb();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("REPDBCLI",$report);
	 print "PARTIAL FILE: $file\n";
$repdb="false";
}
if($runCMDLine        eq "true")
{
     my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE EXECUTE CMD LINE TESTS</h2><br>\n";
print $DATE;
print " EXECUTE CMD LINE TESTS\n";
my $result1.=runCMDLineNP();
my $result2.=runCMDLineComplete();
     $result.=$result1;
	 $result.=$result2;
		 $report.= $result1;
		 $report.= $result2;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("CMDLINE",$report);
	 print "PARTIAL FILE: $file\n"; 
$runCMDLine="false";
}
if($dataGeneration eq "true")
{
# PARAMETERS READ FROM INPUT FILE
$result.= "<h2>$DATE EXECUTE DATA GENERATION</h2><br>\n";
print $DATE;
print " EXECUTE DATA GENERATION\n";
$result.= "TIMEUPDATE = $timeUpdate<br>\n";
$result.= "TIMEWARP   = $timeWarp<br>\n";
$result.= "NUMROPS    = $numRops<br>\n";
$result.= "TECHPACKS :<br>\n";
foreach my $techpack (@techPacks) 
{
  $result.= "	$techpack\n";
}
$result.= "<br>\n";
$result.=dataGeneration();
$dataGeneration="false";  
}
if($epfgdataGeneration eq "true")
{
# PARAMETERS READ FROM INPUT FILE
$result.= "<h2>$DATE EXECUTE DATA GENERATION</h2><br>\n";
print $DATE;
print " EXECUTE DATA GENERATION\n";
$result.= "START_TIME = $epfgstarttime<br>\n";
$result.= "STOP_TIME   = $epfgstoptime<br>\n";
$result.= "TECHPACKS :<br>\n";
$result.=epfgdataGeneration();
$epfgdataGeneration="false";  
}
if($preLoad            eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE PRE_LOAD RUNS SETS TO LOAD DATA</h2>";
print $DATE;
print " PRE_LOAD RUNS SETS TO LOAD DATA\n";
my $result1.=preLoad();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("PRE_LOAD",$report);
	 print "PARTIAL FILE: $file\n"; 
$preLoad="false";
}

if($loadTopology   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE LOAD TOPOLOGY</h2><br>\n";
print $DATE;
print " LOAD TOPOLOGY\n";
my $result1.=loadTopology();
my $result2.=verifyTopology();
     $result.=$result1;
	 $result.=$result2;
		 $report.= $result1;
		 $report.= $result2;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LOADTOPOLOGY",$report);
	 print "PARTIAL FILE: $file\n";
$loadTopology="false";
}
if($verifyDAYBH   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE DAYBH TABLES LOADING</h2><br>\n";
print $DATE;
print "DAYBH TABLES LOADING \n";
my $result1.=verifyDayBH();
     $result.=$result1;
	 	 $report.= $result1;
		 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DAYBH",$report);
	 print "PARTIAL FILE: $file\n";
$verifyDAYBH="false";
}

if($verifyRANKBH   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE RANKBH TABLES LOADING</h2><br>\n";
print $DATE;
print "RANKBH TABLES LOADING \n";
my $result1.=verifyRANKBH();
     $result.=$result1;
	 	 $report.= $result1;
		 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("RANKBH",$report);
	 print "PARTIAL FILE: $file\n";
$verifyRANKBH="false";
}
if($epfgloadTopology   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE LOAD TOPOLOGY</h2><br>\n";
print $DATE;
print " LOAD TOPOLOGY\n";
my $result1.=epfgloadTopology();
my $result2.=verifyTopology();
     $result.=$result1;
	 $result.=$result2;
		 $report.= $result1;
		 $report.= $result2;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LOADTOPOLOGY",$report);
	 print "PARTIAL FILE: $file\n";
$epfgloadTopology="false";
}

if($updateTopology   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE LOAD TOPOLOGY UPDATE</h2><br>\n";
print $DATE;
print " LOAD TOPOLOGY UPDATE\n";
my $result1.=loadTopologyUpdate();
my $result2.=verifyTopology();
          $result.=$result1;
	 $result.=$result2;
		 $report.= $result1;
		 $report.= $result2;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LOADTOPOLOGYUPDATE",$report);

$updateTopology="false";
}
if($epfgupdateTopology   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE LOAD TOPOLOGY UPDATE</h2><br>\n";
print $DATE;
print " LOAD TOPOLOGY UPDATE\n";
my $result1.=epfgupdateTopology();
my $result2.=verifyTopology();
          $result.=$result1;
	 $result.=$result2;
		 $report.= $result1;
		 $report.= $result2;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("LOADTOPOLOGYUPDATE",$report);

$epfgupdateTopology="false";
}
if($verifyUniverses   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE VERIFY UNIVERSES EXIST</h2><br>\n";
print $DATE;
print " VERIFY UNIVERSES EXIST\n";
my $result1.=verifyUniverses();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYUNIVERSES",$report);
	 print "PARTIAL FILE: $file\n";
$verifyUniverses="false";
}
if($verifyBOReports   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE VERIFY BO REPORTS EXIST</h2><br>\n";
print $DATE;
print " VERIFY BO REPORTS EXIST\n";
my $result1.=verifyBOReports();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYBOREPORTS",$report);
	 print "PARTIAL FILE: $file\n";
$verifyBOReports="false";
}
if($runBOReports   eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime(); 
$result.= "<h2>$DATE RUN BO REPORTS</h2><br>\n";
print $DATE;
print " RUN BO REPORTS\n";
my $result1.=runBOsql();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("RUNBOREPORTS",$report);
	 print "PARTIAL FILE: $file\n";
$runBOReports="false";
}
if($verifyAlarms      eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime(); 
$result.= "<h2>$DATE VERIFY ALARM REPORT EXIST</h2><br>\n";
print $DATE;
print " VERIFY ALARM REPORT EXIST\n";
my $result1.=verifyAlarmReports();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYALARMREPORT",$report);
	 print "PARTIAL FILE: $file\n";
$verifyAlarms="false";
}
if($configWebportal      eq "true")
{
$result.= "<h2>$DATE CONFIGURE WEBPORTAL FOR ALARMS </h2><br>\n";
print $DATE;
print " CONFIGURE WEBPORTAL FOR ALARMS \n";
$result.=configWebportal($webportal);
$configWebportal="false";
}
if($loadEbs   eq "w" || $loadEbs   eq "g" || $loadEbs   eq "s" )
{
my $ebsType=uc($loadEbs);
$result.= "<h2>$DATE LOAD DATA EBS$ebsType</h2><br>\n";
print $DATE;
print " LOAD DATA EBS$ebsType\n";
$result.= "EBSBUILD         : $ebsBuild          <br>\n";
$result.= "EBSREFCOUNTER    : $ebsRefCounter     <br>\n";
$result.= "EBSCOUNTERGROUP  : $ebsCounterGroup   <br>\n";
$result.= "YEAR             : $ebsYear           <br>\n";
$result.= "MONTH            : $ebsMonth          <br>\n";
$result.= "DAY              : $ebsDay            <br>\n";
$result.= "HOUR             : $ebsHour           <br>\n";
#$result.= "MINUTE           : $ebsMinute         <br>\n";
#$result.= "SECONDS          : $ebsSeconds        <br>\n";
$result.= "USEZIP           : $ebsUseGzip        <br>\n";
$result.= "NULLVALUE        : $ebsNullValue      <br>\n";
$result.= "EMPTYVALUE       : $ebsEmptyValue     <br>\n";

$result.=loadEbs();
$loadEbs="false";
}
if($testEbs   eq "w" || $testEbs   eq "g" || $testEbs   eq "s" )
{
my $ebsType=uc($testEbs);
$result.= "<h2>$DATE CREATE MOM EBS$ebsType</h2><br>\n";
print $DATE;
print " CREATE MOM EBS$ebsType\n";
$result.=testEbs();
$testEbs="false";
}
if($verifyLoadings      eq "true")
{
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
$result.= "<h2>$DATE VERIFY DATA LOADING</h2><br>\n";
print $DATE;
print " VERIFY DATA LOADING\n";
my $result1.=verifyLoadings();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYDATALOADING",$report);
	 print "PARTIAL FILE: $file\n";
$verifyLoadings="false";
}
if($verifyAggregations      eq "true")
{
    my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();   
$result.= "<h2>VERIFY DATA AGGREGATIONS</h2><br>\n";
print $DATE;
print " VERIFY DATA AGGREGATIONS\n";
my $result1.=verifyAggregations();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYDATAAGGREGATIONS",$report);
	 print "PARTIAL FILE: $file\n";
$verifyAggregations="false";
}



}
return $result;
}


############################################################
# GET HOST NAME
# This is a utility to get the host name
sub getHostName{
open(HOST,"hostname |");
my @host=<HOST>;
chomp(@host);
close(HOST);
return $host[0];
}
############################################################
# VERIFY THE INSTALLED VERSION
# This is a utility to get the version from the eniq_status file
sub verifyVersion{
my $version="";
open(VER,"cat /eniq/admin/version/eniq_status |");
my @version=<VER>;
close(VER);
foreach my $ver (@version)
{ 
$version.=$ver;
}
return $version;
}
############################################################
# PRE TEST, CHECKS THE inDIR: THE DIRECTORIES FOR ALL ETLS 
# This is a very simple test, just runs the query below and lists 
# the results in a table
# The table represents each entry for the inDir directory for all techpacks and 
# interfaces
# This means each techpack and interface should have an entry directory
# I believe in the past there were faults related with missing paths,
# if a path is missing the row is failed.
sub pre{
my $result="";
my $sql=qq{
SELECT c.collection_set_name||"|"|| 
SUBSTRING(action_contents_01,
  CHARINDEX('inDir=', action_contents_01),
  CHARINDEX('interfaceName=', 
  SUBSTRING(action_contents_01, CHARINDEX('inDir=', action_contents_01)))-2
) 
FROM 
etlrep.meta_transfer_actions a 
JOIN etlrep.meta_collections b 
ON (   a.version_number = b.version_number 
AND a.collection_id = b.collection_id 
AND a.collection_set_id = b.collection_set_id) 
JOIN etlrep.meta_collection_sets c 
ON (   b.version_number = c.version_number 
AND b.collection_set_id = c.collection_set_id) 
WHERE 
action_type = 'Parse' AND c.enabled_flag = 'Y'
order BY 1;
go
EOF
};
my @result=undef;
open(TABLES,"$sybase_dir -Uetlrep -Petlrep -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
my @tables=<TABLES>;
chomp(@tables);
close(TABLES);
$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
<tr>
<th>INTERFACE</th>
<th>DIRECTORY</th>
<th>RESULT</th>
</tr>
};

foreach my $tables (@tables)
 {
   $_=$tables;
   my $status="";
   next if(/parser.header/);
   next if(/affected/);
   next if(/^$/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
 
   print $tables;
   
   if(($tables=~/^INTF/)||($tables=~/^Alarm/)||($tables=~/^DC_Z_/))
   {
    if(/AlarmInterfaces/ && 
      /inDir=\$\{PMDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/AlarmInterfaces/ && 
         /inDir=\${PMDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
    }
    elsif(/INTF_/ && 
         /-eniq_oss_1/ && 
         /inDir=\$\{PMDATA_DIR\}\/eniq_oss_1\//)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/INTF_/ && 
          !/-eniq_oss_1/ && 
          /inDir=\$\{PMDATA_DIR\}\/\$\{OSS\}\//)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
	elsif(/DC_Z_/ && 
      /inDir=\$\{PMDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/DC_Z_/ && 
         /inDir=\${PMDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
    }
    else
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "	FAIL\n";
    }

    $tables=~ s/\t//g;
    $tables=~ s/\s//g;
    $tables=~ s/^/<tr><td>/g;
    $tables=~ s/\|/<\/td><td>/g;
    $tables=~ s/$/<\/td>$status<\/tr>/g;
    $result.= "$tables\n";
  }
 }
 $result.= "</table>";
 return $result;

}
############################################################
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# This is a utility
# needs one parameter, the techpacks name
# it gets all the tables for that techpack
sub getAllTables4TP{
my $tp = shift;
   $tp=~ s/ //g;
my $sql=qq{
select 
    A.Table_name
from 
    SYSTABLE  A
where 
    A.table_type like 'VIEW' 
and A.Table_Name LIKE ('$tp%')
and A.creator=103;
go
EOF
};
 my @result=undef;
 open(ALLTP,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @allTechPacksTables=<ALLTP>;
 chomp(@allTechPacksTables);
 close(ALLTP);
 foreach my $t (@allTechPacksTables)
  {
    $_=$t;
    next if(/affected/);
    next if(/^$/);
    $t=~ s/\t//g;
    $t=~ s/\s//g;
    $t=~ s/ //g;
    push @result,$t;
  } 
 return @result;
}
############################################################
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# this is a utility subroutine
# queries the database to check the loading 
# the input parameter is a table name
sub getLoading{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();
my $sql=qq{
select 
     '$table'||'|'||  
     COUNT(*) as COUNT
from $table          
where CONVERT(CHAR(8),DATE_ID,112) = '$date' ;
go
EOF
};
 my @result=undef;
 open(DATA,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @data=<DATA>;
 chomp(@data);
 close(data);
 push @result,$data[0];
 return @result;
}
############################################################
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# This is a utility subroutine 
# queries the db for a certain table and counts the rows
# the input param is the table name
sub getTopologyLoading{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();
my $sql=qq{
select
 '$table'||'|'||
 COUNT(*) as COUNT
from $table;
go
EOF
};
 my @result=undef;
 open(DATA,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @data=<DATA>;
 chomp(@data);
 close(data);
 push @result,$data[0];
 return @result;
}
############################################################
# RUNS A QUERY TO GET ALL TABLES, ALL COLUMNS AND DATATYPES
# This is a utility subroutine
# This is one of the most expensive processes in regression
# runs a query and gets all tables and columns
# is not used in any test, is legacy
sub verifyTables{
 my $result="";
 my$sql=qq{
select 
    A.Table_name||'|'||
    B.column_name||'|'||
       (Select domain_name 
       from SYSDOMAIN 
       where domain_id = B.domain_id) ||'|'||
        B.width ||'|'||
       (CASE Pkey
        when 'Y' then 'YES'
        else NULL
        END) 
from 
    SYSTABLE  A, 
    SYSCOLUMN B
where  
    B.table_id = A.table_id 
and A.Table_Name NOT LIKE ('SYS%')
and A.table_type like 'VIEW'
and A.Table_name like 'D%_E_%'
and A.creator=103
order by 
    Table_Name, 
    column_id;
go
EOF
};
 my @result=undef;
 open(TABLES,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @tables=<TABLES>;
 chomp(@tables);
 close(TABLES);
   $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>NAME</th>
     <th>COLUMN</th>
     <th>TYPE</th>
     <th>SIZE</th>
   </tr>
};

 foreach my $tables (@tables)
 {
   $_=$tables;
   next if(/affected/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
   $tables=~ s/^/<tr><td>/g;
   $tables=~ s/\|/<\/td><td>/g;
   $tables=~ s/$/<\/td><tr>/g;
   $result.= "$tables\n";
 } 
 $result.= "</table>";
 return $result;
}
############################################################
# VERIFIES ALL EXECUTABLES ARE OK
# This is test to check that all scripts in the bin directories are executable
# This test catches scripts ending in hat-M
sub verifyExecutables{
my $result="";
my $count=0;
open(LIST,"file /eniq/sw/bin/* /eniq/admin/bin/* /eniq/bkup_sw/bin/* |");
my @list=<LIST>;
close(LIST);

chomp(@list);
foreach my $list (grep(/executable/, @list))
  {
    $_=$list;
    $list=~s/:.*executable.*//;
    open(EXE,"egrep -l \$'\r\n' $list |");
    my @exe=<EXE>;
    foreach my $exe (@exe)
      {
           $result.= "<font color=#ff0000><b>ERROR: EXE file with DOS format: $exe</b></font><br>\n";
           $count++;
      }
    close(EXE);
  }
   if($count>0)
   {
         $result.= "<font color=#ff0000><b>FAIL</b></font><br>\n";
   }
   else
   {
         $result.= "<font color=#006600><b>PASS</b></font><br>\n";
   }
   return $result;
}

############################################################
# This is a utility subroutine
# just to check
# if the /eniq/sw/log has files
sub hasSwLog{
  open(SWLOG,"ls -altr  /eniq/sw/log | wc -l | ");
  my @swlog=<SWLOG>;
  close(SWLOG);
  return $swlog[0];
}
#############################################################
# METHOD TO GREP ALL THE LOGS AND OUTPUT THE ERRORS, EXCEPTIONS, WARNINGS, SO ON
# Test to grep all the log directories 
# can take a parameter which is a subdirectory
# This process greps the following patterns: 
#"error",
#"exception",
#"fatal",
#"severe", 
#"warning",
#"not found",
#"cannot",
#"not supported",
#"reactivated",

sub verifyLogs{
 my $subDir=shift;
 my $result="";
`rm /eniq/home/dcuser/egreplist.txt`;
 my @filters=(
"error",
"exception",
"fatal",
"severe", 
"warning",
"not found",
"cannot",
"not supported",
"reactivated",
#";;","null"
); 
 my @result=undef;
 my $logDir="";
 my %monthslist=(
                  "Jan","01",
                  "Feb","02",
                  "Mar","03",
                  "Apr","04",
                  "May","05",
                  "Jun","06",
                  "Jul","07",
                  "Aug","08",
                  "Sep","09",
                  "Oct","10",
			"Nov","11",
                  "Dec","12"
                );
my @server_history;
@server_history = `tail -3 /eniq/admin/version/eniq_history`;
my @inst_info=split(/\s/,$server_history[0]);
my $inst_day=$inst_info[1];
my @month=split('-',$inst_day);
my $year_id=$month[0];
my $inst_month=$monthslist{"$month[1]"};
my @date_time=split('_',$month[2]);
my $date_id=$date_time[0];
my $log_start=$month[1]." ".$date_time[0];
my $log_begin="$year_id"."_"."$inst_month"."_"."$date_id";
print "***************Installed date information in YYYY_MM_DD format $log_begin ********************\n";
my $log_end=`date|cut -c5-10`;
my $current_month=substr($log_end,0,3);
my $month_now=$monthslist{"$current_month"};
my @enddate=split(/\s/,$log_end);
my $end_date=$enddate[1];
my $logend=substr($log_end,4,2);
my $logstart=substr($log_start,4,2);
$logstart=$logstart-'1';
print "******************* LOG_START::: $month[1] $logstart *******************************\n";
my $logend=substr($log_end,4,2);
print "******************* LOG_END  ::: $log_end ******************************\n";
$result.=  "<h3>******* LOG_START  ::: $month[1] $logstart *********</h3>";
$result.=  "<h3>******* LOG_END    ::: $log_end ********</h3>";
sub date_calc{
                my $start_log=shift;
                my $sub_start_log=substr($start_log,1,1);
                if ($start_log=~m/^[0].*/)
                {
                  $_=$start_log;
                  $start_log=~s/$start_log/ $sub_start_log/;
                }
                elsif($start_log=~/^\d{1}$/)
                {
                  $_=$start_log;
                  $start_log=~s/$start_log/ $start_log/;
                }
                else
                {
                 # print "Date information is in required format\n";
                } 
                return $start_log;
            }
#`touch egreplist.txt`;
my $eom="31";
my $bom="01";
my $first_day="01";
if((($month_now - $inst_month)>0) || (($month_now - $inst_month)<0))
{
  my $rem_days_inst=$eom-$logstart;
  my $rem_days_curr=$logend-$bom;
  print "*****************log dates for installation month $rem_days_inst************************\n";
  print "*****************log dates for current month $rem_days_curr *************************\n";
  do
  {
   open (MYFILE, '>>egreplist.txt');
   my $logstart_1=$logstart;
   $logstart=date_calc($logstart_1); 
   print MYFILE "$month[1] $logstart\n"; 
   print "$month[1] $logstart\n";
   $logstart++;
   $rem_days_inst--;
  }while($rem_days_inst>=0);
  do
  {
   my $first_day_1=$first_day;
   $first_day=date_calc($first_day_1);
   print MYFILE "$current_month $first_day\n";
   print "$current_month $first_day\n";
   $first_day++;
   $rem_days_curr--;
  }while($rem_days_curr>=0);
  close (MYFILE);
}
else
{
my $log_diff=$logend-$logstart;
#`touch egreplist.txt`;
 do
 {
   open (MYFILE, '>>egreplist.txt'); 
   my $logstart_1=$logstart;
   $logstart=date_calc($logstart_1);
   print MYFILE "$month[1] $logstart\n"; 
   print "$month[1] $logstart\n";
   $logstart++;
   $log_diff--;
 }while($log_diff>=0);
 close (MYFILE); 
}
 if( hasSwLog()> 4 ) 
  {  
    $logDir="/eniq/sw/log".$subDir;
  }
  else 
  {
    $logDir="/eniq/log/sw_log".$subDir;
  }
 print "$logDir";
 open(LS,"file $logDir/* |");
 my @ls=<LS>;
 close(LS);
 open(LS2,"file $logDir/engine/* |");
 my @ls2=<LS2>;
 close(LS2);
 my @directories=(@ls,@ls2);
 chomp(@directories);
 foreach my $logDirs (@directories)
  {
    $_=$logDirs;
    if(/directory/)
    {
       $logDirs=~s/:.*//;
       $result.=  "<h3>$logDirs</h3>"; 
       open(LS1,"file $logDirs/ |");
       my @files=<LS1>;
       chomp(@files);
       close(LS1);
       foreach my $files (@files)
       {
         $_=$files;
         $files=~s/:.*//;
         my @grep_dates;
         open(DATES,"< /eniq/home/dcuser/egreplist.txt")|| die("Could not open file!");
         @grep_dates=<DATES>;
         close(DATES);
         my $file_exist;
         my $exist=0;
         my $file_count=`ls -ld $files/*|wc -l`; 
         foreach my $grep_dates(@grep_dates) 
         {
           my $file_select =`ls -ld $files/* |egrep '$grep_dates'|wc -l`;
           if ($file_select != 0)
           {
           $exist=1;
           }
         
         } 
         next if ($file_count == 0);  
         next if ($exist != 1);
         `ls -ld $files/* |egrep -f /eniq/home/dcuser/egreplist.txt|awk '{print \$9}' > verifylogs_files.txt`;
         open(VERIFY_LOG,"< /eniq/home/dcuser/verifylogs_files.txt");
         my @verify_log=<VERIFY_LOG>;
         chomp(@verify_log);
         close(VERIFY_LOG);
         my @arr;
         foreach my $filter (@filters)
            {
		     open GREP, "egrep -i \"($filter)\" @verify_log| egrep -v \"(FINEST| succesfully |Partition created|permissions to |.LOG_AggregationStatus_|inflating|_ERROR)\" |  sed \"s/[0-9][0-9].[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] //\" | sed \"s/:[0-9]* /:/\" | sed \"s/[0-9][0-9].[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]. //\" | sed \"s/ 00000..... Exception Thrown/ Exception Thrown/\" | sed \"s/.* O.S Err/ Err/\"  | sort -u | " || print "ERROR: $!\n"; 
             @arr=<GREP>;
             close(GREP);
		      foreach my $arr ( @arr ) 
                {
			     $_=$arr;
                 if(/java.lang.|ASA Error|SEVERE|reactivated/)
                     {
                        $result.=  "<font color=660000><b>$arr</b></font><br>"; 
                        print "FAIL $arr"; 
                     }
                 else
                     {
                        $result.=  "$arr<br>"; 
                        print  "$arr"; 
                     }
                } # FOR LINES FOUND
             $result.=  "\nFILTER : $filter<br>\n";
		    } 
        }#FOR EACH FILES
    } #IF 
  }#FOR EACH DIRECTORY
    

#========================================Added New Options=================================================
  
  push(@filters,'Unknown Source');
  push(@filters,'NoClassDefFoundError');
  #push(@filters,'Executing');                      #Only for testing. If code works Properly make it comment. 
  
  my $new_path="/var/svc/log";
  
  open(LS1,"file $new_path/* | grep eniq |");		#file /var/svc/log/* | grep eniq
  my @files=<LS1>;

  $result.="<br><h2>ERROR LOGS Of SMF SERVICES</h2><br>";
  
  foreach my $files (@files)
  {
       $_=$files;
       
	   $files=~s/:.ascii.*//;
       
	   $result.=  "<h3>$files</h3>"; 
	   
		 foreach my $filter (@filters)
         {
           
		   $_=$filter;
		   
		   next if(/warning/);
		   
		   $result.=  "\nFILTER : $filter<br>\n"; 
           open GREP, "egrep -i \"($filter)\" $files | " || print "ERROR: $!\n"; 
           my @arr=<GREP>;
           close(GREP);
           
		   foreach my $arr ( @arr ) 
           {
                $result.=  "<font color=#FF0000><b>$arr</b></font><br>"; 
				print "FAIL $arr"; 
           } # FOR LINES FOUND
         }# FOR FILTER
  }
  #============================================================================================================
  
   
  
 return $result; 
}
############################################################
# RUNS A FEW COMMANDLINE WITHOUT PARAMS TO CHECK EVERYTHING IS OK
# runs the cli executables to check if they throw exceptions
sub runCMDLineNP{
 my $result="";
 my @result=undef;
 my $binDir="/eniq/sw/bin";
 open(LIST,"file $binDir/* |");
 my @list=<LIST>;
 close(LIST);
 chomp(@list);
 $result=qq{
<h3>RUN CMD LINE WITHOUT PARAMS TO CHECK USAGE EXISTS</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
 };
 foreach my $list (grep(/executable/, @list))
  {
    $_=$list;
      next if(/startDayOfTheWeek.bsh/);
	next if(/updateDIM_WEEKDAY.bsh/);
	next if(/updateDatabase.bsh/);
	next if(/updateLoggAggStatus.bsh/);
	next if(/restore_nvu_techpack.bsh/);
	$list=~s/:.*executable.*//;
    open(EXE,"$list |");
    my @exe=<EXE>;
    close(EXE);
    foreach my $exe (@exe)
      {
           $_=$exe;
           if(/Usage/) 
           {
              $result.= "<tr><td>$list</td><td>$exe</td><td><font color=006600><b>PASS</b></font></td><tr>";
           }
           elsif(/ERROR|Exception/i)
           {
              $result.= "<tr><td>$list</td><td>$exe</td><td><font color=660000><b>FAIL</b></font></td><tr>";
           }
      }
  }
 $result.=qq{</table>}; 
 return $result; 
}
############################################################
# RUNS A MORE COMPLETE CMDLINE FT 
# runs a list for cli commands and checks if they throw an exception, error or fail
sub runCMDLineComplete{
  my $result="";
  my @cmds=(
  "/eniq/sw/bin/repdb status",
  "/eniq/sw/bin/dwhdb status",
  "/eniq/admin/bin/cleanup_after_restore.bsh",
#  "/eniq/admin/bin/delete_dwh_emmadb.bsh",
  "/eniq/admin/bin/dwhdb",
  "/eniq/admin/bin/engine",
  "/eniq/admin/bin/engine status",
  "/eniq/admin/bin/scheduler",
  "/eniq/admin/bin/scheduler status",
  "/eniq/admin/bin/eniq_service_start_stop.bsh",
  "/eniq/admin/bin/eniq_smf_start_stop.bsh",
  "bash /eniq/admin/bin/licmgr_rollback.bsh",
  "bash /eniq/admin/bin/manage_eniq_features.bsh",
  "bash /eniq/admin/bin/manage_eniq_oss.bsh",
  "bash /eniq/admin/bin/manage_eniq_services.bsh",
  "bash /eniq/admin/bin/manage_eniq_status.bsh",
# "bash /eniq/admin/bin/manage_eniq_techpacks.bsh",
# "bash /eniq/admin/bin/manage_eniq_tp_interf.bsh",
  "/eniq/admin/bin/0",
#  "/eniq/admin/bin/repdb",
  "/eniq/admin/bin/snapshot_fs.bsh",
  "bash /eniq/admin/bin/update_cell_node_count.bsh",
  "/eniq/admin/bin/zfs_snapshot.bsh",
  "/eniq/bkup_sw/bin/manage_nas_snapshots.bsh",
  "/eniq/bkup_sw/bin/manage_san_snapshots.bsh",
  "/eniq/bkup_sw/bin/manage_zfs_snapshots.bsh",
  "/eniq/bkup_sw/bin/prepare_eniq_bkup.bsh"
  );
 $result=qq{
<h3>RUN CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd); 
     my @result=map {$_."<br>"} @res; 
     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
		
		if(/Exception|Execute failed|cannot execute/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
        elsif(/ERROR : eniq_service_start_stop.bsh|OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet/)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}

############################################################
# WEBSERVER COMMAND LINE TESTS 
# runs all webserver cli test below
sub runWebserver{
  my $result="";
  my @cmds=(
"webserver          ",
"webserver stop     ",
"webserver start    ",
"webserver restart  ",
"webserver status   ",
  );
 $result=qq{
<h3>RUN WEBSERVER CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;

     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|successfully|SMF .*abling|Usage:/i)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}
############################################################
# SCHEDULER COMMAND LINE TESTS 
sub runScheduler{
  my $result="";
  my @cmds=(
"scheduler          ",
"scheduler stop     ",
"scheduler start    ",
"scheduler restart  ",
"scheduler status   ",
"scheduler hold     ",
"scheduler activate "
  );
 $result=qq{
<h3>RUN SCHEDULER CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";

     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;
     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute|ERROR/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|SMF .*abling/i)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}
############################################################
# ENGINE CMD LINE TESTS
sub runEngine{
  my $result="";
  my @cmds=(
#"/eniq/sw/bin/engine -e reloadConfig",
"/eniq/sw/bin/engine -e reloadAggregationCache| tail -10",
#"/eniq/sw/bin/engine -e reloadProfiles",
"/eniq/sw/bin/engine -e loggingStatus| tail -10",
"/eniq/sw/bin/engine -e changeProfile 'Normal'| tail -10",
"/eniq/sw/bin/engine -e holdPriorityQueue| tail -10",
"/eniq/sw/bin/engine -e restartPriorityQueue| tail -10",
"/eniq/sw/bin/engine -e showSetsInQueue| tail -10",
"/eniq/sw/bin/engine -e showSetsInExecutionSlots| tail -10",
"/eniq/sw/bin/engine -e removeSetFromPriorityQueue 1| tail -10",
#"/eniq/sw/bin/engine -e changeSetPriorityInPriorityQueue 1 0",
"/f/engine -e activateSetInPriorityQueue 1 | tail -10",
"/eniq/sw/bin/engine -e holdSetInPriorityQueue 1| tail -10",
"/eniq/sw/bin/engine stop| tail -10",
"sleep 30",
"/eniq/sw/bin/engine start| tail -10",
"sleep 120",
"/eniq/sw/bin/engine restart| tail -10",
"sleep 120",
"/eniq/sw/bin/engine status| tail -10",
"/eniq/sw/bin/engine -e "
  );
 $result=qq{
<h3>RUN ENGINE CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;
     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     
     foreach my $res (@result)
      {
        $_=$res;
        
		if(/sleep/i)
		{
		  $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
          print "PASS\n";
		}
		
		if(/Exception|Execute failed|cannot execute|ERROR/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|successfully|Could not activate profile .Profile.|not removed from priority queue| not changed to 0|Set .1. is activated|Set .1. is set on hold|Logging status|SMF .*abling/)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}
############################################################
# LICENSE SERVER COMMAND LINE TESTS 
sub runLicserv{
  my $result="";
  my @cmds=(
"licserv          ",
"licserv stop     ",
"licserv start    ",
"licserv restart  "
  );
 $result=qq{
<h3>RUN LICENSE SERVER CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;

     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";

         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|successfully|SMF .*abling/i)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}

############################################################
# LICENSE MANAGER CMD LINE TESTS
sub runLicenseManager{
  my $result="";
  my @cmds=(
"licmgr ",
"licmgr -decode ",
"licmgr -decode /var/tmp/ENIQ_FULL_License_Stats",
"licmgr -install /var/tmp/ENIQ_FULL_License_Stats",
"licmgr -getlicinfo",
"licmgr -getlockcode",
"licmgr -isvalid CXC4010854",
"licmgr -listserv",
"licmgr -map CXC4010854",
"licmgr -restart ",
"sleep 200; licmgr -serverstatus ",
"licmgr -stop",
"sleep 30",
"licmgr -start",
"sleep 200; licmgr -status ",
"licmgr -update ",
"licmgr -uninstall test"
  );
 $result=qq{
<h3>RUN LICMGR CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res2=executeThis($cmd);
     my @res3=undef;
      foreach my $res (@res2)
      {
         $_=$res;
         if(/Feature identity : $|Description      : $/)
          {$res="<font color=660000><b>$res</b></font>";}
         push @res3,$res;
      }
     my @res=@res2;
     my @result=map {$_."<br>"} @res;
     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute| Feature identity : $| Description      : $/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";

         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|Locking Code|SMF .*abling|Updating license manager|Getting status/)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}

############################################################
# DWHDB COMMAND LINE TESTS 
sub runDwhdb{
  my $result="";
  my @cmds=(
"dwhdb          ",
"dwhdb stop     ",
"sleep 60; dwhdb start    ",
"sleep 200; dwhdb restart  ",
"sleep 200 ",
  );
 $result=qq{
<h3>RUN DWHDB CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;

     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";

         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|successfully|SMF .*abling/i)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}
############################################################
# REPDB COMMAND LINE TESTS 
sub runRepdb{
  my $result="";
  my @cmds=(
"repdb          ",
"repdb stop     ",
"sleep 60; repdb start    ",
"sleep 200; repdb restart  ",
"sleep 200 ",
  );
 $result=qq{
<h3>RUN REPDB CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
 foreach my $cmd (@cmds)
   {
     print "$cmd	";
     my @res=executeThis($cmd);
     my @result=map {$_."<br>"} @res;

     $result.= "<tr><td>$cmd:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        $_=$res;
        if(/Exception|Execute failed|cannot execute/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         }
        elsif(/OK|You must be root|shall only be used by SMF|Usage:| is online.|All files within .eniq.data.etldata.adapter_tmp removed|Listing active servers on local subnet|successfully|SMF .*abling/i)
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
           print "PASS\n";
         }
      }
      if((@result)==0)
         {
             $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
             print "FAIL\n";
         }
   }
  $result.=qq{</table>};
  return $result;
}
############################################################
# LOAD TOPOLOGY
# This test is in charge of unzipping the topology file and 
# wait 20 minutes 
# then it queries the database for the topology tables and counts the rows
# if the number of rows is 0, it fails the test case

sub loadTopology{
my $result="";
#my $server   = "eniqis2.lmf.ericsson.se";
my $server   = "131.160.87.42";
my $user     = "dcuser";
my $password = "dcuser";

my $ftp=qq{
ftp -n << EOF
open $server
user $user $password
cd /export/home/automation/topology
get Topologia.tar /eniq/data/pmdata/eniq_oss_1/Topologia.tar
bye
tar xvf /eniq/data/pmdata/eniq_oss_1/Topologia.tar
EOF
};
# EXECUTE FTP
open(FTP,"$ftp |")|| die "cannot contact $server\n"; 
my @ftpOut=<FTP>;
close(FTP); 
foreach my $ftpout (@ftpOut)
  {
     $result.= "$ftpout<br>";
  }

# UNTAR TOPOLOGY
open(UNTAR,"cd /eniq/data/pmdata/eniq_oss_1/; tar xvf /eniq/data/pmdata/eniq_oss_1/Topologia.tar |");
my @untar=<UNTAR>;
close(UNTAR);
my $status=0;
foreach my $tar (@untar)
  {
     $_=$tar;
     if(/Exception|Fail|Error/)
     {
        $result.= "$tar	<font color=66000><b>FAIL</b></font><br>";
        print "FAIL\n";
        $status++;
     }
  }
 if($status>0)
   {
     $result.= "	<font color=006600><b>PASS</b></font><br>";
     print "PASS\n"
   }
 print "wait 20 min to load...\n";
 sleep(20*60);

 return $result;

}
#############################################################
sub epfgloadTopology{
my $result="";
 my $TOP_FLAG="YES";
 my $path="/eniq/home/dcuser/epfg/config";
 my $Topology="YES";
 my $gen_time=getToptime();
 my $NoGenFlag="NO";
 my $NODES=$epfgnumberofnodes;
 my $NeNODES=$epfgnumberofnodes;
 my $stnPicoNodes="A:1-2";
 my $stnSiuNodes="A:1-3";
 my $wranRNCRBSNoOfNodes="1:2";
 my $wranRNCRXINoOfNodes="1-2";
 my $ebagBscNodeNames="BAA-1-2";
 my $bscIogNodeNames="BIE-1:2-50:1:1";
 my $bscApgNodeNames="BAA-1:2-50:1:1";
 my $wranNodeAndRBSCellsMapping="1-2:3,3-4:6";
#############################################################
 #my $epfg_version=getepfg_version();
 #if (substr($epfg_version,2,1) gt "M")
 #{
 # $wranRNCRXINoOfNodes="2";
 # $ebagBscNodeNames="BAA-1";
 #}
 #############################################################
# READ THE FILE 
open(INPUT,"< $path/epfg.properties");
my @input=<INPUT>;
chomp(@input);
close(INPUT);
#################
open(OUTPUT, "> $path/epfg.topoutput");

##################

for my $line (@input) 
 {
  $_=$line;
  my $nodes=nodesRegExp(@epfg_techPacks);
  my $nenodes=nenodesRegExp(@epfg_techPacks); 
	if(/TopologyGen=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$Topology\n";
   }
    elsif(/GenTopology=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$TOP_FLAG\n";
   }
   elsif(/$nodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NODES\n";
   }
    elsif(/$nenodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NeNODES\n";
   }
    elsif(/stnPicoNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnPicoNodes\n";
   }
    elsif(/stnSiuNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnSiuNodes\n";
   }
   	elsif(/wranRNCRBSNoOfNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCRBSNoOfNodes\n";
   }
    elsif(/wranNodeAndRBSCellsMapping=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranNodeAndRBSCellsMapping\n";
   }
    elsif(/wranRNCRXINoOfNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCRXINoOfNodes\n";
   }
    elsif(/ebagBscNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$ebagBscNodeNames\n";
   }
    elsif(/bscIogNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$bscIogNodeNames\n";
   }
    elsif(/bscApgNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$bscApgNodeNames\n";
   }
    elsif(/genTime=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$gen_time\n";
   }
    elsif(/GenFlag=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NoGenFlag\n";
   }    
    else
   {
     print OUTPUT "$line\n";
   }
  }
  system("rm $path/epfg.properties");
  system("cp $path/epfg.topoutput $path/epfg.properties");
###############
close(OUTPUT);
   print "Properties file Updated successfully with topology information\n";
   open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
   print "Successfully started the script for topology generation!!!\n";
   $result="Successfully started the script for topology generation!!!\n";
   print "wait 20 min to load...\n";
   sleep(5*60);
   topology_backup();
   sleep(15*60);
   return $result;
}



############################################################
# LOAD TOPOLOGY UPDATE 
# queries the database for the topology tables and counts the rows
# if the number of rows is 0, it fails the test case

sub verifyTopology{
my $result="";
 my @alltopologytables=getAllTables4TP("DIM_E_");
 $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TOPOLOGY TABLE</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};
 foreach my $tables (@alltopologytables)
  {
   my @data=getTopologyLoading($tables); 
    foreach my $data (@data)
     {
       $_=$data; 
       next if(/affected/);
       next if(/Msg 102, Level 15, State 0:/);
       next if(/^$/);
       $data=~ s/\|0/|<b>0<\/b>/;
       $data=~ s/^/<tr><td>/g;
       $data=~ s/ //g;
       $data=~ s/\|/<\/td><td align=center>/g;
       $_=$data;
       if(/<b>0<.b>/)
       {
         $data=~ s/$/<\/td><td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr>/;
       }
       else
       {
          $data=~ s/$/<\/td><td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr>/;
       } 
       $result.="$data\n"; 
     }
  }
 $result.="</table>\n";
 return $result;
}
############################################################
# LOAD TOPOLOGY UPDATE
# This test is in charge of unzipping the topology file and 
# wait 20 minutes 
# then it queries the database for the topology tables and counts the rows
# if the number of rows is 0, it fails the test case

sub loadTopologyUpdate{
my $result   ="";
#my $server   = "eniqis2.lmf.ericsson.se";
my $server   = "131.160.87.42";
my $user     = "dcuser";
my $password = "dcuser";

my $ftp=qq{
ftp -n << EOF
open $server
user $user $password
cd /export/home/automation/topology
get Updated_Topologia.tar /eniq/data/pmdata/eniq_oss_1/Updated_Topologia.tar
bye
EOF
};
# EXECUTE FTP
open(FTP,"$ftp |")|| die "cannot contact $server\n"; 
my @ftpOut=<FTP>;
close(FTP); 
foreach my $ftpout (@ftpOut)
  {
     $result.= "$ftpout<br>";
  }

# UNTAR UPDATED TOPOLOGY
open(UNTAR,"cd /eniq/data/pmdata/eniq_oss_1/; tar xvf /eniq/data/pmdata/eniq_oss_1/Updated_Topologia.tar |");
my @untar=<UNTAR>;
close(UNTAR);
foreach my $tar (@untar)
  {
     $result.= "$tar<br>";
  }
 print "wait 20 min to load...\n";
 sleep(20*60);
 return $result;
}
############################################################
sub epfgloadTopologyUpdate{
my $result   ="";
epfgloadTopology();
}

############################################################
# MODIFY PROP FILES FOR DATA GENERATION
# Process in charge of editing the data generator files  called rep*prop*
sub modifyPropFile{
 my $path= shift;
 open(LS,"ls $path/rep*prop*.txt |");
 my @file=<LS>;
 chomp(@file);
 close(LS);
 print $file[0]; 
 open(PROP,"< $file[0] ");
 my @propFile =<PROP>;
 close(PROP);
 open(NEW,"> $file[0].new ");
 foreach my $prop (@propFile)
 {
    $_=$prop;
    $prop=~s/^TIMEUPDATE\s.*/TIMEUPDATE      = $timeUpdate/;
    $prop=~s/^TIMEWARP.*/TIMEWARP        = $timeWarp/;
    $prop=~s/^NUMROPS.*/NUMROPS         = $numRops/;
    print NEW $prop;
 }
 close(NEW);
 # RENAME THE ORIGINAL FILE
# print "mv $file[0] $file[0].bak \n";
 open(MV,"mv $file[0] $file[0].bak |");
 my @mv=<MV>;
 close(MV);
 # RENAME THE ORIGINAL FILE
# print "mv $file[0].new $file[0] \n"; 
 open(MV1,"mv $file[0].new $file[0] |"); 
 my @mv1=<MV1>;
 close(MV1);
 
}
############################################################
# DATA GENERATION 
sub dataGeneration{
my $result="";
#my $server   = "eniqis2.lmf.ericsson.se";
my $server   = "131.160.87.42";
my $user     = "dcuser";
my $password = "dcuser";

# This part is obsolete because the sim.tar will not be ftpd anymore
# also the generator is about to be changed to EPFG
#my $ftp=qq{ 
#ftp -n << EOF
#open $server
#user $user $password
#cd /export/home/automation/data_gen
#get sim.tar /eniq/home/dcuser/sim.tar
#bye
#EOF
#}; 
# MV DIR SIM 
#my $date=getDate();
#open(MVSIM,"mv /eniq/home/dcuser/sim /eniq/home/dcuser/sim_$date |");
#my @mvsim=<MVSIM>;
#close(MVSIM);
#$result.= $mvsim[0]."<br>\n";
# MV SIM TAR
#open(MVSIM,"mv /eniq/home/dcuser/sim.tar /eniq/home/dcuser/sim_$date.tar |");
#my @mvsim=<MVSIM>;
#close(MVSIM);
#$result.= $mvsim[0]."<br>\n";

# EXECUTE FTP
#open(FTP,"cd /eniq/home/dcuser/; $ftp |")|| die "cannot contact $server $!\n";
#my @ftpOut=<FTP>;
#close(FTP); 
#foreach my $ftpout (@ftpOut)
#  {
#      $result.= "$ftpout<br>";
#  }
# UNTAR SIMULATOR
#open(UNTAR,"cd /eniq/home/dcuser/; tar -xvf /eniq/home/dcuser/sim.tar |"); 
#my @untar=<UNTAR>;
#close(UNTAR); 
#foreach my $tar (@untar)
#  {
#     $result.= "$tar<br>";
#  }

# RUN EACH TECHPACK SIMULATION
    open(SETENV,"cd /eniq/home/dcuser/sim; . ./setenv.sh |");
    $result.= "cd /eniq/home/dcuser/sim; . ./setenv.sh <br>\n";
    my @output=<SETENV>;
    close(SETENV);
    foreach my $output (@output)
     {
        $result.= "$output<br>";
     }

    foreach my $techPack (@techPacks)
     {
        modifyPropFile("/eniq/home/dcuser/sim/EniqSim/scripts/$techPack");
        open(RUN,"cd /eniq/home/dcuser/sim/EniqSim/scripts/$techPack/; chmod +x run.sh; mkdir log; /eniq/home/dcuser/sim/EniqSim/scripts/$techPack/run.sh |");
        $result.= "cd /eniq/home/dcuser/sim/EniqSim/scripts/$techPack/<br>\nchmod +x run.sh;<br> \n./run.sh <br>\n";
        my @run=<RUN>;
        close(RUN);
        foreach my $r (@run)
         {
           $result.= "$r<br>";
         }
     }
return $result;
}

############################################################
# DATA GENERATION USING EPFG
sub epfgdataGeneration{
 my $result="";
 my $START=$epfgstarttime;
 my $END=$epfgstoptime;
 my $NODES=$epfgnumberofnodes;
 my $NeNODES=$epfgnumberofnodes;
 my $startNode="1";
 my $endNode=$epfgnumberofnodes;
 my $FLAG="YES";
 my $path="/eniq/home/dcuser/epfg/config";
 my $stnPicoNodes="A:1-2";
 my $stnSiuNodes="A:1-3";
 my $wranRNCRBSNoOfNodes="1:2";
 my $wranRNCRXINoOfNodes="1-2";
 my $wranRNCCtype="1-2";
 my $wranRNCFtype="3-4";
 my $ebagBscNodeNames="BAA-1-2";
 my $bscIogNodeNames="BIE-1:2-50:1:1";
 my $bscApgNodeNames="BAA-1:2-50:1:1";
 my $cpg_instances="2";
 my $NoTopology="NO";
 my $epfg_version=getepfg_version();
 if (substr($epfg_version,2,1) gt "M")
 {
  $wranRNCRXINoOfNodes="1-2";
  $ebagBscNodeNames="BAA-1";
  $wranRNCCtype="1-2";
  $wranRNCFtype="3-4";
 }
 
###############
   configfile_gen();
   print "Properties file Updated successfully\n";
   open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
   print "Successfully started the script for config file generation!!!\n";
   sleep(20*60);
   change_config();
   print "Properties file Updated successfully with new Config paths\n";
################
# READ THE FILE 
open(INPUT,"< $path/epfg.properties");
my @input=<INPUT>;
chomp(@input);
close(INPUT);
#################
open(OUTPUT, "> $path/epfg.regoutput");

##################
for my $line (@input) 
 {
  $_=$line;
  my $flag=flagRegExp(@epfg_techPacks);
  my $start=startRegExp(@epfg_techPacks);
  my $end=endRegExp(@epfg_techPacks);
  my $nodes=nodesRegExp(@epfg_techPacks);
  my $nenodes=nenodesRegExp(@epfg_techPacks);
  my $start_node=StartNodeRegExp(@epfg_techPacks);
  my $end_node=EndNodeRegExp(@epfg_techPacks);
  if(/$start/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$START\n"; 
   }
   elsif(/$end/)
   { 
     $line=~s/=.*/=/;
     print OUTPUT "$line$END\n";
   }
   elsif(/$flag/)
   { 
     $line=~s/=.*/=/;
     print OUTPUT "$line$FLAG\n";
   }

   elsif(/$nodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NODES\n";
   }
    elsif(/$nenodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NeNODES\n";
   }
    elsif(/$start_node/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$startNode\n";
   }
    elsif(/$end_node/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$endNode\n";
   }
    elsif(/stnPicoNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnPicoNodes\n";
   }
    elsif(/stnSiuNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnSiuNodes\n";
   }
   	elsif(/wranRNCRBSNoOfNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCRBSNoOfNodes\n";
   }
    elsif(/wranRNCRXINoOfNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCRXINoOfNodes\n";
   }
    elsif(/wranRNCC-TypeNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCCtype\n";
   }
    elsif(/wranRNCF-TypeNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCFtype\n";
   }
    elsif(/ebagBscNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$ebagBscNodeNames\n";
   }
    elsif(/bscIogNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$bscIogNodeNames\n";
   }
    elsif(/bscApgNodeNames=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$bscApgNodeNames\n";
   }
    elsif(/TopologyGen=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NoTopology\n";
   }
    elsif(/cpgNumOf/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$cpg_instances\n";
   }
   elsif(/smartMetroNumOf/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$cpg_instances\n";
   }
   elsif(/edgeRtrNumOf/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$cpg_instances\n";
   }
    else
   {
     print OUTPUT "$line\n";
   }
  }
  system("rm $path/epfg.properties");
  system("cp $path/epfg.regoutput $path/epfg.properties");
###############
close(OUTPUT);
print "Properties file Updated successfully\n";

open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
print "Successfully started the script for PM file generation!!!\n";
}


############################################################
# PRE_LOAD
# This process executes 4 tasks, is used to kick off loading, update monitoring types, first loadings and aggregation:
# engine -e startSet DWH_MONITOR SessionLoader_Starter Start
# engine -e startSet DWH_MONITOR UpdateMonitoredTypes Start
# engine -e startSet DWH_MONITOR UpdateFirstLoadings Start 
# engine -e startSet DWH_MONITOR AggregationRuleCopy Start
# NOTE: Currently there is no way to load data and then to re run again PRE_LOAD, because it 
# creates a huge queue of aggregation processes

sub preLoad{
my $result="";
#$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR SessionLoader_Starter Start<br>";
#my @out1=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR SessionLoader_Starter Start ");
#sleep(10);
#$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateMonitoredTypes Start<br>";
#my @out2=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateMonitoredTypes Start ");
#sleep(10);
$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateFirstLoadings Start<br>";
my @out3=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateFirstLoadings Start ");
sleep(60);
$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR AggregationRuleCopy Start<br>";
my @out4=executeThis( "/eniq/sw/bin/engine -e startSet DWH_MONITOR AggregationRuleCopy Start ");
sleep(60);
my @out=(@out3,@out4);
  foreach my $out (@out)
  {
    $result.=$out."<br>";  
  }
  return $result;
}

############################################################
# VERIFY LOADINGS 
# This process goes to AdminUI and checks the loading based on the TIMEWARP variable
# for example if TIMEWARP = -24 then it will check the loadings from yesterday
# 
# The algorithm is basically to check if there are green boxes in the table and count them
# if they are green for the TIMEWARP date then the test is passed, else fail

sub verifyLoadings
{
  my $result;
  my $year   =$YEARTIMEWARP;  #getYearTimewarp();
  my $month  =$MONTHTIMEWARP; #getMonthTimewarp();
  my $day    =$DAYTIMEWARP;   #getDayTimewarp();
  
  system("rm /eniq/home/dcuser/cookies.txt");
  system("rm /eniq/home/dcuser/cookies2.txt");
  
  foreach my $tp (@tpini)
  {
   $_=$tp;
   next if(/^$/);
   $result.="<h3>$tp</h3><BR>\n"; 

   # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/loading_$tp.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");
   #sleep(1);

   # SEND USRID AND PASSWORD
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
   
   # GET LOADING
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/loading_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");

   open(LOAD,"< /eniq/home/dcuser/loading_$tp.html");
   my @loadings=<LOAD>;
   close(LOAD); 
   
   system("rm /eniq/home/dcuser/loading_$tp.html");
 
   my $tpack=0;
   my $found=0;
   my $green=0;
   my $yellow=0;
   my $red=0;
   $result.=qq{    
 <h3>ADMINUI: SHOW LOAD STATUS </h3>
 <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLE</th>
     <th bgcolor="#047e01">GREEN</th>
     <th bgcolor="#ffff00">YELLOW</th>
     <th bgcolor="#CC0000">RED</th>
     <th>RESULT</th>
   </tr>
};
   foreach my $loadings (@loadings)
   {
    $_=$loadings;
    if(/&nbsp;X&nbsp/) 
      {
         $result.="NO DATA FOUND FOR $tp<br>";
         print "NO DATA FOUND FOR $tp\n";
         last;
      }
    if(/\/adminui\/servlet\/ShowLoadings\?year_1=....&month_1=..&day_1=..\&subtype=.*&details=15MIN/) 
       {
         $loadings=~s/.*15MIN.//;
         $loadings=~s/<.*//;
         $loadings=~s/>//;
         $result.="<tr><td>$loadings</td>";
         print "$loadings\n";
         $found=1;
       }
    if($found==1 && /047e01/) { $green++;}
    if($found==1 && /ffff00/) { $yellow++;}
    if($found==1 && /ff0000/) { $red++;}
    if($found==1 && /		<.tr>/) 
        { 
           print  "GREEN :$green\n";
           print  "YELLOW:$yellow\n";
           print  "RED   :$red\n";
           $result.=  "<td align=center>$green</td>";
           $result.=  "<td align=center>$yellow</td>";
           $result.=  "<td align=center>$red</td>";
           if($green==0)
           { 
             $result.=  "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
           }
           else
           {
             $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
           }
           $result.=  "</tr>";
           $found=0; 
           $green=0;
           $yellow=0;
           $red=0;
        }
   }
   $result.=qq{</table>
};

   my @tables= getAllTables4TP($tp);
   $result.=qq{
  <br>
  <h3>SQL LOAD STATUS DB</>
    <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLE</th>
     <th>ROWS</th>
     <th>RESULT</th>
   </tr>
};
   foreach my $table (@tables)
     {
        $_=$table;
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
        next if(/_DAY/);
        next if(!/_RAW/);
        my @data   =getLoading($table);

        foreach my $data (@data)
          {
            $_=$data;
            next if(/^$/);
            next if(/affected/);
            $data=~ s/\t//g;
            $data=~ s/\s//g;
            $data=~ s/^/<tr><td>/g;
            $data=~ s/\|/<\/td><td align=center>/g;
            $data=~ s/$/<\/td><td align=center>RESULT<\/td><tr>/g;
            $_=$data;
            if(/<td align=center>0<.td>/)
             {
              $data=~ s/RESULT/<font color=#660000><b>FAIL<\/b><\/font>/;
             }
            else #(/<td align=center>$numRops<.td>/)
             {
              $data=~ s/RESULT/<font color=#006600><b>PASS<\/b><\/font>/;
             }
            $result.="$data\n";
          }
      }
    $result.="   </table>\n";
    $result.=qq{
  <br>
  <h3>ADMINUI: SHOW LOAD STATUS 15MIN</>
    <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLE</th>
     <th bgcolor="#047e01">GREEN</th>
     <th bgcolor="#ffff00">YELLOW</th>
     <th bgcolor="#CC0000">RED</th>
     <th >RESULT</th>
   </tr>

};
   $found=0;
   $green=0;
   $yellow=0;
   $red=0;
   foreach my $table (@tables)
     {
        $_=$table;
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
        next if(/_DAY/);
        next if(!/_RAW/);
        my @data   =getLoading($table);

        # GET INFO FOR TABLE FROM WEB
         $table=~s/_RAW//;
         # SAVE COOKIES
         system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/loading15min_$table.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ShowLoadings?year_1=$year&month_1=$month&day_1=$day&subtype=$table&details=15MIN\"");

        # SEND USR AND PASSWORD
         system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

         # GET LOADING
         system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /eniq/home/dcuser/loading15min_$table.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ShowLoadings?year_1=$year&month_1=$month&day_1=$day&subtype=$table&details=15MIN\"");

        open(L15MIN,"< /eniq/home/dcuser/loading15min_$table.html");
        my @l15min=<L15MIN>;
        close(L15MIN); 
        system("rm /eniq/home/dcuser/loading15min_$table.html");

        foreach my $l15min (@l15min) 
        {
         $_=$l15min;
          if(/<td bgcolor="#......"><font face="Verdana,Helvetica,Arial" .* size="1">/)
           {
            $found=1;
           }
          if($found==1 && /339900/) { $green++;}
          if($found==1 && /FFFF33/) { $yellow++;}
          if($found==1 && /CC0000/) { $red++;}
          if($found==1 && /<.html>/)
           {
             print  "$table\n";
             print  "GREEN :$green\n";
             print  "YELLOW:$yellow\n";
             print  "RED   :$red\n";
             $result.=  "<td>$table</td>";
             $result.=  "<td align=center>$green</td>";
             $result.=  "<td align=center>$yellow</td>";
             $result.=  "<td align=center>$red</td>";
             if($green==0)
             {
               $result.=  "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
             }
             else
             {
               $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
             }
             $result.=  "</tr>";
             $found=0;
             $green=0;
             $yellow=0;
             $red=0;
           }

        }
     }
     $result.="</table>\n";
  } 
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

  return $result;
}

############################################################
# VERIFY AGGREGATIONS
# 
# This process goes to AdminUI and checks the aggregation based on the TIMEWARP variable
# for example if TIMEWARP = -24 then it will check the loadings from yesterday
# The algorithm is basically to check if there are green boxes in the table and count them
# if they are green for the TIMEWARP date then the test is passed, else fail

sub verifyAggregations{
  my $result;
  my $year   =$YEARTIMEWARP;  #getYearTimewarp();
  my $month  =$MONTHTIMEWARP; #getMonthTimewarp();
  my $day    =$DAYTIMEWARP;   #getDayTimewarp();
  
  system("rm /eniq/home/dcuser/cookies.txt");
  system("rm /eniq/home/dcuser/cookies2.txt");  
  foreach my $tp (@aggini)
  {
   $_=$tp;
   next if(/^$/);
   $result.="<h3>$tp</h3><BR>\n";
   # SAVE COOKIES
   system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&action=/servlet/ShowAggregations&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("/usr/sfw/bin/wget  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET AGGREGATION
   system("/usr/sfw/bin/wget --quiet  --no-check-certificate -O /eniq/home/dcuser/aggregations_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");


   open(AGG,"< /eniq/home/dcuser/aggregations_$tp.html");
   my @aggregations=<AGG>;
   close(AGG);
   system("rm /eniq/home/dcuser/aggregations_$tp.html"); 
   my $tpack=0;
   my $found=0;
   my $green=0;
   my $yellow=0;
   my $red=0;
   $result.=qq{    
  <br>
  <h3>ADMINUI: SHOW AGGREGATIONS </>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%
" >
   <tr>
     <th>TABLE</th>
     <th bgcolor="#047e01">GREEN</th>
     <th bgcolor="#ffff00">YELLOW</th>
     <th bgcolor="#CC0000">RED</th>
     <th>RESULT</th>
   </tr>
};

   foreach my $aggregations (@aggregations)
   {
    $_=$aggregations;
    if(/                  <tr><td width=.230.><font size=.-1.>/)
       {
         $aggregations=~s/.*1.>//;
         $aggregations=~s/<.*//;
         $result.="<tr><td>$aggregations</td>";
         print "$aggregations\n";
         $found=1;
       }
    if($found==1 && /047e01/) { $green++;}
    if($found==1 && /ffff00/) { $yellow++;}
    if($found==1 && /ff0000/) { $red++;}
    if($found==1 && /<!-- one row ends here-->/)
        {
           print  "GREEN :$green\n";
           print  "YELLOW:$yellow\n";
           print  "RED   :$red\n";
           $result.=  "<td align=center>$green</td>";
           $result.=  "<td align=center>$yellow</td>";
           $result.=  "<td align=center>$red</td>";
           if($green==0)
           { 
             $result.=  "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
           }
           else
           {
             $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
           }
           $result.=  "</tr>";
           $found=0;
           $green=0;
           $yellow=0;
           $red=0;
        }
   }
   $result.="</table>\n";

   my @tables= getAllTables4TP($tp);
   $result.=qq{
  <br>
  <h3>SQL AGGREGATION DB STATUS</>
    <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLE</th>
     <th>ROWS</th>
     <th>RESULT</th>
   </tr>
};
   foreach my $table (@tables)
     {
        $_=$table;
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
        next if(/_RAW/);
        my @data=getLoading($table);
        # GET INFO FOR TABLE
        if(/_DAY/)
        {
         $table=~s/_DAY//;
        }
        foreach my $data (@data)
          {
            $_=$data;
            next if(/^$/);
            next if(/affected/);
            $data=~ s/\t//g;
            $data=~ s/\s//g;
            $data=~ s/^/<tr><td>/g;
            $data=~ s/\|/<\/td><td align=center>/g;
      #      $data=~ s/$/<\/td><tr>/g;
            $data=~ s/$/<\/td><td align=center>RESULT<\/td><tr>/g;
            $_=$data;
            if(/<td align=center>0<.td>/)
             {
              $data=~ s/$numRops/<font color=#660000>0<\/font>/g;
              $data=~ s/RESULT/<font color=#660000><b>FAIL<\/b><\/font>/;
             }
            else #(/<td align=center>$numRops<.td>/)
             {
              $data=~ s/$numRops/<font color=#006600>$numRops<\/font>/g;
              $data=~ s/RESULT/<font color=#006600><b>PASS<\/b><\/font>/;
             }

            $result.="$data\n";
            #print "$data<br>\n";
          }
     }
   $result.="</table>\n";
  }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

  return $result;
}

############################################################
# VERIFY EBS TESTCASES
# TODO
sub verifyEBS{
  return "TO BE IMPLEMENTED\n";
}
############################################################
# UTILITY TO EXECUTE ANY COMMAND AND GET RESULT IN ARRAY
sub executeThis{
 my $command = shift;
 open(CMD,"$command |");
 my @cmd=<CMD>;
 close(CMD);
 return @cmd;
}
############################################################
# VERIFY UNIVERSES EXIST IN THE APPROPIATE DIRECTORIES
# This process only counts the universes are in a unv directory for all techpacks
sub verifyUniverses{
 my $result="";
 $result.= "NUMBER OF TECH PACKS:";
 my @tps=executeThis("ls /eniq/sw/installer/bouniverses/BO* | grep -c : ");
 $result.= $tps[0]."<br>";
 @tps=executeThis("ls /eniq/sw/installer/bouniverses/BO* | grep : ");
 chomp(@tps);
 chop(@tps);
 $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>UNIVERSE</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};

 foreach my $tps (@tps)
 {
    my $unv=executeThis("ls $tps/unv/*.unv ");

    if($unv==0)
      {
        $result.= "<tr><td>$tps<\/td>><td align=center>$unv<\/td><td align=center><font color=660000><b>FAIL</b></font></td><tr>\n";
      }
    else
      {
        $result.= "<tr><td>$tps<\/td><td align=center>$unv<\/td><td align=center><font color=006600><b>PASS</b></font></td><\/tr>\n";
      }

 }
 $result.=qq{</table>};
 return $result;
}
############################################################
# GET SQL
# This is a utility
# This is subroutine that extracts the SQL from the BO verification reports
# it is just experimental and should not be trusted without testing the BO reports using a BO server
sub getSQL{
my $report=shift;
open(REP,"< $report");
my @rep=<REP>;
close(REP);
my ($path,$file) = $report =~ m|^(.*[/\\])([^/\\]+?)$|;

my $print=0;
my $sql="";
my $count=0;
my $count2=0;
foreach my $rep (@rep)
 {
   $_=$rep;
   if(/SELECT/ && !/AGG/){ $rep=~s/.*SELECT/SELECT/;}
   $rep=~s/IN .Prompt.*/IS NOT NULL )/;
   next if(/.* GARP-.*/);
   $rep=~s/= .Prompt.*/!= NULL )/;
   $rep=~s/=  .Prompt.*/!= NULL )/;
   $rep=~s/= .variable.*/!= NULL )/;
   $rep=~s/=  .variable.*/!= NULL )/;
   $rep=~s/IN .variable.*/IS NOT NULL )/;
   $rep=~s/= .variable.*/!= NULL )/;
   $rep=~s/NOT IS NOT NULL /IS NOT NULL )/;
   $rep=~s/ROWSTATUS \) IS NOT NULL \)\)/ROWSTATUS ) IS NOT NULL )/;
   $rep=~s/BETWEEN .*/IS NOT NULL )/;
   $rep=~s/\r\n|\n|\r/\n/g;
   #next if(/Ericsson /); 
   if( /SELECT/ && !/AGG/ )
    {
      $sql="";
      $print=1;
      $count++;
    }

   if(!/SELECT|FROM|WHERE|GROUP|^  /)
    {
       if($count>=1 && $print ==1)
         {
           $count2=$count2-1;
           open(SQL,"> ./sql/$file$count2.sql");
           print SQL $sql;
           print SQL ";\ngo\nEOF\n";
           close(SQL);
         }
       $sql="";
       $print=0;
    }
#   else
#     {
#       next;
#     }
  if($print==1)
    {
      $sql.= $rep;
    }

 }

}

############################################################
# VERIFY BO REPORTS IN THE APPROPIATE DIRECTORIES
# 
sub verifyBOReports{
 my $result="";
 my @tps=executeThis("ls /eniq/sw/installer/bouniverses/BO*$verifyBOfilter* | grep :  ");
 chomp(@tps);
 chop(@tps);

 $result.=  "CHECK REPORTS:\n";
   $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>BO REPORTS</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};

 foreach my $tps (@tps)
 {
    $_=$tps;
    next if(/Z_ALARM/);
	next if(/BO_E_WLE/);
    $result.=  "<tr><td>$tps <\/td><td align=center>";
    my @rep=executeThis("ls $tps/rep/* |  egrep -v \"(checkbo|_Z_ALARM)\" | grep -c BO ");
    chomp(@rep);
    foreach my $rep (@rep)
    {
      $_=$rep;
     if ($rep ==0)
       {
        $result.= $rep."<\/td><td align=center><font color=660000><b>FAIL</b></font></td><\/tr>\n";
       }
     else
       {
        $result.= $rep."<\/td><td align=center><font color=006600><b>PASS</b></font></td><\/tr>\n";
       }
    }
 }
 $result.=qq{</table>};
 system("mkdir sql");
 foreach my $tps (@tps)
 {
    my @rep=executeThis("ls $tps/rep/* | egrep -v \"(checkbo|_Z_ALARM)\" | grep BO ");
    chomp(@rep);
    foreach my $rep (@rep)
    {
      $_=$rep;
      print "$rep\n"; 
      if($getSql eq "true")
       { getSQL($rep); }
    }
 }

  return $result;
}
############################################################
# ONCE THE REPORTS ARE EXTRACTED CAN BE RUN
# This is a utility and is only experimental
# once extracted the SQL from the BO reports it executes the report in 
# isql and just counts the rows, if an error or ASA Exception appears
# then it fails the test case.

sub runBOsql{
 my $result="";
 my @tps=getAllTechPacks();
 foreach my $tp (@tps)
 {
 $_=$tp;
 open(LS,"ls sql/*$tp*.sql | grep $runBOfilter |");
 my @files=<LS>;
 chomp(@files);
 close(LS);
 foreach my $file (@files)
   {
    open(FILE,"< $file");
     my @query=<FILE>;
     close(FILE);
     my $sql = "\n";
     foreach my $f (@query)
      {
          $_=$f;
          $f=~s/^ EOF/^EOF/;
          $f=~s/^ROM$/FROM/;
          $sql.=$f;
      }
    $sql .= "\n";
    open(SQL,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |") || die $!;
    my @sql=<SQL>;
    # foreach my $s (@sql)
    #  {
    #    print $s;
    #  }
    chomp(@sql);
    close(SQL);
    my $rows=@sql;
    my $length=length "@sql";
    
    if("@sql"=~"ASA ")
     {
        $result.="$file sql returns:\t$rows	length=$length <br>\n";
        print "$file sql returns:\t $length $sql[0] $sql[1] $sql[2]\n"; 
     }
    else
     {
        print "$file sql returns:\t$rows 	length=$length \n";
     }
   }
 }
 return $result;
}
############################################################
# VERIFY ALARM REPORTS EXIST IN THE APPROPIATE DIRECTORIES
# This subroutine only lists the alarm reports
sub verifyAlarmReports{
my $result="";
 $result.= "CHECK ALARMS wid files found:";
    my @wid=executeThis("ls /eniq/sw/installer/bouniverses/BO*ALARM*/rep/* | grep -c wid ");
    $result.= "\t$wid[0]<br>\n";
    my @widr=executeThis("ls /eniq/sw/installer/bouniverses/BO*ALARM*/rep/* ");

    foreach my $widr (@widr)
    {
      $result.= "\t$widr<br>\n";
    }
  return $result;
}
############################################################
# CONFIG_WEBPORTAL
# This subroutine configures the alarm testing
# creates the directory for alarm data /eniq/data/pmdata/eniq_oss_1/alarmData
# checks if the webportal entry is in /etc/hosts
# if not the it will set the value to the input value in CONFIG_WEBPORTAL <ip>
# 
sub configWebportal{
my $webportal = shift;
my $result="";
executeThis("mkdir -p /eniq/data/pmdata/eniq_oss_1/alarmData ");
my @test=executeThis("grep webportal /etc/hosts | grep -c -v '^#' ");
   # eniqweb8d (131.160.87.116)
   # eniqweb7a (131.160.87.109)
#   my $webportal="131.160.87.116";

if($test[0]=~"0")
{
   executeThis("cp /etc/hosts ./hosts ");
   executeThis("chmod +w ./hosts ");
   executeThis("echo \"$webportal webportal\" >> ./hosts ");
   my $ftp=qq{
ftp -n << EOF
open localhost
user root shroot
cd /etc/
put hosts hosts
bye
EOF
};
   # EXECUTE FTP
   open(FTP,"$ftp |")|| die "cannot contact localhost\n";
   my @ftpOut=<FTP>;
   close(FTP);
}
  my @test2=executeThis("grep webportal /etc/hosts | grep -c -v '^#' ");
  if($test2[0]!~"1")
  {
    $result.="<font color=660000><b>FAIL</b></font><br>";
  }
 else
  {
    $result.="<font color=006600><b>PASS</b></font><br>";
  }
  return $result;
}
############################################################
# SQL TO CHECK ALARMS ARE LOADED
# This process runs a query to count all in the DC_Z_ALARM_INFO_RAW
# Just displays if the result is 0
# 
sub queryAlarms{
my $result="";
my $sql=qq{
select
 count(*)
from
 DC_Z_ALARM_INFO_RAW;
go
};
 open(ALARM,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @alarm=<ALARM>;
 chomp(@alarm);
 close(ALARM);
 if($alarm[0]==0)
  {
    $result.="<font color=660000><b>No alarms found in DC_Z_ALARM_INFO_RAW</b></font><br>";
  }
 else
  {
    $result.="<font color=006600><b>PASS: [ $alarm[0] ] alarms found in DC_Z_ALARM_INFO_RAW.</b></font><br>";
  }
 
  return $result;
}

############################################################
# CHECK DB FOR EBS COUNTERS 
# This subroutine is in charge of quering the db to get 
# the count of EBS counters.
# If they are 0 the test is failed
# else is passed.
sub checkEBSCounters{
my $result="";
my  $ebsType=uc($testEbs);
my $sql=qq{
select 
TYPEID||'|'||
count(TYPEID)
from dwhrep.MeasurementCounter 
where TYPEID like "PM_E_EBS$ebsType:%:%" 
group by TYPEID;
go
EOF
};
 open(TABLES,"$sybase_dir -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
 my @tables=<TABLES>;
 chomp(@tables);
 close(TABLES);
   $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>MEASUREMENT</th>
     <th>COUNTERS</th>
     <th>RESULT</th>
   </tr>
};
 my $count=$ebsCounterGroup*$ebsRefCounter;
 foreach my $tables (@tables)
 {
   $_=$tables;
   next if(/parser.header/);
   next if(/affected/);
   next if(/^$/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
   $tables=~ s/PM_.*:.....://g;
   $tables=~ s/^/<tr><td>/g;
   $tables=~ s/\|/<\/td><td align=center>/g;
   if(/$count/)
   {
     $tables.="<td align=center><font color=006600><b>PASS</b></font>";
   } 
   else
   {
     $tables.="<td align=center><font color=ff0000><b>FAIL</b></font>"
   }
   $tables=~ s/$/<\/td><\/tr>/g;
   $result.= "$tables\n";
 }
 $result.= "</table><br>\n";

 return $result;
}
############################################################
# CHECK DB FOR EBS COLUMNS
# This process queries the DB for EBS columns
# This is a utility
sub checkEBSColumns{
my $result="";

my  $ebsType=uc($testEbs);

my $sql=qq{
select 
     MTABLEID||'|'||
count(MTABLEID)
from 
     dwhrep.MeasurementColumn 
where 
     MTABLEID like 'PM_E_EBS$ebsType:%:%' 
group by 
    MTABLEID
order by 1;
go
EOF
};
 open(TABLES,"$sybase_dir -Udba -Psql -h0 -Drepdb -Srepdb -w 50 -b << EOF $sql |");
 my @tables=<TABLES>;
 chomp(@tables);
 close(TABLES);
   $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>MEASUREMENT</th>
     <th>COLUMNS</th>
     <th>RESULT</th>
   </tr>
};

 foreach my $tables (@tables)
 {
   $_=$tables;
   next if(/parser.header/);
   next if(/affected/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
   $tables=~ s/PM_.*:.....://g;
   $tables=~ s/^/<tr><td>/g;
   if (/\|0/) 
     {
      $tables=~ s/\|/<td align=center>0<\/td><\/td><td align=center><font color=660000><b>FAIL/g;
     }
   else  
     {
      $tables=~ s/\|/<td align=center>/;
      $tables.= "<\/td><td align=center><font color=006600><b>PASS";
     }
   $tables=~ s/$/<\/b><\/font><\/td><tr>/g;
   $result.= "$tables\n";
 }
 $result.= "</table><br>\n";

 return $result;
}


############################################################
# UPDATE MOM EBS
# This test creates a MOM file
# It copies the file into /eniq/data/pmdata/ebs/ebs_ebs$testEbs
# Then it executes engine PM_E_EBS$ebsType Distributor  Start process
# Verifies if the MOM file does not exist after the Distributor
# if does not exist the is passed
# else is failed
# Then the process runs the update EBS and waits until is finished
# 
sub testEbs{
my $result="";
  my $ebsType=uc($testEbs);
  my @o1=executeThis("mkdir -p /eniq/data/pmdata/ebs/ebs_ebs$testEbs"); 
  $result.= "mkdir -p /eniq/data/pmdata/ebs/ebs_ebs$testEbs<br>\n";
  my @o2=executeThis("mkdir -p /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs");
  $result.= "mkdir -p /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs<br>";
  ebs_mom($ebsType,$ebsCounterGroup,$ebsRefCounter);
  my $count=$ebsCounterGroup*$ebsRefCounter;
  my @o3=executeThis("cp /eniq/home/dcuser/EBS$ebsType.xml /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/MOM\_$count.xml");
  system("chmod 777  /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/MOM\_$count.xml");
  sleep(20);
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  sleep(20);

# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  sleep(20);

# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
  sleep(20);
# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");


  print "INTF_PM_E_EBS$ebsType-eniq_oss_1 Distributor_MOM_EBS$ebsType Start\n";
  sleep(20);
  my @output=(@o1,@o2,@o3);
  foreach my $out1 (@output)
  {
    $result.= "\t$out1<br>\n";
  }
  print "sleep 20 sec\n";
  sleep(20);

# GET COOKIES  AND JSESSIONID NOTHING ELSE
  my $t1=getSeconds();
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  https://localhost:8443/adminui/servlet/EbsUpgradeManager");

# SEND USER AND PASSWORD
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

# UPGRADE EBS
  system("/usr/sfw/bin/wget --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=action_run_upgrade&upgradeId=PM_E_EBS$ebsType&submit='Upgrade now!'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");

sleep(20);
# WAIT UNTIL IS UPGRADED
my $status=0;
my $found=0;
# DELETE PREVIOUS RUNS
do{
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @ebs=executeThis("/usr/sfw/bin/wget --quiet --no-check-certificate -O  /eniq/home/dcuser/ebs_upgrade.html  --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt   --post-data \"action=action_get_upgrade_status&submit='refresh status'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");
  open(EBS,"<  /eniq/home/dcuser/ebs_upgrade.html");
  my @ebsresult=<EBS>; 
  close(EBS);
  foreach my $ebsresult (@ebsresult) 
  {
    $_=$ebsresult;
    if(/PM_E_EBS$ebsType/)                                
       {$found=1;};
    if($found==1 && /Running\.\.\./)                      
       {
          print "EBS upgrade running...sleep 1min\n";
          sleep(60);
       }
    if($found==1 && /Previous run finished successfully|Previous status not available/) 
       {
          print "EBS run finished succesfully.\n";
          $result.="EBS$ebsType run finished succesfully.<br>\n";
          $status=1;
          last;
        }
    if($found==1 && /<.form>/) 
       {$found=0; last;};
  }
}while($status==0);
  my $t2=getSeconds();
  my $ebsUpgradeTime=$t2-$t1;
  print "Upgrade time: $ebsUpgradeTime sec\n";
  $result.= "Upgrade time: $ebsUpgradeTime sec<br>";
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @out2=executeThis("ls /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/*xml| wc -l ");
  $result.= "Verify if xml file exists in /eniq/data/pmdata/eniq_oss_1/ebs/ebs_ebs$testEbs/<br>\n";

  if($out2[0] == "0")
    {
      $result.= "\t<font color=006600><b>PASS</b></font> EBS$ebsType MOM file has been processed<br>\n";
      $result.= checkEBSCounters();
      $result.= checkEBSColumns();
    }
  else
    {
      $result.= "\t<font color=ff0000><b>FAIL</b></font> EBS$ebsType MOM file has not been processed<br>\n";
    }
#LOGOUT 
system("/usr/sfw/bin/wget --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/Logout  ");

 return $result;
}
############################################################
# LOAD EBS
# This process is in charge or generating the EBS data file, in the dcuser home directory EBS_data.xml file
# places the data file in /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1 directory
# then it copies the file
# 
sub loadEbs{
 my $result="";
 my $ebsType=uc($loadEbs);
 #ebs_data($ebsType,$ebsCounterGroup,$ebsRefCounter,$ebsEmptyValue,$ebsNullValue,$ebsYear,$ebsMonth,$ebsDay,$ebsHour);
 my $HOUR1=$ebsHour;
 my $HOUR2=$ebsHour;
 my $MIN1 =$ebsMin;
 my $MIN2 =$ebsMin;
 for(my $ROP=0;$ROP<$numRops; $ROP++)
 { 
    $MIN1=($ebsMin + ($ROP*15)%60 );
    if($MIN1==0) {$MIN1="00";}
    $MIN2=($ebsMin + (($ROP*15) +15 )%60);
    if($MIN2==0) {$MIN2="00";}
 
    if(($ebsMin + ($ROP*15))>60)
    {
      $HOUR1=$ebsHour++;
    }
    else
    {
      $HOUR1=$ebsHour;
    }
    if($MIN1==45 && $MIN2 eq "00")
    {
      $HOUR2=$HOUR1+1;
    }
    else
    {
      $HOUR2=$HOUR1;
    }

    ebs_data($ebsType,$ebsCounterGroup,$ebsRefCounter,$ebsEmptyValue,$ebsNullValue,$ebsYear,$ebsMonth,$ebsDay,$HOUR1,$MIN1);

    system("mkdir -p /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1 ");
    if($ebsType eq "S")
     {
       system("cp EBS$ebsType\_data.xml /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1/A$ebsYear$ebsMonth$ebsDay.$HOUR1"."$MIN1+0200-$HOUR2"."$MIN2.$HOUR2"."$MIN2+0200_SubNetwork=EBA_SGSN,ManagedElement=SGSN04_-_1.xml");
     }
    if($ebsType eq "G")
     {
       system("cp EBS$ebsType\_data.xml /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1/A$ebsYear$ebsMonth$ebsDay.$HOUR1"."$MIN1+0200-$HOUR2"."$MIN2.$HOUR2"."$MIN2+0200_SubNetwork=ONRM_ROOT_MO,ManagedElement=AXE0_-_1.xml");
     }
    if($ebsType eq "W")
     {
      system("cp EBS$ebsType\_data.xml /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1/A$ebsYear$ebsMonth$ebsDay.$HOUR1"."$MIN1\-$HOUR2"."$MIN2\_SubNetwork=NRO_RootMo_R,SubNetwork=RNC01,MeContext=RNC01_statsfile_-_1.xml");
     }
 }
   if($ebsUseGzip eq "true")
     {
      system("/usr/bin/gzip /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1/* ");
     }
 return "EBS$ebsType\_data.xml generated, renamed and placed in data directory /eniq/data/pmdata/eniq_oss_1/eba_ebs$loadEbs/1<br>\n"; 
}
############################################################
# GET TIMESTAMP
# This is a utility 
sub getTime{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  return sprintf "%4d-%02d-%02d %02d:%02d:%02d\n", $year+1900,$mon+1,$mday,$hour,$min,$sec;
}
############################################################
# GET DATE
# This is a utility
sub getDate{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  return sprintf "%4d%02d%02d%02d%02d%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
}
############################################################
# GET TIME SECONDS 
# This is a utility
sub getSeconds{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  my $time = $sec + ($min*60) + ($hour*3600) + ($mday*86400) + (($mon+1)*24*86400) ;
  return $time;
}
############################################################
# GET DATE WITH TIMEWARP
# This is a utility
sub getDateTimewarp{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time+$timeWarp*3600);
  return sprintf "%4d%02d%02d", $year+1900,$mon+1,$mday;
}
############################################################
# GET YEAR WITH TIMEWARP
# This is a utility
sub getYearTimewarp{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time+$timeWarp*3600);
  return sprintf "%4d", $year+1900;
}
############################################################
# GET MONTH WITH TIMEWARP
# This is a utility
sub getMonthTimewarp{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time+$timeWarp*3600);
  return sprintf "%02d", $mon+1;
}
############################################################
# GET DAY WITH TIMEWARP
# This is a utility
sub getDayTimewarp{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time+$timeWarp*3600);
  return sprintf "%02d", $mday;
}
############################################################
# GET HOUR WITH TIMEWARP
# This is a utility
sub getHourTimewarp{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time+$timeWarp*3600);
  return sprintf "%02d", $hour;
}
############################################################
# MAIN
# This is a simple main that starts the generation of the HTML log file and 
# calls the parseParam subroutine that controls the execution of the script
# Then when all tests are finished writes the log HTML file in the same directory 
# where this script is executed
{

  if((@ARGV)==0)
  {
    print info();
    exit(0);
  }
  mkdir("$LOGPATH");
  #my $mem_left=getmemory_left();
  #my $mem_left=41; ####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ to bypass the mem check if no epfg data to be generated
  #if ($mem_left >40 && services_check()==0)
  #{
    ################################
  	#       Print Server details   #
	
	print_server_details();
	
	################################
	
	my $report =getHtmlHeader();
  	$report.= "<h2>STARTTIME:";
  	$report.= getTime();
  	$report.= "<h2>HOST:\n";
  	my $host= getHostName();
  	$report.= getHostName()."</h2>";
  	$report.= "<h2>VERSION:\n";
  	$report.= verifyVersion()."</h2>";
  	$report.= parseParam();
  	$report.= "<h2>ENDTIME:";
  	$report.= getTime()."</h2>";
  	$report.= getHtmlTail(); 
  	my $file = writeHtml($host,$report);
  	print efile;
  #}
 # else
  #{
   #	print "\n The Pre-requesit conditions for running RT are not satisfied!!";
   #	print "\n Either ENIQ Services not Online OR There is no sufficient memory in DB!!!!";
   #	print "\n Memory Left: $mem_left GB \n";
  #}
}
###############

###############
sub startRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."StartTime=|"; 
   }
  chop($regexp);
  return $regexp;
}
##########
###############
sub flagRegExp{
  my @tps1=@_;
    my $regexp="";
  for my $line (@tps1)
   {
    my $tp=$epfg_tps{$line};
	$regexp.="^$tp"."GenFlag=|"; 
   }
  chop($regexp);
  return $regexp;
}
##########

sub endRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."EndTime=|";
   }
  chop($regexp);
  return $regexp;
}
#########
sub nodesRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."NoOfNodes=|";
   }
  chop($regexp);
  return $regexp;
}
######################
sub nenodesRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."NoOfNeNodes=|";
   }
  chop($regexp);
  return $regexp;
}
sub StartNodeRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."StartNode=|";
   }
  chop($regexp);
  return $regexp;
}
sub EndNodeRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."EndNode=|";
   }
  chop($regexp);
  return $regexp;
}
##################
sub getToptime{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  return sprintf "%02d-%02d-%4d-%02d:%02d",$mday,$mon+1,$year+1900,$hour,$min+1;
  }
##################
sub GenWhatRegExp{
  my @tps=@_;
  my $regexp="";
  for my $line (@tps)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."GenWhat=|"; 
   }
  chop($regexp);
  return $regexp;
}
##########
sub ConfigFileOutputPathRegExp{
  my @tps=@_;
  my $regexp="";
  for my $line (@tps)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."ConfigFileOutputPath=|"; 
   }
  chop($regexp);
  return $regexp;
}
###############
sub ConfigFileRegExp{
  my @tps=@_;
  my $regexp="";
  for my $line (@tps)
   {
     my $tp=$epfg_tps{$line};
     $regexp.="^$tp"."ConfigFile=|"; 
   }
  chop($regexp);
  return $regexp;
}
#######################################
# This is used for changing the Config file paths from old to new.
sub configpath_change {
my $config_name=shift;
my $actual_path=shift;
#print "$config_name\n";
#my $required_name=substring($config_name,-1,10);
$config_name=~s/ConfigFileOutputPath/ConfigFile/;
#print "$config_name\n";
#print "$actual_path\n";
$hash{ $config_name } = $actual_path;
#print %hash ;
}
###################################
# This is for Config Files generation.
sub configfile_gen{
 my $GEN_TYPE="CONFIG_FILE";
 my $FLAG="YES";
 my $NoTopology="NO";
 my $path="/eniq/home/dcuser/epfg/config";
 my $OMS="YES";
 my $con_path="";
 my $param_name="";
 # READ THE FILE 
open(INPUT,"< $path/epfg.properties");
my @input=<INPUT>;
chomp(@input);
close(INPUT);
#################
open(OUTPUT, "> $path/epfg.configoutput");

##################

for my $line (@input) 
 {
  $_=$line;
  my $gen_type=GenWhatRegExp(@epfg_techPacks);
  my $flag=flagRegExp(@epfg_techPacks);
  my $config_path=ConfigFileOutputPathRegExp(@epfg_techPacks);
  if(/$gen_type/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$GEN_TYPE\n"; 
   }
      elsif(/$flag/)
   { 
     $line=~s/=.*/=/;
     print OUTPUT "$line$FLAG\n";
   }
    elsif(/omsConfigFileGenFlag/)
   { 
     $line=~s/=.*/=/;
     print OUTPUT "$line$OMS\n";
   }
     elsif(/enableTopologyGen=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NoTopology\n";
   }
    elsif(/$config_path/)
   {
     if ($line=~m/(.*)=(.*)/)
	  {
	    $param_name=$1;
	    $con_path=$2;
	  }
	 $line=~s/=.*/=/;
	 configpath_change($param_name,$con_path);
	 print OUTPUT "$line$con_path\n";
   }
   else
   {
     print OUTPUT "$line\n";
   }
  }
  system("rm $path/epfg.properties");
  system("cp $path/epfg.configoutput $path/epfg.properties");
###############
close(OUTPUT);
}
###################
sub change_config
{
my $key="";
my $hashed_result="";
my $path="/eniq/home/dcuser/epfg/config";
my $GEN_TYPE1="PM_FILE";
# CONFIG FILE
#open(CONFIG,"< epfg.config");
#my @config=<CONFIG>;
#my @techpacks=split(/,/,$config[0]);
#chomp(@techpacks);
#close(CONFIG);
#############
open(INPUT1,"< $path/epfg.configoutput");
my @input1=<INPUT1>;
chomp(@input1);
close(INPUT1);
#################
open(OUTPUT1, "> $path/epfg.configoutput1");
for my $line (@input1) 
 {
  $_=$line;
  my $config_path1=ConfigFileRegExp(@epfg_techPacks);
  my $gen_type1=GenWhatRegExp(@epfg_techPacks);
  
  if(/$gen_type1/)
   {
     $line=~s/=.*/=/;
     print OUTPUT1 "$line$GEN_TYPE1\n"; 
   }
  elsif(/$config_path1/)
   {
     if ($line=~m/(.*)=(.*)/)
	  {
	    $key=$1;
	    #$con_path=$2;
	  }
     $line=~s/=.*/=/;
	 $hashed_result=$hash{$key};
     print OUTPUT1 "$line$hashed_result\n"; 
   }
  else
   {
     print OUTPUT1 "$line\n";
   }
  }
  system("rm $path/epfg.properties");
  system("cp $path/epfg.configoutput1 $path/epfg.properties");
  close(OUTPUT1);
}
######################################
# TOPOLOGY BACKUP
# This is to get the topology files backup.
sub topology_backup{

my $backup_path="/eniq/home/dcuser";
my $original_path="/eniq/data/pmdata/eniq_oss_1/";

if(-d "$backup_path/topology_backup")
{ 
   `rm -rf $backup_path/topology_backup`;
}

system("mkdir $backup_path/topology_backup/");

system("cp -R $original_path/core $backup_path/topology_backup/core");
system("cp -R $original_path/gran $backup_path/topology_backup/gran");
system("cp -R $original_path/lte $backup_path/topology_backup/lte");
system("cp -R $original_path/utran $backup_path/topology_backup/utran");
system("cp -R $original_path/tdran $backup_path/topology_backup/tdran");
system("cp -R $original_path/tss $backup_path/topology_backup/tss");
system("cp -R $original_path/snmp $backup_path/topology_backup/snmp");
}

##############################################################################
# Load Topology From Backup folder

sub epfgupdateTopology{

my $backup_path="/eniq/home/dcuser";
my $original_path="/eniq/data/pmdata/eniq_oss_1/";

system("cp -r $backup_path/topology_backup/core $original_path/");
system("cp -r $backup_path/topology_backup/gran $original_path/");
system("cp -r $backup_path/topology_backup/lte $original_path/ ");
system("cp -r $backup_path/topology_backup/utran $original_path/");
system("cp -r $backup_path/topology_backup/tdran $original_path/");
system("cp -r $backup_path/topology_backup/tss $original_path/");
system("cp -r $backup_path/topology_backup/snmp $original_path/");

}

###############################################################################
#BusyHour Information
# queries the database for the BusyHour tables and counts the rows
# if the number of rows is 0, it fails the test case

sub verifyDayBH{
my $result="";
 my @allDAYBHtables=getAllBHTables("DAYBH");
 $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>fbusyhour
 TABLE</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};
 foreach my $tables (@allDAYBHtables)
  {
   my @data=getBHLoading($tables); 
    foreach my $data (@data)
     {
       $_=$data; 
       next if(/affected/);
       next if(/Msg 102, Level 15, State 0:/);
       next if(/^$/);
       $data=~ s/\|0/|<b>0<\/b>/;
       $data=~ s/^/<tr><td>/g;
       $data=~ s/ //g;
       $data=~ s/\|/<\/td><td align=center>/g;
       $_=$data;
       if(/<b>0<.b>/)
       {
         $data=~ s/$/<\/td><td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr>/;
       }
       else
       {
          $data=~ s/$/<\/td><td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr>/;
       } 
       $result.="$data\n"; 
     }
  }
 $result.="</table>\n";
 return $result;
}
##################################
sub getAllBHTables
{
my $table_type=shift;
#print "\n tablename:$table_type";
my $sql=qq{
select 
distinct MTABLEID 
from MeasurementColumn 
where MTABLEID like "%DC_E_%$table_type"; 
go
EOF
 };
 #print "\n $sql";
 my @result=undef;
 open(DATA,"$sybase_dir -Udwhrep -Pdwhrep -h0 -Drepdb -Srepdb -w 100 -b << EOF $sql |")|| die $!;
 
 #print "$sybase_dir";
 
 my @data=<DATA>;
 chomp(@data);
 my $rows=@data;
 my @bhtps=();
 my $i=0;
 foreach my $tp(@data)
 {
   $_=$tp;
   $tp=~s/ //g;
   next if(/affected/);
   next if(/^$/);
   $tp=~s/.*\)://g;
   $tp=~s/:/_/g;
   push @result,$tp;
}
close(DATA);
return @result;
 }
 #############################
 sub getBHLoading
 {
 my $table_name=shift;
 #print "\ntableName:$table_name\n";
 my $sql=qq{
select
'$table_name'||'|'||
count(*) as COUNT
from $table_name; 
go
EOF
 };
my @result1=undef;
 open(COUNT,"$sybase_dir -Udc -Pdc -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |")|| die $!;
 
 #print "$sybase_dir";
 
 my @count=<COUNT>;
 chomp(@count);
 close(COUNT);
 #print "Count in the table=$count[0]\n";
 push @result1,$count[0];
 return @result1;
 }
###################
# RANKBH Information
# queries the database for the RANKBH tables and counts the rows
# if the number of rows is 0, it fails the test case

sub verifyRANKBH{
my $result="";
 my @allRANKBHtables=getAllBHTables("RANKBH");
 $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>RANKBH TABLE</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};
 foreach my $tables (@allRANKBHtables)
  {
   my @data=getBHLoading($tables); 
   my $temp="";
    foreach my $data (@data)
     {
       $_=$data; 
       next if(/affected/);
       next if(/Msg 102, Level 15, State 0:/);
       next if(/^$/);
	   print"\n Result=$data";
       $data=~ s/\|0/|<b>0<\/b>/;
       $data=~ s/^/<tr><td>/g;
       $data=~ s/ //g;
       $data=~ s/\|/<\/td><td align=center>/g;
       $_=$data;
	   #print"\n Result=$data";
       if(/<b>0<.b>/||/<b>1<.b>/||/<b>2<.b>/)
       {
         $data=~ s/$/<\/td><td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr>/;
       }
       else
       {
          $data=~ s/$/<\/td><td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr>/;
       } 
       $result.="$data\n"; 
     }
  }
 $result.="</table>\n";
 return $result;
}
##############################################################
# EPFG Version Details
#This is to get the version of EPFG package used for RT
sub getepfg_version {
my $version_path="/eniq/home/dcuser/epfg/";
open(INPUT1,"< $version_path/version.txt");
my @input1=<INPUT1>;
chomp(@input1);
close(INPUT1);
for my $line (@input1) 
  {
	$_=$line;
	if(/R-state=/)
	  {
		$line=~s/.*=//;
		return $line;
	  }
  }
}
###########################################################
sub getmemory_left
{
my $sql=qq{
sp_iqstatus 
go
EOF
 };
 open(DATA,"$sybase_dir -Udba -Psql -h0 -Ddwhdb -Sdwhdb -w 1000 -b << EOF $sql |")|| die $!;
 my @data=<DATA>;
 chomp(@data);
 close(DATA);
 my $result="";
 foreach my $line(@data)
  {
   $_=$line;
	if(/Main IQ Blocks Used/)
	{
		if ($line=~/(.*:\W+)(\d+) of (\d+),(.*),(.*)/)
		{
			print "\n EJOHMCI \($3-$2\)\/32800  \n";
			$result=($3-$2)/32800;
			print "\n   DISK TEST REQ --> DISK --> $result \n";	
			return $result;
		}
    }

  }
}
#########################################################
sub services_check
{
my $flag=0;
my @services=executeThis("svcs -a| grep eniq "); 
 chomp(@services);
 foreach my $service (@services)
  {
   $_=$service;
   next if(/roll-snap:default/);
   if (!($service=~/^online/))
    {
	   return 1;
	}
	else 
	{
	   return 0;
	}
  }
}
#####################################################

###########################################################
##            This is newly added function               ##
##  It will create one new out-put file which will 		 ##
##  print the Details of the server (name,eniq version). ##
##	If the code stooped in middele of any test-case then ## 
##	we are not getting the final log file.				 ##
###########################################################
sub print_server_details
{

	my $report =getHtmlHeader();
	$report.= "<h2>STARTTIME:";
	$report.= getTime();
	
	$report.= "<h2>HOST:\n";
	open(HOST,"hostname |");
	my @host=<HOST>;
	$report.=$host[0]."</h2>";
	close(HOST);
	
	$report.= "<h2>HISTORY:\n";
	open(VER,"cat /eniq/admin/version/eniq_history |");
	my @version=<VER>;
	
	foreach my $vers(@version)
	{
	  $report.= "<br>".$vers;
	}
	
	$report.="</h2>";
	close(VER);
  	
  	$report.= "<h2>ENDTIME:";
  	$report.= getTime()."</h2>";
  	$report.= getHtmlTail(); 
  	my $file = writeHtml("SERVER_DETAILS",$report);
  	
}
###########################################################
############################################################
# Create all snapshots#

sub CreateSnapshots{
my  $result=qq{
<h3>RUN CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
 
  <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
my $script=qq{ 
(
 sleep 2 ;
 echo "root" ; sleep 2; 
 echo "shroot\n"; sleep 2 ; 
 echo "cd /eniq/bkup_sw/bin/"; sleep 2;
 echo "pwd"; sleep 2;
 echo "ls"; sleep 2;
 echo "/usr/bin/bash ./prepare_eniq_bkup.bsh -R" ;sleep 2;
 echo "Yes"; sleep 30;
) | telnet localhost
};
 

    my @res=executeThis($script); 
     print $script;
     my @result=map {$_."<br>"} @res; 
     $result.= "<tr><td>this is a test:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        print $res;
		$_=$res;
        if(/ERROR/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           
         }
        else
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
         }

		
      }
      if((@result)==0)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         } 

  $result.=qq{</table>};
  return $result;



}
sub CreateRackSnapshots{
my  $result=qq{
<h3>RUN CMD LINE CHECK EXCEPTIONS OR ERRORS ON EXECUTION</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
 
  <tr>
     <th>CMD</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
};
my $script=qq{ 
(
 sleep 2 ;
 echo "root" ; sleep 2; 
 echo "shroot\n"; sleep 2 ; 
 echo "cd /eniq/admin/bin/"; sleep 2;
 echo "bash ./manage_eniq_services.bsh -a stop -s ALL"; sleep 3;
 echo "Yes"; sleep 2;
 echo "cd /eniq/bkup_sw/bin/"; sleep 1;
 echo "pwd"; sleep 1;
 echo "bash ./manage_zfs_snapshots.bsh -a create -f ALL -n panch"; sleep 3;
 echo "Yes"; sleep 20;
) | telnet localhost
};
 

    my @res=executeThis($script); 
     print $script;
     my @result=map {$_."<br>"} @res; 
     $result.= "<tr><td>this is a test:</td><td>@result</td>\n";
     foreach my $res (@result)
      {
        print $res;
		$_=$res;
        if(/ERROR/i)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           
         }
        else
         {
           $result.= "<td><font color=006600><b>PASS</b></font></td></tr>";
         }

		
      }
      if((@result)==0)
         {
           $result.= "<td><font color=ff0000><b>FAIL</b></font></td></tr>";
           print "FAIL\n";
         } 

  $result.=qq{</table>};
  return $result;



}


#######################################################################



