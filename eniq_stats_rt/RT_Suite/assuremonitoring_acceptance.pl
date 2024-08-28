#!/usr/bin/perl -w

use FindBin;
use lib "$FindBin::Bin";

our $acceptanceTestDir = "/eniq/home/dcuser/RegressionLogs";
our $failureReason = "N.A.";
our $hqpdkJarLocation = "/opt/hyperic-agent/hyperic-hq-agent/bundles/agent-4.6.6.1/pdk/lib/hq-pdk-4.6.6.1.jar";
our $html;
our ($startTime, $endTime);

sub main
{
    $startTime=localtime();
    $html=getHtmlHeader();
    setup();
    runTestCases();
    $html.=getHtmlTail();
    createHtmlFile();
}

sub createHtmlFile(){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
    $mon++;
    $year=1900+$year;
    my $date =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);

    open(OUT,">","$acceptanceTestDir/ASSUREMONITOR_ACCEPTANCE_$date.html") or die "cannot create/open file ASSUREMONITOR_ACCEPTANCE_$date.html";
    print OUT $html;
    close(OUT);
}

sub getHtmlHeader{
return qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
        <head>
                <title>AssureMonitoring Acceptance Tests</title>
        </head>
        <body bgcolor=GhostWhite>
        <center>
                <table border="3" cellspacing="2" cellpadding="3" width="50%">
                        <tr>
                                <th colspan=3><h1>AssureMonitoring Acceptance Tests</h1></th>
                        </tr>
                        <tr>
                                <th>Test Case Name</th>
                                <th>Test Result</th>
                                <th>Failure Reason</th>
                        </tr>
};
}

sub getHtmlTail{
    $endTime=localtime();
return qq{
                        <tr align="left">
                                <th>Start Time</th>
                                <td colspan=2>$startTime</td>
                        </tr>
                        <tr align="left">
                                <th>End Time</th>
                                <td colspan=2>$endTime</td>
                        </tr>
                </table>
        </center>
        </body>
</html>
};
}

sub setup{
    $copy_plugin = system('./_expect.sh "cp /opt/assuremonitoring-plugins/plugins/* /opt/hyperic-agent/hyperic-hq-agent/bundles/agent-4.6.6.1/pdk/plugins/"');

    if ($copy_plugin != 0 ){
       $html.=qq{<tr align="left"><td colspan=3><font color="red">Setup Failure : Unable to copy plugin</font></tr>};
       $html.=getHtmlTail();
       createHtmlFile();
       exit 0;
    }
}

sub runTestCases{
    printf "\n######################## AssureMonitoring OSS-MT plugin TEST CASES ###########\n\n";

    #TC 1: Check if the plugin is is discovered.
    assertUtils(testPluginDiscovery(),"Plugin Discovery check for Backlog Analysis Server","testPluginDiscovery",$failureReason);

    #TC 2: Check metric collection for Backlog Analysis server resource.
    assertUtils(testPluginMetricCollectionForServer(),"Metric collection check for Backlog Analysis Server","testMetricCollection",$failureReason);

    #TC 3: Check metric collection for Backlog Analysis Interface service resource.
    assertUtils(testPluginMetricCollectionForService(),"Metric collection check for Backlog Analysis Interface service","testMetricCollection",$failureReason);

    printf "\n######################### All Test Cases for plugin are executed ##################\n";
}

sub testPluginDiscovery(){
    $failureReason = "N.A.";
    $output = `./_expect.sh "java -jar $hqpdkJarLocation -p backlog -m discover"`;

    if ($output !~ m/1 servers detected/){
        $failureReason = "Baclog Analysis server resource could not be detected.";
        return 1;
    }

    if ($output =~ m/Runtime Resource Report...none/){
        $failureReason = "Baclog Analysis Interface service resource could not be detected.";
        return 1;
    }

    if ($output =~ m/ERROR/){
        $failureReason = "ERROR executing plugin discovery.";
        return 1;
    }

    return 0;
}

sub testPluginMetricCollectionForServer(){
    $failureReason = "N.A.";
    $output = `./_expect.sh "java -jar $hqpdkJarLocation -p backlog -t \\"Backlog Analysis\\" -m metric -Dscript=/opt/assuremonitoring-plugins/scripts/backlog.pl -Dtimeout=60"`;

    if ($output !~ m/=>100.0%<=/){
        $failureReason = "Availability is not 100%";
        return 1;
    }

    if ($output =~ m/ERROR/){
        $failureReason = "ERROR executing plugin discovery.";
        return 1;
    }

    return 0;
}

sub testPluginMetricCollectionForService(){
    $failureReason = "N.A.";
    $output = `./_expect.sh "java -jar $hqpdkJarLocation -p backlog -t \\"Backlog Analysis Interface\\" -m metric -Dscript=/opt/assuremonitoring-plugins/scripts/backlog.pl -Dinterface_name=INTF_"`;

    if ($output !~ m/=>100.0%<=/){
        $failureReason = "Availability is not 100%";
        return 1;
    }

    if ($output =~ m/ERROR/){
        $failureReason = "ERROR executing plugin discovery.";
        return 1;
    }

    return 0;
}

sub assertUtils
{
    my ($output,$testCaseName,$testTag,$failureReason) = @_;
    if($output eq 0){
        $html.=qq{<tr align="left"><td>$testCaseName</td><td><font color="green">PASS</font></td><td>$failureReason</td></tr>};
    }
    else{
        $html.=qq{<tr align="left"><td>$testCaseName</td><td><font color="red">FAIL</font></td><td>$failureReason</td></tr>};
    }
}

main();
