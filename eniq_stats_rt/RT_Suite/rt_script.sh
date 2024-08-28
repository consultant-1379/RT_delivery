#!/usr/bin/perl -C0

	use strict;
	use warnings;
	use Text::CSV;
	use File::Slurp;
	use DBI;
	use POSIX qw(strftime);
	use MCE::Grep Sereal => 1;
	use MCE::Loop;
	use MCE::Util;
	use Expect;
	use Data::Dumper;
	use threads;

	 MCE::Grep::init {
      chunk_size => '100M', max_workers => MCE::Util::get_ncpu,

      user_begin => sub {
         #print "## ", MCE->wid, " started\n";
      },

      user_end => sub {
         #print "## ", MCE->wid, " completed\n";
      }
   };

   MCE::Loop::init {
      chunk_size => 1, max_workers => MCE::Util::get_ncpu,
   };


my $LOGPATH="/eniq/home/dcuser/RegressionLogs";
my %hash=();
my $WGET = "/usr/sfw/bin/wget";

if ( $^O eq "linux" ) {
	$WGET = "/usr/bin/wget";
}


#########################
my %epfg_tps=(
"EBA-EBSW","ebawRnc" ,
"EBA-EBSG","ebagBsc" ,
"SASN","sasn" ,
"SASN-SARA","sasnSara" ,
"GGSN","ggsn" ,
"PGW","ggsnPgw" ,
"SGW","ggsnSgw" ,
"MPG","ggsnMpg" ,
"EPG-MBMSGW","epgMbmSgw" ,
"EPG(GGSN_MPG)","epg" ,
"NODE","ggsnNode" ,
"EPG-YANG","epgyang" ,
"EPG-YANG","epgyang2" ,
"wmg-yang","wmgyang" ,
"CCRC","CCRC" ,
"CCPC","CCPC" ,
"CCDM","CCDM" ,
"CCSM","CCSM" ,
"CCES","CCES" ,
"vNSDS","vNSDS" ,
"PCG","PCG" ,
"SMSF","SMSF" ,
"SC","SC" ,
"CUDB","cudb" ,
"EIR-FE","EirFe" ,
"EIRFE","EIRFE" ,
"WMG","Wmg" ,
"WMG","wmg" ,
"WLE","wle" ,
"ESC","Esc" ,
"ESC","ESC" ,
"GSM","gsm:GSMG2:GSMMixModeOff:GSM" ,
"OMS","omsConfigFile" ,
"MSC-APG","mscApg" ,
"MSC-IOG","mscIog" ,
"MSC-BC","mscBc" ,
"MSC-APGOMS","mscApgOms" ,
"MSC-IOGOMS","mscIogOms" ,
"MSC-BCOMS","mscBcOms" ,
"HLR-APG","hlrServerApg" ,
"HLR-IOG","hlrServerIog" ,
"EBSS-SGSN","ebssSgsn" ,
"EBSS-MME","ebssMme" ,
"EBSS-MME","enable3gpp" ,
"SGSN-MME","sgsnMme" ,
"SGSN","sgsn" ,
"SGSNMME","sgsnmmecom" ,
"PCC","PCC" ,
"scef","scef" ,
"MGW","mgw:mgw2fd" ,
"MRS","mrs" ,
"PRBS","PRBS" ,
"TCU03","Tcu03" ,
"EPDG","epdg" ,
"WRAN-LTE","wranLTE:wranERBSG2:wranLte"  ,
"LTE Event Statistics dat","lteEvent" ,
"bss Event Statistics data","bssEvent" ,
"ERBSG2","erbsg2" ,
"RadioNodeMixed","RadioNodeMixed" ,
"RNC","rnc" ,
"Wran-RBS","wranRBS" ,
"Wran-RXI","wranRXI" ,
"FrontHaul","FrontHaul:MiniLinkIndoorSNMP" ,
"vTIF","vTIF" ,
"TD-WiFi","wifi" ,
"TWAMP","twamp" ,
"TWAMP","twampSl" ,
"DSC","dsc" ,
"TSS-ASN","TSSAXEASNAPG" ,
"TSS-ASN","TSSAXEASNIOG" ,
"TSS-ASNOMS","TSSAXEASNOms" ,
"TSSAXE3gpp","TSSAXE3gpp" ,
"IMS-WUIGM","imsWuigm" ,
"MRR","mrr" ,
"NCS BAR","NCS" ,
"BSC-APG","bscApg" ,
"BSC-IOG","bscIog" ,
"STN-PICO","stnPICO:stnPico" ,
"STN-SIU","stnSIU:stnSiu" ,
"STN-TCU","stnTCU:stnTcu" ,
"IPWORKS","ipworks" ,
"SAPC","sapc:sapcECIM" ,
"sapcTSP","sapcTSP" ,
"BSP","bsp" ,
"MLPPP","redbackMlppp" ,
"EDGE-ROUTER","redbackEdgeRtr" ,
"SE-BGF","redbackBgf" ,
"REDBACK ComECIM","RedbComEcim" ,
"CPG","redbackCPG" ,
"SMART_METRO","redbackSmartMetro" ,
"SNMP-NTP","snmpNTP" ,
"SNMP-Mgc","snmpMGC" ,
"SNMP-LANSwitch","snmpLanSwitch" ,
"SNMP-IpRouter","snmpIPRouter" ,
"SNMP-HpMrfp","snmpHPMRFP" ,
"SNMP-GGSN","snmpGgsn" ,
"SNMP-DNSServer","snmpDNSServer" ,
"SNMP_DHCPServer","snmpDHCPServer" ,
"SNMP_Cs_CMS","snmpCSMS" ,
"SNMP_CS_DS","snmpCSDS" ,
"SNMP_Cs_As","snmpCSAS" ,
"SNMP_ACME","snmpAcme" ,
"SNMP_HOTSIP","snmpHotSip" ,
"SNMP_Firewall","snmpFirewall" ,
"SNMP_CSC_DS","snmpCSCDS" ,
"UDM","Udm" ,
"UDM","UDM" ,
"UDR","Udr" ,
"UDR","UDR" ,
"Ausf","Ausf" ,
"AUSF","AUSF" ,
"Nrf","Nrf" ,
"NRF","NRF" ,
"Nssf","Nssf" ,
"NSSF","NSSF" ,
"CSCF","cscf" ,
"vCSCF","vcscf" ,
"SDNC","SDNC" ,
"MTAS","mtas" ,
"mtasTSP","mtasTSP" ,
"RBSG2","RBSG2" ,
"5GRadioNode","5GRadioNode" ,
"Controller","Controller" ,
"AFG","afg" ,
"nrEvents","nrEvents" ,
"SBG","sbg" ,
"SBG(Classic","ISSBG" ,
"BBSC","bbsc" ,
"UPG","upg" ,
"CISCO","CISCO" ,
"Spitfire","spitfire" ,
"ip Transport or Mini -Link","ipTransport" ,
"JUNIPER or JUNOS","JUNIPER" ,
"Mini -Link Outdoor","MinilinkOutdoor" ,
"MinilinkoutdoorSwitch 6391","MinilinkoutdoorSwitch" ,
"WCG","Wcg" ,
"vEME","vEME" ,
"BCE","BCE" ,
"MRSv","MRSv" ,
"MRFC","mrfc" ,
"HSS","hss:hssECIM" ,
"hssTSP","hssTSP:hssTsp" ,
"TSS TGC","tssTgc" ,
"HUAWEI RNC R12 NODE","huaweiRncR12" ,
"NodeBR12","huaweiNodeBR12" ,
"ims","ims" ,
"imsTSP","imsTSP" ,
"imsM","imsM" ,
"TD-RBS","tdRBS" ,
"TD-RNC","tdRNC" ,
"SMPC","smpc" ,
"MGC","mgc" ,
"HLR-BS","hlrBs" ,
"Statistics File","stat" ,
"EM-MTN","emMtn" ,
"EM-MSP","emMsp" ,
"EM-VXX","emSpo" ,
"EM-XSA","emXsa" ,
"EM-DRS","emMdrs" ,
"EM-AXX","emAxx" ,
"EM-SMA","emSma" ,
"EM-SMX","emSmx" ,
"EM-ETU","emEtu" ,
"EM-MLE","emMle" ,
"EM-MHC","emMhc" ,
"EM-MBA","emMba" ,
"EM-IMT","emImt" ,
"EM-MLE","emPmh" ,
"EM-MET","emMet" ,
"EM-SPR","emSpr" ,
"vPP","vPP" ,
"LLE","lle" ,
"TSS-TGC","tssTgc" ,
"IMS","ims" ,
"IMSM","imsM" ,
"IP-RAN","ipran" ,
"IPTNMS-PACKET","emPacket" ,
"IPTNMS-CIRCUIT","emCircuit" ,
"SOEM-PIC","emPicFtp" ,
"SOEM-ASCII","emOptical" ,
"IPTNMS-ASCII","emAscii" ,
"TWAMP","Twamp" ,
"EPG(epdg)","epgepdg" ,
"TWAMPSDC","Twampsdc" ,
"WRAN-RNC","wranRNC" ,
"HLR-Sub","hlrsubsdata" ,
"VLR-Sub","vlrsubsdata" ,
"HUAWEI-RNC","huaweiRnc" ,
"HUAWEI-NODEB","huaweiNodeB" ,
"HUAWEI-NODEBSS","huaweiNodeBss" ,
"TSS","tss" ,
"GMPC","gmpc" ,
"Redback-Bgf","redbackBgf" ,
"Redback-CPG","redbackCPG" ,
"Redback-EdgeRtr","redbackEdgeRtr" ,
"RedbackMlppp","redbackMlppp" ,
"RedbackSmartMetro","redbackSmartMetro" ,
"Scef","Scef" ,
"SDNC","sdnc" ,
"snmpCSAS","snmpCSAS" ,
"snmpCSCDS","snmpCSCDS" ,
"snmpCSDS","snmpCSDS" ,
"snmpCSMS","snmpCSMS" ,
"snmpDHCPServer","snmpDHCPServer" ,
"snmpDNSServer","snmpDNSServer" ,
"snmpHotSip","snmpHotSip" ,
"snmpHPMRFP","snmpHPMRFP" ,
"snmpIPRouter","snmpIPRouter" ,
"snmpMGC","snmpMGC" ,
"snmpNTP","snmpNTP" ,
"NRNSA","NRNSA" ,
"WRAN-RBS_INFO","wranRBS_info" ,
"vSAPC","vSAPC" ,
"WCG","wcg" ,
"vMTAS","vMTAS" ,
"spitFire","spitFire" ,
"IpTransport","IpTransport" ,
"MinilinkIndoor","MinilinkIndoor" ,
"JUNIPER","Juniper" ,
"BCE","bce" ,
"IP-RAN","ipRan" ,
);

my %epfgNodeTPs=();
$epfgNodeTPs{"BSC-APG"}="DC_E_BSS|DC_E_CMN_STS";
$epfgNodeTPs{"BSC-IOG"}="DC_E_BSS|DC_E_CMN_STS";
$epfgNodeTPs{"CPG"}="DC_E_CPG|DC_E_REDB";
$epfgNodeTPs{"CSCF"}="DC_E_CSCF";
$epfgNodeTPs{"CUDB"}="DC_E_CUDB";
$epfgNodeTPs{"DSC"}="DC_E_DSC";
$epfgNodeTPs{"EPDG"}="DC_E_EPDG";
$epfgNodeTPs{"GGSN"}="DC_E_GGSN";
$epfgNodeTPs{"HLR-APG"}="DC_E_BSS";
$epfgNodeTPs{"HLR-IOG"}="DC_E_BSS";
$epfgNodeTPs{"HSS"}="DC_E_HSS";
$epfgNodeTPs{"IMS"}="DC_E_IMS";
$epfgNodeTPs{"IMSM"}="DC_E_IMS";
$epfgNodeTPs{"IPWORKS"}="DC_E_IMS_IPW";
$epfgNodeTPs{"MGW"}="DC_E_MGW|DC_E_IMSGW_MGW";
$epfgNodeTPs{"MRFC"}="DC_E_IMS";
$epfgNodeTPs{"MSC-APG"}="DC_E_CNAXE|DC_E_CMN_STS";
$epfgNodeTPs{"MSC-APGOMS"}="DC_E_CNAXE";
$epfgNodeTPs{"MSC-BC"}="DC_E_CNAXE";
$epfgNodeTPs{"MSC-BCOMS"}="DC_E_CNAXE";
$epfgNodeTPs{"MSC-IOG"}="DC_E_CNAXE|DC_E_CMN_STS";
$epfgNodeTPs{"MSC-IOGOMS"}="DC_E_CNAXE";
$epfgNodeTPs{"MTAS"}="DC_E_MTAS";
$epfgNodeTPs{"PGW"}="DC_E_GGSN";
$epfgNodeTPs{"PRBS"}="DC_E_PRBS_CPP|DC_E_PRBS_ERBS|DC_E_PRBS_RBS";
$epfgNodeTPs{"RNC"}="DC_E_CPP|DC_E_RAN|DC_E_TDRNC";
$epfgNodeTPs{"SAPC"}="DC_E_SAPC";
$epfgNodeTPs{"SASN"}="DC_E_SASN";
$epfgNodeTPs{"SASN-SARA"}="DC_E_SASN-SARA";
$epfgNodeTPs{"SBG"}="DC_E_IMSGW_SBG";
$epfgNodeTPs{"SGSN"}="DC_E_SGSN";
$epfgNodeTPs{"SGSN-MME"}="DC_E_SGSN";
$epfgNodeTPs{"SGW"}="DC_E_GGSN";
$epfgNodeTPs{"STN-PICO"}="DC_E_STN";
$epfgNodeTPs{"STN-SIU"}="DC_E_STN";
$epfgNodeTPs{"STN-TCU"}="DC_E_STN";
$epfgNodeTPs{"TCU03"}="DC_E_TCU";
$epfgNodeTPs{"TD-RBS"}="DC_E_TDRBS";
$epfgNodeTPs{"TD-RNC"}="DC_E_TDRNC";
$epfgNodeTPs{"TD-WiFi"}="DC_E_WIFI";
$epfgNodeTPs{"TWAMP"}="DC_E_IPPROBE";
$epfgNodeTPs{"WRAN-LTE"}="DC_E_ERBS|DC_E_CPP";
$epfgNodeTPs{"Wran-RBS"}="DC_E_RBS|DC_E_CPP";
$epfgNodeTPs{"Wran-RXI"}="DC_E_CPP";
$epfgNodeTPs{"SMPC"}="DC_E_SMPC";
$epfgNodeTPs{"GMPC"}="DC_E_GMPC_GMPC";
$epfgNodeTPs{"vCSCF"}="DC_E_CSCF";
$epfgNodeTPs{"BBSC"}="DC_E_BBSC";
$epfgNodeTPs{"SDNC"}="DC_E_SDNC";
$epfgNodeTPs{"TSS-TGC"}="DC_E_TSS_TGC";
$epfgNodeTPs{"MGC"}="DC_E_IMSGW_MGC";
$epfgNodeTPs{"vPP"}="DC_E_VPP|DC_E_TCU";
$epfgNodeTPs{"MRS"}="DC_E_MRS";
$epfgNodeTPs{"vEME"}="DC_E_vEME";
$epfgNodeTPs{"Juniper"}="DC_J_JUNOS";
$epfgNodeTPs{"NR"}="DC_E_NR";
$epfgNodeTPs{"PCC"}="DC_E_PCC";
$epfgNodeTPs{"Controller"}="DC_E_CONTROLLER";
$epfgNodeTPs{"BULKCM"}="DC_E_BULK_CM";
$epfgNodeTPs{"PCG"}="DC_E_PCG";
$epfgNodeTPs{"SMSF"}="DC_E_SMSF";
$epfgNodeTPs{"UPG"}="DC_E_UPG";
$epfgNodeTPs{"CCDM"}="DC_E_CCDM|DC_E_NRFAGENT";
$epfgNodeTPs{"CCRC"}="DC_E_CCRC|DC_E_NRFAGENT";
$epfgNodeTPs{"CCES"}="DC_E_CCES|DC_E_NRFAGENT";
$epfgNodeTPs{"CCPC"}="DC_E_CCPC|DC_E_NRFAGENT";
$epfgNodeTPs{"CCSM"}="DC_E_CCSM|DC_E_NRFAGENT";
$epfgNodeTPs{"SGSN-MME/vSGSN-MME"}="DC_E_SGSNMME";
$epfgNodeTPs{"EBSS"}="PM_E_EBSS";
$epfgNodeTPs{"MINI-LINK"}="DC_E_IPTRANSPORT";
$epfgNodeTPs{"CPP"}="DC_E_CPP|DC_E_RAN|DC_E_RBS|DC_E_RXI|DC_E_ERBS";
$epfgNodeTPs{"BSS-EVENTS"}="DC_E_BSS";
$epfgNodeTPs{"TSS-AXE"}="DC_E_CMN_STS_PC|DC_E_TSSAXE";
$epfgNodeTPs{"UDM"}="DC_E_UDM";
$epfgNodeTPs{"RBSG2"}="DC_E_RBSG2|DC_E_TCU";
$epfgNodeTPs{"BTSG2"}="DC_E_BTSG2|DC_E_TCU";
$epfgNodeTPs{"vAFG"}="DC_E_AFG";
$epfgNodeTPs{"vECE(SCEF)"}="DC_E_SCEF";
$epfgNodeTPs{"WMG"}="DC_E_WMG";
$epfgNodeTPs{"vNSDS"}="DC_E_NSDS";
$epfgNodeTPs{"vCSCF"}="DC_E_CSCF";
$epfgNodeTPs{"WRAN-RNC"}="DC_E_CPP|DC_E_RAN";
$epfgNodeTPs{"EBSS-MME"}="PM_E_EBSS";
$epfgNodeTPs{"LTE-EVENT"}="DC_E_ERBS";
$epfgNodeTPs{"REDB"}="DC_E_REDB_SMARTMETRO|DC_E_REDB_MLPPP|DC_E_REDB_EDGE|DC_E_REDB_CPG";
$epfgNodeTPs{"RAN"}="DC_E_RNC";
$epfgNodeTPs{"ESC"}="DC_E_ESC";
$epfgNodeTPs{"SC"}="DC_E_SC";
$epfgNodeTPs{"BSP"}="DC_E_BSP";


my %dataValidationTPs=();
#$dataValidationTPs{"BSC-APG"}="";
#$dataValidationTPs{"BSC-IOG"}="";
$dataValidationTPs{"CPG"}="cpg";
$dataValidationTPs{"CSCF"}="cscf";
$dataValidationTPs{"CUDB"}="cudb";
$dataValidationTPs{"DSC"}="dsc";
$dataValidationTPs{"EDGE-ROUTER"}="edgerouter";
$dataValidationTPs{"NODE"}="Node";
$dataValidationTPs{"EPG-MBMSGW"}="mbm_sgw";
#$dataValidationTPs{"EPDG"}="";
$dataValidationTPs{"GGSN"}="ggsn";
#$dataValidationTPs{"HLR-APG"}="";
#$dataValidationTPs{"HLR-IOG"}="";
$dataValidationTPs{"HSS"}="hss";
$dataValidationTPs{"IMS"}="ims";
#$dataValidationTPs{"IMSM"}="";
$dataValidationTPs{"IPWORKS"}="ipworks";
$dataValidationTPs{"MGW"}="mgw";
#$dataValidationTPs{"MGW2.0FD"}="";
$dataValidationTPs{"MLPPP"}="mlppp";
$dataValidationTPs{"MRFC"}="mrfc";
$dataValidationTPs{"MSC-APG"}="msc_apg";
#$dataValidationTPs{"MSC-APGOMS"}="";
#$dataValidationTPs{"MSC-BC"}="";
#$dataValidationTPs{"MSC-BCOMS"}="";
$dataValidationTPs{"MSC-IOG"}="msc_iog";
#$dataValidationTPs{"MSC-IOGOMS"}="";
#$dataValidationTPs{"MTAS"}="";
$dataValidationTPs{"PGW"}="pgw";
#$dataValidationTPs{"PRBS"}="";
$dataValidationTPs{"RNC"}="rnc";
#$dataValidationTPs{"SAPC"}="";
$dataValidationTPs{"SASN"}="sasn";
$dataValidationTPs{"SASN-SARA"}="sasn_sara";
$dataValidationTPs{"SBG"}="sbg";
$dataValidationTPs{"SGSN"}="sgsn";
$dataValidationTPs{"SGSN-MME"}="sgsnmme";
$dataValidationTPs{"SGW"}="sgw";
$dataValidationTPs{"STN-PICO"}="stn_pico";
$dataValidationTPs{"STN-SIU"}="stn_siu";
$dataValidationTPs{"STN-TCU"}="stn_Tcu";
#$dataValidationTPs{"TCU03"}="";
$dataValidationTPs{"TD-RBS"}="tdrbs";
$dataValidationTPs{"TD-RNC"}="tdrnc";
#$dataValidationTPs{"TD-WiFi"}="";
#$dataValidationTPs{"TWAMP"}="";
$dataValidationTPs{"WRAN-LTE"}="LTElte_COMMON";
$dataValidationTPs{"Wran-RBS"}="rbs";
$dataValidationTPs{"Wran-RXI"}="rxi";
$dataValidationTPs{"SMPC"}="smpc";
$dataValidationTPs{"GMPC"}="gmpc";

########################################################################
# Following is the PM file generation nodes 

my %PmGenWhat = (
		"GGSN" => ["ggsn","ggsnMpg","ggsnPgw","ggsnSgw","epgMbmSgw","ggsnNode","epgyang","epgyang2"],
		"CNAXE" => [ "mscApg" ,"mscApgOms","mscIog","mscBc", "hlrApg" , "hlrIog","bscApg","bscIgog","mscBcOms"],
		"SGSN" => ["enable3gpp" ,"ebssSgsn" , "sgsn" , "sgsnMme"], 
		"MGW" => ["mgw","mrs"],
		"SASN" => ["sasn","sasn3gpp"],
		"SAPC" => ["sapc" , "sapcECIM" ,"sapcTSP"],
		"SBG" => ["sbg" ,"ISSBG"],
		"IMS" => ["imsWuigm" ,"ims","imsM","imsTSP"],
		"HSS" => ["hss" , "hssECIM","hssTSP"],
		"WRAN-LTE" => ["wranLte" , "erbsg2"],
		"TD-RNC" => ["tdRNC"],
		"WRAN-RNC" => ["ebawRnc" , "rnc"],
		"BSC" => ["bscApg" , "bscIog" , "BssEvent"],
		"Wran-RBS" => ["wranRBS"],
		"STN" => ["stnPico" , "stnSiu" , "stnTcu" ],                
		"CPG" => ["cpg"],
		"TD-RBS" => ["tdRBS"],                
		"PRBS" => ["PRBS"],
		"DSC" => ["dsc"],
		"EPDG" => ["epdg"],
		"TCU03" => ["Tcu03"],
		"EDGE-ROUTER" => ["edgeRtr"],
		"MTAS" => ["mtas","mtasTSP"],
		"CUDB" => ["cudb","EirFe"],
		"IPWORKS" => ["ipworks"],
		"CSCF" => ["vcscf"],
		"MRFC" => ["mrfc"],
		"WMG" => ["WMG", "wmgyang"],
		"DSC" => ["dsc"],
		"vNSDS" => ["vNSDS"],	
		"SMPC" => ["smpc"],	
		"GMPC" => ["gmpc"],
		"EBSS-MME" => ["ebssMme"],
		"LTE-Event" => ["lteEvent"],
		"vCSCF" => ["vcscf"],
		"TSS-TGC" => ["tssTgc"],
		"MGC" => ["mgc"],
		"BBSC" => ["bbsc"],
		"SDNC" => ["SDNC"],
		"vPP" => ["vPP"],
		"MRS" => ["mrs","MRSv"],
		"vEME" => ["vEME"],
		"MINI-Link" => ["spitfire","iptransport","FrontHaul","MinilinkOutdoor","MiniLinkIndoorSNMP"],
		"Juniper" => ["Juniper"],
		"NR" => ["5GRadioNode","nrEvents"],
		"PCC" => ["PCC"],
		"vAFG" => ["AFG"],
		"Controller" => ["Controller"],
		"RBSG2" => ["RBSG2"],
		"SGSN-MME" => ["sgsnmmecom"],
		"vSGSN-MME" => ["sgsnmmecom"],
		"BSS" => [ "bscApg", "bscIog", "bssEvent"],
		"BULKCM" => [ "enableLteBCGCmdata", "enableERBSG2BCGCmdata", "enableRncBCGCmdata", "enableRbsBCGCmdata", "enableRxiBCGCmdata", "enableGsmBCGCmdata", "enableNrBCGCmdata", "enableMgwBCGCmdata", "enableMscApgBCGCmdata", "enableMscIogBCGCmdata", "enableMscBcBCGCmdata", "enableRanosBCGCmdata"],
		"TSS-AXE" => ["TSSAXEASNAPG", "TSSAXEASNIOG", "TSSAXEASNOms", "TSSAXE3gpp"],
		"BTSG2" => [ "GSMG2GenFlag", "GSMMixModeOff", "RadioNodeMixed"],
		"PCG" => ["PCG"],
		"CCSM" => ["CCSM"],
		"CCRC" => ["CCRC"],
		"CCES" => ["CCES"],
		"CCPC" => ["CCPC"],
		"CCDM" => ["CCDM"],
		"vECE(SCEF)" => ["scef"],
		"SMSF" => ["SMSF"],
		"UDM" => [ "Udm", "Udr", "Ausf", "Nrf", "Nssf"],
		"UPG" => ["upg"],
		"CPP" => [ "rnc","wranrbs", "wranrxi", "wranlte"],
		"BSP"=>["bsp"],
		"ESC"=>["Esc"],
		"RAN"=>["rnc"],
		"REDB"=>["smartMetro","mlppp","edgeRtr","cpg"],
		"SC"=>["SC"],
		"WCG"=>["Wcg"],
		);


my %PmGenNodes = (
		"GGSN" => ["ggsnGenFlag","ggsnMpgGenFlag","ggsnPgwGenFlag","ggsnSgwGenFlag","epgMbmSgwGenFlag","ggsnNodeGenFlag","epgyangGenFlag","epgyang2GenFlag"],
		"CNAXE" => [ "bscApgGenFlag","bscIogGenFlag","mscApgGenFlag","mscApgOmsGenFlag","mscIogGenFlag","mscBcGenFlag","hlrApgGenFlag","hlrIogGenFlag","mscBcOmsGenFlag" ],
		"SGSN" => ["enable3gppGenFlag" ,"ebssSgsnGenFlag" , "sgsnGenFlag" , "sgsnMmeGenFlag"], 
		"MGW" => ["mgwGenFlag","mrsGenFlag"],
		"SASN" => ["sasnGenFlag","sasn3gppGenFlag"],
		"SAPC" => ["sapcGenFlag" ,"sapcECIMGenFlag","sapcTSPGenFlag"],
		"SBG" => ["sbgGenFlag","ISSBGGenFlag"],
		"IMS" => ["imsWuigmGenFlag" ,"imsGenFlag","imsMGenFlag","imsTSPGenFlag"],
		"HSS" => ["hssGenFlag" ,"hssECIMGenFlag","hssTSPGenFlag"],
		"WRAN-LTE" => ["wranLteGenFlag" , "erbsg2GenFlag"],
		"TD-RNC" => ["tdRNCGenFlag"],
		"WRAN-RNC" => ["rncGenFlag"],
		"BSC" => ["bscApgGenFlag" , "bscIogGenFlag" , "BssEventGenFlag"],
		"Wran-RBS" => ["wranRBSGenFlag"],
		"STN" => ["stnPicoGenFlag" , "stnSiuGenFlag" , "stnTcuGenFlag" ],                
		"CPG" => ["cpgGenFlag"],
		"TD-RBS" => ["tdRBSGenFlag"],                
		"PRBS" => ["PRBSGenFlag"],
		"DSC" => ["dscGenFlag"],
		"TCU03" => ["Tcu03GenFlag"],
		"MTAS" => ["mtasGenFlag","mtasTSPGenFlag"],
		"CUDB" => ["cudbGenFlag","EirFeGenFlag"],
		"IPWORKS" => ["ipworksGenFlag"],
		"CSCF" => ["cscfGenFlag"],
		"MRFC" => ["mrfcGenFlag"],
		"WMG"=>["WmgGenFlag","wmgyangGenFlag"],
		"DSC"=>["dscGenFlag"],
		"vNSDS"=>["vNSDSGenFlag"],
		"SMPC" => ["smpcGenFlag"],	
		"GMPC" => ["gmpcGenFlag"],
		"EBSS-MME" => ["ebssMmeGenFlag"],
		"LTE-Event" => ["lteEventGenFlag"], 
		"vCSCF" => ["vcscfGenFlag"],
		"MGC" => ["mgcGenFlag"],
		"HLR-BS" => ["hlrBsGenFlag"],
		"BBSC" => ["bbscGenFlag"],
		"SDNC" => ["SDNCGenFlag"],
		"vPP" => ["vPPGenFlag"],
		"MRS"=>["mrsGenFlag","MRSvGenFlag"],
		"vEME"=>["vEMEGenFlag"],
		"MINI-Link"=>["spitfireGenFlag","ipTransportGenFlag","FrontHaulGenFlag","MinilinkOutdoorGenFlag","MiniLinkIndoorSNMPGenFlag"],
		"Juniper"=>["JUNIPERGenFlag"],
		"NR"=>["5GRadioNodeGenFlag","nrEventsGenFlag"],
		"PCC"=>["PCCGenFlag"],
		"vAFG"=>["afgGenFlag"],
		"Controller"=>["ControllerGenFlag"],
		"RBSG2"=>["RBSG2GenFlag"],
		"SGSN-MME"=>["sgsnmmecomGenFlag"],
		"vSGSN-MME"=>["sgsnmmecomGenFlag"],
		"BSS"=>["bscApgGenFlag","bscIogGenFlag","bssEventGenFlag"],
		"BULKCM"=>["enableLteBCGCmdata","enableERBSG2BCGCmdata","enableRncBCGCmdata","enableRbsBCGCmdata","enableRxiBCGCmdata","enableGsmBCGCmdata","enableNrBCGCmdata","enableMgwBCGCmdata","enableMscApgBCGCmdata","enableMscIogBCGCmdata","enableMscBcBCGCmdata","enableRanosBCGCmdata"],
		"BTSG2"=>["GSMG2GenFlag","GSMMixModeOffGenFlag","RadioNodeMixedGenFlag"],
		"PCG"=>["PCGGenFlag"],
		"CCSM"=>["CCSMGenFlag"],
		"CCRC"=>["CCRCGenFlag"],
		"CCES"=>["CCESGenFlag"],
		"CCPC"=>["CCPCGenFlag"],
		"CCDM"=>["CCDMGenFlag"],
		"vECE(SCEF)"=>["scefGenFlag"],
		"SMSF"=>["SMSFGenFlag"],
		"UDM"=>["UdmGenFlag","UdrGenFlag","AusfGenFlag","NrfGenFlag","NssfGenFlag"],
		"UPG"=>["upgGenFlag"],
		"CPP"=>["rncGenFlag","wranrbsGenFlag","wranRXIGenFlag","wranlteGenFlag"],
		"BSP"=>["bspGenFlag"],
		"TSS-TGC" => ["tssTgcGenFlag"],
		"TSS-AXE"=>["TSSAXEASNAPGGenFlag","TSSAXEASNIOGGenFlag","TSSAXEASNOmsGenFlag","TSSAXE3gppGenFlag"],
		"WCG"=>["WcgGenFlag"],
		"EPDG" => ["epdgGenFlag"],
		"ESC"=>["EscGenFlag"],
		"RAN"=>["rncGenFlag"],
		"REDB"=>["smartMetroGenFlag","mlpppGenFlag","edgeRtrGenFlag","cpgGenFlag"],
		"SC"=>["SCGenflag"],
		);


###########################################
############################################################
# THIS ENV VARIABLE IS NEEDED FOR CRONTAB
$ENV{'SYBASE'}='/eniq/sybase_iq';

#Path of old sybase version
my $sybase_dir_12_7 = "";

#Path of new sybase version
my $sybase_dir_15_2 = "";

open(MWSPROPS, '< /eniq/home/dcuser/mws.properties') or warn("Cannot read mws.properties file!!\n");
my @mwsFile = <MWSPROPS>;
chomp(@mwsFile);
close MWSPROPS;
foreach my $path (@mwsFile){
	$_ = $path;
	if(/^SybaseIQ=/){
		my @input = split("=",$path);
		$sybase_dir_15_2 = '/'.$input[1];
	}
	if(/^SybaseIQOCS=/){
		my @input = split("=",$path);
		$sybase_dir_12_7 = '/'.$input[1];
	}
}

#Store the currently sybase version
my @sybase_version;
#Store the sybase dir path
my $sybase_dir;
my $syb_edition_unchanged;

############################################################
#################################Check the Sybase Version###############################
  @sybase_version=`cat /eniq/sybase_iq/version/iq_version`;
    
  if (($sybase_version[0] =~m/VERSION::12.7.0/)||($sybase_version[0] =~m/VERSION::16.0/))
  {
	$syb_edition_unchanged="true";
	$sybase_dir=$sybase_dir_12_7;
  }
  else
  {
	$syb_edition_unchanged="false";
	$sybase_dir=$sybase_dir_15_2;
  }
  print "Sybase Dir : $sybase_dir\n";
  
###########################################
############################################################
# THIS ENV VARIABLE IS NEEDED FOR CRONTAB
$ENV{'SYBASE'}='/eniq/sybase_iq';

##################################################################################
#             The DATETIME value for the FILENAME of the HTML LOGS               #
##################################################################################

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
  $mon++;
  $year=1900+$year;
my $datenew =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);

###################################################################################


sub executeSQL{

	my $dbname = $_[0];
	my $port = $_[1];
	my $cre = $_[2];
	my $arg = $_[3];
	my $type = $_[4];
	print "executeSQL : $arg  $type $cre $port $dbname\n";
	
	my $dbPwd = getDBPassword($cre);
		
	my $connstr = "ENG=$dbname;CommLinks=tcpip{host=localhost;port=$port};UID=$cre;PWD=$dbPwd";
	my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 1} ) or warn $DBI::errstr;
	my $sel_stmt=$dbh->prepare($arg) or warn $DBI::errstr;

	if ( $type eq "ROW" ) {
	    $sel_stmt->execute() or warn $DBI::errstr;
		my @result = $sel_stmt->fetchrow_array();
		$sel_stmt->finish();
		#$dbh->disconnect;
		return @result;
		}	
	elsif ( $type eq "ALL" ) {
		$sel_stmt->execute() or warn $DBI::errstr;
		my $result = $sel_stmt->fetchall_arrayref();
		foreach my $row (@$result) {
		#print "$row\n";
		}
		$sel_stmt->finish();
		#$dbh->disconnect;
		return $result;
	}
	$dbh->disconnect;
}

my $dcDbPassword = getDBPassword("dc");

sub getAllTechPacksAgg
{
	my $sql="select distinct SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)+1)|| SUBSTR( SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20), 1,CHARINDEX(':',SUBSTR(TYPEID, CHARINDEX(':',TYPEID)+1,20)))|| '&'||SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) from dwhrep.MeasurementCounter where SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DWH_MONITOR' and SUBSTR(TYPEID,0,CHARINDEX(':',TYPEID)) <>'DC_Z_ALARM'";	
	my $res=executeSQL("repdb",2641,"dwhrep",$sql,"ALL");
  
	my @result=undef;

        ###for my $row ( @$res ) {
        ###        for my $field ( @$row ) {
        ###                print "$field\n";
        ###        }
        ###}

	return @result;
}

#my @res = getAllTechPacksAgg();

#ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# This is a utility
# needs one parameter, the techpacks name
# it gets all the tables for that techpack
sub getAllTables4TP{
	my $tp = shift;
	$tp=~ s/ //g;
	my $sql="select A.Table_name from SYSTABLE A where A.table_type like 'VIEW' and A.Table_Name LIKE ('$tp%') and A.creator=103";
	my $allTechPacksTables = executeSQL("dwhdb",2640,"dc",$sql,"ALL");
	
	my @result=undef;
	if( $allTechPacksTables ne "" || $allTechPacksTables eq defined ) {
      	for my $row ( @$allTechPacksTables ) {
                for my $field ( @$row ) {
					push @result, $field;
				}
        }
		chomp(@result);
		@result=grep(/S/, @result);
	}		
	return @result;
}

#ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# This is a utility
# needs one parameter, the techpacks name
# it gets all the tables for that techpack
sub getAllDimTables4TP{
	my $tp = shift;
	$tp=~ s/ //g;
	my $sql="select A.Table_name from SYSTABLE A where A.table_type like 'VIEW' and A.Table_Name LIKE ('$tp%') and A.creator=103";
	my $allTechPacksTables = executeSQL("dwhdb",2640,"dc",$sql,"ALL");
	
	my @result=undef;
	if( $allTechPacksTables ne "" || $allTechPacksTables eq defined ) {
      	for my $row ( @$allTechPacksTables ) {
                for my $field ( @$row ) {
					push @result, $field;
				}
        }
		chomp(@result);
	}		
	return @result;
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

sub executeURL{
	my $htmlFile = $_[0];
	my $url = $_[1];
	#print "$htmlFile   :   $url\n\n";
    system("$WGET --quiet --no-check-certificate -O $htmlFile --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt $url");
    system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
    system("$WGET --quiet --no-check-certificate -O $htmlFile --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies3.txt --load-cookies /eniq/home/dcuser/cookies2.txt $url");
    system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout");
}

############################################################
# UTILITY TO EXECUTE ANY COMMAND AND GET RESULT IN ARRAY
sub executeThis{
my $command = shift;
my @res = `$command`; 
return @res;
}

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
# CHECK LOGGING LEVEL VERIFICATION
# this subroutine veriifies whether logging level changes are reflected correctly in Admin UI
sub loggingLevelVerification
{
	my $htmlFile = "logconfig.html";
	executeThis("perl -i.bak  -p -e 's/etl.DWH_BASE.level=INFO/etl.DWH_BASE.level=FINE/g;' /eniq/sw/conf/engineLogging.properties");
	executeThis("engine restart");
	executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/EditLogging\"");
	open my $info, $htmlFile or die "Could not open $htmlFile: $!";
	my $substrTP="logLevel:DWH_BASE";
	my $substrLevel="<option selected value=\"FINE\">FINE</option>";
	my $status=0;
	my $res=0;
	my $report="";
	while(my $line = <$info>) 
	{
		if( (index($line,$substrTP) == -1) && ($status == 0 )) 
		{
			next
		}
		$status=1;
		if( index($line,$substrLevel) != -1 ) 
		{
			$res=1;
			last
		}
	}
	close $info;
	
	if ($res == 1) 
	{
		print "Logging Level configuration changes verified Successfully..\n";
		$report.= qq{<font color= green>PASS  <font color =black></b>(Logging Level configuration changes verified Successfully)</td>};
	}
	else
	{
		print "Logging configuration mismatch seen in admin UI";
		$report.= qq{<font color= red>FAIL  </b> <font color =black></b>(Logging configuration mismatch seen in admin UI</td>};
	}
	return $report;
}

############################################################
# CHECK ADMINUI_MONITORTYPE  
# this subroutine executes a query to check Type Configuration
# in admin ui is working properly or not.
sub adminuiMonType {
print "inside Monitor Types\n";
my $result;
my $loginURL = "--load-cookies /eniq/home/dcuser/cookies.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check";
my $sql = "SELECT TOP 1 TECHPACK_NAME, TYPENAME, TIMELEVEL, STATUS FROM LOG_MonitoredTypes";
print "1 SQL $sql\n";
my @res = executeSQL("dwhdb",2640,"dc",$sql,"ROW");
my ($TECHPACK_NAME, $TYPENAME, $TIMELEVEL, $STATUS) = @res;
print "2 $TECHPACK_NAME\n";
print "3 $TYPENAME\n";

my $insertMonitorTypeURL = "--post-data 'action=AddMonitoredType&type=$TYPENAME&timelevel=30MIN&status=$STATUS&year_1=2014&month_1=09&day_1=11&save=Add+new+type&timelevel=%24selectedTimelevel&tp=$TECHPACK_NAME' https://localhost:8443/adminui/servlet/AddMonitoredType";
executeURL("InsertMonitorTypeHtml.html",$insertMonitorTypeURL);

print "1 $insertMonitorTypeURL\n";

$sql = "SELECT count(*) FROM LOG_MonitoredTypes WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' AND STATUS='$STATUS'";

print "2 $sql\n";

my ($val) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");
print "\nVal = $val\n";
if ( $val == 1 ) {

print "\nPASS: Adding new Monitoring Type verified successfully..\n\n";
$result .= "<p align=center><br><b>PASS: Adding new Monitoring Type verified successfully..";
my $STATUS = ($STATUS eq "ACTIVE") ? "INACTIVE" : "ACTIVE";
	
my $updateMonitorTypeURL = "--post-data 'action=MonitoredTypes&type=$TECHPACK_NAME&chk%3A$TYPENAME%3A30MIN=on&status=$STATUS&year_1=2014&month_1=09&day_1=12&update=Update+selected' https://localhost:8443/adminui/servlet/MonitoredTypes";
executeURL("UpdateMonitorTypeHtml.html",$updateMonitorTypeURL);

my $sql = "SELECT count(*) FROM LOG_MonitoredTypes WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' AND STATUS='$STATUS'";
($val) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");

if ( $val == 1 ) {

print "\nUpdating Monitor Type verified successfully\n\n";
$result .= "<p align=center><br><b>PASS: Updating Monitor Type verified successfully...";

my $deleteMonitorTypeURL = "--post-data 'action=MonitoredTypes&type=$TECHPACK_NAME&chk%3A$TYPENAME%3A30MIN=on&deleteSelected=Delete+selected&status=$STATUS&year_1=2014&month_1=09&day_1=12' https://localhost:8443/adminui/servlet/MonitoredTypes";
executeURL("deleteMonitorTypeHtml.html",$deleteMonitorTypeURL);

my $sql = "SELECT count(*) FROM LOG_MonitoredTypes WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' AND STATUS='$STATUS'";
my ($val) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");

if ( $val == 0 ) {
print "\nDeleting Monitor Type in admin UI is verified successfully..\n\n";
$result .= "<p align=center><br><b>PASS: Deleting Monitor Type in admin UI is verified successfully..";
return $result;
}
else {
	$result .= "<p align=center><br><b>FAIL: Error while deleting Monitor Type\n\n";
	return $result;
	}
	}
		else {
		$result .= "<p align=center><br><b>FAIL: Error while Updating Monitor Type\n\n";
		return $result;
		}
	}
	else {
	$result .= "<p align=center><br><b>FAIL: Error while inserting new Monitor Type..\n\n";
	return $result;
	}
}
############################################################
# CHECK ADMINUI_TYPECONFIG    
# this subroutine executes a query to check Type Configuration
# in admin ui is working properly or not.
sub adminuiTypeConf {
		my $result="";

		my $sql = "SELECT TOP 1 TECHPACK_NAME, TYPENAME FROM TypeActivation WHERE STATUS = 'ACTIVE' AND TABLELEVEL = 'RAW'";
		my @result = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
		my ($TECHPACK_NAME, $TYPENAME) = @result;
		print "$TECHPACK_NAME\n";
		print "$TYPENAME\n";

		#my $url = "\"--post-data 'action=TypeActivationEdit&status=INACTIVE&defaultStorageTimeValue=30&useDefaultStorageTime=on&maxStorageTimeValue=90&save=Save&tp=$TECHPACK_NAME&tpn=$TYPENAME&level=RAW' https://localhost:8443/adminui/servlet/TypeActivationEdit"\";

		#executeURL("/eniq/home/dcuser/driHtml.html",$url);

		system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data 'action=TypeActivationEdit&status=INACTIVE&defaultStorageTimeValue=30&useDefaultStorageTime=on&maxStorageTimeValue=90&save=Save&tp=$TECHPACK_NAME&tpn=$TYPENAME&level=RAW' \"https://localhost:8443/adminui/servlet/TypeActivationEdit\"");
		# SEND USR AND PASSWORD
		system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
		# post Information
		system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/typeEdit.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=TypeActivationEdit&status=INACTIVE&defaultStorageTimeValue=30&useDefaultStorageTime=on&maxStorageTimeValue=90&save=Save&tp=$TECHPACK_NAME&tpn=$TYPENAME&level=RAW' \"https://localhost:8443/adminui/servlet/TypeActivationEdit\"");


		my $sql1 = "SELECT STATUS FROM TypeActivation WHERE TECHPACK_NAME = '$TECHPACK_NAME' AND TYPENAME = '$TYPENAME' AND TABLELEVEL = 'RAW'";
		my @result1 = executeSQL("repdb",2641,"dwhrep",$sql1,"ROW");
		my ($STATUS) = @result1;

		print "changed status = $STATUS\n";

		if ($STATUS eq 'INACTIVE') {
		$result .= "<p align=center><br><b>Type InActivation for $TYPENAME is successfully verified(PASS)<br>";
		}
		else {
		$result .= "<p align=center><br><b>Type InActivation for $TYPENAME is unSuccessful(FAIL)<br>";
		}	
		system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data 'action=TypeActivationEdit&status=ACTIVE&defaultStorageTimeValue=30&useDefaultStorageTime=on&maxStorageTimeValue=90&save=Save&tp=$TECHPACK_NAME&tpn=$TYPENAME&level=RAW' \"https://localhost:8443/adminui/servlet/TypeActivationEdit\"");
		# SEND USR AND PASSWORD
		system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
		# post Information
		system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/typeEdit.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=TypeActivationEdit&status=ACTIVE&defaultStorageTimeValue=30&useDefaultStorageTime=on&maxStorageTimeValue=90&save=Save&tp=$TECHPACK_NAME&tpn=$TYPENAME&level=RAW' \"https://localhost:8443/adminui/servlet/TypeActivationEdit\"");

		my $sql2 = "SELECT STATUS FROM TypeActivation WHERE TECHPACK_NAME = '$TECHPACK_NAME' AND TYPENAME = '$TYPENAME' AND TABLELEVEL = 'RAW'";
		my @result2 = executeSQL("repdb",2641,"dwhrep",$sql2,"ROW");
		my ($STATUS1) = @result2;

		print "$STATUS1\n";

		if ($STATUS1 eq 'ACTIVE') {
		$result .=  "<p align=center><br><b>Type Activation for $TYPENAME is successfully verified(PASS)<br>";
		}
		else {
		$result .= "<p align=center><br><b>Type Activation for $TYPENAME is unSuccessful(FAIL)<br>";
		}

		return $result;

}

############################################################
# CHECK ADMINUI_DWHCONFIG    
# this subroutine executes a query to check Type Configuration
# in admin ui is working properly or not.

sub adminuiDwhConf {
	my $reslt="";
	my $result="";

	my $sql = "SELECT DEFAULTSTORAGETIME, MAXSTORAGETIME FROM PartitionPlan WHERE PARTITIONPLAN = 'extralarge_count'";
	my @result = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
	my ($PARTITIONPLAN, $MAXSTORAGETIME) = @result;
	print "PARTITIONPLAN = $PARTITIONPLAN\n";
	print "MAXSTORAGETIME = $MAXSTORAGETIME\n";

	my $NewPP = $PARTITIONPLAN + 1;
	print "NewPP = $NewPP\n";

	#my $url = "--post-data 'action=EditPartitionPlan&save&partitionPlan=bulk_cm_raw&defaultStorageTime=$NewPP&maxStorageTimeValue=$MAXSTORAGETIME&submitButton=Save' \"https://localhost:8443/adminui/servlet/EditPartitionPlan\"";
	#executeURL("/eniq/home/dcuser/driHtml.html",$url);

	system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data 'action=save&partitionPlan=extralarge_count&defaultStorageTime=$NewPP&maxStorageTimeValue=$MAXSTORAGETIME&submitButton=Save' \"https://localhost:8443/adminui/servlet/EditPartitionPlan\"");
	# SEND USR AND PASSWORD
	system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
	# post Information
	system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/DwhConf.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=save&partitionPlan=extralarge_count&defaultStorageTime=$NewPP&maxStorageTimeValue=$MAXSTORAGETIME&submitButton=Save' \"https://localhost:8443/adminui/servlet/EditPartitionPlan\"");


	my $sql1 = "SELECT DEFAULTSTORAGETIME, MAXSTORAGETIME FROM PartitionPlan WHERE PARTITIONPLAN = 'extralarge_count'";
	my @result1 = executeSQL("repdb",2641,"dwhrep",$sql1,"ROW");
	my ($NEWPARTITIONPLAN, $NEWMAXSTORAGETIME) = @result1;
	print "NEWPARTITIONPLAN = $NEWPARTITIONPLAN\n";
	print "NEWMAXSTORAGETIME = $NEWMAXSTORAGETIME\n";

	if ($NEWPARTITIONPLAN eq $PARTITIONPLAN + 1) {
	$result .= "<p align=center><br><b>DWH Configuration is successfully altered PASS for extralarge_count partition<br>";}
	else {
	$result .= "<p align=center><br><b>DWH Configuration is unSuccessfully altered FAIL for extralarge_count partition<br>";} 

	system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data 'action=save&partitionPlan=extralarge_count&defaultStorageTime=$PARTITIONPLAN&maxStorageTimeValue=$MAXSTORAGETIME&submitButton=Save' \"https://localhost:8443/adminui/servlet/EditPartitionPlan\"");
	# SEND USR AND PASSWORD
	system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
	# post Information
	system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/DwhConf.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=save&partitionPlan=extralarge_count&defaultStorageTime=$PARTITIONPLAN&maxStorageTimeValue=$MAXSTORAGETIME&submitButton=Save' \"https://localhost:8443/adminui/servlet/EditPartitionPlan\"");

	my $sql2 = "SELECT DEFAULTSTORAGETIME, MAXSTORAGETIME FROM PartitionPlan WHERE PARTITIONPLAN = 'extralarge_count'";
	my @result2 = executeSQL("repdb",2641,"dwhrep",$sql2,"ROW");
	my ($RPARTITIONPLAN, $OLDMAXSTORAGETIME) = @result2;
	print "RPARTITIONPLAN = $RPARTITIONPLAN\n";
	print "OLDMAXSTORAGETIME = $OLDMAXSTORAGETIME\n";

	if ($RPARTITIONPLAN eq $PARTITIONPLAN) {
	$result .= "<p align=center><br><b>DWH Configuration is successfully restored PASS for extralarge_count partition<br>";}
	else {
	$result .= "<p align=center><br><b>DWH Configuration is unSuccessfully restored FAIL for extralarge_count partition<br>";} 
	return $result;
}
############################################################
# CHECK ADMINUI_DRS  
# this subroutine executes a query to check is the 
# data shown in adminui matches with data loaded in DB.
sub adminui_drs {
		my $result="<b><h2>Data is not loaded";
		$result="<b><h2>Latest AdminUI package must be installed which contains Data Row Summary link";
		my $rs="";
		my $flag="";
		my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
		my @abbr = qw( 1 2 3 4 5 6 7 8 9 10 11 12 );
		my $yestDate = sprintf "%s-%02d-%02d 10:00:00", $year+1900, $abbr[$mon], $mday-3;
		my $ydate = sprintf "%s-%02d-%02d", $year+1900, $abbr[$mon], $mday-3;
		print "date to be checked = $yestDate\n";

		my $LogSessionTable = undef;
		my $sql = "SELECT TABLENAME FROM DWHPartition WHERE TABLENAME LIKE '%LOG_SESSION_LOADER_%'";
		my $logSessionTables = executeSQL("repdb",2641,"dwhrep",$sql,"ALL");

		for my $row ( @$logSessionTables ) {
				for my $logSessionTable ( @$row ) {
				$sql = "SELECT STARTTIME, ENDTIME FROM DWHPartition WHERE TABLENAME = '$logSessionTable'";
				my @partitionInfo = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
				my ($STARTTIME, $ENDTIME) = @partitionInfo;
				if (($yestDate ge $STARTTIME) & ($yestDate lt $ENDTIME)) {
					# print "Matched : $logSessionTable\n";
					$sql = "SELECT TOP 1 TYPENAME,ROWCOUNT FROM $logSessionTable WHERE DATATIME = '$yestDate'";
					my $typeInfo = executeSQL("dwhdb",2640,"dc",$sql,"ALL");
						for my $rows ( @$typeInfo ) {
						my ($type,$rowCount) = @$rows;
						my @string = split /[_]+/, $type;
						my $tpName = "$string[0]_$string[1]_$string[2]";
						#print "$tpName : $type : $rowCount\n";
						
						my $url = "\"https://localhost:8443/adminui/servlet/DataRowSummary?dayStr=$ydate&search_str=$tpName&meastype=$type&dlevel=RAW&request_type=counts\"";	
						executeURL("/eniq/home/dcuser/swget.html",$url);
						my $count = 1;
						my $countValline = 0;
						my $adCount = 0;
						#print $count;
						open( FILE, '/eniq/home/dcuser/swget.html' ) or die "Can't open wget: $!";
						while (<FILE>) {
							if ( $_ =~ /$ydate / ) {
							my $flDateTime=$_;
							$flDateTime =~ s/^\s+//;
							$flDateTime =~ s/\s+$//;
							$countValline=$.+5;;
							}
							if ($count == $countValline)
							{
							$adCount=$_;
							$adCount=~ s/^\s+//;
							$adCount=~ s/\s+$//;
							}
							$count++;
							}
							close FILE;
							#print "Adcount : $adCount";
							print "\t Rowcount : $rowCount\n\n";
							
							if ($adCount == $rowCount){
								return my $result .= "<p align=center><br><b>Data Row Summary is Successful(PASS)<br>";
							}
							else{
								return $result .= "<p align=center><br><b>Data Row Summary is Unsuccessful(FAIL)<br>";
								my $flag = 1;
							}

						}
					}
				}
			}
		return $result;
		}
		
		
		


############################################################
# CHECK ADMINUI_DRI     
# this subroutine executes a query to check is the 
# data shown in adminui matches with data loaded in DB.
sub adminui_dri {
		my $result="<b><h2>Data is not loaded";
		my $rs="";
		my $flag="";
		my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
		my @abbr = qw( 1 2 3 4 5 6 7 8 9 10 11 12 );
		my $yestDate = sprintf "%s-%02d-%02d", $year+1900, $abbr[$mon], $mday-3;
		my $ydate = sprintf "%s-%02d-%02d", $year+1900, $abbr[$mon], $mday-3;
		print "date to be checked = $yestDate\n";
	
		my $LogSessionTable = undef;
		my $sql = "SELECT TABLENAME FROM DWHPartition WHERE TABLENAME LIKE '%LOG_SESSION_LOADER_%'";
		my $logSessionTables = executeSQL("repdb",2641,"dwhrep",$sql,"ALL");
		
		for my $row ( @$logSessionTables ) {
				for my $logSessionTable ( @$row ) {
				$sql = "SELECT STARTTIME, ENDTIME FROM DWHPartition WHERE TABLENAME = '$logSessionTable'";
				my @partitionInfo = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
				my ($STARTTIME, $ENDTIME) = @partitionInfo;
				
				print "start time = $STARTTIME\n";
				print "end time = $ENDTIME\n";
				if (($yestDate ge $STARTTIME) & ($yestDate lt $ENDTIME)) {
					my $sqlQuery = qq{SELECT TYPENAME||"|"||ROWCOUNT FROM $logSessionTable WHERE DATE_ID = '$yestDate'};
					my @typeInfo = executeSQL("dwhdb",2640,"dc",$sqlQuery,"ROW");
					my $typeInfoLength = scalar @typeInfo;
					if ( $typeInfoLength > 0 ) {
						print "typeInfo: $typeInfo[0]\n";#fetch only the first row data
						my @typeRow = split(/\|/,$typeInfo[0]);
						my $sqlQuery1 = qq{SELECT SUM(ROWCOUNT) FROM $logSessionTable WHERE TYPENAME = '$typeRow[0]' AND DATE_ID = '$yestDate' GROUP BY TYPENAME};
						my $rowCount = executeSQL("dwhdb",2640,"dc",$sqlQuery1,"ALL");
						for my $rowVal ( @$rowCount ) {
							for my $rowVal1 ( @$rowVal ) {
								$rowCount = $rowVal1;
								last;
							}
						}
						my $tablename = $typeRow[0]."_RAW";
						my $sqlQuery2 = qq{SELECT TYPEID FROM MEASUREMENTTABLE WHERE BASETABLENAME = '$tablename'};
						my $typeId = executeSQL("repdb",2641,"dwhrep",$sqlQuery2,"ALL");
						my @tpName ="";
						for my $val ( @$typeId ) {
							for my $val1 ( @$val ) {
								@tpName = split(':',$val1);
								last;
							}
						}
						
						my @dates = split('-',$yestDate);
						my $htmlfile = "/eniq/home/dcuser/swget.html";
						my $level = 'RAW';
						my $submit = 'Get Information';
						
						system("$WGET --quiet  --no-check-certificate -O $htmlfile  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"tp=$tpName[0]&dgroup=$tpName[0]&dtype=$typeRow[0]&dlevel=$level&year_1=$dates[0]&month_1=$dates[1]&day_1=$dates[2]\" \"https://localhost:8443/adminui/servlet/DataRowInfo\"");

						# SEND USR AND PASSWORD
						system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

						# post Information
						system("$WGET --quiet --no-check-certificate -O $htmlfile --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"tp=$tpName[0]&dgroup=$tpName[0]&dtype=$typeRow[0]&dlevel=$level&year_1=$dates[0]&month_1=$dates[1]&day_1=$dates[2]&submitButton=$submit\" \"https://localhost:8443/adminui/servlet/DataRowInfo\"");

							
						my $count = 1;
						my $countValline = 0;
						my $adCount = 0;
							#print $count;
						open( FILE, '/eniq/home/dcuser/swget.html' ) or die "Can't open wget: $!";
						while (<FILE>) {
								if ( $_ =~ /$yestDate/ ) {
								my $flDateTime=$_;
								$flDateTime =~ s/^\s+//;
								$flDateTime =~ s/\s+$//;
								$countValline=$.+6;
								}
								if ($count == $countValline)
								{
								$adCount=$_;
								$adCount=~ s/^\s+//;
								$adCount=~ s/\s+$//;
								}
								$count++;
						}
							close FILE;
							print "Adcount : $adCount";
							print "\t Rowcount : $rowCount\n\n";
							$result = qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
											<tr>
											<th>TECH PACK</th>
											<th>MEASUREMENT TYPE</th>
											<th>DATE</th>
											<th>RESULT</th>
											</tr>
											};	
							if ($adCount == $rowCount){
							
								$result .= "<tr><td><center>$tpName[0]</td><td><center>$typeRow[0]</td><td><center>$yestDate</td><td><center><font color=006600><b>Data Row Info is Successful(PASS)</td></tr>";
							}
							else{
								$result .= "<tr><td><center>$tpName[0]</td><td><center>$typeRow[0]</td><td><center>$yestDate</td><td><center><font color=660000><b>Data Row Info is Unsuccessful(FAIL)</td></tr>";
								my $flag = 1;
							}
							$result .= "</table>";
						}
					}
				}
			}
		return $result;
		}
		

		
############################################################
# getStartTimeHeader
# this subroutine returns the start time of each test case
# in a standard format

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

sub getEndTimeHeaderForCounterAndKeys
{
	my $pass = shift;
	my $fail = shift;
	my $emptyTables = shift;
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
	$rep .= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail) / <a href=\"#t2\">EMPTY TABLES ($emptyTables)";
	$rep .= qq{<tr>
				<th> <font size = 2 > DETAILED RESULT </th>
				<td><font size = 2 ><b>};
	$rep .= "<a href=\"$server\_$datenew.html\" target=\"_blank\">Click here</a>";
	$rep .= "</table>";
	$rep .= "<br>";
	$rep .= "<h3><font size=4 color=\"Blue\"><b><u>Note:</u> Only Failed TestCases shown, refer link above for Detailed Results</b></font></h3><br>";
	return $rep;
}

############################################################
# getEndTimeHeader_Combo
# this subroutine returns the combo test case
# in a standard format

sub getEndTimeHeader_Combo
{
	my $pass = shift;
	my $fail = shift;
	my $etime = shift;
	my $rep .= "<tr>";
	$rep .= qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td><font size = 2 ><b>};
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


###################################################################
# getEndTimeHeader_Overall
# this subroutine returns the end time of each overall result page
# in a standard format

sub getEndTimeHeader_Overall
{
	my $pass = shift;
	my $fail = shift;
	my $rep .= "<tr>";
	$rep .= qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td><font size = 2 ><b>};
	my $etime = getTime();
#	my $server= getHostName();
	$rep .= "$etime";
#	$rep .= "<tr>";
#	$rep .=qq{<tr>
#				<th> <font size = 2 > RESULT SUMMARY </th>
#				<td><font size = 2 ><b>};
#	$rep .= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)";
	$rep .= "</table>";
	$rep .= "<br>";
	return $rep;
}

###################################################################
# getEndTimeHeader_Log
# this subroutine returns the end time of each overall result page
# in a standard format

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
		next if($part=~/SQL Anywhere Error /);
	    next if($part=~/Msg \d/);
		next if($part=~/ Msg \d/);
   
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
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  
  sleep(20);
# RUN DISTRIBUTOR
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  
  sleep(20);
# RUN DISTRIBUTOR
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
  sleep(20);
# RUN DISTRIBUTOR
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");


  print "INTF_PM_E_EBS$ebsType-eniq_oss_1 Distributor_MOM_EBS$ebsType Start\n";
  sleep(20);
  print "sleep 20 sec\n";
  sleep(20);

# GET COOKIES  AND JSESSIONID NOTHING ELSE
  my $t1=getSeconds();
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  https://localhost:8443/adminui/servlet/EbsUpgradeManager");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

# UPGRADE EBS
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=action_run_upgrade&upgradeId=PM_E_EBS$ebsType&submit='Upgrade now!'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");

sleep(20);
# WAIT UNTIL IS UPGRADED
my $status=0;
my $found=0;
# DELETE PREVIOUS RUNS
do{
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @ebs=executeThis("$WGET --quiet --no-check-certificate -O  /eniq/home/dcuser/ebs_upgrade.html  --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt   --post-data \"action=action_get_upgrade_status&submit='refresh status'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");
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
 system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
        system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&batch_name=$tp&checkall=on&$cmd\" \"https://localhost:8443/adminui/servlet/Aggregation\"");
        
        # SEND USR AND PASSWORD and SAVE second COOKIE
        system("$WGET  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
        # post Information
        system("$WGET  --quiet --no-check-certificate -O /eniq/home/dcuser/dayagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&batch_name=$tp&checkall=on&$cmd\" \"https://localhost:8443/adminui/servlet/Aggregation\"");
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
        system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"timelevel_changed=yes&level=$level&\" https://localhost:8443/adminui/servlet/Aggregation");
        
        # SEND USR AND PASSWORD
        system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/listtpsweekagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
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
           system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/listweekagg0.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"list=List&timelevel_changed=&level=$level&year_1=$year&week_1=1&year_2=$year&week_2=53&batch_name=$tp&\" https://localhost:8443/adminui/servlet/Aggregation");

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
           system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/weekagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&week_1=$week&year_2=$year&week_2=$week&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation");
           
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
        system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"timelevel_changed=yes&level=$level&\" https://localhost:8443/adminui/servlet/Aggregation");
        
        # SEND USR AND PASSWORD
        system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/listtpsmonthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
        
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
           system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/listmonthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"list=List&timelevel_changed=&level=$level&year_1=$year&month_1=1&year_2=$year&month_2=12&batch_name=$tp&\" https://localhost:8443/adminui/servlet/Aggregation");

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
           system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/monthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&year_2=$year&month_2=$month&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation");
           print("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/monthagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"aggregate=Aggregate&timelevel_changed=&level=$level&year_1=$year&month_1=$month&year_2=$year&month_2=$month&batch_name=$tp&checkall=on&$cmd\" https://localhost:8443/adminui/servlet/Aggregation\n");
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

  return $result;
}
############################################################
# SYSTEMSTATUS
# This subroutine goes to admin UI and checks the System status, greps if there are RED bulbs or status NOLOADS
# If that's the case it fails the test case.
sub SystemStatus{
	my $result="";
	my $result_fail = "";
	system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/status.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");

	# SEND USR AND PASSWORD
	system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

	# post Information
	system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/status.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");
	my @status=executeThis("egrep -c '(red_bulp|NoLoads)' /eniq/home/dcuser/status.html");
	if($status[0] == 0)
	{
		print "PASS\n";
		#$result.=" $status[0]<br>\n";
		$result.="<font color = green>_PASS_<br>\n";
	}
	else
	{ 
		print "FAIL\n";
		$result.="<font color = red>_FAIL_<br>\n";
		$result_fail .= "<font color = red>FAIL<br>\n";
	} 
	# LOGOUT 
	system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");
	return $result,$result_fail;
}

############################################################
# DWHSTATUS
# this subroutine goes to AdminUI and verifies the DWHSatus, 
# greps DWH_DBSPACES_MAIN, if present it will pass the test
sub DwhStatus{
	my $report = "";
    my $htmlFile = "dwhStatus.html";
    executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockDwhDba\"");
    my @status=executeThis("grep -c DWH_DBSPACES_MAIN $htmlFile");
    if($status[0] == 0)
    {
        print "PASS\n";
		$report.= qq{<font color= green>PASS</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red> FAIL</td>};
	} 
	return $report;
}



############################################################
# SET_EXECUTION_TIME
# this subroutine checks the set execution time of the TPs DWH_Monitor and DWH_Base 
sub checkSetExecutionTime
{
	my $report="";
	my $report_fail = "";
	my @tps=("DWH_MONITOR","DWH_BASE");
	my @nameset;
	for my $tp (@tps)
	{
		my $fail = 0;
		my $sql="select VERSIONID from TPActivation where TECHPACK_NAME='$tp'";
		my ($res)=executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
		my $start = index( $res, ":");
		my $versionID = substr $res, $start + 1;
		#print "CountDup SQL : $sql   -   Version ID : $versionID\n\n";	
		my $report_main="";
		my $report_sub="";
		my $report_subfail = "";

		if ( $tp eq "DWH_MONITOR" )
		{
			my @dwhmonitor_nameset = ("DailyReAggregation","AggregationRuleCopy","Diskmanager_DWH_MONITOR","UpdateMonitoredTypes");
			@nameset=@dwhmonitor_nameset;
			#"Aggregate","SessionLoader_Starter",
		}
		elsif ( $tp eq "DWH_BASE" )
		{
			my @dwhbase_nameset = ("Cleanup_logdir","Cleanup_transfer_batches","Trigger_Partitioning","Trigger_Service","Update_Dates");
			@nameset=@dwhbase_nameset;
		}
			$report_main.= qq{<table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" >
					 <tr><th> <font size = 2 > $tp </th></table>};

		$report_sub.= qq{<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" ><tr><th> <font size = 2 > Table</th>
					     <th> <font size = 2 > Scheduled Hour : Min</th>
						 <th> <font size = 2 > Last Execution Time</th>
						 <th> <font size = 2 > Status</th>
						 <th> <font size = 2 > Comments</th>};
		$report_subfail.= qq{<table BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="40%" ><tr><th> <font size = 2 > Table</th>
					     <th> <font size = 2 > Scheduled Hour : Min</th>
						 <th> <font size = 2 > Last Execution Time</th>
						 <th> <font size = 2 > Status</th>
						 <th> <font size = 2 > Comments</th>};

		

		foreach my $nameset (@nameset)
		{
			my $sql2="select LAST_EXECUTION_TIME, SCHEDULING_HOUR,SCHEDULING_MIN from META_SCHEDULINGS where VERSION_NUMBER='$versionID' and NAME='$nameset'";
			my @res2=executeSQL("repdb",2641,"etlrep",$sql2,"ROW");
#			my ($executionTime,$executionHour,$executionMin) = @res2;
			my ($executionTime,$executionHour,$executionMin) = @res2;
			print "$nameset\n";
			my ($year, $month, $day, $hour, $min, $sec) = split /\W+/, $executionTime;
			#my $min="";
			#my $hour="";
			print " Execution Time : $executionTime    \nScheduledHour : $executionHour      \nScheduledMin : $executionMin  \n";
			print "Calculated Hour from datetimeid : $hour\n";
			print "Calculated Min from datetimeid : $min\n";
			$report_sub.= qq{<tr><td><font size = 2 >$nameset</td> <td> $executionHour : $executionMin  </td> <td> $hour : $min </td> };
			$report_subfail.= qq{<tr><td><font size = 2 >$nameset</td> <td> $executionHour : $executionMin  </td> <td> $hour : $min </td> };
			if ($min==$executionMin && $hour==$executionHour) 
			{
				$report_sub.= qq{<td><font size = 2  color=green >_PASS_</td><td> </td> };
			}
			elsif ($min eq "" && $hour eq "" && ($nameset eq "Cleanup_logdir" || $nameset eq "Cleanup_transfer_batches")) {
				my @install=executeThis("cat /eniq/admin/version/*");
				my @temp=split(" ",$install[2]);
				print "@install";
							
				$report_sub.= qq{<td><font size = 2  color=red >_FAIL_(The $nameset is not executed.)</td>};
				$report_sub.= qq{<td><font size = 2  color=red >The Shipment Installation date: $temp[1] . Please check with DM team for Template details.</td>};
				$report_subfail.= qq{<td><font size = 2  color=red >FAIL (The $nameset is not executed.)</td>};
				$report_subfail.=qq{<td><font size = 2  color=red >The Shipment Installation date: $temp[1] . Please check with DM team for Template details.</td>};
				$fail = 1;
			}
			elsif ($min eq "" && $hour eq "") {
				$report_sub.= qq{<td><font size = 2  color=red >_FAIL_($nameset is not executed.)</td><td> </td>};
				$report_subfail.= qq{<td><font size = 2  color=red >FAIL ($nameset is not executed.)</td><td> </td>};
				$fail = 1;
			}
			else {
				#$flag = $flag + 1;
				$report_sub.= qq{<td><font size = 2  color=red >_FAIL_</td>};
				$report_subfail.= qq{<td><font size = 2  color=red >FAIL</td>};
				$fail = 1;
			}
		}
		#if ($flag=0 ){$report_main.= qq{<th> <font size = 2 color=green > <b> PASS</th></table>};}
		#else{$report_main.= qq{<th> <font size = 2 color=red > <b> FAIL </th> </table>};}
		$report.= $report_main;
		$report.= $report_sub;
		if ($fail == 1)
		{
			$report_fail.= $report_main;
			$report_fail.= $report_subfail;
		}
		#undef $flag;
	}
	return $report,$report_fail;
}
############################################################
# REPSTATUS
# This subroutine checks AdminUI and Repstatus 
# greps the webpage for IQ.Server, if present it passes the test
sub RepStatus
{
	my $report = "";
    my $htmlFile = "repstatus.html";
    executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/StatusDetails?ds=rockEtlRepDba\"");
    my @status=executeThis("grep -c IQ.Server $htmlFile");
    if($status[0] == 1)
    {
        print "PASS\n";
		$report.= qq{<font color= green>PASS</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red> FAIL</td>};
	} 
	return $report;
}

############################################################
# ENGINESTATUS
# This subroutine goes to AdminUI and checks that engine status is Normal
sub EngineStatus
{
	my $report = "";
	my $report_fail = "";
    my $htmlFile = "engineStatus.html";
    executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/EngineStatusDetails\"");
    my @status=executeThis("grep -c Normal $htmlFile");
    if($status[0] == 1)
    {
        print "PASS\n";
		$report.= qq{<font color= green>_PASS_</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red>_FAIL_</td>};
		$report_fail.= qq{<font color= red>FAIL</td>};
	} 
	return $report,$report_fail;
}
############################################################
# SCHEDULESTATUS
# This subroutine goes to AdminUI and checks that scheduler status is active
sub SchedulerStatus
{
	my $report = "";
	my $report_fail = "";
    my $htmlFile = "schedulerStatus.html";
    executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/SchedulerStatusDetails\"");
    my @status=executeThis("grep -c active $htmlFile");
    if($status[0] == 1)
    {
        print "PASS\n";
		$report.= qq{<font color= green>_PASS_</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red>_FAIL_</td>};
		$report_fail.= qq{<font color= red>FAIL</td>};
	} 
	return $report,$report_fail;		
}

############################################################
# LICSERVSTATUS
# This subroutine goes to AdminUI and checks that the licenserver lists the FAJ or CXC
# is number is higher than 40 the test is passed.
sub LicservStatus
{
	my $report = "";
	my $report_fail = "";
    my $htmlFile = "licServStatus.html";
    executeURL($htmlFile,"\"https://localhost:8443/adminui/servlet/ShowInstalledLicenses\"");
    my @status=executeThis("egrep -c '(FAJ|CXC)' $htmlFile");
    if($status[0] > 0)
    {
        print "PASS\n";
		$report.= qq{<font color= green>_PASS_</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red>_FAIL_</td>};
		$report_fail.= qq{<font color= red>FAIL</td>};
	} 
	return $report,$report_fail;		
}


############################################################
# LICMGR STATUS 
# This subroutine goes to AdminUI and checks licmgr and verifies that is 'running OK'
# is so the test is passed.
sub LicmgrStatus{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	my $report = "";
  $year=$year+1900; 
  my $month= sprintf("%02d",$mon+1);
  my $day  = sprintf("%02d",$mday);

#http://eniq21.lmf.ericsson.se:8080/servlet/LicenseLogsViewer
 # system("$WGET --no-check-certificate -O  /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&submit=Search&action=ReadLicenseLog\" \"https://localhost:8443/adminui/servlet/ReadLicenseLog\"");
    my @status=executeThis("egrep -c '(is running OK)' /eniq/home/dcuser/liclog.html") ;

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&submit=Search&action=ReadLicenseLog\" \"https://localhost:8443/adminui/servlet/ReadLicenseLog\"");

    @status=executeThis("egrep -c '(is&nbsp;running&nbsp;OK)' /eniq/home/dcuser/liclog.html") ;
  if($status[0] > 20 )
     {
       print "LicmgrStatus--PASS\n";
	   $report.= qq{<font color= green>PASS</td>};
     }
  else
     {
       print "LicmgrStatus--FAIL\n";
	   $report.= qq{<font color= red> FAIL</td>};
   }
	 return $report;	
#LOGOUT 
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
   system("$WGET --quiet  --no-check-certificate -O test0.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  --post-data \"selectedpack=&action=ETLSessionLog&search=Search&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&start_hour=0&end_hour=23&a_status=OK&selectedtable=$selectedtable&source=&a_filename=\" https://localhost:8443/adminui/servlet/ETLSessionLog");
   
   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O test.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/sessionlog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"selectedpack=&action=ETLSessionLog&search=Search&year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month&day_2=$day&start_hour=0&end_hour=23&a_status=OK&selectedtable=$selectedtable&source=&a_filename=\"  https://localhost:8443/adminui/servlet/ETLSessionLog");
   
   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O test.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}
############################################################
# DATAROWINFO
# This subroutine should go to AdminUI and verify each of the DataRow Info tables for certain dates.
sub dataRowInfo{
my $result="";
my $rs="";
my $flag="";
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
my @abbr = qw( 1 2 3 4 5 6 7 8 9 10 11 12 );
my $yestDate = sprintf "%s-%02d-%02d 10:00:00", $year+1900, $abbr[$mon], $mday-1;
my $ydate = sprintf "%s-%02d-%02d", $year+1900, $abbr[$mon], $mday-1;
print "date to be checked = $yestDate\n";

$result.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >
<tr>
<th>TPNAME</th>
<th>TYPENAME</th>
<th>ROWCOUNT_AD</th>
<th>ROWCOUNT_DB</th>
<th>RESULT</th>
</tr>
};

my $LogSessionTable = undef;
my $sql = "SELECT TABLENAME FROM DWHPartition WHERE TABLENAME LIKE '%LOG_SESSION_LOADER_%'";
my $logSessionTables = executeSQL("repdb",2641,"dwhrep",$sql,"ALL");
sleep 5;

for my $row ( @$logSessionTables ) {
for my $logSessionTable ( @$row ) {
$sql = "SELECT STARTTIME, ENDTIME FROM DWHPartition WHERE TABLENAME = '$logSessionTable'";
my @partitionInfo = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
sleep 5;
my ($STARTTIME, $ENDTIME) = @partitionInfo;
if (($yestDate ge $STARTTIME) & ($yestDate lt $ENDTIME)) {
# print "Matched : $logSessionTable\n";
if ($logSessionTable eq "")
{
	print "LogSessionTable Empty  $logSessionTable\n";
}
$sql = "SELECT TYPENAME,ROWCOUNT FROM $logSessionTable WHERE DATATIME = '$yestDate'";
my $typeInfo = executeSQL("dwhdb",2640,"dc",$sql,"ALL");
sleep 5;
for my $rows ( @$typeInfo ) {
my ($type,$rowCount) = @$rows;
my @string = split /[_]+/, $type;
my $tpName = "$string[0]_$string[1]_$string[2]";
print "$tpName : $type : $rowCount\n";
$result.="<tr>";
$result.="<td>$tpName\t</td>";
$result.="<td>$type\t</td>";
$result.="<td>$rowCount\t</td>";

my $url = "\"https://localhost:8443/adminui/servlet/DataRowRawInfo?date=$ydate&dgroup=$tpName&dtype=$type&dlevel=RAW\"";
executeURL("/eniq/home/dcuser/swget.html",$url);
my $count = 1;
my $countValline = 0;
my $adCount = 0;
#print $count;
open( FILE, '/eniq/home/dcuser/swget.html' ) or die "Can't open wget: $!";
while (<FILE>) {
if ( $_ =~ /$ydate / ) {
my $flDateTime=$_;
$flDateTime =~ s/^\s+//;
$flDateTime =~ s/\s+$//;
$countValline=$.+5;;
}
if ($count == $countValline)
{
$adCount=$_;
$adCount=~ s/^\s+//;
$adCount=~ s/\s+$//;
#close FILE;
}
$count++;
}
close FILE;
print "Adcount : $adCount";
print "\t Rowcount : $rowCount\n\n";
$result.="<td>$adCount\t</td>";
if ($adCount == $rowCount){
$result.="<td>\t PASS\n</td>";
}
else{
$result.="<td>\t FAIL\n</td>";
my $flag = 1;
}

}
}
}
}
$result.="</tr>";
$result.="</table>";
$result.="</body>";
$result.="</html>";

return $result;
}


############################################################
# MONITORINGRULES
# Completed

sub adminuiMonRule{
	my $result="";
	my $rs="<a href=\"H:\\Desktop\\MonRule.html\">Monitoring Types PASS</a>";
	
	my $sql = "SELECT TOP 1 TECHPACK_NAME, TYPENAME FROM TypeActivation WHERE status = 'ACTIVE' and tablelevel = 'RAW' ORDER by typename";
	my @result = executeSQL("repdb",2641,"dwhrep",$sql,"ROW");
	my ($TECHPACK_NAME, $TYPENAME) = @result;

	print "$TECHPACK_NAME $TYPENAME \n\n";
	#$result ="<p> $TECHPACK_NAME $TYPENAME </p>";

	################################################################################################################################################################
	################                       Adding new Monitoring Rules
	################################################################################################################################################################

	my $insertMonitorRulesURL = "--post-data 'action=AddMonitoringRule&type=$TYPENAME&timelevel=30MIN&MAXSOURCE=MAXSOURCE&MAXSOURCEthreshold=1&MAXSOURCEstatus=ACTIVE&MAXROW=MAXROW&MAXROWthreshold=2&MAXROWstatus=ACTIVE&MINROW=MINROW&MINROWthreshold=3&MINROWstatus=ACTIVE&MINSOURCE=MINSOURCE&MINSOURCEthreshold=4&MINSOURCEstatus=ACTIVE&add=Add+new&type=%24type&timelevel=%24timelevel&tp=$TECHPACK_NAME' https://localhost:8443/adminui/servlet/AddMonitoringRule";

	executeURL("InsertMonitorRuleHtml.html",$insertMonitorRulesURL);

	my @ruleNames = ('MAXSOURCE','MAXROW','MINROW','MINSOURCE');
	my $val;
	my $j;

	for (my $i = 0; $i < @ruleNames; $i++) {

		$j=$i+1;

		$sql = "SELECT count(*) FROM LOG_MonitoringRules WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' AND STATUS='ACTIVE' and RULENAME='$ruleNames[$i]' and THRESHOLD=$j";
		($val) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");

		if ( $val == 0 ){
			$result .= "<p align=center><br><b>Adding new Monitoring Rules verification failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME $ruleNames[$i] threshold $j <\br>";
			print "Adding new Monitoring Rules verification failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME $ruleNames[$i] threshold $j \n\n";
			last;
		}

	}

	if ( $val == 1 ) {
		$result .="<p align=center><br><b>PASS : Adding new Monitoring Rules verified successfully.. ";
		print "Adding new Monitoring Rules verified successfully..\n\n";
	}

	#############################################################################################################################################################
	##################                           Update Monitoring Rules
	############################################################################################################################################################


	my $updateMonitorRulesURL = "--post-data 'action=AddMonitoringRule&MAXSOURCE=MAXSOURCE&MAXSOURCEthreshold=1&MAXSOURCEstatus=INACTIVE&MAXROW=MAXROW&MAXROWthreshold=2&MAXROWstatus=ACTIVE&MINROW=MINROW&MINROWthreshold=3&MINROWstatus=ACTIVE&MINSOURCE=MINSOURCE&MINSOURCEthreshold=4&MINSOURCEstatus=ACTIVE&save=Save&type=$TYPENAME&timelevel=30MIN&tp=$TECHPACK_NAME' https://localhost:8443/adminui/servlet/AddMonitoringRule";

	executeURL("UpdateMonitorRuleHtml.html",$updateMonitorRulesURL);

	$sql = "SELECT count(*) FROM LOG_MonitoringRules WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' AND STATUS='INACTIVE' and RULENAME='MAXSOURCE' and THRESHOLD=1";

	($val) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");
	if ( $val == 1 ) {
		$result .=  "<p align=center><br><b>PASS : Updating Monitoring Rules verified successfully..";
		print "Updating Monitoring Rules verified successfully..\n\n";
	}
	else
	{
		$result .=  "<p align=center><br><b>>Updating Monitoring Rules failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME MAXSOURCE threshold 1";
		print "Updating Monitoring Rules failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME MAXSOURCE threshold 1\n\n";
	}

	###############################################################################################################################################################
	#####################                     Delete Monitoring Rule
	###############################################################################################################################################################

	my $deleteMonitoringRulesURL = "--post-data 'action=AddMonitoringRule&MAXSOURCE=MAXSOURCE&MAXSOURCEthreshold=1&MAXSOURCEstatus=INACTIVE&MAXROW=MAXROW&MAXROWthreshold=2&MAXROWstatus=ACTIVE&MINROW=MINROW&MINROWthreshold=3&MINROWstatus=ACTIVE&MINSOURCE=MINSOURCE&MINSOURCEthreshold=4&MINSOURCEstatus=ACTIVE&delete=Delete&type=$TYPENAME&timelevel=30MIN&tp=$TECHPACK_NAME' https://localhost:8443/adminui/servlet/AddMonitoringRule";

	executeURL("DeleteMonitorRuleHtml.html",$deleteMonitoringRulesURL);
	for (my $i = 0; $i < @ruleNames; $i++) {

		$j=$i+1;

		my $sql1 = "SELECT count(*) FROM LOG_MonitoringRules WHERE TECHPACK_NAME='$TECHPACK_NAME' AND TYPENAME='$TYPENAME' AND TIMELEVEL='30MIN' and RULENAME='$ruleNames[$i]' and THRESHOLD=$j";
		($val) = executeSQL("dwhdb",2640,"dc",$sql1,"ROW");

		if ( $val == 1 ){
			$result .=  "<p align=center><br><b>Deleting Monitoring Rules verification failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME $ruleNames[$i] threshold $j,";
			print "Deleting Monitoring Rules verification failed for techpack $TECHPACK_NAME typename $TYPENAME timelevel 30MIN RULENAME $ruleNames[$i] threshold $j \n\n";
			
			return $result;
		}
	}

	if ( $val == 0 ) {
		$result .= "<p align=center><br><b>PASS : Deleting Monitoring Rules verified successfully..";
		print "Deleting Monitoring Rules verified successfully..\n\n";
		
		return $result;
	}

}
############################################################
# TYPECONFIG
# This test is not finished.
# Currently is just a stub

sub TypeConfig{

#http://eniq21.lmf.ericsson.se:8080/servlet/TypeActivation
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/liclog.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LicenseLogsViewer\"");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}
############################################################
# DWHCONFIG
# This subroutine goes to AdminUI, to DWH Configuration
# just checks that the different partitions exist, but does not configure anything 
# because can result in data loss or database failure
sub DWHConfig{

#http://eniq21.lmf.ericsson.se:8080/servlet/ShowPartitionPlan
   system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ShowPartitionPlan\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/partplan.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/ShowPartitionPlan\"");
 
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}

############################################################
# VERIFY_DIRECTORIES
# This test only checks that the directories do not exceed 90% 
# os space, is every thing is below that the test is passed.
sub VerifyDirectories{
my  $result=qq{
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>CMD</th>
     <th>STATUS</th>
   </tr>
};
my  $result_fail=$result;

 my @dir=executeThis("df -lk | grep eniq "); 
 chomp(@dir);
 foreach my $dir (@dir)
  {
   my @line = split(/\s+/,$dir);
   print "$line[4] $line[5]";
   $line[4]=~s/%//;
   if($line[4]< 90)
   {
     $result.="<tr><td>$line[4] $line[5]</td><td align=center><font color=006600><b>_PASS_</b></font></td></tr>\n";
     print "PASS\n";
   }
   else
   {
     $result.="<tr><td>$line[4] $line[5]</td><td align=center><font color=660000><b>_FAIL_</b></font></td></tr>\n";
	 $result_fail.="<tr><td>$line[4] $line[5]</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
     print "FAIL\n";
   }
  }
 $result.="</table>";
 $result_fail.="</table>";
 return $result,$result_fail;
}
############################################################
# VERIFY ADMIN SCRIPTS
# This test executes each of the scripts below and expects a result 
# from the console, if the output includes words like 
# /Exception|Execute failed|cannot execute/i
# if so the test is failed
# else is passed.
sub VerifyAdminScripts{
	my @cmds=("manage_eniq_oss.bsh","manage_eniq_services.bsh");
	my  $result=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >
				<tr>
				<th>SCRIPT</th>
				<th>DESCRIPTION</th>
				<th>STATUS</th>
			</tr>
		};
		my  $result_fail=$result;
		foreach my $cmd ( @cmds )
		{
			my $password = "shroot12";
			my $echo = "echo";
			my $script="$echo $password | su -c \"bash /eniq/admin/bin/$cmd\"";
			my @res=executeThis($script); 
			print $script;
			my @result=map {$_."<br>"} @res; 
			$result.= "<tr><td><center><b>$cmd:</td><td>@result</td>\n";
			foreach my $res (@result)
			{
				print $res;
			}
			if((@result)==0)
			{
				$result.= "<td><font color=red><b>_FAIL_</b></font></td></tr>";
				$result_fail.="<tr><td><center><b>$cmd:</td><td>@result</td>\n";
				$result_fail.="<td><font color=red><b>FAIL</b></font></td></tr>";
				print "VerifyAdminScripts--FAIL\n";
			}
			else{
				$result.= "<td><font color=green><b>_PASS_</b></font></td></tr>";
				print "VerifyAdminScripts--PASS\n";
			}
		} 
		$result.=qq{</table>};
		$result_fail.=qq{</table>};
		return $result,$result_fail;
}
############################################################
# ENIQVERSION
# This subroutine goes to AdminUI and checks the version, if the 
# string starts with ENIQ_STATUS ENIQ the test is passed.
# else is failed
# NOTE: when the version file is not available another string is displayed like 'version not available'
sub eniqVersion{
	my $report = "";
    my $htmlFile = "eniqVersion.html";
    executeURL($htmlFile,"--post-data \"action=/servlet/CommandLine&command=ENIQ+software+version&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
    my @status=executeThis("egrep  '(ENIQ_STATUS)' $htmlFile");
    if($status[0] =~"ENIQ_STATUS ENIQ")
    {
        print "PASS\n";
		$report.= qq{<font color= green>PASS</td>};
	}
	else
	{ 
		print "FAIL\n";
		$report.= qq{<font color= red> FAIL</td>};
	} 
	return $report;
}

############################################################
# DISKSPACE
# This subroutine goes to AdminUI and checks that the DiskSpace information
# displayed in Monitoring Commands has the right header, and displays info for eniq_sp 

############################################################
# DISKSPACE
# This subroutine goes to AdminUI and checks that the DiskSpace information
# displayed in Monitoring Commands has the right header, and displays info for eniq_sp 
sub DiskSpace{

#https://localhost:8443/servlet/CommandLine
   system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Disk+space+information&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/dsk.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Disk+space+information&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
 my @status=executeThis("egrep  '(Filesystem\\s*size   used  avail capacity  Mounted on|eniq_sp)' /eniq/home/dcuser/dsk.html");
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}
############################################################
# INSTALLED_MODULES
# This subroutine goes to AdminUI and verifies that the installed modules exist
# NOTE: it has to be updated when new modules are added
sub InstalledModules{

#https://localhost:8443/servlet/CommandLine
   system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"command=Installed+modules&submit=Start&action=/adminui/servlet/CommandLine\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/modules.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"command=Installed+modules&submit=Start&action=/adminui/servlet/CommandLine\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}
############################################################
# INSTALLED_TPS
# This subroutine goes to AdminUI and verifies that the techpacks display the columns
# Note: this module does not check if the right version is installed, that is handled in
# the BASELINE checker
sub InstalledTps{

#https://localhost:8443/servlet/CommandLine
   system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/tps.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

}
############################################################
# ACTIVE PROCS
# This subroutine goes to AdminUI and verifies that the Monitoring Commands displays active processes
sub ActiveProcs{
 
 my $result="";
 
 $result.="<h3> Most Active processes as on Admin UI <h3>";

my $result_fail = $result;

#https://localhost:8443/servlet/CommandLine
   system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Most+active+processes&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/active.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Most+active+processes&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
   
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
	  $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><td>$status</td></tr><tr></tr><tr></tr></table>\n};
       $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><br><br><tr><td><h3>RESULT :</h3></td><td align=center><font color=006600><b>_PASS_</b></font></td></tr></table>\n};
    }
   else
    {
      print "FAIL\n";
	  $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><td align=center>$status</td></tr></table>\n};
       $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><br><br><tr><td><h3>RESULT :</h3></td><td align=center><font color=006600><b>_FAIL_</b></font></td></tr></table>\n};
	   $result_fail.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><td align=center>$status</td></tr></table>\n};
       $result_fail.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><br><br><tr><td><h3>RESULT :</h3></td><td align=center><font color=006600><b>FAIL</b></font></td></tr></table>\n};
   
    }
  } 

#LOGOUT 
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");
return $result,$result_fail;

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
system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/max.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
   # GET Information
   system("$WGET  --quiet --no-check-certificate -O /eniq/home/dcuser/max.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/LoaderStatusServlet\"");
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
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/wrong.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=wrong&j_password=wrong' https://localhost:8443/adminui/j_security_check");

   # post Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/wrong.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui\"");
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/without.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/EbsUpgradeManager\"");
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");
 
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
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/future.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET LOADING
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/future.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&action=/servlet/ShowAggregations&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("$WGET  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET AGGREGATION
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/futagg.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
my $result="";
my $result_fail = "";

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
     $result.= "<font color=006600><b>_PASS_</b></font><br>\n";
  }
 else
  {
     print "FAIL\n";
     $result.= "<font color=660000><b>_FAIL_</b></font><br>\n";
	 $result_fail .= "<br><font color=660000><b>FAIL</b></font><br>\n";
  }
#LOGOUT 
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

 return $result,$result_fail;

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
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/bh.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");

   # SEND USR AND PASSWORD
   system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

   # GET BUSYHOUR Information
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/bh.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");
   
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
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/bh_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month_2&day_2=$day&search_string=$tp&search_done=true&submit='Get BH Information'\"  \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");
   #sleep(1);

   # SEND USR AND PASSWORD
   system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);

   # GET BUSYHOUR Information
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/bh_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&year_2=$year&month_2=$month_2&day_2=$day&search_string=$tp&search_done=true&submit='Get BH Information'\"  \"https://localhost:8443/adminui/servlet/ViewBHInformation\"");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --server-response --keep-session-cookies --save-cookies cookies.txt https://localhost:8443/alarmcfg/LoginPage  ");

# SEND SERVER, USER, PASSWORD AND AUTH METHOD
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=LoginPage&cms=$webserver:6400&username=$user&password=$password&authtype=secEnterprise&submit=Login\" https://localhost:8443/alarmcfg/LoginPage  ");

# CHECK EXISTING ALARMS $MINUTES MIN
#system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\"  ");

system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\"  ");

# ADD REPORT $MINUTES
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --referer=\"https://localhost:8443/alarmcfg/ExistingAlarms?currentInterface=AlarmInterface_$minutes\" \"https://localhost:8443/alarmcfg/AddReport?add=$reportnum\"  ");

# ADD REPORT $MINUTES
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/AddReport?add=$reportnum\"  ");

# ADD ALARM
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers  --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=AddAalarm&reportid=$reportnum&select_techpacks=$select_techpacks&select_types=$select_types&select_levels=$select_levels&select_basetables=$select_basetables&submit='Add report'\" \"https://localhost:8443/alarmcfg/AddAlarm\"  ");

# ADD REPORT FOR ALARM $MINUTES MIN
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/AddReport\"  ");

# LOG OUT 
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"https://localhost:8443/alarmcfg/Logout\"  ");
if($! ==0)  
   {
     print "PASS\n";
   }
   else
   {
     print "FAIL\n";
   }
#LOGOUT
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");
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
	my @engineStatus=executeThis("/eniq/sw/bin/engine -e getCurrentProfile");
	chomp(@engineStatus);
	my $status = $engineStatus[0];
	if($status ne 'Normal') {
        print "Engine Status : $status - Changing status to Normal\n ";
        executeThis("/eniq/sw/bin/engine -e changeProfile Normal");
	}
	else {
        print "Engine Status : $status\n";
	}
	sleep(60);
  }while(!($processesExecution==0 && $processesQueue==0));
  print "No sets in queue : PASS\n";
}

############################################################
# WAIT UNTIL NO LOADER SETS ARE IN EXECUTION OR IN QUEUE 
# This test case only runs 2 commands:
# engine -e  showSetsInExecutionSlots 
# engine -e  showSetsInQueue 
# and counts the output , if both are 0 then it finishes, and the test is passed.
# This is very helpful to check if the regression is finished loading

sub waitUntilLoadersDone{
  my $processesExecution=1;
  my $processesQueue    =1;
  do{
	my @execution=executeThis("/eniq/sw/bin/engine -e  showSetsInExecutionSlots | egrep -v '(----|TechPack|Version|SetName|Finished|Querying sets|Connecting engine|Aggregator|Aggregation|\+ )' | wc -l");
    chomp(@execution);
    $processesExecution=$execution[0];
    my @queue    =executeThis("/eniq/sw/bin/engine -e  showSetsInQueue | egrep -v '(----|TechPack|SetName|Finished|Querying sets|Aggregator|Aggregation|Connecting engine )' | wc -l");
    chomp(@queue);
    $processesQueue    =$queue[0];
    print "ProcessesinExecutionQueue: $processesExecution  ProcessesInQueue: $processesQueue sleep 1min\n";
	my @engineStatus=executeThis("/eniq/sw/bin/engine -e getCurrentProfile");
	chomp(@engineStatus);
	my $status = $engineStatus[0];
	if($status ne 'Normal') {
        print "Engine Status : $status - Changing status to Normal\n ";
        executeThis("/eniq/sw/bin/engine -e changeProfile Normal");
	}
	else {
        print "Engine Status : $status\n";
	}
	sleep(60);
  }while(!($processesExecution==0 && $processesQueue==0));
  print "No sets in queue : PASS\n";
}

############################################################
# WAIT UNTIL NO Aggregator SETS ARE IN EXECUTION OR IN QUEUE 
# This test case only runs 2 commands:
# engine -e  showSetsInExecutionSlots 
# engine -e  showSetsInQueue 
# and counts the output , if both are 0 then it finishes, and the test is passed.
# This is very helpful to check is the regression is finished loading

sub waitUntilAggregatorsDone{
  my $processesExecution=1;
  my $processesQueue    =1;
  do{
	my @execution=executeThis("/eniq/sw/bin/engine -e  showSetsInExecutionSlots | egrep -v '(----|TechPack|Version|SetName|Finished|Querying sets|Connecting engine|Loader|\+ )' | wc -l");
    chomp(@execution);
    $processesExecution=$execution[0];
    my @queue    =executeThis("/eniq/sw/bin/engine -e  showSetsInQueue | egrep -v '(----|TechPack|SetName|Finished|Querying sets|Loader|Connecting engine )' | wc -l");
    chomp(@queue);
    $processesQueue    =$queue[0];
    print "ProcessesinExecutionQueue: $processesExecution  ProcessesInQueue: $processesQueue sleep 1min\n";
	my @engineStatus=executeThis("/eniq/sw/bin/engine -e getCurrentProfile");
	chomp(@engineStatus);
	my $status = $engineStatus[0];
	if($status ne 'Normal') {
        print "Engine Status : $status - Changing status to Normal\n ";
        executeThis("/eniq/sw/bin/engine -e changeProfile Normal");
	}
	else {
        print "Engine Status : $status\n";
	}
	sleep(60);
  }while(!($processesExecution==0 && $processesQueue==0));
  print "No sets in queue : PASS\n";
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
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt https://localhost:8443/adminui/servlet/LoaderStatusServlet");
   
   # SEND USR AND PASSWORD
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/help.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   
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
my $result_fail = $result;
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
 @result=undef;
 foreach my $version (@version)
 {
   $_=$version;
   next if(/affected/);
   next if($version=~/SQL Anywhere Error /);
	    next if($version=~/Msg \d/);
	next if($version=~/ Msg \d/);
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
 open(BSLN,"cd $path;ls *.zip  | grep -v eniq_config_R2B01.zip|");
 my @bsln=<BSLN>;
 chomp(@bsln);
 close(BSLN);
 my @result=undef;
 foreach my $bsln (@bsln)
 {
   $_=$bsln;
   $bsln=~s/.zip//;
   $bsln=~s/-/_/g;
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
 close(BLTP);
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
  open(BLINTF,"cd $path/eniq_techpacks;ls | grep INTF|");
 my @blintf=<BLINTF>;
 chomp(@blintf);
 close(BLINTF);
 my @blintff;
  foreach ( @blintf )
 {
	if(/(.*)_R/){
		#print " $1 \t";
		push(@blintff , $1);
	}
 
 }
 return @blintff;
}
###############################
# GET INSTALLED TECHPACKS
# This subroutine is a utility
# is in charge of getting the installed techpacks from AdminUI (Monitoring Commands)
sub getInstalledTechpacks{

 system("$WGET --quiet  --no-check-certificate -O /dev/null  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");

 # SEND USR AND PASSWORD
 system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

 # post Information
 system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/tps.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=/servlet/CommandLine&command=Installed+tech+packs&submit=Start\" \"https://localhost:8443/adminui/servlet/CommandLine\"");
 
 my @status=executeThis("egrep '(Not active Tech Packs|					<tr>|						<td class=.basic.>)'  /eniq/home/dcuser/tps.html");
 chomp(@status);
# close(status);
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
  if(/.._._.*|AlarmInterfaces|\w_\w|R.*_\w/i)
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

return @result;
}
###############################
# GET INSTALLED MODULES
# This subroutine is a utility
# is in charge of getting the installed modules using
# grep module /eniq/sw/installer/versiondb.properties | sed 's/module.//'  | sed 's/=/-/'
sub getInstalledModules{
open(MODULES,"grep module /eniq/sw/installer/versiondb.properties | sed 's/module.//'  | sed 's/=/-/' | sed 's/-/_/' |");
my @modules=<MODULES>;
close(MODULES);
chomp(@modules);
return @modules;
}
##############################
#GET Active Interfaces
sub getActiveInterfaces{
#print `cd /eniq/sw/installer;./get_active_interfaces | cut -d" " -f1 | sort | uniq`;
	if ( $^O eq "linux" ) {
		my $intf_sql = "SELECT DISTINCT COLLECTION_SET_NAME FROM META_COLLECTION_SETS WHERE ENABLED_FLAG = 'Y' AND type = 'Interface' ORDER BY COLLECTION_SET_NAME";
		my $allIntfs = executeSQL("repdb",2641,"etlrep",$intf_sql,"ALL");
		my @intf=undef;
      	for my $row ( @$allIntfs ) {
			for my $field ( @$row ) {
				$field =~s/-eniq_oss_\d//;
				push @intf, $field;
			}
        }	
		chomp(@intf);
		return @intf;
	}
	else{
		open(INTF,"cd /eniq/sw/installer;./get_active_interfaces | cut -d\" \" -f2 | sort | uniq |" );
		my @intf=<INTF>;
		close(INTF);
		chomp(@intf);
		return @intf;
	}
}
###################################################
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
 my %result=();
 
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
	elsif($installed=~m/^eniq_config/){
		$_=$installed;
		$_=~s/b\d*//;
		$installed=$_;
	}
	
	$result{$installed}+=7;
  }
 return %result; 
}

sub remSpace{
my ( $ref_1,$ref_2)=@_;
my @arr=@{$ref_1};
my @res=undef;
foreach my $arr (@arr)
 {
   if ($arr ne ""){
   $arr=~s/\s+//;
   push @res, $arr;
   }
 }
 return @res;
}


############################################################################
#This subroutine compares baseline interfaces 
#with the one in get_active_interfaces
############################################################################
sub compareBaselineInterfaces{
my $path=shift;
my @bi1=getINTFs($path);
my @bi=remSpace(\@bi1);
my @interfaces1=getActiveInterfaces();
my @interfaces=remSpace(\@interfaces1);
my %modres=compareBase(\@bi,\@interfaces);
 my $result.=qq{
 <h3>Compared with: $path</h3>
 <table align="center" BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>INTERFACE</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
 };
 my $result_fail.= $result;
 
 foreach my $interface (sort keys %modres)
 {
    $_=$interface;
    
	next if(/^$/);
	
	if($modres{$interface}== 3)
    {
		my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>_FAIL_</b></font></td></tr>\n";
		$result_fail.= "<tr><td>$interface</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>FAIL</b></font></td></tr>\n";
    } 
    
	if($modres{$interface}== 7)
    {
		my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>_FAIL_</b></font></td> </tr>\n";
		$result_fail.= "<tr><td>$interface</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td> </tr>\n";
	}

	if($modres{$interface}== 10)
	{
		my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$interface);
		print $string;
		$result.= "<tr><td>$interface</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>_PASS_</b></font></td></tr>\n";
	}
 }

 $result.="</table> <br>\n";
 $result_fail.="</table> <br>\n";
 return $result,$result_fail;
}





############################################################################
#    [ Updated on 11-03-2011 ]
# This subroutine is in charge of comparing the installation path modules 
# and the modules installed in the server if equal then PASS, else FAIL.
############################################################################

sub compareBaselineModules 
{
 my $PFpath = shift;
 my $Parserpath = shift;
 $PFpath = $PFpath."/eniq_base_sw/eniq_sw";
 $Parserpath = $Parserpath."/eniq_parsers/";
 my @bl1=getBLmodules($PFpath);
 my @bl2=getBLmodules($Parserpath);
 my @bl3=(@bl1,@bl2);
 my @bl=remSpace(\@bl3);
 my @modules1=getInstalledModules();
 my @modules=remSpace(\@modules1);
 my %modres=compareBase(\@bl,\@modules);
 my $result.=qq{
 <h3>Compared with: $PFpath </h3>
 <table  align="center" BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>MODULE</th>
     <th>DESCRIPTION</th>
     <th>STATUS</th>
   </tr>
 };
 my $result_fail.=$result;
 
 foreach my $module (sort keys %modres)
 {
    $_=$module;
    
	next if(/^$/);
	
	if($modres{$module}== 3)
    {
		my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>_FAIL_</b></font></td></tr>\n";
		$result_fail.= "<tr><td>$module</td><td>FOUND IN BASELINE, NOT INSTALLED</td><td align=center> <font color=660000><b>FAIL</b></font></td></tr>\n";
    } 
    
	if($modres{$module}== 7)
    {
		my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>_FAIL_</b></font></td> </tr>\n";
		$result_fail.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td> </tr>\n";
	}

	if($modres{$module}== 10)
	{
		my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$module);
		print $string;
		$result.= "<tr><td>$module</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>_PASS_</b></font></td></tr>\n";
	}
 }

 $result.="</table> <br>\n";
 $result_fail.="</table> <br>\n";
 return ($result,$result_fail);
}
############################################################################

############################################################################
# COMPARE BASELINE
# This subroutine is in charge or comparing 
# the installation path techpacks and the techpacks displayed in adminUI
# if equal then PASS, else FAIL
sub compareBaselineTechpacks{
my $path = shift;
my @bt1=getBLTPs($path);
my @bt=remSpace(\@bt1);
@bt1=remSpace(\@bt);
my @tps=getInstalledTechpacks();
#my @tps=getTPversion();
my %modres=compareBase(\@bt,\@tps);
my $result.=qq{
<h3>Compared with: $path</h3>
<table align="center" BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
<tr>
<th>TECHPACK STATUS</th>
<th>DESCRIPTION</th>
<th>STATUS</th>
</tr>
};
my $result_fail.=$result;
foreach my $module (sort keys %modres)
{
$_=$module;
next if(/^$/);
if($modres{$module}== 3)
{
     my $string=sprintf("%-35s FOUND IN BASELINE, NOT INSTALLED: FAIL\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td> FOUND IN BASELINE, NOT INSTALLED</td><td align=center><font color=660000><b>_FAIL_</b></font></td></tr>\n";
	 $result_fail.= "<tr><td>$module</td><td> FOUND IN BASELINE, NOT INSTALLED</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
}
if($modres{$module}== 7)
{
     my $string=sprintf("%-35s FOUND INSTALLED, NOT IN BASELINE: FAIL\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>_FAIL_</b></font></td></tr>\n";
	 $result_fail.= "<tr><td>$module</td><td>FOUND INSTALLED, NOT IN BASELINE</td><td align=center><font color=660000><b>FAIL</b></font></td></tr>\n";
}
if($modres{$module}== 10)
{
     my $string=sprintf("%-35s FOUND IN BASELINE, INSTALLED: PASS\n",$module);
     print $string;
     $result.= "<tr><td>$module</td><td>FOUND IN BASELINE, INSTALLED</td><td align=center><font color=006600><b>_PASS_</b></font></td></tr>\n";
}
}
$result.="</table> <br>\n";
$result_fail.="</table> <br>\n";
return $result,$result_fail;
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
#sub getEBSType{
#my $type=shift;
#if($type eq "S") {return @ebss;}
#if($type eq "G") {return @ebsg;}
#if($type eq "W") {return @ebsw;}
#}
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
@ebss=("sgsn","ra","cell","sa","hni","apn","ggsn","hlr","hzi","tac","tacsvn");
@ebsg=("cell","trx");
@ebsw=("cell");
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
my $testCase = shift;
if ($testCase eq "")
{
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
else
{
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
}

sub adHtmlHeader {
return qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>
ENIQ Regression Feature Test(AdminUI Test Cases)
</title>
<style>
table, th, td {
border: 1px solid black;
}
</style>
</head>
<body>
<h2>AdminUI Test Case Results</h2>
<table style=\"width:50%\">
<td>TEST CASE</td>
<td>RESULT</td>
}
};
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
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
# $mon++;
#  $year=1900+$year;
#my $date =sprintf("%4d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$wday);
open(OUT," > $LOGPATH/$server\_$datenew.html");
print  OUT $out;
close(OUT);
return "$LOGPATH/$server\_$datenew.html\n";
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
	 next if($allTechPacks=~/SQL Anywhere Error /);
	    next if($allTechPacks=~/Msg \d/);
		next if($allTechPacks=~/ Msg \d/);
     next if(/^$/);
	 print "$allTechPacks \n";
     push @result,$allTechPacks;
    }
  
  close(ALLTP);
  return @result;
}
############################################################


############################################################
# START PARAM
# These parameters are used to set or unset a test
# if the test is set to true then the test is executed, else is not
# parameters without initial value are variables that get their input from 
# the configuration file

my $adminuiMonType     ="false";
my $servercleanup	="false";
my $adminuiTypeConf   ="false";
my $adminuiDwhConf    ="false";
my $adminui_drs 	  ="false";
my $adminui_dri 	  ="false";
my $engineProcess     ="false";
my $epTp              ="";
my $epProcess         ="";
my $resizedb          ="false";
my $help              ="false";
my $sim_feature_test  ="false";
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
my $epfgloadtopology	="false";
my $verifyTopologyTables ="false";
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
my $col_no			   ="false";
my $pre               ="false";
my $prebase			  = "false";
my $preout		  = "false";
my $addAlarmReport    ="false";
my $addAlarmMinutes   ="15min";
my $baselinePath      ="";
my $featureBaselinePath      ="";
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
my $busyHourCount     ="false";
my $sample = "false";
my $wait10 = "false";
my $WaitLoaders = "false";
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
"mdc/gmpc",
"mdc/tdrbs",
"mdc/tdrnc",
"mdc/imsM",
"mdc/hss",
"mdc/mtas",
"asn1/bss",
"asn1/msc",
"sasn"
);
my @epfg_techPacks	  =  undef;
my @epfgTopoTPs = undef;
  my $chkpart				="false";
  my $Reaggregation			="false";
  my $SystemStatus			="false";
  my $DwhStatus				="false";
  my $Euupgvalidation		="false";
  my $setexectime			="false";
  my $dbspace				="false";
  my $RepStatus				="false";
  my $EngineStatus			="false";
  my $Assuremonitoring				="false";
  my $SchedulerStatus		="false";
  my $LicservStatus			="false";
  my $LicmgrStatus			="false";
  my $SessionLogs			="false";
  my $DataRowInfo			="false";
  my $adminuiMonRule			="false";
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
  my $loggingLevel			="false";
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
  my $Counter_keys					="false";
  my $dataid_dataname               ="false";
  my $soem_twamp					="false";
  my $NODE			                ="false";
  my $AGG			                ="false";
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
#sub getTechPacks{
#@techPacks         = (
#"mdc/erbs",
#"mdc/ims",
#"mdc/mgw",
#"mdc/rnc",
#"mdc/sgsn",
#"mdc/stn",
#"mdc/ggsn",
#"mdc/ipworks",
#"mdc/rbs",
#"mdc/rxi",
#"mdc/smpc",
#"mdc/gmpc",
#"mdc/tdrbs",
#"mdc/tdrnc",
#"mdc/imsM",
#"asn1/bss",
#"asn1/msc",
#"sasn"
#);
#return @techPacks;
#}
########################################################

sub getEpfgTechpacks{
my @epfg_techPacks         = (
"EBA-EBSW" ,
"EBA-EBSG" ,
"SASN" ,
"SASN-SARA" ,
"GGSN" ,
"PGW" ,
"SGW" ,
"MPG" ,
"EPG-MBMSGW" ,
"EPG(GGSN_MPG)" ,
"NODE" ,
"EPG-YANG" ,
"EPG-YANG" ,
"wmg-yang" ,
"CCRC" ,
"CCPC" ,
"CCDM" ,
"CCSM" ,
"CCES" ,
"vNSDS" ,
"PCG" ,
"SMSF" ,
"SC" ,
"CUDB" ,
"EIR-FE" ,
"EIRFE" ,
"WMG" ,
"WMG" ,
"WLE" ,
"ESC" ,
"ESC" ,
"GSM" ,
"OMS" ,
"MSC-APG" ,
"MSC-IOG" ,
"MSC-BC" ,
"MSC-APGOMS" ,
"MSC-IOGOMS" ,
"MSC-BCOMS" ,
"HLR-APG" ,
"HLR-IOG" ,
"EBSS-SGSN" ,
"EBSS-MME" ,
"EBSS-MME" ,
"SGSN-MME" ,
"SGSN" ,
"SGSNMME" ,
"PCC" ,
"scef" ,
"MGW" ,
"MRS" ,
"PRBS" ,
"TCU03" ,
"EPDG" ,
"WRAN-LTE" ,
"LTE Event Statistics dat" ,
"bss Event Statistics data" ,
"ERBSG2" ,
"RadioNodeMixed" ,
"RNC" ,
"Wran-RBS" ,
"Wran-RXI" ,
"FrontHaul" ,
"vTIF" ,
"TD-WiFi" ,
"TWAMP" ,
"TWAMP" ,
"DSC" ,
"TSS-ASN" ,
"TSS-ASN" ,
"TSS-ASNOMS" ,
"TSSAXE3gpp" ,
"IMS-WUIGM" ,
"MRR" ,
"NCS BAR" ,
"BSC-APG" ,
"BSC-IOG" ,
"STN-PICO" ,
"STN-SIU" ,
"STN-TCU" ,
"STN-PICO" ,
"STN-SIU" ,
"STN-TCU" ,
"IPWORKS" ,
"SAPC" ,
"SAPC" ,
"sapcTSP" ,
"BSP" ,
"MLPPP" ,
"EDGE-ROUTER" ,
"SE-BGF" ,
"REDBACK ComECIM" ,
"CPG" ,
"SMART_METRO" ,
"SNMP-NTP" ,
"SNMP-Mgc" ,
"SNMP-LANSwitch" ,
"SNMP-IpRouter" ,
"SNMP-HpMrfp" ,
"SNMP-GGSN" ,
"SNMP-DNSServer" ,
"SNMP_DHCPServer" ,
"SNMP_Cs_CMS" ,
"SNMP_CS_DS" ,
"SNMP_Cs_As" ,
"SNMP_ACME" ,
"SNMP_HOTSIP" ,
"SNMP_Firewall" ,
"SNMP_CSC_DS" ,
"UDM" ,
"UDM" ,
"UDR" ,
"UDR" ,
"Ausf" ,
"AUSF" ,
"Nrf" ,
"NRF" ,
"Nssf" ,
"NSSF" ,
"CSCF" ,
"vCSCF" ,
"SDNC" ,
"MTAS" ,
"mtasTSP" ,
"MGW" ,
"RBSG2" ,
"5GRadioNode" ,
"Controller" ,
"AFG" ,
"nrEvents" ,
"GSMG2" ,
"GSMMixModeOff" ,
"SBG" ,
"SBG(Classic" ,
"BBSC" ,
"UPG" ,
"CISCO" ,
"Spitfire" ,
"ip Transport or Mini -Link" ,
"JUNIPER or JUNOS" ,
"FrontHaul" ,
"Mini -Link Outdoor" ,
"MinilinkoutdoorSwitch 6391" ,
"WCG" ,
"vEME" ,
"BCE" ,
"MRSv" ,
"MRFC" ,
"HSS" ,
"hssTSP" ,
"TSS TGC" ,
"HUAWEI RNC R12 NODE" ,
"NodeBR12" ,
"ims" ,
"imsTSP" ,
"imsM" ,
"TD-RBS" ,
"TD-RNC" ,
"SMPC" ,
"MGC" ,
"HLR-BS" ,
"Statistics File" ,
"EM-MTN" ,
"EM-MSP" ,
"EM-VXX" ,
"EM-XSA" ,
"EM-DRS" ,
"EM-AXX" ,
"EM-SMA" ,
"EM-SMX" ,
"EM-ETU" ,
"EM-MLE" ,
"EM-MHC" ,
"EM-MBA" ,
"EM-IMT" ,
"EM-MLE" ,
"EM-MET" ,
"EM-SPR" ,
"vPP" ,
"LLE" ,
"TSS-TGC" ,
"IMS" ,
"IMSM" ,
"IP-RAN" ,
"IPTNMS-PACKET" ,
"IPTNMS-CIRCUIT" ,
"SOEM-PIC" ,
"SOEM-ASCII" ,
"IPTNMS-ASCII" ,
"TWAMP" ,
"EPG(epdg)" ,
"TWAMPSDC" ,
"WRAN-RNC" ,
"HLR-Sub" ,
"VLR-Sub" ,
"HUAWEI-RNC" ,
"HUAWEI-NODEB" ,
"HUAWEI-NODEBSS" ,
"TSS" ,
"GMPC" ,
"Redback-Bgf" ,
"Redback-CPG" ,
"Redback-EdgeRtr" ,
"RedbackMlppp" ,
"RedbackSmartMetro" ,
"Scef" ,
"SDNC" ,
"WRAN-LTE" ,
"WRAN-LTE" ,
"snmpCSAS" ,
"snmpCSCDS" ,
"snmpCSDS" ,
"snmpCSMS" ,
"snmpDHCPServer" ,
"snmpDNSServer" ,
"snmpHotSip" ,
"snmpHPMRFP" ,
"snmpIPRouter" ,
"snmpMGC" ,
"snmpNTP" ,
"NRNSA" ,
"WRAN-RBS_INFO" ,
"vSAPC" ,
"WCG" ,
"GSM" ,
"vMTAS" ,
"spitFire" ,
"IpTransport" ,
"MinilinkIndoor" ,
"JUNIPER" ,
"BCE" ,
"IP-RAN" ,
"BULKCM",
"CPP",
"BTSG2",
"VAFG",
"TCU03",
"MINI-Link",
"BSC",
"vECE(SCEF)" ,
"CNAXE",
"BSS",
"STN",
"REDB",
"RAN",
"LTE-Event",
"NR",
"TSS-AXE",
);

return @epfg_techPacks;
}

########################################################



sub getRackepfg_Techpacks{
my @rack_techPacks         = (
"MTAS",
"GGSN",
"PGW",
"SGW",
"CUDB",
"MSC-APG",
"MSC-IOG",
"MSC-BC",
"MSC-APGOMS",
"MSC-IOGOMS",
"MSC-BCOMS",
"SGSN",
"SGSN-MME",
"MGW",
"MGW2.0FD"
);

return @rack_techPacks;
}
######################################################
sub getMultiepfg_Techpacks{
my @rack_techPacks         = (
"SASN",
"SASN-SARA",
"IPWORKS",
"SAPC",
"SBG",
"CSCF",
"HSS",
"MRFC",
"IMS",
"IMSM"
);

return @rack_techPacks;
}


######################################################
sub getBladeepfg_Techpacks{
my @blade_techPacks         = (
"EBA-EBSW",
"EBA-EBSG",
"EBSS-SGSN",
"WRAN-LTE",
"RNC",
"BSC-APG",
"BSC-IOG",
"Wran-RBS",
"Wran-RXI",
"HLR-APG",
"HLR-IOG",
"STN-PICO",
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
"TD-WiFi",
"TSS-TGC",
"TWAMP",
"TD-RNC",
"TD-RBS",
"PRBS"
);
return @blade_techPacks;
}
########################################

sub getAll_Techpacks{
my @all_techPacks         = (
"DC_E_MTAS",
"DC_E_GGSN",
"DC_E_CUDB",
"DC_E_CNAXE",
"DC_E_SGSN",
"DC_E_MGW",
"DC_E_SASN_SARA",
"DC_E_SASN",
"DC_E_IMSSBG",                           
"DC_E_IMS_IPW",
"DC_E_IMS",
"DC_E_SAPC",
"DC_E_HSS",
"DC_E_DSC",
"DC_E_ERBS",
"DC_E_RAN",
"DC_E_RBS",
"DC_E_CPP",
"DC_E_PRBS_RBS",
"DC_E_PRBS_ERBS",
"DC_E_PRBS_CPP",
"DC_E_BSS",
"DC_E_STN",
"DC_E_CMN_STS",
"DC_E_SMPC",
"DC_E_GMPC",
"DC_E_TSS_TGC",
"DC_E_SNMP",
"DC_E_WIFI",
"DC_E_TDRBS",
"DC_E_TDRNC",
"DC_E_IPPROBE",
"DC_E_REBD",
"DC_E_CPG",
"DC_E_EPDG",
"DC_E_TCU"
);
return @all_techPacks;
}

########################################
sub getRackTechpacks{
my @rack_techPacks         = (
"DC_E_MTAS",
"DC_E_GGSN",
"DC_E_CUDB",
"DC_E_CNAXE",
"DC_E_SGSN",
"DC_E_MGW"
);
return @rack_techPacks;
}
##############################3##############
sub getMultiBladeTechpacks{
my @rack_techPacks         = (
"DC_E_SASN_SARA",
"DC_E_SASN",
"DC_E_IMSSBG",                           
"DC_E_IMS_IPW",
"DC_E_IMS",
"DC_E_SAPC",
"DC_E_HSS",
"DC_E_DSC"
);
return @rack_techPacks;
}

##############################################

sub getBladeTechpacks{
my @blade_techPacks         = (
"DC_E_ERBS",
"DC_E_RAN",
"DC_E_RBS",
"DC_E_CPP",
"DC_E_PRBS_RBS",
"DC_E_PRBS_ERBS",
"DC_E_PRBS_CPP",
"DC_E_BSS",
"DC_E_STN",
"DC_E_CMN_STS",
"DC_E_SMPC",
"DC_E_GMPC",
"DC_E_TSS_TGC",
"DC_E_SNMP",
"DC_E_WIFI",
"DC_E_TDRBS",
"DC_E_TDRNC",
"DC_E_IPPROBE",
"DC_E_REBD",
"DC_E_CPG",
"DC_E_DSC"
);

return @blade_techPacks;
}
#######################################################


my @tpini            =  ();
my @aggini           =  undef;
my $contents = 	qq{<br><table border="1">
				<tr>
				<th colspan="3"><font size="2" color=Blue><b><u>Contents</u></b></font></th>
				</tr>
				<tr>
				<th>No.</th>
				<th>Test Case</th>
				<th>Result</th>
				</tr>
				};

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
my $inputwait = 0;
my $result="";
my $adminUI_res = "";
my $adminUI_count = "";
my $adminUI_start = "";
my $admin_end = "";
my $uni = "";
#my $alarm_uni = "";
my $uni_count = "";
my $uni_start = "";
my $uni_end = "";
my $server_res = "";
my $serv_count = "";
my $serv_start = "";
my $serv_end = "";
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
	if(/^ADMINUI_DWHCONFIG/)
   {
   $adminuiDwhConf					 ="true";
   }
    if(/^ADMINUI_TYPECONFIG/)
   {
   $adminuiTypeConf					 ="true";
   }
   if(/^ADMINUI_MONTYPE/)
   {
   $adminuiMonType					 ="true";
   }
    if(/^ADMINUI_DATA_ROW_SUMMARY/)
   {
   $adminui_drs					 ="true";
   }
   if(/^ADMINUI_DATA_ROW_INFO/)
   {
   $adminui_dri				 ="true";
   
   
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
   ;
   }
    if(/^DBSpace_FileSystemUsage/) 
   {
   $dbspace                     ="true";
   }   
   if(/^DWHDBSTATUS/) 
   {
   $DwhStatus                         ="true";
   }
   if(/^UPGRADECONTENTSCHECK/) 
   {
   $Euupgvalidation                 ="true";
   }
   if(/^SETEXECUTIONTIME/) 
   {
   $setexectime						="true";
   
   
   }
   if(/^ASSUREMONITORING/) 
   {
   $Assuremonitoring				="true";
#   
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
  
   if(/^ADMINUI_MONRULE/) 
   {
   $adminuiMonRule                   ="true";
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
   if(/^DISKSPACE_ADMINUI/) 
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
   if(/^LOGGING_LEVEL/) 
   {
   $loggingLevel                       ="true";
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
   if(/^Counter/) 
   {
   $Counter_keys               ="true";
   
   }
    if(/^DataMismatch/) 
   {
    $dataid_dataname               ="true";
    print "working";
   }
    if(/^SOEM&TWAMP/) 
   {
    $soem_twamp               ="true";
    print "working";
   }
    if(/^COlumnNumberMismtach/) 
   {
    $col_no               ="true";
    print "working";
   }
    if(/^Datavalidation/) 
   {
    $NODE              ="true";
	system("webserver restart");
    print "DATA Validation\n";
   }
    if(/^aggregation/) 
   {
    $AGG              ="true";
    print "DATAaggregation";
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
if(/^SIM_FEATURE_TEST/)
{
$sim_feature_test             ="true";
}
if(/^COMPARE_BASELINE/)
{
	$compareBaseline      ="true";
	($baselinePath,$featureBaselinePath) = getMwsPath();
	########NOT REQUIRED BECAUSE MWS CONVENTION HAS CHANGED##########
	#open(FILE , '/eniq/admin/version/eniq_status');
	#my $fileversion = <FILE>;
	#close FILE;
	#print " the first line is $fileversion \n";
	#my $value = '';
	#my $pfRelease = '';	
	#print "ENIQ Status File - $fileversion";
	#if ($fileversion =~ /.*Shipment_(.*) AOM.*/)
	#{
	#	$pfRelease=$1;
	#	print "Platform Release - $pfRelease \n";
	#}
	#my $temp = substr($fileversion, -2);
	#print "String concat2 - $temp \n";
	#$temp =~ s/^\s+//;
	#print "String concat3 - $temp\n";
	#if ($temp =~ /^[+-]?\d+$/ )
	#{
	#$report.=".EU$temp";
	#}
	#'/net/10.45.192.134/JUMP/ENIQ_STATS/ENIQ_STATS/'.$report.'/eniq_base_sw/';
	##################################################################
	
	print "PF Baseline Path - $baselinePath\n";
	print "Feature Baseline Path - $featureBaselinePath\n";
	
}
if(/^VERIFY_EXECUTABLES/)
{
$verifyExes        ="true";
}
if(/^READLOG/)
{
  #$verifyLogs      ="true";
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
if(/^DAYBH-INFO/)
{
$verifyDAYBH       ="true";
}
if(/^RANKBH-INFO/)
{
$verifyRANKBH       ="true";
}
if(/^SERVERCLEANUP/)
{
$servercleanup	="true";
}
if(/^EPFGLOADTOPOLOGY/)
{
$epfgloadtopology	="true";
}
if(/^VERIFY TOPOLOGY TABLES/) 
{
	$verifyTopologyTables  ="true";
	system("dwhdb restart");
	$input =~ s/VERIFY TOPOLOGY TABLES//;
	#print " the input is:$input \n";
	my @input = split(' ',$input);
	#print " the input is:@input \n";
	my $leng = @input ;
	if($input[0] eq 'ALL')
		{
			@epfg_techPacks=getEpfgTechpacks();
			print "This is the list of techpacks.. @epfg_techPacks \n";
			my $tp="";
			for my $tps (@epfg_techPacks)
			{
				$tp=$epfg_tps{$tps};
				my @inputTp = split(":",$tp);
				for my $topotp (@inputTp) {
					push @epfgTopoTPs, $topotp;
				}
			}
		}else { 
			for( my $i = 0 ; $i<=$leng ; $i++)
				{
				push(@epfg_techPacks,$input[$i]);
				}
			my $tp="";
			for my $tps (@epfg_techPacks)
			{
				$tp=$epfg_tps{$tps};
				push @epfgTopoTPs, $tp;
			}

			print "This is the list of techpacks.. @epfg_techPacks \n";
			}
	
}
if(/^BUSY_HOUR_COUNT/)
{
	$busyHourCount = "true";
	
	
}
if(/^SAMPLE/)
{
	$sample = "true";
	
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

elsif(/^EPFG DATAGEN DISABLE ALL/)
{
	@epfg_techPacks    =undef;
	print "EPFG TOPOLOGY Data not loaded.\n";
}

###################################################### 
if(/^DATAGENMANAGER/)
{
$dataGeneration       ="true";
}
if(/^EPFGLOADPM/)
{
$epfgdataGeneration       ="true";
$input =~ s/EPFGLOADPM//;
	#print " the input is:$input \n";
	my @input;
	($epfgnumberofnodes,$epfgstarttime,$epfgstoptime,@input) = split(' ',$input);
	#print " the input is:\t $epfgnumberofnodes \t $epfgstarttime,\t $epfgstoptime,\t @input \n";
	$timeWarp = $epfgstarttime;
	my $leng = @input ;
	if($input[0] eq 'ALL')
		{
			@epfg_techPacks=getEpfgTechpacks();
			print "This is the list of techpacks.. @epfg_techPacks \n";
			
		}else { 
			for( my $i = 0 ; $i<=$leng ; $i++)
				{
				push(@epfg_techPacks,$input[$i]);
				}
			print "This is the list of techpacks.. @epfg_techPacks \n";
			}
	


  
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
	print "GLOBAL DATE : $DATETIMEWARP\n";

#	my ($TIME,$DAYTIME,$MONTHTIME,$YEARTIME);
  
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
  
}
if(/^WAIT /)
{
$inputwait=~s/WAIT //;

# TRANSFORM TO MINUTES
$wait10 = "true";

}
if(/WAIT_UNTIL_PROCESSES_DONE/)
{
 waitUntilProcessesDone();
}
if(/WAIT_UNTIL_LOADERS_DONE/)
{
$WaitLoaders = "true";
 
}
if(/WAIT_UNTIL_AGGREGATORS_DONE/)
{
 waitUntilAggregatorsDone();
}
if(/^PRE_LOAD/)
{
$preLoad       ="true";
}
elsif(/^PRE_INDIR/)
{
$pre       ="true";

}
if(/^PREBASE/)
{
	print " Prebase is true \n";
$prebase       ="true";

}
if(/^PREOUT/)
{
$preout       ="true";

}
#########################################
if(/^LISTUPDATE TPINI DISABLE ALL/)
{
@tpini    = ();
}
elsif(/^LISTUPDATE TPINI ENABLE ALL/)
{
@tpini    = Divide_Techpacks();
print "LISTUPDATE TPINI ENABLE ALL : \n";
for my $g1 (@tpini)
{
	print "$g1\n";
}
# CHECK TP 
#DEFINE ALL TECHPACKS SOMEWHERE
#my $date=`date +'%a'`;
#if($date=~/^Mon/i)
#{
#@tpini    = Divide_Techpacks();
#}
#else{
#@tpini=delivered_feature();
#}
#print " this is the list of techpacks:@tpini\n";
}
elsif(/^LISTUPDATE TPINI ENABLE /)
{
$input=~s/LISTUPDATE TPINI ENABLE //;
$input=~s/ //g;
@tpini = split(/,/, $input);
}
#############################################

if(/^SHOW_LOADINGS/)
{
$verifyLoadings    ="true";


}
#############################################
if(/^LISTUPDATE AGGINI ENABLE ALL/)
{
@tpini    = Divide_Techpacks();
# CHECK TP 
#DEFINE ALL TECHPACKS SOMEWHERE
#my $date=`date +'%a'`;
#if($date=~/^Mon/i)
#{
#@tpini    = Divide_Techpacks();
#}
#else{
#@tpini=delivered_feature();
#}
print " this is the list of techpacks:@tpini\n";
}


elsif(/^LISTUPDATE AGGINI ENABLE /)
{
$input=~s/ //g;
@aggini = split(/,/, $input);
}
elsif(/^LISTUPDATE AGGINI DISABLE ALL/)
{
@aggini= undef;
}
##############################################
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
}
$result = DoSomething($inputwait);
return $result;
}

sub DoComparebaseline
{
my $DATE=getDate();
#$contents .=	qq{<tr><td>1</td><td><a href="#COMPAREBASELINE_">COMPARE BASELINE</a></td>};
    my $report = getStartTimeHeader("compareBaseline");
	my $result.= "<h2><a name=\"COMPAREBASELINE_\">$DATE COMPAREBASELINE</a></h2><br>\n";

	my ($result1,$result1_fail)=compareBaselineModules($baselinePath,$featureBaselinePath);
	my ($result2,$result2_fail)=compareBaselineTechpacks($featureBaselinePath);
	my ($result3,$result3_fail)=compareBaselineInterfaces($featureBaselinePath);
	my ($result4,$result4_fail)=majorVersionCheck($featureBaselinePath);
	$result.=$result1;
	$result.=$result2;
	$result.=$result3;
	$result.=$result4;
	my $result_count.=$result1;
	$result_count.=$result2;
	$result_count.=$result3;
	$result_count.=$result4;
	my $fail =()= $result_count =~ /_FAIL_+/g;
	my $pass =()= $result_count =~ /_PASS_+/g;
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	my $mod_fail =()= $result1_fail =~ /FAIL+/g;
	my $tp_fail =()= $result2_fail =~ /FAIL+/g;
	my $intf_fail =()= $result3_fail =~ /FAIL+/g;
	my $version_fail =()= $result4_fail =~ /FAIL+/g;
	 
	$report .= getEndTimeHeader($pass,$fail);
	if($fail==0){
		$report.= "<p><font size=8 color=006600><b>NO FAILED TESTCASES</b></font></p>";
	}
	else{
		if ($mod_fail==0){
			$report.= "<br><br><p><font size=8 color=006600><b>NO FAILED PLATFORM MODULES PRESENT</b></font></p><br><br>";
		}
		else{
			$report.= $result1_fail;
		}
		if ($tp_fail==0){
			$report.= "<br><br><p><font size=8 color=006600><b>NO FAILED TECHPACKS PRESENT</b></font></p><br><br>";
		}
		else{
			$report.= $result2_fail;
		}
		if ($intf_fail==0){
			$report.= "<br><br><p><font size=8 color=006600><b>NO FAILED INTERFACES PRESENT</b></font></p><br><br>";
		}
		else{
			$report.= $result3_fail;
		}
		if ($version_fail==0){
			$report.= "<br><br><p><font size=3 color=006600><b>ALL CLASSES ARE WITH JDK1.7 IMPLEMENTATION</b></font></p><br><br>";
		}
		else{
			$report.= $result4_fail;
		}
	}
    $report.= getHtmlTail(); 
    my $file = writeHtml("COMPAREBASELINE_VERIFICATION",$report);
	open(FH, ">>", "/eniq/home/dcuser/Temp.html") or die "File couldn't be opened";
	print FH $result;
	print "COMPAREBASELINE_VERIFICATION: PASS- $pass FAIL- $fail\n";
	print "PARTIAL FILE: $file\n"; 
}

sub DoVerifyLoadings
{
my $DATE=getDate();
	#$contents .=	qq{<tr>				<td></td>				<td><a href="#verifyLoadings_">VERIFY DATA LOADING</a></td>				};
	my $report =getStartTimeHeader("verifyLoadings");
#    my $report =getHtmlHeader();
#    $report.= "<h2>STARTTIME:";
#    $report.= getTime();
	my $result.= "<h2><a name=\"verifyLoadings_\">$DATE VERIFY DATA LOADING</h2><br>\n";
	print $DATE;
	print " VERIFY DATA LOADING\n";
	my ($result1,$result1_fail) = verifyLoadings();
    $result.=$result1;
	my $result_count.=$result1;
	 
		my $fail =()= $result_count =~ /FAIL+/g;
		my $pass =()= $result_count =~ /PASS+/g;
	 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
						
	$report .= getEndTimeHeader($pass,$fail);

	#---ADDED CODE---#
	#$report.= "<tr>";
	#$report.=qq{<tr>
	#				<th> <font size = 2 > END TIME </th>
	#				<td><font size = 2 ><b>};
    #my $etime = getTime();
	 #$report.= "$etime";
	 #$report.= "<tr>";
	 #$report.=qq{<tr>
		#			<th> <font size = 2 > RESULT SUMMARY </th>
		#			<td><font size = 2 ><b>};
	 #$report.= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)";
	 #$report.= "</table>";
	 #$report.= "<br>";
	#---ADDED CODE---#
	
	if($fail==0)
	{
		$report.= "<p><font size=8 color=006600><b>NO FAILED TESTCASES</b></font></p>";
	}
	else
	{
	$report .= $result1_fail;
	}
	#$result.=$result1;
#	$report.= "<h2>ENDTIME:";
#    $report.= getTime()."</h2>";
    $report.= getHtmlTail(); 
    my $file = writeHtml("VERIFY_DATA_LOADING",$report);
	open(FH, ">>", "/eniq/home/dcuser/Temp.html") or die "File couldn't be opened";
	print FH $result;
	print "VERIFY_DATA_LOADING: PASS- $pass FAIL- $fail\n";
	print "PARTIAL FILE: $file\n";
}

sub DoVerifyTopoLoad
{
my $DATE=getDate();
	#$contents .=	qq{<tr>				<td></td>				<td><a href="#verifyTopologyTables_">VERIFY TOPOLOGY TABLES</a></td>				};
	my $report = getStartTimeHeader("verifyTopologyTables");
#   my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> EPFG VERIFY TOPOLOGY TABLES</u> </font> </h1>";
		my $result.= "<h2><a name=\"verifyTopologyTables_\">$DATE VERIFY TOPOLOGY TABLES</a></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#         my $stime = getTime();
#		  $report.= "$stime";
	print $DATE;
	print "VERIFY TOPOLOGY TABLES\n";
	my ($result1,$result1_fail) = verifyTopology();
	$result.=$result1;
		my $pass =()= $result1 =~ /PASS+/g;
		my $fail =()= $result1=~ /FAIL+/g;
	 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};					

	$report .= getEndTimeHeader($pass,$fail);
	
	#---ADDED CODE---#
	#$report.= "<tr>";
	#$report.=qq{<tr>
	#				<th> <font size = 2 > END TIME </th>
	#				<td><font size = 2 ><b>};
    #my $etime = getTime();
	 #$report.= "$etime";
	 #$report.= "<tr>";
	 #$report.=qq{<tr>
		#			<th> <font size = 2 > RESULT SUMMARY </th>
		#			<td><font size = 2 ><b>};
	 #$report.= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)";
	 #$report.= "</table>";
	 #$report.= "<br>";
	 #---ADDED CODE---#

	 if($fail==0)
	 {
		$report.= "<p><font size=8 color=006600><b>NO FAILED TESTCASES</b></font></p>";
	 }
	 else
	 	{
		$report.= $result1_fail;
	}
	#$result.=$result1;
	$report.= getHtmlTail(); 
    my $file = writeHtml("VERIFY_TOPOLOGY_TABLES",$report);
	open(FH, ">>", "/eniq/home/dcuser/Temp.html") or die "File couldn't be opened";
	print FH $result;
	print "VERIFY_TOPOLOGY_TABLES: PASS- $pass FAIL- $fail\n";
	print "PARTIAL FILE: $file\n";
}
sub DoLogs
{
my $DATE=getDate();
	#$contents .=	qq{<tr>				<td></td>				<td><a href="#READLOG_">LOG VERIFICATION</a></td>				};
    my $report =getStartTimeHeader("verifyLogs");
	my $report1 =getStartTimeHeader("verifyLogs");
	my $report2 =getStartTimeHeader("verifyLogs");
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
my $result.= "<h2><font color=Black><a name=\"READLOG_\">$DATE LOG VERIFICATION</a></font></h2><br>";
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
	open(FH, ">>", "/eniq/home/dcuser/Temp.html") or die "File couldn't be opened";
	print FH $result;

}
sub DoCounters
   {
  my $DATE=getDate();
   print "working";
		#$contents .=	qq{<tr>				<td></td>				<td><a href="#COUNTER_">COUNTER AND KEYS VALIDATION</a></td>				};
	my $report = getStartTimeHeader("Counter_keys");
#        my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
     my $result.= "<h2><a name=\"COUNTER_\">$DATE COUNTER AND KEYS VALIDATION</h2><br>\n";
     print $DATE;
     print " Counter_keys\n";
     my ($result1,$result1_fail,$emptyTables1) = Counter_keys();
	 $result.=$result1;
	 my $result_count.=$result1;
	 
		my $fail =()= $result_count =~ /_FAIL_+/g;
		my $pass =()= $result_count =~ /_PASS_+/g;
		my $emptyTables =()= $emptyTables1 =~ /<tr><td>+/g;
		
	print "fail: $fail\n";
	print "pass: $pass\n";
	 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail) / <a href=\"#t1\">EMPTY TABLES ($emptyTables)</td>
						</tr>
						};
	 $report .= getEndTimeHeaderForCounterAndKeys($pass,$fail,$emptyTables);
	 
		if($fail==0 && $emptyTables ==0)
		{
			$report.= "<p><font size=8 color=006600><b>NO FAILED TESTCASES</b></font></p>";
		}
		else
		{
		$report.=$emptyTables1;
		$report.= $result1_fail;
		}
		#$result.=$result1;
#	 $report.= "<h2>ENDTIME:";
#     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("COUNTER_AND_KEYS_VALIDATION",$report);
	 open(FH, ">>", "/eniq/home/dcuser/Temp.html") or die "File couldn't be opened";
	print FH $result;
	 print "COUNTER_AND_KEYS_VALIDATION: PASS- $pass FAIL- $fail\n";
	 print "PARTIAL FILE: $file\n";

   }

#############  NOW DO SOMETHING  ##########
sub DoSomething
{
my $inputwait = $_[0];
my $result="";
my $adminUI_res = "";
my $adminUI_count = "";
my $adminUI_start = "";
my $admin_end = "";
my $uni = "";
#my $alarm_uni = "";
my $uni_count = "";
my $uni_start = "";
my $uni_end = "";
my $server_res = "";
my $serv_count = "";
my $serv_start = "";
my $serv_end = "";
my $DATE=getDate();

my @Func_Array = ();
my $time1 = localtime();
print "starttime = $time1\n";
if($compareBaseline eq "true")
{
async { DoComparebaseline() };
}
if($verifyTopologyTables  eq "true")
{
async { epfgloadTopology() };
}
if($epfgdataGeneration      eq "true")
{
async { epfgpmdataGeneration() };
}
$_->join() for threads->list;

$time1 = localtime();
print "endtime = $time1\n";

if($SystemStatus eq "true") 
{
	$contents .=	qq{<tr>
					<td></td>
					<td><a href="#SystemStatus_">SYSTEM STATUS VERIFICATION(ADMINUI PLATFORM CHECKS)</a></td>
					};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}
		print $DATE;
		print " SYSTEM STATUS VERIFICATION ADMINUI\n";
#		my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> SYSTEM STATUS VERIFICATION ADMINUI</u> </font> </h1>";
		$result.= "<h2><font color=Black><a name=\"SystemStatus_\">$DATE SYSTEM STATUS VERIFICATION (ADMINUI PLATFORM CHECKS)</a></font></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#			<tr>
#			<th> <font size = 2 >START TIME </th>
#			<td> <font size = 2 > <b>};
#		$report.= getTime();
		my ($result1,$result1_fail) = SystemStatus();
		$adminUI_count .= $result1;
		 my $fail =()= $result1 =~ /_FAIL_+/g;
		 my $pass =()= $result1 =~ /_PASS_+/g;
		 
		 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		 if ($fail != 0)
		{
			$adminUI_res .= "<h2>$DATE SYSTEM STATUS VERIFICATION ADMINUI</h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
#		$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
		$result.=$result1;
		$admin_end = getTime();
#		$report.= $result1;
#		$report.= getHtmlTail(); 
#		my $file = writeHtml("SYSTEMSTATUS_ADMINUI",$report);
#		print "PARTIAL FILE: $file\n"; 
		$SystemStatus                         ="false";
}
if($EngineStatus eq "true") 
	{
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ENGINESTATUS_">ENGINESTATUS VERIFICATION(ADMINUI PLATFORM CHECKS)</a></td>
				};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}
#		$adminUI_res .= "<h2><font color=Black>$DATE ENGINESTATUS VERIFICATION</font></h2><br>\n";
		print $DATE;
		print " ENGINESTATUS VERIFICATION\n";
#		my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> ENGINESTATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2><font color=Black><a name=\"ENGINESTATUS_\">$DATE ENGINESTATUS VERIFICATION(ADMINUI PLATFORM CHECKS)</a></font></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#		$report.= getTime();
		my ($result1,$result1_fail) = EngineStatus();
		$adminUI_count .= $result1;
		 my $fail =()= $result1 =~ /_FAIL_+/g;
		 my $pass =()= $result1 =~ /_PASS_+/g;
		 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		 if ($fail != 0)
		{
			$adminUI_res .= "<h2><font color=Black>$DATE ENGINESTATUS VERIFICATION</font></h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
#		$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
		$result.=$result1;
		$admin_end = getTime();
#		$report.= $result1;
#		$report.= getHtmlTail(); 
#		my $file = writeHtml("ENGINESTATUS",$report);
#		print "PARTIAL FILE: $file\n"; 
		$EngineStatus="false";
	}
if($SchedulerStatus eq "true")
	{
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#SCHEDULERSTATUS_">SCHEDULER STATUS VERIFICATION(ADMINUI PLATFORM CHECKS)</a></td>
				};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}
#		$adminUI_res .= "<h2>$DATE SCHEDULERSTATUS</h2><br>\n";
		print $DATE;
		print " SCHEDULERSTATUS\n";
#		my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> SCHEDULERSTATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2><font color=Black><a name=\"SCHEDULERSTATUS_\">$DATE SCHEDULER STATUS VERIFICATION (ADMINUI PLATFORM CHECKS)</a></font></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#		$report.= getTime();
		my ($result1,$result1_fail) = SchedulerStatus();
		$adminUI_count .= $result1;
		my $fail =()= $result1 =~ /_FAIL_+/g;
		my $pass =()= $result1 =~ /_PASS_+/g;
		$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		if ($fail != 0)
		{
			$adminUI_res .= "<h2>$DATE SCHEDULERSTATUS</h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
#		$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
		$result.=$result1;
		$admin_end = getTime();
#		$report.= $result1;
#		$report.= getHtmlTail(); 
#		my $file = writeHtml("SCHEDULERSTATUS",$report);
#		print "PARTIAL FILE: $file\n"; 
		$SchedulerStatus="false";
    }
if($LicservStatus eq "true") 
   {
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#LICSERVSTATUS_">LICENSE SERVER STATUS VERIFICATION (ADMINUI PLATFORM CHECKS)</a></td>
				};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}
#		$adminUI_res .= "<h2>$DATE LICSERVSTATUS</h2><br>\n";
		print $DATE;
		print " LICSERVSTATUS\n";
#		my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> LICSERVSTATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2><font color=Black><a name=\"LICSERVSTATUS_\">$DATE LICENSE SERVER STATUS VERIFICATION (ADMINUI PLATFORM CHECKS)</font></a></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#		$report.= getTime();
		my ($result1,$result1_fail) = LicservStatus();
		$adminUI_count .= $result1;
		my $fail =()= $result1 =~ /_FAIL_+/g;
		my $pass =()= $result1 =~ /_PASS_+/g;
		$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		if ($fail != 0)
		{
			$adminUI_res .= "<h2>$DATE LICSERVSTATUS</h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
#		$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
		$result.=$result1;
		$admin_end = getTime();
#		$report.= $result1;
#		$report.= getHtmlTail(); 
#		my $file = writeHtml("LICSERVSTATUS",$report);
#		print "PARTIAL FILE: $file\n"; 
		$LicservStatus="false";
	}
if($VerifyDirectories eq "true") 
   {
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#VERIFY_DIRECTORY_">VERIFY DIRECTORY SPACE (Sanity Directory Scripts Check)</a></td>
				};
		if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
#	$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFY DIRECTORY SPACE </b></font> </h2>";
#        my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> VERIFY DIRECTORY SPACE </u> </font> </h1>";
		$result.= "<h2><font color=Black><a name=\"VERIFY_DIRECTORY_\">$DATE VERIFY DIRECTORY SPACE (Sanity Directory Scripts Check)</a></font></h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#         my $stime = getTime();
#		  $report.= "$stime";
#          $result.= "<h2><font color=Black>$DATE VERIFY DIRECTORY SPACE</font></h2><br>\n";
     print $DATE;
     print " VERIFY_DIRECTORIES\n";
     my ($result1,$result1_fail)=VerifyDirectories();
	     $serv_count .= $result1;
		 my $fail =()= $result1 =~ /_FAIL_+/g;
		 my $pass =()= $result1 =~ /_PASS_+/g;
		 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
#	 my $pass =()= $result1 =~ /PASS+/g;
#	 $report.= "<tr>";
#	$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#    my $etime = getTime();
#	 my $server= getHostName();
#	 $report.= "$etime";
#	 $report.= "<tr>";
#	 $report.=qq{	<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
#	 $report.= "<a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)";
#	 $report.=qq{<tr>
#				<th> <font size = 2 > DETAILED RESULT </th>
#				<td><font size = 2 ><b>};
#	 $report.= "<a href=\"$server\_$datenew.html\" target=\"_blank\">Click here</a>";
#	 $report.= "</table>";
#	 $report.= "<br>";
	if($fail != 0)
	{
		$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFY DIRECTORY SPACE </b></font> </h2>";
		$server_res.= $result1_fail;
	}
	$result.=$result1;
	 $serv_end = getTime();
#	 $report.= "<h2>ENDTIME:";
#     $report.= getTime()."</h2>";
#     $report.= getHtmlTail(); 
#    my $file = writeHtml("VERIFY_DIRECTORIES",$report);
#	 print "PARTIAL FILE: $file\n";
   $VerifyDirectories                 ="false";
   }
   if($VerifyAdminScripts eq "true") 
   {
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#VERIFY_ADMIN_SCRIPTS_">ADMIN SCRIPTS VERIFICATION (Sanity Directory Scripts Check)</a></td>
				};
	if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
#	$server_res = "<h2> <font color=MidnightBlue><center><b> ADMIN SCRIPTS VERIFICATION </b></font> </h2>";
#	my $report =getHtmlHeader();
#	$report.= "<h1> <font color=MidnightBlue><center> <u> ADMIN SCRIPTS VERIFICATION </u> </font> </h1>";
	$result.= "<h2><font color=Black><a name=\"VERIFY_ADMIN_SCRIPTS_\">$DATE ADMIN SCRIPTS VERIFICATION (Sanity Directory Scripts Check)</a></font></h2><br>\n";
#	$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#				<tr>
#				<th> <font size = 2 >START TIME </th>
#				<td> <font size = 2 > <b>};
#	$report.= getTime();
	my ($result1,$result1_fail)=VerifyAdminScripts();
	$serv_count .= $result1;
	my $fail =()= $result1 =~ /_FAIL_+/g;
	my $pass =()= $result1 =~ /_PASS_+/g; 
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
#	$report.=qq{<tr>
#			<th> <font size = 2 > END TIME </th>
#			<td> <font size = 2 ><b>};
#	$report.= getTime();
#	my $server= getHostName();
#	$report.=qq{<tr>
#				<th> <font size = 2 > RESULT SUMMARY </th>
#				<td><font size = 2 ><b>};
#	$report.= "<a href=\"#t1\"> <font color = green>PASS ($pass)<font color = black>  /  <a href=\"#t2\"><font color = red>FAIL ($fail)</td>";
#	$report.=qq{<tr>
#				<th> <font size = 2 > DETAILED RESULT </th>
#				<td><font size = 2 ><b>};
#	$report.= "<a href=\"$server\_$datenew.html\" target=\"_blank\">Click here</a>";
#	$report.= "</table>";
#	$report.= "<br>";
	if($fail != 0)
	{
		$server_res = "<h2> <font color=MidnightBlue><center><b> ADMIN SCRIPTS VERIFICATION </b></font> </h2>";
		$server_res.= $result1_fail;
	}
	$result.= $result1;
	$serv_end = getTime();
#    $report.= getHtmlTail();
#   my $file = writeHtml("VERIFY_ADMIN_SCRIPTS",$report);
#	print "PARTIAL FILE: $file\n";
   $VerifyAdminScripts                ="false";
   }
   if($ActiveProcs eq "true") 
   {
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ACTIVE_PROCS_">ACTIVE PROCESSES (ADMINUI PLATFORM CHECKS)</a></td>
				};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}

#       my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime(); 
     $result.= "<h2><font color=Black><a name=\"ACTIVE_PROCS_\">$DATE ACTIVE PROCESSES (ADMINUI PLATFORM CHECKS)</a></font></h2><br>\n";
#	 $adminUI_res .= "<h2>$DATE ACTIVE_PROCS</h2><br>\n";
     print $DATE;
     print " ACTIVE_PROCS\n";
     my ($result1,$result1_fail) = ActiveProcs();
	     $adminUI_count .= $result1;
		 my $fail =()= $result1 =~ /_FAIL_+/g;
		 my $pass =()= $result1 =~ /_PASS_+/g;
		 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		 if ($fail != 0)
		{
			$adminUI_res .= "<h2>$DATE ACTIVE_PROCS</h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
		$result.=$result1;
		$admin_end = getTime();
#		 $report.= $result1;
#	 $report.= "<h2>ENDTIME:";
#     $report.= getTime()."</h2>";

#    $report.= getHtmlTail(); 
#     my $file = writeHtml("ACTIVE_PROCS",$report);
#	 print "PARTIAL FILE: $file\n";
   $ActiveProcs                       ="false";
   }
   if($ShowAggFutureDates eq "true") 
   {
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#FUTURE_DATES_">SHOW AGGREGATION FUTURE DATES (ADMINUI PLATFORM CHECKS)</a></td>
				};
		if ($adminUI_start eq "")
		{
			$adminUI_start = getStartTimeHeader("adminUI");
		}
#		$adminUI_res .= "<h2>$DATE SHOW_AGG_FUTURE_DATES</h2><br>\n";
#        my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
     $result.= "<h2><font color=Black><a name=\"FUTURE_DATES_\">$DATE SHOW AGGREGATION FUTURE DATES (ADMINUI PLATFORM CHECKS)</a></font></h2><br>\n";
     print $DATE;
     print " SHOW_AGG_FUTURE_DATES \n";
     my ($result1,$result1_fail) = ShowAggFutureDates();
		 $adminUI_count .= $result1;
		my $fail =()= $result1 =~ /_FAIL_+/g;
		my $pass =()= $result1 =~ /_PASS_+/g;
		$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
		if ($fail != 0)
		{
			$adminUI_res .= "<h2>$DATE SHOW_AGG_FUTURE_DATES</h2><br>\n";
			$adminUI_res .= $result1_fail;
		}
		$result.=$result1;
		$admin_end = getTime();
#		 $report.= $result1;
#	 $report.= "<h2>ENDTIME:";
#    $report.= getTime()."</h2>";
#     $report.= getHtmlTail(); 
#     my $file = writeHtml("SHOW_AGG_FUTURE_DATES",$report);
#	 print "PARTIAL FILE: $file\n";
   $ShowAggFutureDates                ="false";
   }
   if($prebase   eq "true")
{
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ETL_">VERIFICATION OF ETL baseDirs (Sanity Directory Scripts Check)</a></td>
				};
				
	if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
	my $report =getStartTimeHeader("pretest");
 $result.= "<h2><font color=Black><a name=\"ETL_\">$DATE VERIFICATION OF ETL baseDirs (Sanity Directory Scripts Check) </a></font></h2>";
  print $DATE;
  print " VERIFICATION OF ETL baseDir's\n";
  my ($result1,$result1_fail) = prebase();
     $result.=$result1;
	 $serv_count .= $result1;
	 my $pass =()= $result1 =~ /_PASS_+/g;
	 my $fail =()= $result1 =~ /_FAIL_+/g;
	 
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	 $report .= getEndTimeHeader($pass,$fail);
	if($fail!=0)
	{
		$server_res .= "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF ETL baseDirs </b></font> </h2>";
		$server_res .= $result1_fail;
	}
$serv_end = getTime();
     $report.= getHtmlTail(); 
     #my $file = writeHtml("PRETEST",$report);
	 #print "PARTIAL FILE: $file\n"; 
  $prebase="false";
}
if($pre eq "true")
{
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ETL_">VERIFICATION OF ETL inDirs (Sanity Directory Scripts Check)</a></td>
				};
	if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
#	$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF ETL inDir's </b></font> </h2>";
#    my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
 $result.= "<h2><font color=Black><a name=\"ETL_\">$DATE VERIFICATION OF ETL inDir's (Sanity Directory Scripts Check)</a></font></h2>";
  print $DATE;
  print " VERIFICATION OF ETL inDir's\n";
  my ($result1,$result1_fail) = pre();
	$result.=$result1;
	 $serv_count .= $result1;
	 my $fail =()= $result1 =~ /_FAIL_+/g;
	 my $pass =()= $result1 =~ /_PASS_+/g;
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	if ($fail != 0)
	{
		$server_res .= "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF ETL inDir's </b></font> </h2>";
		$server_res .= $result1_fail;
	}
	$serv_end = getTime();
#		 $report.= $result1;
#	 $report.= "<h2>ENDTIME:";
 #    $report.= getTime()."</h2>";
 #    $report.= getHtmlTail(); 
 #    my $file = writeHtml("PRETEST",$report);
#	 print "PARTIAL FILE: $file\n"; 
  $pre="false";
}
if($verifyUniverses   eq "true")
{
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#verifyUniverses_">VERIFICATION OF BO UNIVERSES (Universe and Alarm Report Verification)</a></td>
				};
	if ($uni_start eq "")
	{
		$uni_start = getStartTimeHeader("verifyUniverses");
	}
#	$uni = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF BO UNIVERSES </b></font> </h2>";
#		my $report =getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> VERIFICATION OF BO UNIVERSES </u> </font> </h1>";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
#					<th> <font size = 2 >START TIME </th>
#					<td> <font size = 2 > <b>};
#		$report.= getTime();
	$result.= "<h2><font color=Black><a name=\"verifyUniverses_\">$DATE VERIFICATION OF BO UNIVERSES(Universe and Alarm Report Verification)</a></font></h2><br>\n";
	print $DATE;
	print " VERIFY UNIVERSES EXIST\n";
	my ($result1,$result1_fail) = verifyUniverses();
#		$report.=qq{<tr>
#					<th> <font size = 2 > END TIME </th>
#					<td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{<tr>
#					<th> <font size = 2 > RESULT SUMMARY </th>
#					<td><font size = 2 ><b>};
	$result.=$result1;
	$uni_count .= $result1;
	
	my $fail =()= $result1 =~ /_FAIL_+/g;
	my $pass =()= $result1 =~ /_PASS_+/g;
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	if ($fail != 0)
	{
		$uni = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF BO UNIVERSES </b></font> </h2>";
		$uni .= $result1_fail;
	}
	$uni_end = getTime();
#		$report.= $result1;
#     $report_uni.= getHtmlTail(); 
#     my $file = writeHtml("VERIFYUNIVERSES",$report);
#	 print "PARTIAL FILE: $file\n";
	$verifyUniverses="false";
}
if($verifyAlarms      eq "true")
{
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ALARM_">VERIFICATION OF ALARM REPORT(Universe and Alarm Report Verification)</a></td>
				};
	if ($uni_start eq "")
	{
		$uni_start = getStartTimeHeader("verifyUniverses");
	}
#	$uni = "<h2> <font color=Black><center><b> VERIFICATION OF ALARM REPORT </b></font> </h2>";
#    my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#         $report.= getTime(); 
	$result.= "<h2><font color=Black><a name=\"ALARM_\">$DATE VERIFICATION OF ALARM REPORT(Universe and Alarm Report Verification)</h2></font><br>\n";
	print $DATE;
	print " VERIFY ALARM REPORT EXIST\n";
	my ($result1, $result_fail)=verifyAlarmReports();
	$result.=$result1;
	$uni_count .= $result1;
	my $fail =()= $result1 =~ /_FAIL_+/g; 
	 my $pass =()= $result1 =~ /_PASS_+/g;
	 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	if ($fail != 0)
	{
		$uni .= "<h2> <font color=Black><center><b> VERIFICATION OF ALARM REPORT </b></font> </h2>";
		$uni .= $result_fail;
	}
	$uni_end = getTime();
#	$report.= $result1;
#	 $report.= "<h2>ENDTIME:";
#    $report.= getTime()."</h2>";
#     $report.= getHtmlTail(); 
#     my $file = writeHtml("VERIFYALARMREPORT",$report);
#	 print "PARTIAL FILE: $file\n";
	$verifyAlarms="false";
}
if($setexectime eq "true")
   {
   system("webserver restart");
   system("repdb restart");
		$contents .=	qq{<tr>
				<td></td>
				<td><a href="#EXECUTION_">VERIFICATION OF SET EXECUTION TIME (Sanity Directory Scripts Check)</a></td>
				};
	if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
#	$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF SET EXECUTION TIME </b></font> </h2>";
#		my $report = getHtmlHeader();
#		$report.= "<h1> <font color=MidnightBlue><center> <u> VERIFICATION OF SET EXECUTION TIME </u> </font> </h1>";
	 $result.= "<h2><a name=\"EXECUTION_\">VERIFICATION OF SET EXECUTION TIME(Sanity Directory Scripts Check)</h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" ><tr><th> <font size = 2 >START TIME </th><td> <font size = 2 > <b>};
#		$report.= getTime();
	my ($result1,$result1_fail) = checkSetExecutionTime();
	$serv_count .= $result1;
#		$report.=qq{<tr><th> <font size = 2 > END TIME </th><td><font size = 2 ><b>};
#		$report.= getTime();
#		$report.=qq{</table> <br>};
	my $fail =()= $result1 =~ /_FAIL_+/g;
	my $pass =()= $result1 =~ /_PASS_+/g;
	$contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	if ($fail != 0)
	{
		$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF SET EXECUTION TIME </b></font> </h2>";
		$server_res .= $result1_fail;
	}
	$result.=$result1;
	$serv_end = getTime();
#		$report.= $result1;
#		$report.= getHtmlTail();
#		my $file = writeHtml("SETEXECUTIONTIME",$report);
#		print "PARTIAL FILE: $file\n";
	$setexectime="false";
   }

if($preLoad            eq "true")
{
#    my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
#$result.= "<h2>$DATE PRE_LOAD RUNS SETS TO LOAD DATA</h2>";
print $DATE;
print " PRE_LOAD RUNS SETS TO LOAD DATA\n";
#my $result1.=preLoad();
preLoad();
#     $result.=$result1;
#		 print $result1;
	 print "\nENDTIME:";
     my $etime = getTime();
	 print "$etime\n\n";
 #    $report.= getHtmlTail(); 
#     my $file = writeHtml("PRE_LOAD",$report);
#	 print "PARTIAL FILE: $file\n"; 
$preLoad="false";
}
if($wait10 eq "true")
{
my $sleep       =0;
$sleep       =$inputwait*60;
print "SLEEP $sleep\n";
sleep($sleep);
}
if($WaitLoaders eq "true")
{
waitUntilLoadersDone();
}
system("dwhdb restart");
system("webserver restart");
if($verifyTopologyTables  eq "true")
{
async { DoVerifyTopoLoad() };
}
if($epfgdataGeneration   eq "true")
{
async { DoVerifyLoadings() };
}
if($Counter_keys eq "true")
{
async { DoCounters() };
}
$_->join() for threads->list;

if($verifyLogs eq "true")
{
	$contents .=	qq{<tr>
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
}

if($adminui_dri eq "true")
    {
	system("dwhdb restart");
   system("repdb restart");
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#DATAROW_">ADMINUI DATA ROW TEST CASE (ADMINUI TEST CASES)</a></td>
				};
	
        my $report =getHtmlHeader();
		  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI TEST CASES </u> </font> </h1>";
		  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI DATA ROW TEST CASE </u> </font> </h1>";
		  $result.="<h2> $DATE ADMINUI TEST CASES </h2>";
		$result.="<h2><font color=Black><a name=\"DATAROW_\">$DATE ADMINUI DATA ROW TEST CASE </a></font></h2>";
		  $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >};
          	  $report.= "<tr>";
		  $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
          my $stime = getTime();
		  $report.= "<td><b>$stime\t</td>";
	 my $result1=adminui_dri();
	#print " 1111111111 $result1 \n";	
	 my $fail =()= $result1 =~ /FAIL+/g; 
	 my $pass =()= $result1 =~ /PASS+/g; 
	 $contents .=	qq{<td><a href=\"#t1\">PASS ($pass) / <a href=\"#t2\">FAIL ($fail)</td>
						</tr>
						};
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
         my $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail)</td>";
	 $report.= "</table>";
	 $report.= "<br>";
	 $result.=$result1;
	 if($pass == 0) {
		$report.= $result1;
	 }
	 
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#SHOW_">SHOW REF TABLE TEST CASE (ADMINUI TEST CASES)</a></td>
				};
	$report.="<h1> <font color=MidnightBlue><center> <u> SHOW REF TABLE TEST CASE </u> </font> </h1>";
	$result.="<h2><font color=Black><a name=\"SHOW_\">$DATE SHOW REF TABLE TEST CASE </h2>";
	 $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >};
        $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
         $stime = getTime();
	$report.= "<td><b>$stime\t</td>";
	 my $result2=ShowRefTables();
	
	 my $fail1 =()= $result2 =~ /FAIL+/g; 
	 my $pass1 =()= $result2 =~ /PASS+/g; 
	  $contents .=	qq{<td><a href=\"#t1\">PASS ($pass1) / <a href=\"#t2\">FAIL ($fail1)</td>
						</tr>
						};
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
          $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass1) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail1)</td>";
	 $report.= "</table>";
	 $report.= "<br>";

	 $result.=$result2;
	 
	 #$report.= $result2;

     $report.= getHtmlTail();
     my $file = writeHtml("ADMINUI_DATAROW_SHOWREF",$report);
	 print "ADMINUI_DATAROW_TESTCASE: PASS- $pass FAIL- $fail\n";
	 print "ADMINUI_DATAROW_SHOWREF: PASS- $pass1 FAIL- $fail1\n";
	 print "PARTIAL FILE: $file\n";
     $adminui_dri               ="false";
   }
if($busyHourCount eq "true")
{
system("repdb restart");
	   $contents .=	qq{<tr>
					<td></td>
					<td><a href="#BUSY_HOUR_COUNT_">BUSY_HOUR_COUNT</a></td>
					</tr>
					};
    	   my $report = getStartTimeHeader("busyhourcountcheck");

	   print $DATE;
	   print " BUSY_HOUR_COUNT \n";
	   my ($result1,$result1_fail)=BusyHourCountCheck();
	  #print " \n\n $result1_fail \n\n";
	   $result.=$result1;

	   my $result_count.=$result1;
	   my $fail =()= $result_count =~ /FAIL+/g;
	   my $pass =()= $result_count =~ /PASS+/g;
	   $report .= getEndTimeHeader($pass,$fail);
	   $report.= $result1_fail;
          $report.= getHtmlTail(); 
	   #print " \n\n $report \n\n";
          my $file = writeHtml("BUSY_HOUR_COUNT",$report);
		  print "BUSY_HOUR_COUNT: PASS- $pass FAIL- $fail\n";
	   print "PARTIAL FILE: $file\n"; 
	   $busyHourCount="false";

}

if($servercleanup eq "true")
	{
#		my $report =getHtmlHeader();
		print "\nCLEANUP ENIQ SERVER...\n";
#		$result.= "<h2>$DATE CLEANUP ENIQ SERVER</h2><br>\n";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#					<tr>
		print "\nSTART TIME : ";
#					<td> <font size = 2 > <b>};
		my $stime = getTime();
		print "$stime\n";
#		print "$DATE CLEANUP ENIQ SERVER\n";
		my $result1.=serverCleanup();
#		$result.=$result1;
		print "$result1";
#		$report.= "<tr>";
#		$report.=qq{<tr>
		print "\nEND TIME : ";					#<th> <font size = 2 > END TIME </th>
#				<td><font size = 2 ><b>};
		my $etime = getTime();
		print "$etime\n\n";
#		$report.= "<tr>";
#		$report.= "</table>";
#		$report.= "<br>";
#		$report.= $result1;
#		$report.= getHtmlTail(); 
#		my $file = writeHtml("CLEANUPENIQSERVER",$report);
#		print "\nPARTIAL FILE: $file\n";
		$servercleanup="false";
	}
   if($engineProcess eq "true")
   {
       my $report =getHtmlHeader();
	   $report.= "<h1> <font color=MidnightBlue><center> <u> ENGINE_PROCESS $epTp $epProcess </u> </font> </h1>";
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
     my $file = writeHtml("ENGINEPROCESS",$report); 
	 print "PARTIAL FILE: $file\n";
     $engineProcess                ="false";
   }
   
# Checks which version of java the files have been compiled in
sub majorVersionCheck {
	my $Parserpath = shift;
	$Parserpath = $Parserpath."/eniq_parsers/";
	my $JAVAP = '/eniq/sw/runtime/jdk/bin/javap';
	my $target_file = '/eniq/home/dcuser/list_of_classes';
	system("find /eniq/sw/platform/ -name \"*\.class\" > $target_file");
	system("find /eniq/sw/runtime/ -name \"*.class\" | grep -v \"apache-tomcat-\"  >> $target_file");
	my @parsers = getBLmodules($Parserpath);
	@parsers = remSpace(\@parsers);
	my ($value,$majorversion,@failures) = 0;
	my ($data,$path,$class) = 0;
	my $pack = 0;
	open(INPUT,"< $target_file");
	my @input=<INPUT>;
	chomp(@input);
	close(INPUT);
	my $result="";
 	 $result.=qq{
 	<br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
  	 <tr>
		<th>CLASS FILES</th>
		<th>JDK USED</th>
		<th>RESULT</th>
   	</tr>
		};
	my $result_fail = $result;
	foreach $value(@input){
		if ($value =~ /((.+)\/(.+))\.class/) {
			$majorversion =`$JAVAP -verbose -classpath '$2' '$3' 2>/dev/null | grep "major version:"`;
			$data = $1;
			$path =  $2;
			$class = $3;
			my $isParse = 0;
			($pack) = ($path =~ /\/eniq\/sw\/platform\/(.+)\/classes\/.*/);
			$pack =~ s/-/_/g;
			if ( $^O eq "linux" ){
				if ( $majorversion !~ /52/ ){
					print "\n$class - $majorversion";
					$result_fail .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion<\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";
					$result .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion<\/td> <td align=center><font color=660000><b>_FAIL_<\/b><\/font><\/td><\/tr> ";
				}
				else{
					#$result .= "<tr> <td align=center><font color=660000><b>$data<\/b><\/font> <\/td> <td align=center><font color=660000><b>PASS<\/b><\/font><\/td><\/tr>"; 		}
					$result.="<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center><b>JDK 8<\/b> <\/td> <td align=center><font color=006600><b>_PASS_<\/b><\/font><\/td><\/tr>";
				}
			}
			else{
				if ( $majorversion !~ /52/ ){
					if ( $majorversion !~ /51/ ){
						print "\n$class - $majorversion";
						$result_fail .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion BIG FAIL<\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";
						$result .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion<\/td> <td align=center><font color=660000><b>_FAIL_<\/b><\/font><\/td><\/tr> ";
					}
					else{
						foreach my $par(@parsers){
							if ($pack eq $par){
								$isParse = 1;
								last;
							}
						}
						if($isParse){
							$result.="<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center><b>JDK 7 (Parsers)<\/b> <\/td> <td align=center><font color=006600><b>_PASS_<\/b><\/font><\/td><\/tr>";
						}
						else{
							print "\n$class - $majorversion";
							$result_fail .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion<\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";
							$result .= "<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center>$majorversion<\/td> <td align=center><font color=660000><b>_FAIL_<\/b><\/font><\/td><\/tr> ";
						}
					}
				}
				else{
					#$result .= "<tr> <td align=center><font color=660000><b>$data<\/b><\/font> <\/td> <td align=center><font color=660000><b>PASS<\/b><\/font><\/td><\/tr>"; 		}
					$result.="<tr> <td align=center><b>$data<\/b><\/font> <\/td> <td align=center><b>JDK 8<\/b> <\/td> <td align=center><font color=006600><b>_PASS_<\/b><\/font><\/td><\/tr>";
				}
			}
		}
	}
	$result_fail .= "</table>\n";
	$result .= "</table>\n";
	#print "  the result fail is $result_fail \n\n result pass is $result";
 	return ($result , $result_fail);
}

   	sub ShowRefTables {
        my $result="";
        my $adcount="";
        my @dbcount = undef;
        my $dbcount="";

       my $emptyString="";
        my $htmlfile = "/eniq/home/dcuser/swget.html";

         system("$WGET --quiet  --no-check-certificate -O $htmlfile  --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"rtype=DIM_E_LTE_NR&row_limit=500&f_column=NE_TYPE&f_type=%3D&f_value=RadioNode&send=Show\" \"https://localhost:8443/adminui/servlet/ShowRefType\"");

        # SEND USR AND PASSWORD
        system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

        # post Information
        system("$WGET --quiet --no-check-certificate -O $htmlfile --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"rtype=DIM_E_LTE_NR&row_limit=500&f_column=NE_TYPE&f_type=%3D&f_value=RadioNode&send=Show\"  \"https://localhost:8443/adminui/servlet/ShowRefType\"");


        open( FILE, '/eniq/home/dcuser/swget.html' ) or die "Can't open wget: $!";
        
        while (my $line = <FILE>) {
              
                $adcount++ if $line =~ /RadioNode&nbsp/;
        }
        
        $adcount = $adcount;
        print "\n\n adcount = $adcount \n\n";

        #Getting no of tables loaded in database
        my $sql = "select count(*) from DIM_E_LTE_NR WHERE NE_TYPE = 'RadioNode'";
        @dbcount = executeSQL("dwhdb",2640,"dc",$sql,"ROW");
      
        $dbcount = $dbcount[0];
        print "\n\n dbcount = $dbcount \n\n";
		$result = qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
						<tr>
						<th>TABLE</th>
						<th>NE_TYPE</th>
						<th>No of data in DB</th>
						<th>No of data in ADMINUI</th>
						<th>RESULT</th>
						</tr>
					};	
		
        #Comparing both tables
        if ($adcount eq $dbcount){
			$result .= "<tr><td><center>DIM_E_LTE_NR</td><td><center>RadioNode</td><td><center>$dbcount</td><td><center>$adcount</td><td><center><font color=006600><b>PASS</td></tr>";

        }
        else{
            $result .= "<tr><td><center>DIM_E_LTE_NR</td><td><center>RadioNode</td><td><center>$dbcount</td><td><center>$adcount</td><td><center><font color=006600><b>FAIL</td></tr>";

        }
		$result .= "</table>";
		return $result;
}

   if($adminuiMonType eq "true")
    {
       my $report =getHtmlHeader();
		  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI MONITORING TYPE </u> </font> </h1>";
		  $result.="<h2>ADMINUI MONITORING TYPE</h2>";
		  $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >};
          $report.= "<tr>";
		  $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
          my $stime = getTime();
		  $report.= "<td><b>$stime\t</td>";
	 my $result1=adminuiMonType();
	 my $fail =()= $result1 =~ /FAIL+/g; 
	 my $pass =()= $result1 =~ /PASS+/g; 
   	 
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
     my $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail)</td>";
	 $report.= "</table>";
	 $report.= "<br>";
	 $report.= $result1;
	 $result.=$result1;
     $report.= getHtmlTail();
     my $file = writeHtml("ADMINUI_MONITORING_TYPE",$report);
	 print "PARTIAL FILE: $file\n";
     $adminuiMonType               ="false";
   }
   
   if($adminui_drs eq "true")
    {
       my $report =getHtmlHeader();
		  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI DATA ROW SUMMARY </u> </font> </h1>";
		  $result.="<h2>ADMINUI DATA ROW SUMMARY</h2>";
		  $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >};
          $report.= "<tr>";
		  $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
          my $stime = getTime();
		  $report.= "<td><b>$stime\t</td>";
	 my $result1=adminui_drs();
	 my $fail =()= $result1 =~ /FAIL+/g; 
	 my $pass =()= $result1 =~ /PASS+/g; 
   	 
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
     my $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail)</td>";
	 $report.= "</table>";
	 $report.= "<br>";
	 $result.=$result1;
	 $report.= $result1;
     $report.= getHtmlTail();
     my $file = writeHtml("ADMINUI_DATAROWSUMMARY",$report);
	 print "PARTIAL FILE: $file\n";
     $adminui_drs               ="false";
   }
   
   
   
   if($adminuiTypeConf eq "true")
   {
     my $report =getHtmlHeader();
	  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI TYPE CONFIGURATION </u> </font> </h1>";
	  $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >};
	  $result.= "<h2>ADMINUI TYPE CONFIGURATION</h2>";
	  $report.= "<tr>";
	  $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
	  my $stime = getTime();
	  $report.= "<td><b>$stime\t</td>";
	 my $result1=adminuiTypeConf();
	 my $fail =()= $result1 =~ /FAIL+/g; 
	 my $pass =()= $result1 =~ /PASS+/g; 
   	 
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
     my $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail)</td>";
	 $report.= "</table>";
	 $report.= "<br>";
	 $report.= $result1;
	 $result.= $result1;
     $report.= getHtmlTail();
     my $file = writeHtml("ADMINUI_TYPECONFIGURATION",$report);
	 print "PARTIAL FILE: $file\n"; 
     $adminuiTypeConf                ="false";
   }
    if($adminuiDwhConf eq "true")
   {
		my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> ADMINUI - DWH CONFIG VERIFICATION </u> </font> </h1>";
		$result.= "<h2>ADMINUI DWH CONFIGURATION</h2>";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="1" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
		$report.= getTime();
		my $result1=adminuiDwhConf();
		my $fail =()= $result1 =~ /FAIL+/g; 
		my $pass =()= $result1 =~ /PASS+/g; 
		 
		$report.=qq{<tr>
					<th> <font size = 2 > END TIME </th>
					<td> <font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{<tr>
					<th> <font size = 2 > RESULT SUMMARY </th>
					<td><font size = 2 ><b>};
		$report.= "<a href=\"#t1\"><font color = green>PASS ($pass) <font color = black> / <a href=\"#t2\"><font color = red> FAIL ($fail)</td>";
		$report.= "</table>";
		$report.= "<br>";
		$report.= $result1;
		$result.= $result1;
		$report.= getHtmlTail();
		my $file = writeHtml("ADMINUI_DWHCONFIGURATION",$report);
		print "PARTIAL FILE: $file\n"; 
		$adminuiDwhConf                ="false";
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
    if($dbspace eq "true") 
   {
#		my $report = getStartTimeHeader("dbspace");
#			$result.= "<h2>$DATE Monitoring of database size and Filesystem </h2><br>\n";
		print "\n $DATE Monitoring of database size and Filesystem \n\n";
#		$report.= "<h1> <font color=MidnightBlue><center> <u> DATABASE SIZE AND FILESYSTEM VERIFICATION </u> </font> </h1>";
#		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
#				<tr>
#				<th> <font size = 2 >START TIME </th>
#				<td> <font size = 2 > <b>};
#		$report.= getTime();
    #my $result.= "<h2>$DATE Monitoring of database size and Filesystem </h2><br>\n";
     
     my ($result1, $result_fail) = Sizecheck();
	 my $fail =()= $result1 =~ /FAIL+/g; 
	 my $pass =()= $result1 =~ /PASS+/g; 
#	$report .= qq{<tr>
#				<th> <font size = 2 > END TIME </th>
#				<td> <font size = 2 ><b>};
#	$report.= getTime();
#	$report.=qq{<tr>
#				<th> <font size = 2 > RESULT SUMMARY </th>
#				};
#	$result.=$result1;
#	$report.= $result1;
#	$report.= getHtmlTail(); 
#	my $file = writeHtml("DB_filesystem_Size",$report);
#	print "PARTIAL FILE: $file\n"; 
	$dbspace="false";
	}
	

	
############################################################
#EU UPGRADE PACKAGE VALIDATION
#checks for the validation of package between
#upgrade.config file and eniq_base_sw path
 
 
 if($Euupgvalidation eq "true") 
{
	print "\n---------------ENIQ UPGRADE TECHPACK--------------\n";
	my @intf_eniqbase;
	my @ConfigFile = `grep \"TECHPACK::\" /var/tmp/ENIQ_EU_upgrade/upgrade.configuration | awk -F\"::\" '{print \$3}'`;
	@ConfigFile=remSpace(\@ConfigFile);
	my @basePath = `ls /var/tmp/ENIQ_EU_upgrade/eniq_base_sw | grep \".tpi\" | grep -v INTF`;
	@basePath=remSpace(\@basePath);
	validateModules(\@basePath,\@ConfigFile);
	
	print "\n\n\n---------------ENIQ UPGRADE INTERFACE--------------\n";
	@ConfigFile = `grep \"INTERFACE::\" /var/tmp/ENIQ_EU_upgrade/upgrade.configuration | awk -F\"::\" '{print \$3}'`;
	@ConfigFile=remSpace(\@ConfigFile);
	@basePath = `ls /var/tmp/ENIQ_EU_upgrade/eniq_base_sw/ | grep INTF`;
	@basePath=remSpace(\@basePath);
	validateModules(\@basePath,\@ConfigFile);
	
	print "\n\n\n---------------ENIQ UPGRADE PLATFORM and BUSINESS OBJECTS--------------\n";
	@ConfigFile = `grep .zip /var/tmp/ENIQ_EU_upgrade/upgrade.configuration | egrep -v ENIQ | awk -F\".\" '{print \$1}' | sort | uniq`;
	@ConfigFile=remSpace(\@ConfigFile);
	@basePath = `ls /var/tmp/ENIQ_EU_upgrade/eniq_base_sw | grep \".zip\" | egrep -v \"(INTF|ERIC)\" | sed 's/.zip//'`;
	@basePath=remSpace(\@basePath);
	validateModules(\@basePath,\@ConfigFile);	
}


sub validateModules {
	my @eniqbase = @{$_[0]};
	my @upgradeFile = @{$_[1]};

	my $tp_upgsize= $#upgradeFile;   
	my $tp_eniqbasesize=$#eniqbase; 

	if ($tp_upgsize == $tp_eniqbasesize) {
		print "\n\nNumber of Modules in eniq_base_sw path and upgrade.configuration file are equal.\n";
	}
	else {
		print "\nERROR : Modules count in upgrade.configuration($tp_upgsize) file and the path \/var\/tmp\/ENIQ_EU_upgrade\/eniq_base_sw($tp_eniqbasesize) path are not equal\n\n";
	}
	my %modres=compareBase(\@eniqbase,\@upgradeFile);
	foreach my $module (sort keys %modres) {
		$_=$module;
		next if(/^$/);
		if($modres{$module}== 3)
		{
			print "$module: Found in ENIQ BASE path, Not updated in Config file\n";			 
		}
		if($modres{$module}== 7)
		{
			print "$module: Found in Config File, Not found in ENIQ BASE\n";			 
		}
		if($modres{$module}== 10)
		{
			#print "$module: Found in ENIQ BASE and Config file\n";
		}
	}
}






   if($DwhStatus eq "true") 
   {
		my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> DWH STATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2>DWH STATUS VERIFICATION</h2><br>\n";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
		$report.= getTime();
		my $result1.=DwhStatus();
		$report.=qq{<tr>
					<th> <font size = 2 > END TIME </th>
					<td><font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{<tr>
					<th> <font size = 2 > RESULT SUMMARY </th>
					<td><font size = 2 ><b>};
		$result.=$result1;
		$report.= $result1;
		$report.= getHtmlTail(); 
		my $file = writeHtml("DWHSTATUS",$report);
		print "PARTIAL FILE: $file\n"; 
		$DwhStatus="false";
   }
   
   
   
   if($Assuremonitoring  eq "true")
   {
		executeThis("chmod 750 /eniq/home/dcuser/assuremonitoring_acceptance.pl");
		executeThis("chmod 750 /eniq/home/dcuser/_expect.sh");
		my $filename1 = '/eniq/home/dcuser/assuremonitoring_acceptance.pl';
		my $filename2 = '/eniq/home/dcuser/_expect.sh';
		if ((-e $filename1) && (-e $filename2))
		{
			$result.= "<h2>$DATE ASSURE MONITORING ACCEPTANCE VERIFICATION</h2><br>\n";
			system("perl $filename1");
		}
		else
		{
		print "ERROR: Assuremonitoring_acceptance.pl and _expect.sh files are not found in the /eniq/home/dcuser/";
		}
		$Assuremonitoring="false";
   }
   
	if($RepStatus eq "true") 
	{
		my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> REPDBSTATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2>$DATE REPDB STATUS VERIFICATION</h2><br>\n";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
		$report.= getTime();
		my $result1.=RepStatus();
		$report.=qq{<tr>
					<th> <font size = 2 > END TIME </th>
					<td><font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{<tr>
					<th> <font size = 2 > RESULT SUMMARY </th>
					<td><font size = 2 ><b>};
		$result.=$result1;
		$report.= $result1;
		$report.= getHtmlTail(); 
		my $file = writeHtml("REPSTATUS",$report);
		print "PARTIAL FILE: $file\n"; 
		$RepStatus="false";
	}
	if($LicmgrStatus eq "true") 
	{
        my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> LICMNGR STATUS VERIFICATION </u> </font> </h1>";
		$result.= "<h2>$DATE LICMNGRSTATUS</h2><br>\n";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
		$report.= getTime();
        my $result1.=LicmgrStatus();
		$report.=qq{<tr>
					<th> <font size = 2 > END TIME </th>
					<td><font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{<tr>
					<th> <font size = 2 > RESULT SUMMARY </th>
					<td><font size = 2 ><b>};
		$result.=$result1;
		$report.= $result1;
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
   
  
 
   if($adminuiMonRule eq "true") 
   {     
		 my $report =getHtmlHeader();
		  $report.="<h1> <font color=MidnightBlue><center> <u> ADMINUI MONITORING RULES</u> </font> </h1>";
		  $result.="<h2>ADMINUI MONITORING RULES</h2>";
		  $report.=qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="80%" >};
          $report.= "<tr>";
		  $report.= "<td><font size = 2 ><b>START TIME:\t</td>";
          my $stime = getTime();
		  $report.= "<td><b>$stime\t</td>";

		my $result1.=adminuiMonRule();
		$result.=$result1;
		 my $fail =()= $result1 =~ /FAIL+/g; 
		 my $pass =()= $result1 =~ /PASS+/g; 
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>END TIME:\t</td>";
     my $etime = getTime();
	 $report.= "<td><b>$etime\t</td>";
	 $report.= "<tr>";
	 $report.= "<td><font size = 2 ><b>RESULT:\t</td>";
	 $report.= "<td><a href=\"#t1\"><font size = 2 color=006600><b>PASS ($pass) / <a href=\"#t2\"><font size = 2 color=006600><b>FAIL ($fail)</td>";
	 $report.= "</table>";
	 $report.= "<br>";
	 $report.= $result1;
     $report.= getHtmlTail();
     my $file = writeHtml("ADMINUI_MONITORING_RULES",$report);
	 print "PARTIAL FILE: $file\n";
     $adminuiMonRule               ="false";
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
     my $file = writeHtml("CREATE_SNAPSHOTS",$report);
	 print "PARTIAL FILE: $file\n";
   $CreateRackSnapshots               ="false";
   }
     
   if($eniqVersion eq "true") 
   {
   		my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> ENIQVERSION VERIFICATION </u> </font> </h1>";
		$result.= "<h2>$DATE ENIQVERSION VERIFICATION</h2><br>\n";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
					<tr>
					<th> <font size = 2 >START TIME </th>
					<td> <font size = 2 > <b>};
		$report.= getTime();
		my $result1.=eniqVersion();
		$report.=qq{<tr>
					<th> <font size = 2 > END TIME </th>
					<td><font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{<tr>
					<th> <font size = 2 > RESULT SUMMARY </th>
					<td><font size = 2 ><b>};
		$result.=$result1;
		$report.= $result1;
		$report.= getHtmlTail(); 
		my $file = writeHtml("ENIQVERSION",$report);
		print "PARTIAL FILE: $file\n"; 
		$eniqVersion="false";
   }
   if($DiskSpace eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE DISKSPACE ADMINUI</h2><br>\n";
     print $DATE;
     print " DISKSPACE\n";
     my $result1.=DiskSpace();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("DISKSPACE_ADMINUI",$report);
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
  my $result1.= help();
         $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("HELP",$report);
	 print "PARTIAL FILE: $file\n"; 
  $help="false";
}

if($sim_feature_test       eq "true")
{   
    my $undef=undef;

	my $delim = `echo \$PS1`;
	chomp($delim);
	$delim = substr($delim,-2);
	my $exp = new Expect;
	$exp->spawn("/usr/bin/bash");
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("su - root\r");}]);
	$exp->expect($undef, [":", sub {$exp = shift; $exp->send("shroot\r");}]);
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("bash\r");}]);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("mkdir -p -m 7777 /var/opt/fds/statistics /var/opt/vxml-ivr/env_prod/reports /opt/occ/var/performance/pm3gppXml /opt/telorb/axe/tsp/NM/PMF/reporterLogs/CcnCounters /opt/telorb/axe/tsp/NM/PMF/reporterLogs/DiameterMeasures /opt/telorb/axe/tsp/NM/PMF/reporterLogs/PlatformMeasures /export/home/minsat/DE\r");}]);
	$exp->expect(2);
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("su - dcuser\r");}]);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("bash\r");}]);
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("cp sim_feature_test.zip /eniq/sw/platform/sim*\r");}]);
	$exp->expect(5);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("cd /eniq/sw/platform/sim* \r");}]);
	$exp->expect(2);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("rm -rf sim_feature_test\r");}]);
	$exp->expect(2);

	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("unzip sim_feature_test.zip\r");}]);
	$exp->expect(10);

	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("chmod -R 7777 sim_feature_test\r");}]);
	$exp->expect(2);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("cd sim_feature_test/scripts \r");}]);
	$exp->expect(2);
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("./startFeatureTest.sh \r");}]);
	$exp->expect(5);
	
	$sim_feature_test="false"
}




if($preout  eq "true")
{
	$contents .=	qq{<tr>
				<td></td>
				<td><a href="#ETL_">VERIFICATION OF ETL outDirs (Sanity Directory Scripts Check)</a></td>
				</tr>
				};
	if ($serv_start eq "")
	{
		$serv_start = getStartTimeHeader("server");
	}
#	$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF ETL outDirs </b></font> </h2>";
#    my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();
 $result.= "<h2><font color=Black><a name=\"ETL_\">$DATE VERIFICATION OF ETL outDir's (Sanity Directory Scripts Check)</a></font></h2>";
  print $DATE;
  print " VERIFICATION OF ETL outDir's\n";
  my ($result1,$result1_fail) = preout();
     $result.=$result1;
	 $serv_count .= $result1;
	 my $fail =()= $result1 =~ /FAIL+/g;
	if ($fail != 0)
	{
		$server_res = "<h2> <font color=MidnightBlue><center><b> VERIFICATION OF ETL outDir's </b></font> </h2>";
		$server_res .= $result1_fail;
	}
	$serv_end = getTime();
#		 $report.= $result1;
#	 $report.= "<h2>ENDTIME:";
 #    $report.= getTime()."</h2>";
 #    $report.= getHtmlTail(); 
 #    my $file = writeHtml("PRETEST",$report);
#	 print "PARTIAL FILE: $file\n"; 
  $preout="false";
}


if($verifyExes        eq "true")
{
	my $report =getHtmlHeader();
	$report.="<h1> <font color=MidnightBlue><center> <u> VERIFY EXECUTABLES</u> </font> </h1>";
	$result.= "<h2>$DATE VERIFY EXECUTABLES</h2>";
	$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
				<tr>
				<th> <font size = 2 >START TIME </th>
				<td> <font size = 2 > <b>};
	$report.= getTime();
	my $result1=verifyExecutables();
	my $fail =()= $result1 =~ /FAIL+/g; 
	my $pass =()= $result1 =~ /PASS+/g; 
	$report.=qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td> <font size = 2 ><b>};
	$report.= getTime();
	$report.=qq{<tr>
				<th> <font size = 2 > RESULT SUMMARY </th>
				<td><font size = 2 ><b>};
	$report.= "<a href=\"#t1\"><font color = green>PASS ($pass)<font color = black>  /  <a href=\"#t2\"><font color = red>FAIL ($fail)</td>";
	$report.= "</table>";
	$report.= "<br>";
	$report.= $result1;
	$result.= $result1;
    $report.= getHtmlTail();
    my $file = writeHtml("VERIFY_EXECUTABLES",$report);
	print "PARTIAL FILE: $file\n";
	$verifyExes="false"; 
}
if($engine eq "true")
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
if($repdb  eq "true")
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


if($sample eq "true")
{
					$contents .=	qq{<tr>
					<td></td>
					<td><a href="#SAMPLE_">SAMPLE</a></td>
					</tr>
					};
    	   my $report = getStartTimeHeader("sample");

	   print $DATE;
	   print " SAMPLE \n";
	   my ($result1,$result1_fail)=sample();
	  #print " \n\n $result1_fail \n\n";
	   $result.=$result1;
	   my $result_count.=$result1;
	   my $fail =()= $result_count =~ /FAIL+/g;
	   my $pass =()= $result_count =~ /PASS+/g;
	   $report .= getEndTimeHeader($pass,$fail);
	   $report.= $result1_fail;
          $report.= getHtmlTail(); 
	   #print " \n\n $report \n\n";
          my $file = writeHtml("SAMPLE",$report);
	   print "PARTIAL FILE: $file\n"; 
	   $sample="false";

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


if($soem_twamp      eq "true")
{
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime()."</h2>";
print " SOEM & TWAMP\n";
my $result1.=Soem_Scalibility();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("SOEM&TWAMP",$report);
	 print "PARTIAL FILE: $file\n";
$soem_twamp="false";
}
if($col_no      eq "true")
{
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime()."</h2>";
		  $result.="<h2>Check Column Number mismatch of dwhdb with repdb</h2>";
my $result1.=CompareColNos();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("ColNoMismatch",$report);
	 print "PARTIAL FILE: $file\n";
$soem_twamp="false";
}

   if($dataid_dataname eq "true") 
   {
        my $report =getHtmlHeader();
          $report.= "<h2>STARTTIME:";
          $report.= getTime();
     $result.= "<h2>$DATE Dataid and dataname Mismatch</h2><br>\n";
     print $DATE;
     print "Dataid_dataname\n";
     my $result1.=dataid_dataname();
	     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("Dataid_dataname",$report);
	 print "PARTIAL FILE: $file\n";
   $dataid_dataname               ="false";
   }
    if($NODE eq "true") 
   {
        my $report =getHtmlHeader();
		$report.= "<h1> <font color=MidnightBlue><center> <u> DATA VALIDATION </u> </font> </h1>";
		$report.= qq{<body bgcolor=GhostWhite> </body> <center> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" >
				<tr>
				<th> <font size = 2 >START TIME </th>
				<td> <font size = 2 > <b>};
		$report.= getTime();
		my $result1.=dataloading();
		$report.=qq{<tr>
				<th> <font size = 2 > END TIME </th>
				<td> <font size = 2 ><b>};
		$report.= getTime();
		$report.=qq{</table> <br>};
				#<th> <font size = 2 > RESULT SUMMARY </th></table>
				#};
		$result.=$result1;
		$report.= $result1;
		$report.= getHtmlTail(); 
		my $file = writeHtml("DATA_VALIDATION",$report);
	 print "PARTIAL FILE: $file\n";
	$NODE               ="false";
   }


if($AGG eq "true") 
   {
        my $report =getHtmlHeader();
        my $dat_time=getTime();
		chomp($dat_time);
     $report.= "<H1>Aggregation testcase</H1><br>\n";
     print $DATE;
    
	  
    my $host=getHostName();
    chomp($host);

   $report.="<H2 ALIGN=LEFT>HOST :: ".$host."</H2>\n";
   
   $report.="<H2 ALIGN=LEFT>STARTTIME :: ".$dat_time."</H2>\n";
   
      my $result1.=data_aggregation();
	  $result.=$result1;
	
	  $report.= $result1;
	
	 $report.= "<H2 ALIGN=LEFT>ENDTIME::";
     $report.= getTime()."</H2>";
	 
     $report.= getHtmlTail(); 
     my $file = writeHtml("DataAggregation",$report);
	 print "PARTIAL FILE: $file\n";
   $AGG              ="false";
   }

if($verifyAggregations   eq "true")
{
	my $report = getStartTimeHeader("verifyAggregations");
#    my $report =getHtmlHeader();
#          $report.= "<h2>STARTTIME:";
#          $report.= getTime();   
$result.= "<h2>VERIFY DATA AGGREGATIONS</h2><br>\n";
print $DATE;
print " VERIFY DATA AGGREGATIONS\n";
my ($result1,$result1_fail) = verifyAggregations();
     $result.=$result1;
		 $report.= $result1;
	 $report.= "<h2>ENDTIME:";
     $report.= getTime()."</h2>";
     $report.= getHtmlTail(); 
     my $file = writeHtml("VERIFYDATAAGGREGATIONS",$report);
	 print "PARTIAL FILE: $file\n";
$verifyAggregations="false";
}



comboTC($adminUI_res,$adminUI_count,$adminUI_start,$admin_end,"adminUI");
comboTC($uni,$uni_count,$uni_start,$uni_end,"verifyUniverses");
comboTC($server_res,$serv_count,$serv_start,$serv_end,"server");

$contents .= "</table><br>";
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
my $result_fail="";
my @intfExceptionList = ("INTF_DC_E_ML_HC_E" , "INTF_DC_E_OPT_MHL3000" , "INTF_DC_E_OPT_OMS3200" , "INTF_DC_E_OPT1600_1200" , "INTF_DC_E_OPT800_1400", "INTF_DC_E_TNSPPT" , "INTF_DIM_E_IPTNMS_ASCII" , "INTF_DIM_E_IPTNMS_CIRCUIT" , "INTF_DIM_E_IPTNMS_PACKET" , "INTF_DIM_E_SOEM_ASCII" , "INTF_DIM_E_SOEM_MBH_ASCII" , "INTF_DIM_E_SOEM_PIC");
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
$result_fail .= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
<tr>
<th>INTERFACE</th>
<th>DIRECTORY</th>
<th>RESULT</th>
</tr>
};

foreach my $tables (@tables)
 {
   $_=$tables;
   my $tab_fail = 0;
   my $status="";
   my $failstatus="";
   next if(/parser.header/);
   next if(/affected/);
   next if($tables=~/SQL Anywhere Error /);
	    next if($tables=~/Msg \d/);
		next if($tables=~/ Msg \d/);
   next if(/^$/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
 
   print $tables;
   
   if(($tables=~/^INTF/)||($tables=~/^Alarm/)||($tables=~/^DC_Z_/))
   {
   my @intfTableArray = split(/\|/,$tables);
   my @intfName = split("-",$intfTableArray[0]);
   
    if(/AlarmInterfaces/ && 
      /inDir=\$\{PMDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
    elsif(/AlarmInterfaces/ && 
         /inDir=\${PMDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
	 $tab_fail = 1;
    } elsif ($intfName[0] ~~ @intfExceptionList && /-eniq_oss_1/ && 
         /inDir=\$\{PMDATA_SOEM_DIR\}\/eniq_oss_1\//) 
	{
	$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
	}
    elsif(/INTF_/ && 
         /-eniq_oss_1/ && 
         /inDir=\$\{PMDATA_DIR\}\/eniq_oss_1\//)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
    elsif(/INTF_/ && 
          !/-eniq_oss_1/ && 
          /inDir=\$\{PMDATA_DIR\}\/\$\{OSS\}\//)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
	elsif ($intfName[0] ~~ @intfExceptionList && /-eniq_oss_2/ && 
         /inDir=\$\{PMDATA_SOEM_DIR\}\/eniq_oss_2\//) 
	{
	$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
	}
    elsif(/INTF_/ && 
         /-eniq_oss_2/ && 
         /inDir=\$\{PMDATA_DIR\}\/eniq_oss_2\//)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
    elsif(/INTF_/ && 
          !/-eniq_oss_2/ && 
          /inDir=\$\{PMDATA_DIR\}\/\$\{OSS\}\//)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
	elsif(/DC_Z_/ && 
      /inDir=\$\{PMDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     print "    PASS\n";
    }
    elsif(/DC_Z_/ && 
         /inDir=\${PMDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
	 $tab_fail = 1;
    }
    else
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "	FAIL\n";
	 $tab_fail = 1;
    }

    $tables=~ s/\t//g;
    $tables=~ s/\s//g;
    $tables=~ s/^/<tr><td>/g;
    $tables=~ s/\|/<\/td><td>/g;
	if ($tab_fail == 1)
	{
		my $fail = $tables;
		$fail=~ s/$/<\/td>$failstatus<\/tr>/g;
		$result_fail .= "$fail\n";
	}
	$tables=~ s/$/<\/td>$status<\/tr>/g;
	$result.= "$tables\n";
  }
 }
 $result.= "</table>";
 $result_fail .= "</table>";
 return $result,$result_fail;

}

############################################################
# PRE TEST, CHECKS THE basedir: THE DIRECTORIES FOR ALL ETLS 
# This is a very simple test, just runs the query below and lists 
# the results in a table
# The table represents each entry for the inDir directory for all techpacks and 
# interfaces
# This means each techpack and interface should have an entry directory
# I believe in the past there were faults related with missing paths,
# if a path is missing the row is failed.
sub prebase{
my $result="";
my $result_fail="";
my @intfExceptionList = ("INTF_DC_E_PRBS_ERBS:9" , "INTF_DIM_E_VPP:6");
my $sql=qq{
SELECT c.collection_set_name||"|"|| 
SUBSTRING(action_contents_01,
  CHARINDEX('baseDir=', action_contents_01))
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
$result_fail .= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
<tr>
<th>INTERFACE</th>
<th>DIRECTORY</th>
<th>RESULT</th>
</tr>
};
my $status="";
print " \n I am in PPREBASE \n";
foreach my $tables (@tables)
 {
	$_=$tables;
   my $tab_fail = 0;
   my $status="";
   my $failstatus="";
   next if(/parser.header/);
   next if(/affected/);
   next if($tables=~/SQL Anywhere Error /);
	    next if($tables=~/Msg \d/);
		next if($tables=~/ Msg \d/);
   next if(/^$/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
 
   
   if(($tables=~/^INTF/)||($tables=~/^Alarm/)||($tables=~/^DC_Z_/))
   {
	if(/AlarmInterfaces/ && 
      /baseDir=\$\{ARCHIVE_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     #print "    PASS\n";
    }
    elsif(/AlarmInterfaces/ && 
         /baseDir=\${ARCHIVE_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     #print "    FAIL\n";
	 $tab_fail = 1;
    }
    elsif(/INTF_/ && 
         /-eniq_oss_1/ && 
         /baseDir=\$\{ARCHIVE_DIR\}\/eniq_oss_1\//)
    {
		if( $tables =~ /\${ARCHIVE_DIR}(.+)/)
		{
			my @IntfTableArray = split(/\|/,$tables);
			my $count = `ls -lrt /eniq/archive/$1 | wc -l `;
			if( $count == 5)
			{ 
				$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
				#print "    PASS\n";
			}
			else {
				my $count1 = 0; 
				for my $intfNames (@intfExceptionList) {
				my @intf = split(":",$intfNames);
				my @intfDbValue = split("-",$IntfTableArray[0]);
					if( $intf[0] eq $intfDbValue[0]) {
						$count1++;
						if( $intf[1] == $count) {
							$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
							#print "    PASS\n";
						} else {
							$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
							$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
							$tab_fail = 1;
						}
					}
				}
				if ( $count1 == 0 ) {
					$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
					$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
					$tab_fail = 1;
				}
			}
		}
	}
    elsif(/INTF_/ && 
          !/-eniq_oss_1/ && 
          /baseDir=\$\{ARCHIVE_DIR\}\/\$\{OSS\}\//)
    {
		if( $tables =~ /\${ARCHIVE_DIR}(.+)/)
		{
			my $count = `ls -lrt /eniq/archive/$1 | wc -l `;
			if( $count == 5)
			{
				$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
				#print "    PASS\n";
			}
			else {
				$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
				$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
				$tab_fail = 1;
			}
		}
    }
	elsif(/INTF_/ && 
         /-eniq_oss_2/ && 
         /baseDir=\$\{ARCHIVE_DIR\}\/eniq_oss_2\//)
    {
		if( $tables =~ /\${ARCHIVE_DIR}(.+)/)
		{
			my @IntfTableArray = split(/\|/,$tables);
			my $count = `ls -lrt /eniq/archive/$1 | wc -l `;
			if( $count == 5)
			{ 
				$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
				#print "    PASS\n";
			}
			else {
				my $count1 = 0; 
				for my $intfNames (@intfExceptionList) {
				my @intf = split(":",$intfNames);
				my @intfDbValue = split("-",$IntfTableArray[0]);
					if( $intf[0] eq $intfDbValue[0]) {
						$count1++;
						if( $intf[1] == $count) {
							$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
							#print "    PASS\n";
						} else {
							$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
							$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
							$tab_fail = 1;
						}
					}
				}
				if ( $count1 == 0 ) {
					$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
					$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
					$tab_fail = 1;
				}
			}
		}
	}
    elsif(/INTF_/ && 
          !/-eniq_oss_2/ && 
          /baseDir=\$\{ARCHIVE_DIR\}\/\$\{OSS\}\//)
    {
		if( $tables =~ /\${ARCHIVE_DIR}(.+)/)
		{
			my $count = `ls -lrt /eniq/archive/$1 | wc -l `;
			if( $count == 5)
			{
				$status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
				#print "    PASS\n";
			}
			else {
				$status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
				$failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
				$tab_fail = 1;
			}
		}
    }				 
	elsif(/DC_Z_/ && 
      /baseDir=\$\{ARCHIVE_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>_PASS_</b></font></td>";
     #print "    PASS\n";
    }
    elsif(/DC_Z_/ && 
         /baseDir=\${ARCHIVE_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     #print "    FAIL\n";
	 $tab_fail = 1;
    }
    else
    {
     $status="<td align=center><font color=660000><b>_FAIL_</b></font></td>";
	 $failstatus="<td align=center><font color=660000><b>FAIL</b></font></td>";
     #print "	FAIL\n";
	 $tab_fail = 1;
    }

    $tables=~ s/\t//g;
    $tables=~ s/\s//g;
    $tables=~ s/^/<tr><td>/g;
    $tables=~ s/\|/<\/td><td>/g;
    
	if ($tab_fail == 1)
	{	
		my $fail = $tables;
		$fail=~ s/$/<\/td>$failstatus<\/tr>/g;
		$result_fail .= "$fail\n";
	}
	$tables=~ s/$/<\/td>$status<\/tr>/g;
		$result.= "$tables\n";
  }
  
 }
 $result.= "</table>";
 
 $result_fail .= "</table>";
 return $result,$result_fail;

}



############################################################
# PRE TEST, CHECKS THE outDIR: THE DIRECTORIES FOR ALL ETLS 
# This is a very simple test, just runs the query below and lists 
# the results in a table
# The table represents each entry for the inDir directory for all techpacks and 
# interfaces
# This means each techpack and interface should have an entry directory
# I believe in the past there were faults related with missing paths,
# if a path is missing the row is failed.
sub preout{
my $result="";
my $result_fail="";
my $sql=qq{
SELECT c.collection_set_name||"|"|| 
SUBSTRING(action_contents_01,
  CHARINDEX('outDir=', action_contents_01),
  CHARINDEX('interfaceName=', 
  SUBSTRING(action_contents_01, CHARINDEX('outDir=', action_contents_01)))-2
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
$result_fail .= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
<tr>
<th>INTERFACE</th>
<th>DIRECTORY</th>
<th>RESULT</th>
</tr>
};

foreach my $tables (@tables)
 {
   $_=$tables;
   my $tab_fail = 0;
   my $status="";
   next if(/parser.header/);
   next if(/affected/);
   next if($tables=~/SQL Anywhere Error /);
	    next if($tables=~/Msg \d/);
		next if($tables=~/ Msg \d/);
   next if(/^$/);
   $tables=~ s/\t//g;
   $tables=~ s/\s//g;
 
   print " the table is :: \n $tables \n";
   
   if(($tables=~/^INTF/)||($tables=~/^Alarm/)||($tables=~/^DC_Z_/))
   {
    if(/AlarmInterfaces/ && 
      /outDir=\$\{ETLDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/AlarmInterfaces/ && 
         /outDir=\${ETLDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
	 $tab_fail = 1;
    }
    elsif(/INTF_/ && 
         /-eniq_oss_1/ && 
         /outDir=\$\{ETLDATA_DIR\}\/eniq_oss_1\//)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/INTF_/ && 
          !/-eniq_oss_1/ && 
          /outDir=\$\{ETLDATA_DIR\}\/\$\{OSS\}\//)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
	elsif(/DC_Z_/ && 
      /outDir=\$\{ETLDATA_DIR\}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=006600><b>PASS</b></font></td>";
     print "    PASS\n";
    }
    elsif(/DC_Z_/ && 
         /outDir=\${ETLDATA_DIR}\/AlarmInterface_/)
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "    FAIL\n";
	 $tab_fail = 1;
    }
    else
    {
     $status="<td align=center><font color=660000><b>FAIL</b></font></td>";
     print "	FAIL\n";
	 $tab_fail = 1;
    }

    $tables=~ s/\t//g;
    $tables=~ s/\s//g;
    $tables=~ s/^/<tr><td>/g;
    $tables=~ s/\|/<\/td><td>/g;
    $tables=~ s/$/<\/td>$status<\/tr>/g;
    $result.= "$tables\n";
	if ($tab_fail == 1)
	{
		$result_fail .= "$tables\n";
	}
  }
 }
 $result.= "</table>";
 $result_fail .= "</table>";
 return $result,$result_fail;

}

############################################################
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# this is a utility subroutine
# queries the database to check the loading 
# the input parameter is a table name
sub getLoading{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();

my $sql="select '$table'||'|'|| COUNT(*) as COUNT from $table where CONVERT(CHAR(8),DATE_ID,112) = '$date'";
my ($dat)=executeSQL("dwhdb",2640,"dc",$sql,"ROW");

return $dat;
}
############################################################
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# This is a utility subroutine 
# queries the db for a certain table and counts the rows
# the input param is the table name
sub getTopologyLoading{
	my $table = shift;
	my $date  = $DATETIMEWARP;###getDateTimewarp();
	my $sql="select '$table'||'|'|| COUNT(*) as COUNT from $table";
	my ($dat)=executeSQL("dwhdb",2640,"dc",$sql,"ROW");
	#print "GetTopoLoad SQL : $sql	-	Res : $dat\n";
	return $dat;
}
############################################################
# RUNS A QUERY TO GET ALL TABLES, ALL COLUMNS AND DATATYPES
# This is a utility subroutine
# This is one of the most expensive processes in regression
# runs a query and gets all tables and columns
# is not used in any test, is legacy
sub verifyTables{
 #my $result="";
 my $table=shift;
 my$sql=qq{
select 
    A.Table_name||':'||
    B.column_name
       
from 
    SYSTABLE A, 
    SYSCOLUMN B
where  
    B.table_id = A.table_id 
and A.table_type like 'VIEW'
and A.Table_name like ('$table%')
and A.creator=103
order by 
    Table_Name, 
    column_id;
go
EOF
};
 my @result=undef;
 open(TABLES,"$sybase_dir -Udc -P$dcDbPassword -h0 -Ddwhdb -Sdwhdb << EOF $sql |");
 my @tables=<TABLES>;
 chomp(@tables);
 close(TABLES);
  # $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   #<tr>
    # <th>NAME</th>
     #<th>COLUMN</th>
   #</tr>
#};

 foreach my $tables1 (@tables)
 {
	$tables1 =~ s/^\s+//;
	$tables1 =~ s/\s+$//;
	if( $tables1 =~m/^$table/ ) {
		push @result, $tables1;
	}
 } 
 #$result.= "</table>";
 return @result;
}
############################################################
# VERIFIES ALL EXECUTABLES ARE OK
# This is test to check that all scripts in the bin directories are executable
# This test catches scripts ending in hat-M
sub verifyExecutables{
	my $result="";
	my $count=0;
	open(LIST,"file /eniq/sw/bin/* /eniq/admin/bin/* /eniq/bkup_sw/bin/* /eniq/connectd/bin/* /eniq/smf/bin/* |");    
	my @list=<LIST>;
	close(LIST);
	chomp(@list);
	foreach my $list (grep(/executable/, @list))
	{
		$_=$list;
		$list=~s/:.*executable.*//;
		open(EXE,"egrep -l \$'\r\n' $list |");
		my @exe=<EXE>;
		#print "Exe list : @exe\n";;
		foreach my $exe (@exe)
		{
			$result.= "<p align=center><font color=#ff0000><align=center><b>ERROR: EXE file with DOS format: $exe</b></font><br>\n";
			$count++;
		}
		close(EXE);
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
		if (@logfilters ne undef)
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
	

	my @enginelogFilters=("error","exception","fatal","severe","warning","not found","cannot","not supported","reactivated","Altering column");
	my @svclogFilters=("error","exception","fatal","severe","warning","not found","cannot","not supported","reactivated","Unknown Source","NoClassDefFoundError"); 
	my @iqmsgLogFilters=("Dump all thread stacks at","Abort","fatal","Error","Please report this to SAP IQ support","^E.");
	my @featureLogFilters=("Exception","Fail","Skip","Severe","Error","Warning","ERROR","WARNING","SKIP","SEVERE","FAIL","EXCEPTION");
	
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

#############################################################
#Generate Core Topology files
#############################################################
sub epfgloadCoreTopology{
my $result="";
 my $TOP_FLAG="YES";
 my $path="/eniq/home/dcuser/epfg/config";
 my $Topology="YES";
 my $gen_time=getToptime();
 my $NoGenFlag="NO";
 my $NODES=$epfgnumberofnodes;
 my $NeNODES=$epfgnumberofnodes;
 my $stnPicoNodes="A:1-1";
 my $stnSiuNodes="A:1-1";
 my $stnTcuNodes="A:1-1";
 my $wranRNCRBSNoOfNodes="1:1";
 my $wranRNCRXINoOfNodes="1-1";
 my $wranRNCCTypeNodes="1-1";
 my $wranRNCFTypeNodes="1-1";
 my $wranRNCFTypeStopFlag="YES";
 my $ebagBscNodeNames="BAA-1-1";
 my $bscIogNodeNames="BIE-1:1-1:1:1";
 my $bscApgNodeNames="BAA-1:1-1:1:1";
 my $wranNodeAndRBSCellsMapping="1-1:1,1-1:1";
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
	if(/CoreTopologyGen=/)
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
    elsif(/stnTcuNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnTcuNodes\n";
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
    elsif(/wranRNCC-TypeNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCCTypeNodes\n";
   }
    elsif(/wranRNCF-TypeNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCFTypeNodes\n";
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
   ##open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
   print "Successfully started the script for topology generation!!!\n";
   $result="Successfully started the script for CORE topology generation!!!\n";
   print "wait 20 min to load...\n";
   sleep(40*60);
   #topology_backup();
   #sleep(15*60);
   return $result;
}
############################################################
#Generate Topology files for every node other than core
############################################################

sub epfgloadTopology{
my $result="";
 my $TOP_FLAG="YES";
 my $path="/eniq/home/dcuser/epfg/config";
 my $Topology="YES";
 #my $gen_time=getToptime();
 my $NoGenFlag="NO";
 my $NODES=$epfgnumberofnodes;
 my $NeNODES=$epfgnumberofnodes;
 my $stnPicoNodes="A:1-2";
 my $stnSiuNodes="A:1-3";
 my $stnTcuNodes="A:1-1";
 my $wranRNCRBSNoOfNodes="1:1";
 my $wranRNCRXINoOfNodes="1-1";
 my $ebagBscNodeNames="BAA-1-1";
 my $bscIogNodeNames="BIE-1:1-1:1:1";
 my $bscApgNodeNames="BAA-1:1-1:1:1";
 my $wranNodeAndRBSCellsMapping="1-1:1,1-1:1";
 
 ###################################################################
 
 
 
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
my $topo="";
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
		$topo=$line;
		$topo=~s/GenTopology=.*//;
		
		if ( grep { $_ eq $topo} @epfgTopoTPs )
		{
			$line=~s/=.*/=/;
			print OUTPUT "$line$TOP_FLAG\n";
			#print "TOPO : $topo $line$TOP_FLAG\n";
			$topo=undef;
		}
		else
		{
			 print OUTPUT "$line\n";
		}
   }
   elsif((/$nodes/) && (!/GenFlag=/))
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NODES\n";
   }
    elsif((/$nenodes/) && (!/GenFlag=/))
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
    elsif(/stnTcuNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnTcuNodes\n";
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
	 my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
  my $gen_time= sprintf "%02d-%02d-%4d-%02d:%02d",$mday,$mon+1,$year+1900,$hour,$min+2;
  my $actual= sprintf "%02d-%02d-%4d-%02d:%02d",$mday,$mon+1,$year+1900,$hour,$min;
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
   #stats
   system("sed -i 's#ENIQ_VOLUME_MT_POINT=/eniq/data/pmdata/eniq_oss_1/#ENIQ_VOLUME_MT_POINT=/eniq/data/pmdata/eniq_oss_1/;/eniq/data/pmdata/eniq_oss_2/#g' /eniq/home/dcuser/epfg/config/epfg.properties");
   print "Properties file Updated successfully with topology information\n";
   open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
   print "Successfully started the script for topology generation!!!\n";
   $result="Successfully started the script for WRAN,GRAN,LTE and WIFI topology generation!!!\n";
   sleep(7*60);
   open(STOPEXEC,"cd /eniq/home/dcuser/epfg; chmod +x stop_epfg.sh; /eniq/home/dcuser/epfg/stop_epfg.sh |");
   print "wait 20 min to load...\n";
   #stats
   sleep(13*60);
   #topology_backup();
   #sleep(15*60);
   return $result;
}

#############################################################
#  CLEAN UP ENIQ SERVER
#  Cleans up EPFG & RT files. Then truncates all the DIM and DC tables. Also cleansup files input directories.

sub serverCleanup{
	my $result="";
	my $baseDir="/eniq/home/dcuser";
	my $rtbkpDir="$baseDir/RT_Logs_Old";
	my $DC_USER="dc";
	my $DWHREP_USER="dwhrep";
	my $DC_PASSWORD="dc";
	my $DWHREP_PASSWORD="dwhrep";
	my $DWH_NAME_dwhdb="dwhdb";
	my $DWH_NAME_repdb="repdb";
	my $epfgInpDir="/eniq/data/pmdata/tmp";
	my $eniqInpDir="/eniq/data/pmdata/eniq_oss_1";
		
	if (-d "$rtbkpDir") {
		executeThis("rm -rf $rtbkpDir");			 
		executeThis("mkdir -p $rtbkpDir");
	}
			
	#if (-f "$baseDir/nohup.out") {
	#	executeThis("mv $baseDir/nohup.out $rtbkpDir/.");
	#	print "Nohup.out file moved to $rtbkpDir\n";
	#}
	
	#if (-d "$baseDir/epfg") {
	#	executeThis("bash $baseDir/epfg/stop_epfg.sh");
	#	executeThis("mv $baseDir/epfg $rtbkpDir/.");
	#}
	
	#if (-d "$LOGPATH") {
	#	executeThis("mv $LOGPATH $rtbkpDir/.");
	#}
	
	if (-d "$baseDir/sql") {
		executeThis("mv $baseDir/sql $rtbkpDir/.");
	}
	
	my $fileCount=`ls -lrt $baseDir/*.html | wc -l`;
	if ($fileCount != 0) {
		executeThis("mv $baseDir/*.html $rtbkpDir/.");
	}
	
	#$fileCount=`ls -lrt $baseDir/*.txt | wc -l`;
	#if ($fileCount != 0) {
	#	executeThis("mv $baseDir/*.txt $rtbkpDir/.");
	#}
	
	$fileCount=`ls -lrt $baseDir/*.txtbkp | wc -l`;
	if ($fileCount != 0) {
		executeThis("mv $baseDir/*.txtbkp $rtbkpDir/.");
	}
	$result.="\nOld RT and EPFG Logs are moved to $rtbkpDir as backup.\n"; 
	
	if (-e $sybase_dir) {
		`rm $baseDir/result.sql`;
		`rm $baseDir/query.output`;
		print "Sybase Dir : $sybase_dir\n";
		my $sql="select distinct techpack_name from tpactivation";
		my $allTechPacks = executeSQL("repdb",2641,"dwhrep",$sql,"ALL");
		for my $row ( @$allTechPacks ) 
		{
			my ($tp) = @$row;
					
			$sql="select tablename from DWHPARTITION where tablename like '$tp%'";
			my $allTableNames = executeSQL("repdb",2641,"dwhrep",$sql,"ALL");
			
			for my $tableNames (@$allTableNames) {
				my ($table) = @$tableNames;
				`echo "truncate table $table" >> "$baseDir/result.sql"`;
			}
			`echo "go" >> "$baseDir/result.sql"`;
			
			#print "Please wait sql queries are running...\n";
			`${sybase_dir} -P${DC_USER} -U${DC_USER} -S${DWH_NAME_dwhdb} -i ${baseDir}/result.sql -o ${baseDir}/query.output`;

			print "SQL Statements executed successfully for $tp\n";
			$result.="\nSQL Statements executed successfully for $tp\n"; 
			`rm $baseDir/result.sql`;
		}
	}
	else {
		print "Sybase Directory not defined..\n";
		$result.="\nSybase Directory not defined..\n";
	}
	
	if(-d $epfgInpDir) {
		executeThis("rm -rf $epfgInpDir/*");
		$result.="\n$epfgInpDir Directory Removed..\n"; 
	}
	
	if(-d $eniqInpDir) {
		executeThis("rm -rf $eniqInpDir/*");
		$result.="\n$eniqInpDir Directory Removed..\n";
	}
	return $result;
}

sub BusyHourCountCheck
{
my $result="";
  $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>BHLEVEL</th>
     <th>RESULT</th>
   </tr>
	};
	my $result_fail = $result;

	my $sql1 = "Select distinct BHOBJECT , VERSIONID , BHLEVEL from BusyhourMapping";
	#print "1 SQL $sql1\n";
	my $res = executeSQL("repdb",2641,"dwhrep",$sql1,"ALL");
	my @Bhlevel = " ";
	my (%final_hash , %actual_hash) = "";
	my $count_length = 0;
	for my $row ( @$res ) 
		{
			my  ($BhObject , $Versionid , $Bhlevel) = @$row;
			push(@Bhlevel,$Bhlevel);
			my $sql2 = " Select Bhtype , BHcriteria from Busyhour WHERE Versionid like '$Versionid' and Bhtype like 'Pp%' and bhlevel like '$Bhlevel' ";
			
			my $res2 = executeSQL("repdb",2641,"dwhrep",$sql2,"ALL");
			for my $row2 ( @$res2 )
			{
			my ( $var1 , $var2 ) = @$row2;
			
			if( $var2 ne '' ){
				$count_length++;
					}
			}
			
			$final_hash{$Bhlevel} = $count_length;
			$count_length = 0;
			
		}
	foreach (@Bhlevel)
	{
		my $sql3 = "select count(*) from sysviews  where viewname like '$_%pp%'";
		my @res = executeSQL("dwhdb",2640,"dc",$sql3,"ROW");
		my $tmp = $res[0];
		#print " result ==  $tmp  \t   bhlevel $_ \n";
		$actual_hash{$_} = $tmp;
	}
	
	foreach (keys %final_hash)
		{
		
		 if($final_hash{$_} == $actual_hash{$_})
			{
				if($_ ne '')
				{
				$result .= "<tr> <td align=center><b>$_<\/b><\/font> <\/td> <td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr> ";
				}
			}
		else 
			{
				$result_fail .= "<tr> <td align=center><b>$_<\/b><\/font> <\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";
				$result .= "<tr> <td align=center><b>$_<\/b><\/font> <\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";				
			}
		}
	

	
 $result.="</table>\n";
 $result_fail .= "</table>\n";
 return $result,$result_fail;
}
sub sample
{
my $result="";
  $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>BHLEVEL</th>
     <th>RESULT</th>
   </tr>
	};
	my $result_fail = $result;


my $undef=undef;
my $delim = `echo \$PS1`;
chomp($delim);
$delim = substr($delim,-2);

my $exp = new Expect;
my @array = '';
$exp->spawn("/usr/bin/bash");
my $value = "";
#mkdir tempfiles
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("mkdir /eniq/home/dcuser/tempfiles\r");}]); 
$exp->expect(10);

#Change permissions of tempfiles and all the subdirectories under it 
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/chmod -R 777 tempfiles\r");}]);
$exp->expect(2);

my %filehash = ( '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_TSP_ManagedElement_HSS04.xml' => 'SubNetwork=ONRM_RootMo,Site=MSHSS04',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_SGSN_ManagedElement_SGSN36.xml' => 'SubNetwork=ONRM_ROOT_MO,Site=MSSGSN36',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_SGW_ManagedElement_CUDB15.xml' => 'SubNetwork=ONRM_ROOT_MO,Site=MSCUDB15',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_NetSim303_EPDG_ManagedElement_EPG03.xml' => 'SubNetwork=ONRM_ROOT_MO,Site=MSEPG03',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_SGSNMME_ManagedElement_SGSNM01.xml' => 'SubNetwork=ONRM_RootMo,Site=MSSGSNM01',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_NetSim303_GGSN_ManagedElement_GGSN10.xml' => 'SubNetwork=ONRM_ROOT_MO,Site=MSGGSN10',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_TSP_ManagedElement_CSCF05.xml' => 'SubNetwork=ONRM_RootMo,Site=MSCSCF05',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_TSP_ManagedElement_MRFC05.xml' => 'SubNetwork=ONRM_RootMo,Site=MSMRFC05',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_IPWorks_PM_ManagedElement_IPWk04.xml' => 'SubNetwork=ONRM_RootMo,Site=MSIPWk04',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_TSP_ManagedElement_MTAS01.xml' => 'SubNetwork=ONRM_RootMo,Site=MSMTAS01',
		   '/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/SubNetwork_TSP_ManagedElement_SAPC04.xml' => 'SubNetwork=ONRM_RootMo,Site=MSSAPC04',
);

my %filevalues = ( 'SubNetwork=ONRM_RootMo,SubNetwork=TSP,ManagedElement=HSS04' => 'DC_E_HSS',
		     'SubNetwork=ONRM_ROOT_MO,ManagedElement=EPG03' => 'DC_E_EPG',
		     'SubNetwork=ONRM_RootMo,SubNetwork=TSP,ManagedElement=CSCF02' => 'DC_E_CSCF',
		     'SubNetwork=ONRM_RootMo,SubNetwork=SGSNMME,ManagedElement=SGSNM01' => 'DC_E_SGSNMME',
		     'SubNetwork=ONRM_RootMo,SubNetwork=TSP,ManagedElement=MRFC05' => 'DC_E_MRFC',
		     'SubNetwork=ONRM_RootMo,SubNetwork=TSP,ManagedElement=SAPC04' => 'DC_E_SAPC',
		     'SubNetwork=ONRM_ROOT_MO,SubNetwork=SGSN,ManagedElement=SGSN36' => 'DC_E_SGSN',
		     'SubNetwork=ONRM_ROOT_MO,SubNetwork=NetSim303_GGSN,ManagedElement=GGSN10' => 'DC_E_GGSN',
		     'SubNetwork=ONRM_ROOT_MO,SubNetwork=SGW,ManagedElement=CUDB15' => 'DC_E_CUDB',
		     'SubNetwork=ONRM_RootMo,SubNetwork=TSP,ManagedElement=MTAS01' => 'DC_E_MTAS',
		     'SubNetwork=ONRM_RootMo,SubNetwork=IPWorks_PM,ManagedElement=IPWk04' => 'DC_E_IPWk',
);

my %filevalue = ( 'HSS04' => 'DC_E_HSS',
		     'EPG03' => 'DC_E_EPG',
		     'CSCF02' => 'DC_E_CSCF',
		     'SGSNM01' => 'DC_E_SGSNMME',
		     'MRFC05' => 'DC_E_MRFC',
		     'SAPC04' => 'DC_E_SAPC',
		     'SGSN36' => 'DC_E_SGSN',
		     'GGSN10' => 'DC_E_GGSN',
		     'CUDB15' => 'DC_E_CUDB',
		     'MTAS01' => 'DC_E_MTAS',
		     'IPWk04' => 'DC_E_IPWk',
);


my $dest ='/eniq/home/dcuser/tempfiles/';
my $dest1='/eniq/data/pmdata/eniq_oss_1/core/topologyData/CoreNetwork/';
my $dest2='/eniq/data/pmdata/eniq_oss_2/core/topologyData/CoreNetwork/';

my @nodearray  = "";

foreach (keys %filehash)
	{
		if( $_ =~ /.+_ManagedElement_(.*)\.xml/)
		{
			push(@nodearray,$1);
		}
	}

foreach (keys %filehash)
			{
			$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send(" cp $_ $dest\r");}]);
			$exp->expect(2);
			}

foreach (keys %filehash)
{
	$value=dataupdatexml($_ , $filehash{$_});
	push(@array,$value);
}	


$exp->expect($undef, ['#:', sub {$exp = shift; $exp->send("engine -e startAndWaitSet INTF_DIM_E_CN_CN-eniq_oss_1 Adapter_INTF_DIM_E_CN_CN_ct\r");}]);
$exp->expect(5);

sleep(60);

#DB query here -- get the time updated 

my %tphash1 = executeSQLALL('dwhdb',2640,'dc',\@nodearray,'type1','');

print Dumper(%tphash1);

foreach (@array)
{
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send(" mv $_ $dest1\r");}]);
$exp->expect(2);
}


$exp->expect($undef, ['#:', sub {$exp = shift; $exp->send("engine -e startAndWaitSet INTF_DIM_E_CN_CN-eniq_oss_1 Adapter_INTF_DIM_E_CN_CN_ct\r");}]);
$exp->expect(5);

sleep(60);

#DB query here -- get the time updated
 
my %tphash2 = executeSQLALL('dwhdb',2640,'dc',\@nodearray,'type1','');
print Dumper(%tphash2);

#check the time is properly updated or not

foreach (keys %tphash1)
	{
	    my $temp = "";
	    if($tphash1{$_}[1] eq $tphash2{$_}[1])
			{ 
			 $temp = $filevalues{$_};
			$result_fail .= "<tr> <td align=center><b>$temp<\/b><\/font> <\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";
			$result .= "<tr> <td align=center><b>$temp<\/b><\/font> <\/td> <td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr> ";	
			 print " $temp It is failed \n";
			}
		else 
			{
	 		$temp = $filevalues{$_};
			$result .= "<tr> <td align=center><b>$temp<\/b><\/font> <\/td> <td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr> ";
			 print " $temp It is passed \n";
			}
	}
	

#mkdir eniq_oss_2
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("mkdir -p /eniq/data/pmdata/eniq_oss_2/core/topologyData/CoreNetwork\r");}]); 
$exp->expect(10);

#Change permissions of tempfiles and all the subdirectories under it 
$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("/usr/bin/chmod -R 777 /eniq/data/pmdata/eniq_oss_2/core/topologyData/CoreNetwork\r");}]);
$exp->expect(2);

	$dest = $dest.'*.xml';
	print " file hash ===  $dest\n";
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send(" cp $dest $dest2\r");}]);
	$exp->expect(2);

$exp->expect($undef, ['#:', sub {$exp = shift; $exp->send("engine -e startAndWaitSet INTF_DIM_E_CN_CN-eniq_oss_2 Adapter_INTF_DIM_E_CN_CN_ct\r");}]);

sleep(60);

my %tphash3 = executeSQLALL('dwhdb',2640,'dc',\@nodearray,'type2','\%filevalue');

my @secondarrayone = "";

foreach $a (keys %filevalue)
{
	push(@secondarrayone,$a);
				
}

foreach $a (@secondarrayone)
{
	foreach $b ( keys %tphash3 )
		{
			if( $a eq $b )
				{
				    $b = $filehash{$a};				
				}
		}
}
 
print Dumper(%tphash3);

$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("rm -rf tempfiles/\r");}]);
$exp->expect(2);

$result.="</table>\n";
 $result_fail .= "</table>\n";
 return $result,$result_fail;

}

sub dataupdatexml
{
my ( $filename , $attributename ) = @_;
my ($filenew,$attributenew , @newarray) = "";
my $dest ='/eniq/home/dcuser/tempfiles/';

if( $filename =~ /.+CoreNetwork\/(.*)\.xml/)
{

$filenew = $1.'_new.xml';
}
my $newpath = $dest.$filenew;
$attributenew = $attributename.'_new';



open(FILEOPEN,"$filename") || die "Couldn't open file file.txt, $!";

open(FILECLOSE,"> $newpath") || die "Couldn't open file file.txt, $!";

my $var1 = "<attr name=\"siteRef\">$attributename</attr>";
my $var2 = "<attr name=\"siteRef\">$attributenew</attr>";

while ( <FILEOPEN>)
{
	chomp($_);
	
	if ( $_ =~ s/$var1/$var2/)
	{
	  
	  print FILECLOSE $_ ;
	  print FILECLOSE "\n";
		
	}
	elsif($_ eq '<!-- Generated 1 entries -->')
	{
	print FILECLOSE $_ ;
	print FILECLOSE "\n";
	last;
	}else
		{
	print FILECLOSE $_ ;
	print FILECLOSE "\n";
	}
}

close (FILEOPEN);
close (FILECLOSE);
return ($newpath);
}

sub executeSQLALL{
	 my $dbname = $_[0];
        my $port = $_[1];
        my $cre = $_[2];
        my $tp = $_[3];
	 my $type = $_[4];
	 my $res = $_[5];
	 my ( $result , @result , %tphash ) = '';
	 if( $type eq 'type1')
		{
	 my $connstr = "ENG=$dbname;CommLinks=tcpip{port=$port};;UID=$cre;PWD=$cre";
     my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 1} );
	 my $startsql1 = "Select NE_FDN,MODIFIED,SITE_FDN from DIM_E_CN_CN Where NE_FDN LIKE '%" ;
	 my $endsql1 = "' AND STATUS LIKE 'ACTIVE'";
	 foreach my $var (@$tp)
	  {
		my $sql=$startsql1.$var.$endsql1;
		print " SQL stamt \n $sql \n";
		my $sel_stmt=$dbh->prepare($sql);
		$sel_stmt->execute() or warn $DBI::errstr;
		my @result = $sel_stmt->fetchrow_array();
		$sel_stmt->finish();
		$tphash{$result[0]} = [ @result ];			
	 }
	 $dbh->disconnect;
	 return(%tphash);
		}
	else 
	{
	 my $connstr = "ENG=$dbname;CommLinks=tcpip{port=$port};;UID=$cre;PWD=$cre";
     my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 1} );
	 my $startsql1 = "Select NE_FDN,MODIFIED,SITE_FDN from DIM_E_CN_CN Where NE_FDN LIKE '%" ;
	 my $endsql1 = "' AND STATUS LIKE 'ACTIVE'";
	 foreach my $var (@$tp)
	  {
		my $sql=$startsql1.$var.$endsql1;	
		print " SQL stamt \n $sql \n";	
		my $sel_stmt=$dbh->prepare($sql);
		$sel_stmt->execute() or warn $DBI::errstr;
		my @result = $sel_stmt->fetchrow_array();
		$sel_stmt->finish();
		my $len = @result;
		
		if($len > 1 )
			{
			$tphash{$var} = 'pass';}
		else {
			
			$tphash{$var} = 'fail';}
	 }
	 $dbh->disconnect;
	 return(%tphash);
	}
}

############################################################
# LOAD TOPOLOGY UPDATE 
# queries the database for the topology tables and counts the rows
# if the number of rows is 0, it fails the test case

sub verifyTopology{
my $result="";
  $result.=qq{
 <br><table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TOPOLOGY TABLE</th>
     <th>COUNT</th>
     <th>RESULT</th>
   </tr>
};
my $result_fail = $result;
my @alltopologytables=getAllDimTables4TP("DIM_E_");
		
 for my $dimTable (@alltopologytables)
 {
	if ($dimTable ne "")
	{
		my $data=getTopologyLoading($dimTable); 
		my $data_fail;
		my $data_ex;
		$data=~ s/\|0/|<b>0<\/b>/;
		$data=~ s/^/<tr><td>/g;
		$data=~ s/ //g;
		$data=~ s/\|/<\/td><td align=center>/g;
		$data_ex = $data;
		$_=$data;
		if(/<b>0<.b>/)
		{
			$data=~ s/$/<\/td><td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr>/;
#			$data_fail=~ s/\|0/|<b>0<\/b>/;
#			$data_fail=~ s/^/<tr><td>/g;
#			$data_fail=~ s/ //g;
#			$data_fail=~ s/\|/<\/td><td align=center>/g;
			$data_fail = $data_ex;
			$data_fail =~ s/$/<\/td><td align=center><font color=660000><b>FAIL<\/b><\/font><\/td><\/tr>/;
		}
		else
		{
			$data=~ s/$/<\/td><td align=center><font color=006600><b>PASS<\/b><\/font><\/td><\/tr>/;
		} 
		$result.="$data\n"; 
		if( defined $data_fail ) {
			$result_fail .= "$data_fail\n";
		}
	}
  }
 $result.="</table>\n";
 $result_fail .= "</table>\n";
 return $result,$result_fail;
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
sub epfgpmdataGeneration{
 my $result="";
 my $START=$epfgstarttime;
 my $END=$epfgstoptime;
 my $NODES=$epfgnumberofnodes;
 my $NeNODES=$epfgnumberofnodes;
 my $startNode="1";
 my $endNode=$epfgnumberofnodes;
 my $FLAG="YES";
 my $GPP="YES";
 my $path="/eniq/home/dcuser/epfg/config";
 my $stnPicoNodes="A:1-1";
 my $stnSiuNodes="A:1-1";
 my $stnTcuNodes="A:1-1";
 my $wranRNCRBSNoOfNodes="1:1";
 my $wranRNCRXINoOfNodes="1-1";
 my $wranRNCCtype="1-1";
 my $wranRNCFtype="1-1";
 my $wranRNCFTypeStopFlag="YES";
 my $ebagBscNodeNames="BAA-1-1";
 my $bscIogNodeNames="BIE-1:1-1:1:1";
 my $bscApgNodeNames="BAA-1:1-1:1:1";
 my $cpg_instances="1";
 my $NoTopology="NO";
 my $epfg_version=getepfg_version();
 my @inputarray= undef;
 my ($x, $y);
 my $flag = "no";
 my $pmTP="";
 if (substr($epfg_version,2,1) gt "M")
 {
  $wranRNCRXINoOfNodes="1-1";
  $ebagBscNodeNames="BAA-1";
  $wranRNCCtype="1-1";
  $wranRNCFtype="1-1";
 }
 
foreach $a (@epfg_techPacks)
{
	foreach $b ( keys %PmGenNodes )
		{
			if( lc($a) eq lc($b) )
				{
					push(@inputarray,@{$PmGenNodes{$b}});
				
				}
		}
}
chomp(@inputarray);
#print " the input array is ::: @inputarray \n";
###############
   configfile_gen();
   print "Properties file Updated successfully for Config File Gen\n";
   open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
   print "Successfully started the script for config file generation!!!\n";
   #stats
   sleep(5*60);
   open(STOPEXEC,"cd /eniq/home/dcuser/epfg; chmod +x stop_epfg.sh; /eniq/home/dcuser/epfg/stop_epfg.sh |");
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
#@epfg_techPacks=DivideEpfg_Techpacks();
#for my $tps (@epfg_techPacks)
#{
#	print " Test TP : $tps\n";
#}
my @bulkCmGenFlag = ("enableLteBCGCmdata" , "enableERBSG2BCGCmdata" , "enableRncBCGCmdata" , "enableRbsBCGCmdata" , "enableRxiBCGCmdata" , "enableGsmBCGCmdata" , "enableNrBCGCmdata" , "enableMgwBCGCmdata" , "enableMscApgBCGCmdata" , "enableMscIogBCGCmdata" , "enableMscBcBCGCmdata" , "enableRanosBCGCmdata");
#my $pmTP="";
for my $line (@input) 
 {
  $_=$line;
  #my $flag=flagRegExp(@epfg_techPacks);
  my $start=startRegExp(@epfg_techPacks);
  my $end=endRegExp(@epfg_techPacks);
  my $nodes=nodesRegExp(@epfg_techPacks);
  my $nenodes=nenodesRegExp(@epfg_techPacks);
  my $start_node=StartNodeRegExp(@epfg_techPacks);
  my $end_node=EndNodeRegExp(@epfg_techPacks);
	$flag = "no";
  my @line1 = split('=', $line); 
  if((/$start/) && (!/GenFlag=/))
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$START\n"; 
	 #print "STARTTIME : $line$START	:	$start\n";
   }
   elsif((/$end/) && (!/GenFlag=/) )
   { 
     $line=~s/=.*/=/;
     print OUTPUT "$line$END\n";
	 #print "ENDTIME : $line$END	:	$end\n";
   }
   elsif(/enable3gppGenFlag=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$GPP\n";
   }   
    elsif(/GenFlag=/)
   {
		foreach $y (@inputarray) {
			$pmTP=$line;
			$pmTP=~s/GenFlag=.*/GenFlag=/;
			my $y1=$y."=";
			if ( $pmTP eq $y1) {
				$flag = "yes";
				$pmTP =~ s/GenFlag=/GenFlag=YES/;
				print OUTPUT "$pmTP \n";
				last;																		
				}									
		}
		if ( $flag eq "no" ){
			#print " \n 444444444444  $flag \n";
			print OUTPUT "$line \n";
		}
   }
   elsif($line1[0] ~~ @bulkCmGenFlag ) {
		$flag = "yes";
		$pmTP=$line;
		print "line1 == $line1[0]";
		$pmTP=~s/$line1[0]=.*/$line1[0]=/;
		$pmTP =~ s/$line1[0]=/$line1[0]=YES/;
		print OUTPUT "$pmTP \n";
		if ( $flag eq "no" ){
			print OUTPUT "$line \n";
		}
   }
   elsif(/BCGCmdata=/)
   {
		if ( grep { $_ eq "Bcg"} @epfgTopoTPs)
		{
			$line=~s/=.*/=/;
			print OUTPUT "$line$FLAG\n";
		}
		else
		{
			 print OUTPUT "$line\n";
		}
   }
    elsif(/$nodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NODES\n";
	 #print "PM NODES : $line$NODES\n";
   }
    elsif(/$nenodes/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$NeNODES\n";
	 #print "PM NENODES : $line$NeNODES\n";
   }
    elsif(/$start_node/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$startNode\n";
	 #print "START_NODE : $line$startNode\n";
   }
    elsif(/$end_node/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$endNode\n";
	 #print "END_NODE : $line$endNode\n";
   }
    elsif(/stnPicoNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnPicoNodes\n";
   }
     elsif(/stnTcuNodes=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$stnTcuNodes\n";
	 #print "stnTcuNodes : $line$stnTcuNodes\n";
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
    elsif(/wranRNCFTypeStopFlag=/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$wranRNCFTypeStopFlag\n";
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
    elsif(/mlpppNumOf/)
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
print "Properties file Updated successfully for PM file generation\n";

open(RUN,"cd /eniq/home/dcuser/epfg; chmod +x start_epfg.sh; /eniq/home/dcuser/epfg/start_epfg.sh |");
print "Successfully started the script for PM file generation!!!\n";
sleep(30*60);
open(STOPEXEC,"cd /eniq/home/dcuser/epfg; chmod +x stop_epfg.sh; /eniq/home/dcuser/epfg/stop_epfg.sh |");
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
my $delim = `echo \$PS1`;
	chomp($delim);
	$delim = substr($delim,-2);

	my $exp = new Expect;
	my $undef = undef;
	$exp->spawn("/usr/bin/bash");
	
	$exp->expect($undef, [$delim, sub {$exp = shift; $exp->send("su - dcuser\r");}]);
	$exp->expect(5);
	$exp->expect($undef, [":", sub {$exp = shift; $exp->send("dcuser\r");}]);
	$exp->expect(5);
	
$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR SessionLoader_Starter Start<br>";
my @out1=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR SessionLoader_Starter Start ");
sleep(10);
$result.="/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateMonitoredTypes Start<br>";
my @out2=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateMonitoredTypes Start ");
sleep(30);
print "Triggering set /eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateFirstLoadings\n";
my @out3=executeThis("/eniq/sw/bin/engine -e startSet DWH_MONITOR UpdateFirstLoadings");
sleep(300);
print "Triggering set /eniq/sw/bin/engine -e startSet DWH_MONITOR AggregationRuleCopy\n";
my @out5=executeThis( "/eniq/sw/bin/engine -e startSet DWH_MONITOR AggregationRuleCopy");
sleep(60);
my @out=(@out1,@out2,@out5,@out3);
  foreach my $out (@out)
  {
    print "$out\n";  
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
  my $result_fail;
  my $year   =$YEARTIMEWARP;  #getYearTimewarp();
  my $month  =$MONTHTIMEWARP; #getMonthTimewarp();
  my $day    =$DAYTIMEWARP;   #getDayTimewarp();
  
  system("rm /eniq/home/dcuser/cookies.txt");
  system("rm /eniq/home/dcuser/cookies2.txt");
  
  my @tpList=undef;
if (@epfg_techPacks!=undef)
{
	my $tp="";
	my $substr="|";
	for my $tps (@epfg_techPacks)
	{
		$_=$tps;
		next if(/^$/);
		$tp=$epfgNodeTPs{$tps};
		next if($tp eq "");
		if (index($tp, $substr) != -1) {
			my @tpNames=split(/\|/,$tp);
			foreach my $j (@tpNames)
			{
				$_=$j;
				next if(/^$/);
				push @tpList, $j;  
			}
		}
		else {
			push @tpList, $tp;
		}
	}
	@tpList=uniqArr(@tpList);
}
  
  
  if (@tpList==undef)
  {	
	 print "Retrieve list of TP's for Loadings Verification.. (List not initialized)\n";
	 @tpList = Divide_Techpacks();
  }
  	 
  foreach my $tp (@tpList)
  {
   $_=$tp;
   next if(/^$/);
   
   #Commented out below AdminUI portion
=begin Deprecated
   # SAVE COOKIES
   system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/loading4_$tp.html --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");
   #sleep(1);

   # SEND USRID AND PASSWORD
   system("$WGET --quiet  --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
   
   # GET LOADING
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/loading4_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&techPackName=$tp&getInfoButton='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowLoadStatus\"");
   
   # Log OFF
   system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout");

   open(LOAD,"< /eniq/home/dcuser/loading4_$tp.html");
   my @loadings=<LOAD>;
   close(LOAD); 
   
   system("rm /eniq/home/dcuser/loading4_$tp.html");
 
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
	$result_fail .= qq{    
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
   my $dummy_load = "";
    $_=$loadings;
    if(/&nbsp;X&nbsp/) 
      {
         $result.="NO DATA FOUND FOR $tp<br>";
		 $result_fail .= "NO DATA FOUND FOR $tp<br>";
         print "NO DATA FOUND FOR $tp\n";
         last;
      }
    if(/\/adminui\/servlet\/ShowLoadings\?year_1=....&month_1=..&day_1=..\&subtype=.*&details=15MIN/) 
       {
         $loadings=~s/.*15MIN.//;
         $loadings=~s/<.*//;
         $loadings=~s/>//;
         $result .="<tr><td>$loadings</td>";
		 $dummy_load = $loadings;
		 
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
			$result_fail .= "<tr><td>$dummy_load</td>";
			$result_fail .= "<td align=center>$green</td>";
			$result_fail .= "<td align=center>$yellow</td>";
			$result_fail .= "<td align=center>$red</td>";
			$result_fail .= "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
           }
           else
           {
             $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
#			 $result_fail .= "<br><br><p><font size=8 color=006600><b>NO FAILED LOADERS</b></font></p><br><br>";
           }
           $result.=  "</tr>";
		   $result_fail .=  "</tr>";
           $found=0; 
           $green=0;
           $yellow=0;
           $red=0;
        }
   }
   $result.=qq{</table>
		};
   $result_fail .= qq{</table>
		};
=end Deprecated
=cut
   my @tables= getAllDimTables4TP($tp);
  my $tablesSize = scalar @tables; 
	if($tablesSize > 1) {
   $result.="<h3>$tp</h3><BR>\n"; 					   							  
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
   $result_fail .= "<h3>$tp</h3><BR>\n";
$result_fail.=qq{
  <br>
  <h3>SQL LOAD STATUS DB</>
    <table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>TABLE</th>
     <th>ROWS</th>
     <th>RESULT</th>
   </tr>
};
} 
   foreach my $table (@tables)
     {
        $_=$table;
		#print "Table : $table\n";
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
		next if($table=~/SQL Anywhere Error /);
	    next if($table=~/Msg \d/);
		next if($table=~/ Msg \d/);
        next if(/_DAY/);
        next if(!/_RAW/);
        my @data=getLoading($table);

        foreach my $data (@data)
          {
			my $data_fail;
            $_=$data;
			#print "Data : $data\n";
            next if(/^$/);
            next if(/affected/);
			next if($data=~/SQL Anywhere Error /);
	    next if($data=~/Msg \d/);
		next if($data=~/ Msg \d/);
            $data=~ s/\t//g;
            $data=~ s/\s//g;
            $data=~ s/^/<tr><td>/g;
            $data=~ s/\|/<\/td><td align=center>/g;
            $data=~ s/$/<\/td><td align=center>RESULT<\/td><tr>/g;
#			$data_fail = $data;
            $_=$data;
            if(/<td align=center>0<.td>/)
             {
              $data=~ s/RESULT/<font color=#660000><b>FAIL<\/b><\/font>/;
			  $data_fail = $data;
#			  $data_fail=~ s/RESULT/<font color=#660000><b>FAIL<\/b><\/font>/;
             }
            else #(/<td align=center>$numRops<.td>/)
             {
              $data=~ s/RESULT/<font color=#006600><b>PASS<\/b><\/font>/;
             }
            $result.="$data\n";
#			my $fail =()= $data_fail =~ /FAIL+/g;
#			if ($fail==0)
#			{
#				$result_fail .= "<br><br><p><font size=8 color=006600><b>NO FAILED LOADERS</b></font></p><br><br>";
#			}
#			else
#			{
				if( defined $data_fail ) {			  
					$result_fail.="$data_fail\n";
				}
#			}
          }
      }
    $result.="   </table>\n";
	$result_fail.="   </table>\n";
#Commented out below AdminUI portion
=begin Deprecated

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
	$result_fail.=qq{
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
   #print "\nSecond Iteration..\n";
   foreach my $table (@tables)
     {
        $_=$table;
		
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
		next if($table=~/SQL Anywhere Error /);
	    next if($table=~/Msg \d/);
		next if($table=~/ Msg \d/);
        next if(/_DAY/);
        next if(!/_RAW/);
        my @data   =getLoading($table);

        # GET INFO FOR TABLE FROM WEB
         $table=~s/_RAW//;
         # SAVE COOKIES
         system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/loading415min_$table.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ShowLoadings?year_1=$year&month_1=$month&day_1=$day&subtype=$table&details=15MIN\"");

        # SEND USR AND PASSWORD
         system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

         # GET LOADING
         system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/loading415min_$table.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ShowLoadings?year_1=$year&month_1=$month&day_1=$day&subtype=$table&details=15MIN\"");
		 
		# Log OFF
		system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout");

        open(L15MIN,"< /eniq/home/dcuser/loading415min_$table.html");
        my @l15min=<L15MIN>;
        close(L15MIN); 
        system("rm /eniq/home/dcuser/loading415min_$table.html");

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
				$result_fail .= "<td>$table</td>";
				$result_fail .= "<td align=center>$green</td>";
				$result_fail .= "<td align=center>$yellow</td>";
				$result_fail .= "<td align=center>$red</td>";
				$result_fail .= "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
             }
             else
             {
               $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
#			   $result_fail .= "<br><br><p><font size=8 color=006600><b>NO FAILED LOADERS</b></font></p><br><br>";
             }
             $result.=  "</tr>";
			 $result_fail.=  "</tr>";
             $found=0;
             $green=0;
             $yellow=0;
             $red=0;
           }

        }
     }
     $result.="</table>\n";
	 $result_fail.="</table>\n";
   
=end Deprecated
=cut
}
  return $result,$result_fail;
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
  my $result_fail;
  my $year   =$YEARTIMEWARP;  #getYearTimewarp();
  my $month  =$MONTHTIMEWARP; #getMonthTimewarp();
  my $day    =$DAYTIMEWARP;   #getDayTimewarp();
  
  system("rm /eniq/home/dcuser/cookies.txt");
  system("rm /eniq/home/dcuser/cookies2.txt");  
  my @tpList=undef;
if (@epfg_techPacks!=undef)
	{
	my $tp="";
	my $substr="|";
	for my $tps (@epfg_techPacks)
	{
		$_=$tps;
		next if(/^$/);
		$tp=$epfgNodeTPs{$tps};
		next if($tp eq "");
		if (index($tp, $substr) != -1) {
			my @tpNames=split(/\|/,$tp);
			foreach my $j (@tpNames)
			{
				$_=$j;
				next if(/^$/);
				push @tpList, $j;  
			}
		}
		else {
			push @tpList, $tp;
		}
	}
	@tpList=uniqArr(@tpList);
}
  
  
  if (@tpList==undef)
  {	
	 print "Retrieve list of TP's for Loadings Verification.. (List not initialized)\n";
	 @tpList = Divide_Techpacks();
  }

  foreach my $tp (@tpList)
  {
   $_=$tp;
   next if(/^$/);
   $result.="<h3>$tp</h3><BR>\n";
   $result_fail .= "<h3>$tp</h3><BR>\n";
   # SAVE COOKIES
   system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&action=/servlet/ShowAggregations&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");
   #sleep(1);
  
   # SEND USR AND PASSWORD
   system("$WGET  --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
   #sleep(1);
 
   # GET AGGREGATION
   system("$WGET --quiet  --no-check-certificate -O /eniq/home/dcuser/aggregations_$tp.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"year_1=$year&month_1=$month&day_1=$day&type=$tp&value='Get Information'\"  \"https://localhost:8443/adminui/servlet/ShowAggregations\"");


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
	$result_fail .= qq{    
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
		 $result_fail .= "<tr><td>$aggregations</td>";
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
			$result_fail .= "<td align=center>$green</td>";
			$result_fail .= "<td align=center>$yellow</td>";
			$result_fail .= "<td align=center>$red</td>";
			$result_fail .= "<td align=center><font color=660000><b>FAIL</b></font></td>\n";
           }
           else
           {
             $result.=  "<td align=center><font color=006600><b>PASS</b></font></td>\n";
			 $result_fail .= "<br><br><p><font size=8 color=006600><b>NO FAILED AGGREGATORS</b></font></p><br><br>";
           }
           $result.=  "</tr>";
		   $result_fail.=  "</tr>";
           $found=0;
           $green=0;
           $yellow=0;
           $red=0;
        }
   }
   $result.="</table>\n";
   $result_fail.="</table>\n";

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
   $result_fail.=qq{
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
		next if($table=~/SQL Anywhere Error /);
	    next if($table=~/Msg \d/);
		next if($table=~/ Msg \d/);
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
			next if($data=~/SQL Anywhere Error /);
	    next if($data=~/Msg \d/);
		next if($data=~/ Msg \d/);
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

  return $result;
}

############################################################
# VERIFY EBS TESTCASES
# TODO
sub verifyEBS{
  return "TO BE IMPLEMENTED\n";
}


############################################################
# VERIFY UNIVERSES EXIST IN THE APPROPIATE DIRECTORIES
# This process only counts the universes are in a unv directory for all techpacks
sub verifyUniverses{
 my $result1="";
 my $result="";
 my $result1_fail = "";
 my $result_pass="";
 my $result_fail="";
 my $result_Subfail="";
 my $pass=0;
 my $fail=0;
 my @tps=executeThis("ls /eniq/sw/installer/bouniverses/BO* | grep -c : ");
 #$result.= $tps[0]."<br>";
 @tps=executeThis("ls /eniq/sw/installer/bouniverses/BO* | grep : ");
 chomp(@tps);
 chop(@tps);
 $result1.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr><br><br>
     <th>UNIVERSE</th>
     <th>RESULT</th>
   </tr>
};

 foreach my $tp (@tps)
 {
    my $unv_check=executeThis("find $tp/unv/ \\\( -name \"*.lcmbiar\" -o -name \"*.unv\" \\\)");
	print "$unv_check   :           find $tp/unv/ \\\( -name \"*.lcmbiar\" -o -name \"*.unv\" \\\)\n";
	if ($unv_check==0)
    {
        $result_Subfail.= "<tr><td>$tp<\/td><td align=center><font color=660000><b>_FAIL_</b></font></td><tr>\n";
		$result_fail.= "<tr><td>$tp<\/td><td align=center><font color=660000><b>FAIL</b></font></td><tr>\n";
		$fail=$fail+1;
    }
    else
      {
        $result_pass.= "<tr><td>$tp<\/td><td align=center><font color=006600><b>_PASS_</b></font></td><\/tr>\n";
		$pass=$pass+1;
      }

 }
 #$result.= "<a href=\"#t1\"> <font color=green>PASS ($pass)</a><font color=black>  /  <a href=\"#t2\"><font color = red>FAIL ($fail)</td></table>";	  
	  $result.=$result1;
	  $result.=$result_pass;
	  $result.=$result_Subfail;
	  $result .= "</table>\n";
	  $result1_fail.= $result1;
	  $result1_fail.=$result_fail;
	  $result1_fail.= "</table>\n";
 return $result,$result1_fail;
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
my $result1="";
my $result_fail1 = "";
my $result_fail = "";
 $result.= "<br>CHECK ALARMS Alarm files found:";
    my @wid=executeThis("ls /eniq/sw/installer/bouniverses/BO*ALARM*/rep/* | grep -c lcmbiar");
    $result.= "\t$wid[0]<br>\n";
    my @widr=executeThis("ls /eniq/sw/installer/bouniverses/BO*ALARM*/rep/* ");
$result1 .= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
			<tr>
			<th>Alarm Report</th>
			<th>RESULT</th>
			</tr>
			};
	$result.= $result1;
	if ($wid[0] == 0)
	{
		$result.= "<tr><td align=center>No Alarm Reports Found<\/td><\/td><td align=center><font color=660000><b>_FAIL_</b></font></td></tr>";
		$result_fail1.= "<tr><td align=center>No Alarm Reports Found<\/td><\/td><td align=center><font color=660000><b>FAIL</b></font></td></tr>";
	}
	else
	{
		foreach my $widr (@widr)
		{
			$result.= "<tr><td align=center>$widr<\/td><\/td><td align=center><font color=006600><b>_PASS_</b></font></td></tr>";
		}
	}
	$result_fail.=$result1;
	$result_fail.=$result_fail1;
	$result_fail.= "</table>\n";
	$result .= "</table>\n";
  return $result,$result_fail;
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
open webserver
user root shroot
cd /etc/
put hosts hosts
bye
EOF
};
   # EXECUTE FTP
   open(FTP,"$ftp |")|| die "cannot contact webserver\n";
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
my $sql="select count(*) from DC_Z_ALARM_INFO_RAW";
my ($dat)=executeSQL("dwhdb",2640,"dc",$sql,"ROW");

 if($dat==0)
  {
    $result.="<font color=660000><b>No alarms found in DC_Z_ALARM_INFO_RAW</b></font><br>";
  }
 else
  {
    $result.="<font color=006600><b>PASS: [ $dat ] alarms found in DC_Z_ALARM_INFO_RAW.</b></font><br>";
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
   next if($tables=~/SQL Anywhere Error /);
	    next if($tables=~/Msg \d/);
	next if($tables=~/ Msg \d/);
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
   next if($tables=~/SQL Anywhere Error /);
   next if($tables=~/Msg \d/);
   next if($tables=~/ Msg \d/);
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
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --save-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  sleep(20);

# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
  sleep(20);

# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");
 
  sleep(20);
# RUN DISTRIBUTOR
  # GET COOKIES  AND JSESSIONID NOTHING ELSE
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt  \"https://localhost:8443/adminui/servlet/ETLRunSetOnce?colName=INTF_PM_E_EBS$ebsType\-eniq_oss_1&setName=Distributor_MOM_EBS$ebsType\"");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");


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
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt  https://localhost:8443/adminui/servlet/EbsUpgradeManager");

# SEND USER AND PASSWORD
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies.txt --save-cookies /eniq/home/dcuser/cookies2.txt --post-data 'action=j_security_check&j_username=eniq&j_password=eniq' https://localhost:8443/adminui/j_security_check");

# UPGRADE EBS
  system("$WGET --quiet --no-check-certificate -O /dev/null --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt --post-data \"action=action_run_upgrade&upgradeId=PM_E_EBS$ebsType&submit='Upgrade now!'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");

sleep(20);
# WAIT UNTIL IS UPGRADED
my $status=0;
my $found=0;
# DELETE PREVIOUS RUNS
do{
  system("rm /eniq/home/dcuser/ebs_upgrade.html");
  my @ebs=executeThis("$WGET --quiet --no-check-certificate -O  /eniq/home/dcuser/ebs_upgrade.html  --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt   --post-data \"action=action_get_upgrade_status&submit='refresh status'\" https://localhost:8443/adminui/servlet/EbsUpgradeManager");
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
system("$WGET --no-check-certificate -O /dev/null --quiet --cache=on --save-headers --server-response --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt https://localhost:8443/adminui/servlet/Logout  ");

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
  my $a=$ARGV[0];
  my $d=getdatetime();
#executeThis("/usr/bin/cat $a | sed 's/EPFG START TIME.*/EPFG START TIME $d-10:00/g' > tmp2.txt");

#executeThis("/usr/bin/cat tmp2.txt | sed 's/EPFG STOP TIME.*/EPFG STOP TIME $d-11:00/g' > tmp3.txt");

#executeThis("/usr/bin/cat tmp3.txt > $a");
#executeThis("/usr/bin/rm -rf tmp*");
#print "the date is changed";
#set_cfg();
#print "CFG files are changed";
  mkdir("$LOGPATH");
  #my $mem_left=getmemory_left();
  #my $mem_left=41; ####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ to bypass the mem check if no epfg data to be generated
  #if ($mem_left >40 && services_check()==0)
  #{
    ################################
  	#       Print Server details   #
	
	#print_server_details();
	
	################################
	my $report = getStartTimeHeader("OVERALL");
#  	$report.= "<h2>STARTTIME:";
#  	$report.= getTime();
#  	$report.= "<h2>HOST:\n";
	$report .= qq{<tr>
				<th> <font size = 2 > HOST </th>
				<td><font size = 2 ><b>};
	my $host= getHostName();
	$report .= "$host";
	$report .= "<tr>";
#  	$report.= getHostName()."</h2>";
#  	$report.= "<h2>VERSION:\n";
	$report.= qq{<tr>
				<th> <font size = 2 > VERSION </th>
				<td><font size = 2 ><b>};
  	my $version = verifyVersion();  #."</h2>";
	$report .= "$version";
	$report .= "<tr>";
  	my $tot_report.= parseParam();
	my $fail =()= $tot_report =~ /_FAIL_+/g;
	my $pass =()= $tot_report =~ /_PASS_+/g;
	$tot_report =~s/_PASS_/PASS/g;
	$tot_report =~s/_FAIL_/FAIL/g;
#  	$report.= "<h2>ENDTIME:";
#  	$report.= getTime()."</h2>";
	$report.= getEndTimeHeader_Overall($pass,$fail);
	$report .= $contents;
	$report.= $tot_report;
  	$report.= getHtmlTail(); 
  	#my $file = writeHtml($host,$report);

#unset_cfg();
#print "CFG files are rolled back\n";

print "\n-------------------------------------END-------------------------------------------------------\n";
#  	print efile;
		
  #}
 # else
  #{
   #	print "\n The Pre-requesit conditions for running RT are not satisfied!!";
   #	print "\n Either ENIQ Services not Online OR There is no sufficient memory in DB!!!!";
   #	print "\n Memory Left: $mem_left GB \n";
  #}
  #Divide_Techpacks();
}
###############

###############
sub startRegExp{
  my @tps1=@_;
  my $regexp="";
  for my $line (@tps1)
   {
     my $tp=$epfg_tps{$line};
	 if( defined $tp ) {
     $regexp.="^$tp"."StartTime=|"; 
	 #print "$line : $tp  :	$regexp\n";
	}					  
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
	if( $tp eq defined) {
		$regexp.="^$tp"."GenFlag=|"; 
	}
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
		my $tp = "";
     $tp=$epfg_tps{$line};
	 if( defined $tp ) {
		$regexp.="^$tp"."EndTime=|";
	 }
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
		my $tp = "";
		$tp = $epfg_tps{$line};
		if( defined $tp ) {
			$regexp.="^$tp"."NoOfNodes=|";
		}
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
	 my $tp = "";
     $tp = $epfg_tps{$line};
	 if( defined $tp ) {
		$regexp.="^$tp"."NoOfNeNodes=|";
	 }
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
    if( defined $tp ) {
		$regexp.="^$tp"."StartNode=|";
	}
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
	 if( defined $tp ) {
		$regexp.="^$tp"."EndNode=|";
	 }
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
  my @inputarray="";
  foreach $a (@tps)
{
	foreach $b ( keys %PmGenWhat )
		{
			if( $a eq $b )
				{
					push(@inputarray,@{$PmGenWhat{$b}});
				
				}
		}
}
  for my $tp (@inputarray)
   {
		$regexp.="^$tp"."GenWhat=|"; 
		
   }
  chop($regexp);
  return $regexp;
}
##########
##########
sub ConfigFileOutputPathRegExp{
  my @tps=@_;
  my $regexp="";
  for my $line (@tps)
   {
	my $tp = "";
     $tp=$epfg_tps{$line};
	if( defined $tp ) {	 
		$regexp.="^$tp"."ConfigFileOutputPath=|"; 
	}
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
	if( defined $tp ) {
		$regexp.="^$tp"."ConfigFile=|"; 
	}
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

my $pmTP="";
for my $line (@input) 
 {
  $_=$line;
  my $gen_type=GenWhatRegExp(@epfg_techPacks);
  #print "1. GenType : $gen_type\n";
  #my $flag=flagRegExp(@epfg_techPacks);
  #print "2. Flag : $flag\n";
  my $config_path=ConfigFileOutputPathRegExp(@epfg_techPacks);
  #print "3. Config Path : $config_path\n";
  if(/$gen_type/)
   {
     $line=~s/=.*/=/;
     print OUTPUT "$line$GEN_TYPE\n"; 
	 #print "GenType : $line$GEN_TYPE\n"; 
   }
    elsif(/GenFlag=/)
   {
		$pmTP=$line;
		$pmTP=~s/GenFlag=.*//;
		
		if ( grep { $_ eq $pmTP} @epfgTopoTPs )
		{
			$line=~s/=.*/=/;
			print OUTPUT "$line$FLAG\n";
			#print "PM TP : $pmTP $line$FLAG\n";
			$pmTP=undef;
		}
		else
		{
			 print OUTPUT "$line\n";
		}
   }
   elsif(/BCGCmdata=/)
   {
		if ( grep { $_ eq "Bcg"} @epfgTopoTPs)
		{
			$line=~s/=.*/=/;
			print OUTPUT "$line$FLAG\n";
		}
		else
		{
			 print OUTPUT "$line\n";
		}
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
	 #print "CONFIG: Param Name : $param_name\n Config Path : $con_path\n";
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
my $GEN_TYPE2="CM_FILE";
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
  print " \n  GEN type :: $gen_type1 \n ";
  
  if(/$gen_type1/)
   {
	if($line=~/BcgGenWhat=/)
	{
		$line=~s/=.*/=/;
		print OUTPUT1 "$line$GEN_TYPE2\n";
		}
	else
	{
     $line=~s/=.*/=/;
     print OUTPUT1 "$line$GEN_TYPE1\n"; 
	 #print "PM GenType : $line$GEN_TYPE1\n";
   }
   }
  #elsif(/$config_path1/)
   #{
	# print "PM Config Path : $config_path1\n\n";
     #if ($line=~m/(.*)=(.*)/)
	 # {
	  #  $key=$1;
		#print "PM Key : $key\n";
	    #old####$con_path=$2;
	  #}
     #$line=~s/=.*/=/;
	 #$hashed_result=$hash{$key};
     #print OUTPUT1 "$line$hashed_result\n"; 
	 #print "Hash Result : $line$hashed_result\n";
   #}
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
	   next if($data=~/SQL Anywhere Error /);
	   next if($data=~/Msg \d/);
	   next if($data=~/ Msg \d/);
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
   next if($tp=~/SQL Anywhere Error /);
   next if($tp=~/Msg \d/);
   next if($tp=~/ Msg \d/);
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
	   next if($data=~/SQL Anywhere Error /);
	   next if($data=~/Msg \d/);
	   next if($data=~/ Msg \d/);
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
##############################################################
###############################################################
sub Divide_Topology{
#my $host=getHostName();
#print "the host is:$host";
my @tpini=();
my $result=undef;
#my @rack=("atrcx1196","atclvm623","atrcx893","atrcx1298vm1","atrcx1298vm2","atrcx1298vm3","atrcx1299esx","atrcx1300vm1","atrcx1300vm2","atrcx1300vm3","atrcx1017","atrcx1328","atrcxb1641","atrcxb2953","atrcx1195","atrcx1057","atclvm570","atrcxb1466");
#my @blade=("atrcxb1867","atrcxb1310","atrcxb1309","atrcxb1308","atrcxb1360","atrcxb1335","atrcxb2286");
#if ( grep $_ eq $host, @rack )
#{
# print "this is rack\n";
# $result    = epfgloadTopology(); 
#} 
#elsif ( grep $_ eq $host, @blade )
#{
  #print "this is blade\n";
 #$result    = epfgloadTopology(); 
#}

#else
#{
  # print "not in the list\n";
  # $result=undef;
 #}
$result    = epfgloadTopology(); 
return $result;
print "the gentopo is : $result\n";

}

###############################################################
#this subroutine splits techpacks according to rack and blade##
###############################################################
sub Divide_Techpacks{
#print "Divide Techpacks..\n";
@tpini    = getAll_Techpacks();

#my $host=getHostName();
#print "the host is:$host";
#my @tpini=();
#my @rack=("atrcx1196","atclvm623","atrcx893","atrcx1298vm1","atrcx1298vm2","atrcx1298vm3","atrcx1299esx","atrcx1300vm1","atrcx1300vm2","atrcx1300vm3","atrcx1017","atrcx1328","atrcx1195","atrcx1057","atclvm570");
#my @blade=("atrcxb1867","atrcxb1310","atrcxb1309","atrcxb1308","atrcxb1360","atrcxb1335","atrcx1055","atrcxb2286");
#my @multiblade=("atrcxb1641","atrcxb2953","atrcxb1466");
#if ( grep $_ eq $host, @rack )
#{
# print "this is rack\n";
# @tpini    = getRackTechpacks(); 
#} 
#elsif ( grep $_ eq $host, @blade )
#{
#  print "this is blade\n";
# @tpini    = getBladeTechpacks(); 
#}
#elsif ( grep $_ eq $host, @multiblade )
#{
#  print "this is multiblade\n";
# @tpini    = getMultiBladeTechpacks(); 
#}
#else
#{
#   print "not in the list\n";
#   @tpini=();
# }
print "this is the list of techpacks : @tpini\n";
return @tpini;
}
###########################################################

sub DivideEpfg_Techpacks{
#my $host=getHostName();
my @epfg_techpacks=undef;
@epfg_techpacks    = getEpfgTechpacks();
#my @rack=("atrcx1196","atclvm623","atrcx893","atrcx1298vm1","atrcx1298vm2","atrcx1298vm3","atrcx1299esx","atrcx1300vm1","atrcx1300vm2","atrcx1300vm3","atrcx1017","atrcx1328","atrcx1195","atrcx1057","atclvm570");
#my @blade=("atrcxb1867","atrcxb1310","atrcxb1309","atrcxb1308","atrcxb1360","atrcxb1335","atrcxb2286");
#my @multiblade=("atrcxb1641","atrcxb2953","atrcxb1466");
#if ( grep $_ eq $host, @rack )
#{
#print "this is rack\n";
#@epfg_techpacks    = getRackepfg_Techpacks(); 
#} 
#elsif ( grep $_ eq $host, @blade )
#{
 # print "this is blade\n";
 #@epfg_techpacks    = getBladeepfg_Techpacks(); 
#}
#elsif ( grep $_ eq $host, @multiblade )
#{
 # print "this is blade\n";
 #@epfg_techpacks    = getMultiepfg_Techpacks(); 
#}
#else
#{
 #  print "not in the list\n";
 #  @epfg_techpacks=undef;
 #}
 print "this is list @epfg_techpacks\n";
return @epfg_techpacks;
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
) | telnet webserver
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
) | telnet webserver
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
#############################################################################################
#get columnnames from syscolumn corresponding to raw tables in systable for each techpack####
#############################################################################################
#############################################################################################
sub Counter_keys {
my $result="";
my $result_fail="";
my $emptyTables="";

my @tpList=undef;

if (@epfg_techPacks ne undef)
{
	my $tp="";
	my $substr="|";
	for my $tps (@epfg_techPacks)
	{
		$_=$tps;
		next if(/^$/);
		$tp=$epfgNodeTPs{$tps};
		next if($tp eq "");
		if (index($tp, $substr) != -1) {
			my @tpNames=split(/\|/,$tp);
			foreach my $j (@tpNames)
			{
				$_=$j;
				next if(/^$/);
				push @tpList, $j;  
			}
		}
		else {
			push @tpList, $tp;
		}
	}
	@tpList=uniqArr(@tpList);
}

if (@tpList eq undef)
{
	print "Retrieve list of TP's for Counter Key Verification.. (List not initialized)\n";
	@tpList = Divide_Techpacks();
}

foreach my $tp (@tpList)
{
	my $result1_fail = "";
	$_=$tp;
   next if(/^$/);
   print "Counter TP : $tp\n";
   $result.="<h3>$tp</h3><BR>\n";
   $result1_fail.="<h3>$tp</h3><BR>\n";
 
	my @emptytables=();
	my @tables=();
	@tables= getAllTables4TP($tp);
	foreach my $table (@tables)
    {
		
		my $result2_fail = "";
		if ($table ne "") 
		{
			$_=$table;
			next if(/^$/);
			next if(/ /);
			next if(/DISTINCT_DATES$/);
			next if(/affected/);
			next if($table=~/SQL Anywhere Error /);
			next if($table=~/Msg \d/);
			next if($table=~/ Msg \d/);
			next if(/_DAY/);
			next if(!/_RAW/);
			
			my $loading=getTableLoading($table);
			 
			 #print "No of Rows in the table($table): $loading\n";
			if ($loading!=0)
			{
				my @column=verifyTables($table);
				$result.="<h3>$table</h3><BR>\n";
				$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
							<tr>
							<th>Counters and Keys</th>
							<th>No. of Rows Loaded</th>
							<th>Result</th>					   
							</tr>
						};
				my $columnSize = @column;
				if ($columnSize > 0 ) {
																	
					my $appendColumns = "";
					my $tablename = "";
					my $columnsss="";
					my @columnList=undef;
					my $failCount=0;
					my $passcount=0;
					foreach my $column (@column)
					{
						if ( $column eq defined || $column ne "" )
						{
							my ($tab,$col)=split(':', $column);
							if ($tablename ne "") {
								if ( $tab ne $tablename."_DISTINCT_DATES" ) {
									if ( $tab eq $tablename) {
										push @columnList, $col;
									}
									my $size = @columnList;
									if ( $tab ne $tablename || $columnSize-1 == $size) {
										my $size = @columnList;
										my $size1 = 0;
										my $limitedSize = 0;
										for my $columnValues (@columnList) {
											$size1++;
											$limitedSize++;
											if( $columnValues eq defined || $columnValues ne "" ) {
												if( $size == $size1 || $limitedSize == 50) {
													$limitedSize =0;
													$appendColumns.= "'$columnValues'||'|'||COUNT($columnValues)";
													my @display=selectColumn($tablename,$appendColumns);
													my @noOfDatasLoaded=undef;
													foreach my $disp (@display)
													{	
														push @noOfDatasLoaded, split(':', $disp);
														foreach my $noOfDatas (@noOfDatasLoaded) {
															my $disp_fail = "";
															$_=$noOfDatas;  
															next if(/^$/);
															next if(/Msg 102, Level 15, State 0:/);
															next if($noOfDatas=~/SQL Anywhere Error /);
															next if($noOfDatas=~/Msg \d/);
															next if($noOfDatas=~/ Msg \d/);
															next if($noOfDatas=~/CT-LIBRARY\w*/);
															next if($noOfDatas=~/external error\w*/);		
															next if(/affected/);
															$noOfDatas=~ s/\t//g;
															$noOfDatas=~ s/\s//g;
															#print "the counter and no of rows are :$noOfDatas\n";
															$noOfDatas=~ s/\t//g;
															$noOfDatas=~ s/\s//g;
															$noOfDatas=~ s/^/<tr><td>/g;
															$noOfDatas=~ s/\|/<\/td><td align=center>/g;
															$noOfDatas=~ s/$/<\/td><td align=center>RESULT<\/td><tr>/g;
										#					$disp_fail=$noOfDatas;
															$_=$noOfDatas;
															
															if(/<td align=center>0<.td>/)
															{
																$failCount++;
																if( $failCount == 1 ) {
																	$result2_fail .= "<h3>$table</h3><BR>\n";
																	$result2_fail.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
																					<tr>
																					<th>Counters and Keys</th>
																					<th>No. of Rows Loaded</th>
																					<th>Result</th>					   
																					</tr>
																					};
																}
																$noOfDatas=~ s/RESULT/<font color=#660000><b>_FAIL_<\/b><\/font>/;
																$disp_fail= $noOfDatas;
																$disp_fail=~ s/RESULT/<font color=#660000><b>FAIL<\/b><\/font>/;
																#print "the counter is not loaded\n";
															}
															else #(/<td align=center>$numRops<.td>/)
															{
																$noOfDatas=~ s/RESULT/<font color=#006600><b>_PASS_<\/b><\/font>/;
																#print "the counter is  loaded\n";
															}
															if( $noOfDatas ne "") {
																$result.="$noOfDatas\n";
															}
															if ($disp_fail ne "") {
																$result2_fail .= "$disp_fail\n";
															}

														}
													}
													$appendColumns="";
												} else {
													$appendColumns.= "'$columnValues'||'|'||COUNT($columnValues)||':'||";
												}
											}
										}
										@columnList = undef;
										push @columnList, $col;
									}
								}
								
							} else {
								push @columnList, $col;
							}
							$tablename  = $tab;
							$columnsss = $col;
							#print "table: $tab and column : $col\n";
						}
					}
					$failCount=0;
					$passcount=0;
				}
				
				$result.="   </table>\n";
				$result2_fail.="   </table>\n";
								
				my $count=countDup_SUS($table);
				if($count!=0)
				{  	      
					$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
								<tr>
								<th>ROWSTATUS</th>
								<th>DATETIME_ID</th>
								<th>MOID</th>
								</tr>
								};
#					$result_fail.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >
#								<tr>
#								<th>ROWSTATUS</th>
#								<th>DATETIME_ID</th>
#								<th>MOID</th>
#								</tr>
#								};
					my @rowstats=getRowstatus($table);
					foreach my $row (@rowstats)
					{
						$row=~ s/\t//g;
						$row=~ s/\s//g;
						$row=~ s/^/<tr><td>/g;
						$row=~ s/\|/<\/td><td>/g;
						$row=~ s/$/<\/td><tr>/g;
						$result.= "$row\n";
#						$result_fail.= "$row\n";
						#print "the row is :$row";
					}
					$result.="</table>";
#					$result_fail.="</table>";
				}
				else
				{
					$result.="<h3>No duplicate or suspected rows for the table $table<h3>";
#					$result_fail.="<h3>No duplicate or suspected rows for the table $table<h3>";
				}				
			}
			else
			{
				push (@emptytables,$table) ;
			}
		}
	$result1_fail .= $result2_fail;
	
	}
    my  $tabsize=scalar @tables;
	my  $emptyarr=scalar @emptytables;
	my $emptyTablessize = @emptytables;
    if ($emptyTablessize > 0 ) {
		$result.=qq{<table border="0"><tr><th>List of empty tables </th></tr></table>};	    
		$result.="<br>\n";
		$result.= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" >};

		$result.= join("", map { "<tr><td>${_}</td></tr>" } @emptytables);

		$result.="</table>";
		$emptyTables.=qq{<table border="0"><tr><th>List of empty tables </th></tr></table>};	    
		$emptyTables.="<br>\n";
		$emptyTables.= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" >};

		$emptyTables.= join("", map { "<tr><td>${_}</td></tr>" } @emptytables);

		$emptyTables.="</table>"; 
	}
	my $fail =()= $result1_fail =~ /_FAIL_+/g;
	if ($fail != 0)
	{
		$result_fail .= $result1_fail;
		$result_fail =~s/_FAIL_/FAIL/g;
	}
}
 return $result,$result_fail,$emptyTables;
 }
sub selectColumn{
my $date  = $DATETIMEWARP;
my($table,$column)=@_;
my $sql="select $column as COUNT from $table where CONVERT(CHAR(8),DATE_ID,112) = '$date'";
my ($dat) = executeSQL("dwhdb",2640,"dc",$sql,"ROW");
#print "selectColumn - SQL : $sql	--	RES	:	$dat\n";
return $dat;
}
# GETS ALL THE TABLES FOR CERTAIN TECHPACK FROM DWHDB
# this is a utility subroutine
# queries the database to check the loading 
# the input parameter is a table name
sub getTableLoading{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();
my $sql="select COUNT(*) from $table where CONVERT(CHAR(8),DATE_ID,112) = '$date'"; 
my ($dat)=executeSQL("dwhdb",2640,"dc",$sql,"ROW");
#print "GetTableLoading SQL : $sql	-	Res : $dat\n";
return $dat;
}
sub getRowstatus{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();
my $sql=qq{
select ROWSTATUS||'|'||DATETIME_ID||'|'||MOID 
from $table          
where CONVERT(CHAR(8),DATE_ID,112) = '$date'
and rowstatus='DUPLICATE' or rowstatus='SUSPECTED'
ORDER BY MOID,DATETIME_ID;
go
EOF
};
#print "getRowstatus - SQL	:	$sql\n";

 my @result=undef;
 open(DATA,"$sybase_dir -Udc -P$dcDbPassword -h0 -Ddwhdb -Sdwhdb -w 50 -b << EOF $sql |");
 my @data=<DATA>;
 chomp(@data);
 close(DATA);
 foreach my $data (@data)
 {
   $_=$data;
   next if(/affected/);
   next if($data=~/SQL Anywhere Error /);
   next if($data=~/Msg \d/);
   next if($data=~/ Msg \d/);
   next if($data=~/^CT-LIBRARY\w*/);
	next if($data=~/external error\w*/);		
   $data=~ s/\t//g;
   $data=~ s/\s//g;
   push @result,$data;
   }
 return @result;
}

##################################################
#select count(*) when rowstatus is duplicate or suspected
######################################################
sub countDup_SUS{
my $table = shift;
my $date  = $DATETIMEWARP;###getDateTimewarp();

my $sql="select count(*) from $table where CONVERT(CHAR(8),DATE_ID,112) = '$date' and rowstatus='DUPLICATE'or rowstatus='SUSPECTED'";
my ($dat)=executeSQL("dwhdb",2640,"dc",$sql,"ROW");
#print "CountDup SQL : $sql	-	Res : $dat\n";

return $dat;

}
###################################################################################################
sub dataid_dataname{
 my $result="";
 
my @tpList=undef;
if (@epfg_techPacks!=undef)
{
	my $tp="";
	my $substr="|";
	for my $tps (@epfg_techPacks)
	{
		$_=$tps;
		next if(/^$/);
		$tp=$epfgNodeTPs{$tps};
		next if($tp eq "");
		if (index($tp, $substr) != -1) {
			my @tpNames=split(/\|/,$tp);
			foreach my $j (@tpNames)
			{
				$_=$j;
				next if(/^$/);
				push @tpList, $j;  
			}
		}
		else {
			push @tpList, $tp;
		}
	}
	@tpList=uniqArr(@tpList);
}
 
 if (@tpList==undef)
{
	print "Retrieve list of TP's for Data ID/Name Verification.. (List not initialized)\n";
	@tpList = Divide_Techpacks();
}
 
 #print "\nTP LIST : \n\n";
 foreach my $tp_name (@tpList)
{
    $_=$tp_name;
   next if(/^$/);
   print "TP : $tp_name\n";
   $result.="<h3><font color=006600><b>DATAFOMAT CHECK FOR $tp_name TECHPACK TABLES</b></font><h3>";
my (@tp_dataformatid,
	@tp_dataname,
#	@tp_dataname,
	@tp_dataid,
	@tp_dataname_StrLen,
	@tp_dataid_StrLen);	
	
	my $sql_Tpactivation = qq{
select VERSIONID from dwhrep.TPActivation WHERE TECHPACK_NAME = '$tp_name';
go
EOF
};
	open(TP_VERSION,"$sybase_dir -Udwhrep -Pdwhrep -h0 -Drepdb -Srepdb -w 500 -b << EOF $sql_Tpactivation |")|| die $!;
	my @tp_name_version = <TP_VERSION>;
	chomp(@tp_name_version);
	close(TP_VERSION);
		
	#print "tp_version is :@tp_name_version\n";
	#$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" ><tr>\n<td><font color=800000>ACTIVE TP_VERSION</font></td><td><font colour=0000A0><b>$tp_name_version[0]</b></font></td>\n</tr></table>};
	$result.="<br>&nbsp;</br>";
	
foreach my $tp_name_version (@tp_name_version)
	{
		#print "TP Version : $tp_name_version\n";
			$tp_name_version =~ s/[ ]//g;
			$tp_name_version =~ s/^[ ]//g;
			next if($tp_name_version=~/SQL Anywhere Error /);
			next if($tp_name_version=~/Msg \d/);
			next if($tp_name_version=~/ Msg \d/);
		if($tp_name_version =~ /^DC_E_.*:.*/)
		{
		 @tp_dataformatid = getDataFormatID($tp_name_version);
		 foreach my $tp_dataformatid (@tp_dataformatid)
				{	
					#print "TP DataFormatID : $tp_dataformatid\n";
					my (@tp_dataname_temp_result,@tp_dataid_temp_result);
					
					$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" ><tr>\n<th>$tp_dataformatid</th></tr></table>\n};
                    $result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="70%" >};
					
					$result.="\n<tr><td>DataName</td><td>DataName length</td><td>DataID</td><td>DataID Length</td><td>Status</td><td>Result</td></tr>\n";
					my ($tp_dataname,
						$tp_dataid,
						$tp_dataname_StrLen,
						$tp_dataid_StrLen) = getDataFormat($tp_dataformatid);
					@tp_dataname = @$tp_dataname;
					@tp_dataid = @$tp_dataid;
					@tp_dataname_StrLen = @$tp_dataname_StrLen;
					@tp_dataid_StrLen = @$tp_dataid_StrLen;
					
					if ( $tp_dataformatid =~ /^DC_E_BSS:.*/ || $tp_dataformatid =~ /^DC_E_CNAXE:.*/ )
					{   
						#print "The dataformatd is $tp_dataformatid";
						for (my $h = 0 ; $h <= $#tp_dataname;$h++)
						{
							if($tp_dataname[$h] =~ /.*\_.*/ && $tp_dataid[$h] =~ /.*\_.*/)
							{
								push @tp_dataname_temp_result,$tp_dataname[$h];
								push @tp_dataid_temp_result,$tp_dataid[$h];
								
							}
							else
							{ 
								if($tp_dataname[$h] =~/^CLEGPRSULQ\_\d+\w+$/ || $tp_dataname[$h] =~/^CLPSULSS\_\d+\w+$/)
								{								
									my $temp_str = $tp_dataname[$h];
									$temp_str =~ s/.*_//g;
									$temp_str =~ s/^/A/g;
									push @tp_dataname_temp_result,$temp_str;
									push @tp_dataid_temp_result,$tp_dataid[$h];
								}						
								else	
								{
									my $temp_str = $tp_dataname[$h];
									$temp_str =~ s/.*_//g;
									push @tp_dataname_temp_result,$temp_str;
									push @tp_dataid_temp_result,$tp_dataid[$h];
								}
							}					
						}
					}
					elsif($tp_dataformatid =~ /^DC_E_CUDB:.*/)
					{   
						#print "The dataformatd is $tp_dataformatid";
						for (my $h = 0 ; $h <= $#tp_dataname;$h++)
							{
								if($tp_dataid[$h] =~ /.*\..*/ && $tp_dataname[$h] =~ /.*\..*/)
								{
									push @tp_dataname_temp_result,$tp_dataname[$h];
									push @tp_dataid_temp_result,$tp_dataid[$h];
									
								}
								else
								{
									my $temp_str = $tp_dataid[$h];
									$temp_str =~ s/\..*//g;
									$temp_str =~ s/\#//g;
									push @tp_dataid_temp_result,$temp_str;
									push @tp_dataname_temp_result,$tp_dataname[$h];
								}					
							}
					}
						elsif($tp_dataformatid =~ /^DC_E_SASN:.*/ || $tp_dataformatid =~ /^DC_E_SGSN:.*/)
								{
									for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
											if($tp_dataid[$h] =~ /\_.*\_.*/ && $tp_dataname[$h] =~ /.*\_.*/)
											{
												push @tp_dataname_temp_result,$tp_dataname[$h];
												push @tp_dataid_temp_result,$tp_dataid[$h];
												
											}
											else
											{
												my $temp_str = $tp_dataid[$h];
												$temp_str =~ s/\-/\_/g;
												$temp_str =~ s/\./\_/g;
												$temp_str =~ s/\_/\_/g;
												$temp_str =~ s/\%//g;
												
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
											}					
										}
								}
								elsif($tp_dataformatid =~ /^DC_E_SAPC:.*/)
								{
								    #print "the techpack is $tp_name and the dataformat id is $tp_dataformatid\n";
									for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
												my $temp_str = $tp_dataid[$h];
												#print "dataid is $temp_str";
												$temp_str =~ s/\./\_/g;
												$temp_str =~ s/\_/\_/g;
												#print "changeddataid is $temp_str";
												
												
											    push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
															
										}
								}
								
								elsif( $tp_dataformatid =~ /^DC_E_HSS:.*/)
								{
									for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
											if($tp_dataid[$h] =~ /^tsp\..*/ && $tp_dataname[$h] =~ /^tsp\_.*/)
											{
												
												my $temp_str = $tp_dataid[$h];
											
												$temp_str =~ s/\./\_/g;
												$temp_str =~ s/\_/\_/g;
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											else
											{
												push @tp_dataname_temp_result,$tp_dataname[$h];
												push @tp_dataid_temp_result,$tp_dataid[$h];
												
												
											}					
										}
								}
											elsif($tp_dataformatid =~ /^DC_E_MTAS:.*/ )
								{
									for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
											if($tp_dataid[$h] =~ /^tsp\..*/ && $tp_dataname[$h] =~ /^tsp\_.*/)
											{
												
												my $temp_str = $tp_dataid[$h];
											
												$temp_str =~ s/\./\_/g;
												$temp_str =~ s/\_/\_/g;
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
												elsif($tp_dataid[$h] =~ /^SN\..*$/)
											{
												
												my $temp_str = $tp_dataid[$h];
											      if($temp_str=~/^SN\.DC$/)
												  {
												  $temp_str =~ s/SN\./MTAS\_/g;
												  
												  }
												  
												else{
												$temp_str =~ s/SN\.//g;
												}
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											
											else
											{
												push @tp_dataname_temp_result,$tp_dataname[$h];
												push @tp_dataid_temp_result,$tp_dataid[$h];
												
												
											}					
										}
								}
								
									elsif( $tp_dataformatid =~ /^DC_E_IMS:.*/)
								{
									for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
											if($tp_dataid[$h] =~ /^tsp\..*/ && $tp_dataname[$h] =~ /^tsp\_.*/)
											{
												
												my $temp_str = $tp_dataid[$h];
											
												$temp_str =~ s/\./\_/g;
												$temp_str =~ s/\_/\_/g;
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											elsif($tp_dataid[$h] =~ /^.*\.actual$/ )
											{
												my $temp_str = $tp_dataid[$h];
												$temp_str =~ s/\.actual//g;
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											elsif($tp_dataid[$h] =~ /^SN\..*$/)
											{
												
												my $temp_str = $tp_dataid[$h];
											      if($temp_str=~/^SN\.DC$/)
												  {
												  $temp_str =~ s/SN\./IMS\_/;
												  
												  }
												  
												else{
												$temp_str =~ s/SN\.//g;
												}
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											elsif($tp_dataid[$h] =~ /^.*\.m.*$/ )
											{    
											  
												my $temp_str = $tp_dataid[$h];
												$temp_str =~ s/\.m/M/g;
												
												push @tp_dataid_temp_result,$temp_str;
												push @tp_dataname_temp_result,$tp_dataname[$h];
												
												
											}
											else
											{
												push @tp_dataname_temp_result,$tp_dataname[$h];
												push @tp_dataid_temp_result,$tp_dataid[$h];
											}											
											
										}
								}
						
								
							else
							{
								for (my $h = 0 ; $h <= $#tp_dataname;$h++)
										{
												push @tp_dataname_temp_result,$tp_dataname[$h];
												push @tp_dataid_temp_result,$tp_dataid[$h];
										}
							}
					if($#tp_dataname == $#tp_dataid)
						{
							for (my $i = 0 ; $i <= $#tp_dataname ; $i++)
							{
								print "Dataname : $tp_dataname[$i] - DataID : $tp_dataid[$i]\n";
								my $temp_length_Dataname = length("$tp_dataname[$i]");
								my $temp_length_DataID = length("$tp_dataid[$i]");
								my $temp_length_DataName_result = length("$tp_dataname_temp_result[$i]");
								my $temp_length_DataID_result = length("$tp_dataid_temp_result[$i]");
								
								    $tp_dataid_temp_result[$i]=~s/^MOID\..*//;
								
							
								
								
								if($tp_dataname_temp_result[$i] eq $tp_dataid_temp_result[$i] && $tp_dataname_StrLen[$i] == $temp_length_Dataname && $tp_dataid_StrLen[$i] == $temp_length_DataID && $temp_length_DataName_result == $temp_length_DataID_result)
									{
										###print "$tp_dataname[$i],$temp_length_Dataname,$tp_dataname_StrLen[$i],$tp_dataid[$i],$temp_length_DataID,$tp_dataid_StrLen[$i],MATCHED,PASSED\n";
										$result.="<tr>\n<td>$tp_dataname[$i]</td><td>$temp_length_Dataname</td><td>$tp_dataid[$i]</td><td>$temp_length_DataID</td><td><font color=006600>MATCHED</font></td><td><font color=006600>PASSED</font></td>\n</tr>\n";
									}
								
								else
									{
											my ($flag);
													for (my $k = $i+1 ; $k <= $#tp_dataid ; $k++)
															{	
																if ( $tp_dataid[$i] eq $tp_dataid[$k])
																{	
																	$flag = 1;
																	if ($flag == 1)
																	{
																		if($tp_dataname_temp_result[$i] eq $tp_dataid_temp_result[$i] && $tp_dataname_temp_result[$k] ne $tp_dataid_temp_result[$k]) 
																		{
																		print "$tp_dataname[$k],$temp_length_Dataname,$tp_dataname_StrLen[$i],$tp_dataid[$k],$temp_length_DataID,$tp_dataid_StrLen[$i],DUPLICATE,FAILED\n";
																		$result.="<tr>\n<td>$tp_dataname[$i]</td><td>$temp_length_Dataname</td><td><td>$tp_dataid[$i]</td><td>$temp_length_DataID</td><td><font color=0000FF><b>DUPLICATE</b></font></td><td><font color=0000FF><b>FAILED</b></font></td>\n</tr>\n";
																		last;
																		}
																		if($tp_dataname_temp_result[$k] eq $tp_dataid_temp_result[$k] && $tp_dataname_temp_result[$i] ne $tp_dataid_temp_result[$i])
																		{
																		print "$tp_dataname[$i] ,$temp_length_Dataname,$tp_dataname_StrLen[$i], $tp_dataid[$i] ,$temp_length_DataID,$tp_dataid_StrLen[$i], DUPLICATE ,FAILED\n";
																		$result.="<tr>\n<td>$tp_dataname[$i]</td><td>$temp_length_Dataname</td><td>$tp_dataid[$i]</td><td>$temp_length_DataID</td><td><font color=0000FF><b>DUPLICATE</b></font></td><td><font color=0000FF><b>FAILED</b></font></td>\n</tr>\n";
																		last;
																		}
																	}
																}
															}																								
										if($flag != 1)
										{
										print "$tp_dataname[$i],$temp_length_Dataname,$tp_dataname_StrLen[$i], $tp_dataid[$i],$temp_length_DataID,$tp_dataid_StrLen[$i], NOT MATCHED ,FAILED\n";
										$result.="<tr>\n<td>$tp_dataname[$i]</td><td>$temp_length_Dataname</td><td>$tp_dataid[$i]</td><td>$temp_length_DataID</td><td><font color=ff0000>NOT MATCHED</font></td><td><font color=ff0000><b>FAILED</b></font></td>\n</tr>\n";
										}
									}
									
								
							}
							$result.="<br>&nbsp;</br>";
						}
					else
						{
							print "List of Elements in TP_DATANAME is `($#tp_dataname + 1)` not matched with List of Elements in TP_DATANAME is `($#tp_dataid + 1)`\n";
						 $result.="<br>&nbsp;</br>";
						 $result.="<h3><font color=ff0000><b>List of Elements in TP_DATANAME is `($#tp_dataname + 1)` not matched with List of Elements in TP_DATANAME is `($#tp_dataid + 1)`</b></h3>";
						 $result.="<br>&nbsp;</br>";
						}
						$result.= "</table>";
						
				}
		}
	}
	
}	
return $result;
}	

sub getDataFormatID
{
my $dataformatid = shift;
my @tp_DataFormatID_result;
my $sql_DataFormat = qq{
select DATAFORMATID from dwhrep.DataFormat WHERE VERSIONID = '$dataformatid';
go
EOF
};
    open(DataFormatID,"$sybase_dir -Udwhrep -Pdwhrep -h0 -Drepdb -Srepdb -w 500 -b << EOF $sql_DataFormat |")|| die $!;
	
	my @tp_DataFormatID = <DataFormatID>;
	chomp(@tp_DataFormatID);
	close(DataFormatID);
	
	foreach my $t (@tp_DataFormatID)
  {
    $_=$t;
    next if(/affected/);
	next if($t=~/SQL Anywhere Error /);
	next if($t=~/Msg \d/);
	next if($t=~/ Msg \d/);
    next if(/^$/);
 	$t =~ s/\t//g;
    $t =~ s/\s//g;
    $t =~ s/ //g;
	$t =~ s/^\s+//g;
	push @tp_DataFormatID_result,$t;
  } 
	return @tp_DataFormatID_result;
}


sub getDataFormat{

my $temp_dataformatid = shift;
my (@allDataName,@allDataid,@allDataName_StrLen,@allDataid_StrLen);
#print "\nTEMP_DATAFORMATID IS $temp_dataformatid\n";
my (@allDataName_result,@allDataid_result); #@allDataName,@allDataid

my $sql_DataItem_DataName = qq{
select DATANAME from dwhrep.DataItem where DATAFORMATID like '$temp_dataformatid' and PROCESS_INSTRUCTION in ('PEG','GAUGE', 'CM_VECTOR','VECTOR','','key') order by COLNUMBER;
go
EOF
};

my $sql_DataItem_DataId = qq{
select DATAID from dwhrep.DataItem where DATAFORMATID like '$temp_dataformatid' and PROCESS_INSTRUCTION in ('PEG','GAUGE', 'CM_VECTOR','VECTOR','','key') order by COLNUMBER;
go
EOF
};

my $sql_DataName_stringlength = qq{
select datalength(DATANAME) from dwhrep.DataItem where DATAFORMATID like '$temp_dataformatid' and PROCESS_INSTRUCTION in ('PEG','GAUGE', 'CM_VECTOR','VECTOR','','key') order by COLNUMBER;
go
EOF
};

my $sql_DataId_stringlength = qq{
select datalength(DATAID) from dwhrep.DataItem where DATAFORMATID like '$temp_dataformatid' and PROCESS_INSTRUCTION in ('PEG','GAUGE', 'CM_VECTOR','VECTOR','','key') order by COLNUMBER;
go
EOF
};

	@allDataName = GetDataformat_repdb($sql_DataItem_DataName);
	@allDataid = GetDataformat_repdb($sql_DataItem_DataId);
	@allDataName_StrLen = GetDataformat_repdb($sql_DataName_stringlength);
	@allDataid_StrLen = GetDataformat_repdb($sql_DataId_stringlength);
	
	return (\@allDataName,\@allDataid,\@allDataName_StrLen,\@allDataid_StrLen);
}

 sub GetDataformat_repdb{
 
   my $sql = shift;
   my (@allTemp,@allTemp_result);
	open(ALLTemp,"$sybase_dir -Udwhrep -Pdwhrep -h0 -Drepdb -Srepdb -w 500 -b << EOF $sql |")|| die $!;
	@allTemp=<ALLTemp>;
	chomp(@allTemp);
	close(ALLTemp);
	
	foreach my $m (@allTemp)
  {	
    $_=$m;
	next if(/affected/);
	next if($m=~/SQL Anywhere Error /);
	next if($m=~/Msg \d/);
	next if($m=~/ Msg \d/);
    next if(/^$/);
    $m =~ s/\t//g;
    $m =~ s/\s//g;
    $m =~ s/ //g;
	$m =~ s/^\s+//g;
    push @allTemp_result,$m;	
  }
	return (@allTemp_result);
 }
 
################################################################################################### 
#################################################################
sub getInputCsv{
my $i=shift;
$_=$i;
my $file=undef;
my @FILE_LIST=undef;

if(/lte|rbs|rxi|rnc/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/wran/$i/$i*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
if(/sgsn/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/sgsn_3gpp/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}



if(/sgsnmme/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/sgsnmme_3gpp/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}




elsif(/ggsn/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/ggsn_classic*";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
elsif(/pgw/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/ggsnpgw*";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
elsif(/sgw/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/ggsnsgw*";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
elsif(/Node/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/ggsnNode*";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
elsif(/mbm_sgw/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/epgmbmsgw*";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}

elsif(/cpg|edgerouter|mlppp|sebgf|smartmetro/)
{
  @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/redback/$i/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
  #print $file;
}
elsif(/WCDMA_COMMON/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/PRBS/$i/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];

}
elsif(/LTElte_COMMON/)
{
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/PRBS/$i/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];

}
elsif(/bsc_iog|bsc_apg|msc_apg|msc_iog|stn_Tcu|stn_pico|stn_siu/)
{
 my ($a,$b)=split('_',$i);
 @FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$a/$b/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
}
else
{
@FILE_LIST = glob "/eniq/home/dcuser/epfg/config/$i/*.csv";
 $file = $FILE_LIST[$#FILE_LIST];
 # print $file;
   
}
###print "the file is $file\n";
 return $file;

}
sub CSVDATA
{
my $a=shift;
print "the node is $a\n";
$_=$a;
my $filelist = getInputCsv($a);
my $tagcolumn=undef;
my $datacolumn=undef;
my $groupname=undef;
my %hashcsv=();
my %hashcsv1=();
my %dupcheck=();
my @tagid=undef;
my @dataids=undef;
my @asn=undef;
my $lineCount;
my %desiredColumns;
my %columnContents;
my $colCount;
my @group=undef;
my $ASN=undef;

my @files=split(',',$filelist);

for my $file(@files)
{
open(F, $file) or die "Unable to open $file: $!\n";

$lineCount = 0;
%dupcheck=();
%desiredColumns=();
%columnContents=();
@tagid=undef;
@dataids=undef;
@asn=undef;
$tagcolumn=undef;
$datacolumn=undef;
$groupname=undef;
$ASN=undef;
 @group=undef;

while(<F>) {
  $lineCount++;
  my $csv = Text::CSV->new();
  my $status = $csv->parse($_); # should really check this!
  my @fields = $csv->fields();
  $colCount = 0;
  
  if ($lineCount == 1) {
    # Let's look at the column headings.
for (my $i=0;$i<=$#fields;$i++) {
      $colCount++;
      if ($i==0) {
        # This heading matches, save the column #.
        $tagcolumn=$colCount;
		$desiredColumns{$tagcolumn} = 1;
		 ##print "the column containing tagid is:$tagcolumn\n";
		}
	  if($i==$#fields){
	     # This heading matches, save the column #.
         $datacolumn=$colCount;
		 $desiredColumns{$datacolumn} = 1;
		 ##print "the column containing tagid is:$datacolumn\n";
		 }
		  if($i==2){
	     # This heading matches, save the column #.
         $groupname=$colCount;
		 $desiredColumns{$groupname} = 1;
		 ##print "the column containing tagid is:$datacolumn\n";
		 }
		 if($fields[$i]=~/^Select.*Counters.*/i)
		{
	     # This heading matches, save the column #.
         $ASN=$colCount;
		 $desiredColumns{$ASN} = 1;
		 ##print "the column containing tagid is:$datacolumn\n";
		 }
		 
	 }
    }
  else {
	
    #next if(/^#/);
    # Not the header row.  Parse the body of the file.
    foreach my $field (@fields) {
      $colCount++;
      if (exists $desiredColumns{$colCount}) {
        # This is one of the desired columns.
        # Do whatever you want to do with this column!
        push(@{$columnContents{$colCount}}, $field);
      }
    }
  }
}
close(F);

my $key;
foreach my $key (sort keys %columnContents) {
	if ($key==$tagcolumn){
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	next if(/^$/);
	push(@tagid,$i);
	#print "tagids are:@tagid\n";
	}
  }
  if ($key==$datacolumn){
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	next if(/^$/);
	
	push(@dataids,$i);
	#print "dataids are:@dataids\n";
	}
  }
  if ($key==$ASN)
  {
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	next if(/^$/);
	
	push(@asn,$i);
	#print "dataids are:@dataids\n";
	}
  }
  if ($key==$groupname){
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	next if(/^$/);
	
	push(@group,$i);
	#print "dataids are:@group\n";
	}

}
}
if($a=~/^sgsn.*/){
print "for sgsn\n";
for (my $i =0; $i < $#tagid; $i++) 
 {  
    $_=$tagid[$i];
	next if (/^$/);
	$tagid[$i]=~s/\s+//g;
	my $string="$tagid[$i]".","."$group[$i]";
	###print "the string is $string\n";
	$dupcheck{$string}=$asn[$i];
  
 }
 }
 elsif($a=~/^ggsn.*/)
{
for (my $i =0; $i < $#tagid; $i++) 
 {
 if (index($tagid[$i], ".")==-1){
 $dupcheck{ $tagid[$i] }=$dataids[$i];
 }
 else{
    my @array=split('.',$tagid[$i]);
    $dupcheck{ $array[$#array] }=$dataids[$i]
	
   }
}
}
elsif($a=~/^hss.*/)
{
 for (my $i =0; $i < $#tagid; $i++) 
 {
 my $s=undef;
 $tagid[$i]=~s/\s+//g;
 if ($tagid[$i]=~/^.*Counters$/i)
 {
   if($tagid[$i]=~/^Diameter.*Counters$/i)
   {
    $tagid[$i]=~s/Counters/_counters/gi
   
   }
   elsif($tagid[$i]=~/^IP.*Counters$/i)
   {
    $tagid[$i]=~s/Counters/_MeassurementJob/gi;
   
   
   }
   elsif($tagid[$i]=~/^SS7.*Counters$/i)
   {
     $tagid[$i]=~s/Counters/Statistics/gi;
   }

	elsif($tagid[$i]=~/^Login.*Counters$/i)
   {
     $tagid[$i]=~s/^Login.*Counters/tspLoginFailureMonitorMJ/gi;
   }
   
	elsif($tagid[$i]=~/^PlatformMeasures.*Counters$/i)
   {
     $tagid[$i]=~s/Counters//gi;
   }
   else{
   $tagid[$i]=~s/Counters//gi;
   $tagid[$i]=~s/^/HSS-/gi;
   }
 }
 
 elsif($tagid[$i]=~/^OamProvisioning.*/){
 $tagid[$i]=~s///g;
 }
 elsif($tagid[$i]=~/^CUDB.*/){
 $tagid[$i]=~s/\s+//g;
 
 }
 else{
 $tagid[$i]=~s/^/HSS-/gi;
 }
 $dupcheck{ $tagid[$i] }=$dataids[$i];
 
 }

}

elsif($a=~/^sapc.*/)
{
 for (my $i =0; $i < $#tagid; $i++) 
 {
 my $s=undef;
 $tagid[$i]=~s/\s+//g;
 if ($tagid[$i]=~/^.*Counters$/i)
 {
   if($tagid[$i]=~/^Diameter.*Counters$/i)
   {
    $tagid[$i]=~s/Counters/_counters/gi
   
   }
   elsif($tagid[$i]=~/^IP.*Counters$/i)
   {
    $tagid[$i]=~s/Counters/_MeassurementJob/gi;
   
   
   }
  elsif($tagid[$i]=~/^Login.*Counters$/i)
   {
     $tagid[$i]=~s/^Login.*Counters/tspLoginFailureMonitorMJ/gi;
   }
   
  elsif($tagid[$i]=~/^SAPC.*Counters$/i){
   $tagid[$i]=~s/Counters//gi;
   $tagid[$i]=~s/^SAPC/Sapc/gi;
   }
   $dupcheck{ $tagid[$i] }=$dataids[$i];
 }
 else{
 $dupcheck{ $tagid[$i] }=$dataids[$i]
}
}
}
elsif($a=~/^cpg.*/ || $a=~/^edgerouter.*/ ||$a=~/^mlppp.*/ || $a=~/^sebgf.*/ ||$a=~/^smartmetro.*/)
{
  for (my $i =0; $i < $#dataids; $i++) 
 {  
    $tagid[$i]=~s/\s+//g;
    $tagid[$i]=~s/^/PM_policy_/gi;
    $dupcheck{ $tagid[$i] }=$dataids[$i];
}
}
elsif($a=~/^bsc.*/ || $a=~/^msc.*/ || $a=~/^sasn_sara$/) {

  for (my $i =0; $i < $#asn; $i++) 
 {
	$dupcheck{ $tagid[$i] }=$asn[$i];
	
 }
}

elsif ($a=~/^ims$/){

  for (my $i =0; $i < $#tagid; $i++) 
 {
	
	if($tagid[$i]=~/^EAS_TRAFFIC$/)
	{
	  $tagid[$i]=~s/EAS_//gi;
	  $dupcheck{ $tagid[$i] }=$dataids[$i];
	}
	elsif($tagid[$i]=~/^Aggregation_Proxy$/)
	{
	  $tagid[$i]=~s/_//gi;
	  $dupcheck{ $tagid[$i] }=$dataids[$i];
	}
	
	else{

	$dupcheck{ $tagid[$i] }=$dataids[$i];
	}
 }
}

elsif ($a=~/^sasn$/){

  for (my $i =0; $i < $#asn; $i++) 
 {
	$tagid[$i]=~s/^oss-//g;
	if($tagid[$i]=~/.*content-filter.*/ || $tagid[$i]=~/.*umc-mk.*/)
	{
	  $dupcheck{ $tagid[$i] }=$asn[$i];
	}
	else{
	my @array=split('-',$tagid[$i]);
	$dupcheck{$array[0]}=$asn[$i];
	}
 }
}

 else{
   for (my $i =0; $i < $#dataids; $i++) 
 {
	$dupcheck{ $tagid[$i] }=$dataids[$i];
	
 }
 }

 for my $k (sort keys %dupcheck) {
 
  push @{ $hashcsv1{$k} },$dupcheck{$k}; 
  
  
}
print " the csvdata is ......";
 for my $k (sort keys %hashcsv1) {
 my $s=join ';', @{ $hashcsv1{$k} };
  #printf "%s => %s\n", $k, join ';', @{ $hashcsv1{$k} };
  $hashcsv{$k}=$s;
 }
} 
 
 return (\%hashcsv);
 
 }
 sub getTableCounters_FromCsv
 {
  my $a=shift;
  $_=$a;
  my $tp= "DC_E_"."$a";
  my $sel_statement=undef;
if($a=~/^rbs$/||$a=~/^rxi$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'$tp%'or TECHPACK_NAME like '%DC_E_CPP%'))";
}
elsif($a=~/^lte$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_ERBS%'or TECHPACK_NAME like 'DC_E_CPP%'))";
}
elsif($a=~/^cscf$/||$a=~/^mrfc/||$a=~/^ims$/){
 $sel_statement =  "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like 'DC_E_IMS'))";
}
elsif($a=~/^LTElte_COMMON$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_PRBS_CPP' or TECHPACK_NAME ='DC_E_PRBS_ERBS'))";
}
elsif($a=~/^WCDMA_COMMON$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_PRBS_CPP' or TECHPACK_NAME ='DC_E_PRBS_RBS'))";
}
elsif($a=~/^sbg$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_IMSGW_SBG'))";
}
elsif($a=~/^ipworks$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR','key')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_IMS_IPW'))";
}
elsif($a=~/^edgerouter$/||$a=~/^mlppp$/||$a=~/^smartmetro$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_REDB'))";
}
elsif($a=~/^tdrnc$/||$a=~/^tdrbs$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_CPP' OR TECHPACK_NAME ='$tp'))";
}
elsif($a=~/^cpg$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='||DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME ='DC_E_REDB' or TECHPACK_NAME like '$tp%'))";
}
elsif($a=~/^rnc$/){
 $sel_statement =  "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID 
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_RAN%' or TECHPACK_NAME like 'DC_E_CPP%'))";
}
elsif($a=~/^mgw$/){
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID 
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'$tp' or TECHPACK_NAME like 'DC_E_BULK_CM'))";
}
elsif($a=~/^sgsn$/||$a=~/^sgsnmme$/)
{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_SGSN'))";
}
elsif($a=~/^ggsn$/||$a=~/^pgw$/||$a=~/^sgw$/||$a=~/^Node$/||$a=~/^mbm_sgw$/)
{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_GGSN'))";
}
elsif($a=~/^bsc_iog$/||$a=~/^bsc_apg$/)
{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_BSS' OR TECHPACK_NAME like 'DC_E_CMN_STS'))";
}
elsif($a=~/^stn_pico$/||$a=~/^stn_siu$/ ||$a=~/^stn_Tcu$/)
{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_STN'))";
}
elsif($a=~/^msc_iog$/||$a=~/^msc_apg$/)
{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'DC_E_CNAXE' OR TECHPACK_NAME like 'DC_E_CMN_STS'))";
}
else{
 $sel_statement = "select SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||'='|| DefaultTags.TAGID, SUBSTR(DefaultTags.DATAFORMATID,CHARINDEX(')',DefaultTags.DATAFORMATID)+3)||';'||DataItem.DATAID||'&'||DataItem.DATANAME||'='||DataItem.PROCESS_INSTRUCTION||'#'||DATASCALE
from DefaultTags,DataItem where DefaultTags.DATAFORMATID = DataItem.DATAFORMATID and DataItem.PROCESS_INSTRUCTION in (
'PEG', 'GAUGE', 'VECTOR','CMVECTOR')
and DataItem.DATAFORMATID in
(
select DATAFORMATID from DataItem  where
 SUBSTR(DATAFORMATID,0,CHARINDEX(')',DATAFORMATID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME like
'$tp'))";
}
#print "SQL:	$sel_statement\n";
my ($test1,$test2) = &db_query( $sel_statement );
my %hash_table = %$test1;
my %hash_counters = %$test2;
my $test3=CSVDATA($a);
my %hashcsv=%$test3;
my @list=sort keys %hash_table;
my %tstring=();
my %tstring1=();
my @list1=sort keys %hashcsv;
my @missedtags=undef;
my %hash_final=();
my %hash_temp=();
my %hash_temp1=();
foreach my $key (sort keys %hashcsv)
{
   my @array=split(';',$hashcsv{$key});
   
   for my $i(@array)
   {
    $_=$i;
	next if (/^$/);
	next if(/^.*\(IPADDR\)$/);
	next if(/^.*\(STRING\)$/i);
    next if(/^.*:string.*/i);
	 next if(/^.*:class$/i);
	next if(/^.*\(.*:null:null\)$/);
	next if (/^.*\(string:.*:.*\)$/);
	next if (/^PID\(.*:.*:.*\)$/);
    next if (/^ID\d+$/);
    next if (/^start_time$/);
	next if (/^start_time:.*/);
	next if (/^port:int$/);
	next if (/^slot:int$/);
	next if (/^ipworksDhcpv4Name$/);
	$i=~s/\s+//g;
    if(/^.*\(\d+\)$/)
	{  print "the vec1:$i\n";
		$i=~s/\(\d+\)//g;
		my $key1="$key"."_V";
       
	   push @{ $tstring{$key1} }, $i;

	}
	
	 elsif(/^.*:Counter64$/)
	{  
		$i=~s/:Counter64//g;
	   push @{ $tstring{$key} }, $i;

	}

	elsif(/^.*\(^N.*\)$/)
	{  print "the vec1:$i\n";
		$i=~s/\(^N.*\)//g;
		my $key1="$key"."_V";
       
	   push @{ $tstring{$key1} }, $i;

	}
	 elsif(/^.*\(.*:.*:.*\)$/)
	{  
		$i=~s/\(.*:.*:.*\)//g;
	   push @{ $tstring{$key} }, $i;

	}
	elsif(/^.*_Sbg.*\(.*\)$/i)
	{  
		$i=~s/_Sbg.*\(.*\)//g;
	   push @{ $tstring{$key} }, $i;

	}
	elsif(/^.*-.*\(laLoadInt\)/i)
	{ 
	  $i=~s/\(laLoadInt\)//g;
	 push @{ $tstring{$key} }, $i;  
	}
	elsif(/^.*:int$/i)
	{ 
	  $i=~s/:int//g;
	 push @{ $tstring{$key} }, $i;  
	}
	elsif(/^.*:gauge$/i)
	{
	  $i=~s/:gauge//gi;
	 push @{ $tstring{$key} }, $i;  
	}
	elsif(/^.*\(INT\)$/)
	{  print "the ggsn:$i\n";
		$i=~s/\(INT\)//g;
	    print "the ggsnmod:$i\n";
       
	   push @{ $tstring{$key} }, $i;

	}
 	elsif(/^.*\(uinteger\)$/)
	{  
		$i=~s/\(uinteger\)//g;
	   
       
	   push @{ $tstring{$key} }, $i;

	}
	elsif($i=~/^.*\[.*\]$/)
	{  $i=~s/\[.*\]//g;
	   my $key1="$key"."_V";
	   push @{ $tstring{$key1} }, $i;
   	}
   else
   {
   push @{ $tstring{$key} }, $i;	
   }
  }
}

for my $k (sort keys %tstring) {

   my $s=join ',',uniq(@{ $tstring{$k} });
  #printf "%s => %s\n", $k, join ',', uniq(@{ $tstring{$k} });
  $tstring1{$k}=$s;


}

 my %bschash=();
  my %hashbsc=();
 if($a=~/^bsc.*/){

 foreach my $key (keys %hash_table)
 {
  my $value=$hash_table{$key};
 push @{ $bschash{$value} }, $key;
 
 }
  foreach my $key (keys %bschash)
 {
  my $value1=$bschash{$key};
  my @value=@$value1;
  my $s=join(',',@value);
  $s=~s/^,//;
  $s=~s/,$//;
  $hashbsc{$key}=$s;
 
 }

 }
 
 foreach my $key (sort keys %tstring1) 
 {
	$_=$key;
	next if (/^$/);
	$key=~s/\s+//g;
	my $v=$tstring1{$key};
	my @value=();
	@value=split(',',$v);
	 
		 if (exists $hash_table{$key}){
		 my $v1=$hash_table{$key};
		 #my $v2=$hashbsc{$key};
		 
		 $_=$v1;
		        if($a=~/^bsc.*/){ 
				   my $v2=$hashbsc{$v1};
					my @bmsctab=("DC_E_BSS_MOMCTR:eniqasn1","DC_E_BSS_ASSOCIATION:eniqasn1","DC_E_BSS_CELL_ADJ:eniqasn1","DC_E_BSS_CELL_UTRAN_ADJ:eniqasn1");
					my @bmsctag=("CLEGPRSULQ","SUPERCH");
					if (index($v2, ",") == -1 && (grep {$_ ne $key} @bmsctag) && (grep {$_ ne $v1} @bmsctab))
				                 {
								   $hash_temp{$v}=$v1;
				
								 }
					 else{ 
							my $s1=undef;
						    my @finalvalues=();
							foreach my $i (@value)
							{   $_=$i;
							    next if (/^$/);
								my $string="$key"."_"."$i"; 
								push (@finalvalues,$string);
					
							}		   
								my $finalstring=join ',',@finalvalues;
								$hash_temp{$finalstring}=$v1;
							}
                }				
				else{
				$hash_temp{$v}=$v1;
		         }		 
		 }
		 else
		 {
		   push(@missedtags,$key);
		 }
		 
		 
	}
	foreach my $key (sort keys %hash_temp) 
 {
 
    my $value=$hash_temp{$key};
	push (@{$hash_temp1{$value}},$key);
	
  }
  	foreach my $key (sort keys %hash_temp1) 
 {
    my $s=join ',', @{ $hash_temp1{$key} };
   $hash_final{$key}=$s;
  }
	
	###print "hash ..................";
 foreach my $key (sort keys %hash_final) 
 {
	$_=$hash_final{$key};
	next if (/^$/);
	###print  "$key->$hash_final{$key}\n";	 
	}
return(\%hash_final, \%hash_counters,@missedtags);
}
####Prepare query excute and retun hashes tagid->Dataformatid,and counter->table
sub db_query {
    my $sel = shift;
    my %hash=();
	my %hash1=();
	my %hash2=();
	my @raw=undef;
	my @insert=undef;
	my @tags=undef;
	
	###print "REPDB SQL : $sel\n";
	my $res=executeSQL("repdb",2641,"dwhrep",$sel,"ALL");
	for my $rows ( @$res ) {
		#print "RES  TAG : @$rows[0]	-  INSERT : @$rows[1]\n";
		push(@tags,@$rows[0]);
		push(@insert,@$rows[1]);
	}
	
	##print "Hash Data......\n";
 foreach my $key (  sort keys %hash)
 { 
	$_=$key;
	$hash{$key}=~s/:.*/_RAW/;  
 }
 my %data;

foreach my $i (  @insert){
  $_=$i;
  next if(/^$/);
  my ($k, $v) = split(';',$i);
  push @{ $data{$k} }, $v;
}
my %final;
#print " the repdb :::\n";
for my $k (sort keys %data) {
 
  my $s=join ',', @{ $data{$k} };
 #printf "%s => %s\n", $k, join ',', @{ $data{$k} };
  $final{$k}=$s;
  
}
#print " the tags and tables\n";
foreach my $i (  @tags){
  $_=$i;
  next if(/^$/);
  my ($v, $k) = split('=',$i);
  push @{ $hash1{$k} }, $v;
}

foreach my $k (sort keys %hash1) {
my $s= join(',', uniq1(@{ $hash1{$k}})) . "\n";
  $hash2{$k}=$s; 
  #print "after uniq\n";
  #printf "%s => %s\n", $k, join ',', uniq1(@{ $hash1{$k}}) ;
}
   
    return(\%hash2, \%final); 
}

 sub uniq1 {
    return keys %{{ map { $_ => 1 } @_ }};
} 

  sub uniq { 
    return keys %{{ map { $_ => 1 } @_ }};
}

sub uniq2 {
	return keys %{{ map { $_ => 1 } @_ }};
}

sub uniqArr {
    my %seen;
    grep !$seen{$_}++, @_;
}


sub modify{
	my $a=shift;
	my ($test1,$test2,@test3) =getTableCounters_FromCsv($a);
	my %tstring = %$test1;
	my %hash_counters = %$test2;

	my @array=undef;
	my @arraysort=undef;
	my @new=undef;
	my @C_value=undef;
	my %finalstring=();
	my %hash=();
	#my @list=undef;
	my %missedcounter=();
	foreach my $key2 (sort keys %tstring)
	{

		#print "the table:$key2\n";
		$_=$tstring{$key2};
		next if(/^$/);

		#print "the value:$tstring{$key2}\n";

		##print "$key ->$tstring{$key}\n";
		my $v=$tstring{$key2};

		my @value=split(',',$v);
		##print "the hash_counter\n";
		if ($key2=~/^DC_E_BULK_CM_.*,DC_E_MGW_.*/ || $key2 =~/^DC_E_MGW_.*,DC_E_BULK_CM_.*/)
		{
			my $missed_bulk=''; 
			my @missedarr=undef;
			my @vmgw=split(',',$key2);
			foreach my $key (sort @vmgw)
			{ 
				my %final=();
				my %temp=();
				my %temp1=();
				if (exists $hash_counters{$key}){
					##print "$key\n";
					my $v1= $hash_counters{$key};

					my @value1=split(',',$v1);
					foreach my $v2 (@value1)
					{
						$_=$v2;
						next if(/^$/);
						my ($k, $v3) = split('&',$v2);
						push @{ $temp{$k} }, $v3;

					}
					for my $k (sort keys %temp) {

						my $s=join ',', @{ $temp{$k} };
						#printf "%s => %s\n", $k, join ',', @{ $temp{$k} };
						$final{$k}=$s;

					}
					my @finalvalue=undef;
					if ($missed_bulk eq '')
					{
						print "the 1st key mgw \n";
						@finalvalue=split(',',$v);
					}
					else
					{
						@finalvalue=split(',',$missed_bulk);
					}
					foreach my $i (@finalvalue)
					{

						$_=$i;
						next if (/^$/);		
						if (exists $final{$i}){
							my $p = lc($final{$i});
							#my $j="$p"."="."$temp{$i}";

							###DEBUG###print "the p=$p\n";
							push(@{$temp1{$key}}, $p);
						}
						else { 
							push @missedarr,$i;
						} 
					}
				}  

				foreach my $key(sort keys %temp1)
				{
					my $j=join(",", sort @{$temp1{$key}});
					$finalstring{$key}=$j;
				}
			}
			my $arr=join (',',@missedarr); 
			$missed_bulk="$missed_bulk".","."$arr";
			$missed_bulk=~s/,,/,/g;
		}
		else{
			#print "i am in else\n";
			#print "the key : $key2\n";

			my @vmgw=split(',',$key2);
			foreach my $key (sort @vmgw)
			{
				my %final=();
				my %temp=();
				my %temp1=();
				$_=$key;
				next if (/^$/);	  
				if (exists $hash_counters{$key}){
					##print "$key\n";
					my $v1= $hash_counters{$key};
					my @value1=split(',',$v1);
					foreach my $v2 (@value1)
					{
						$_=$v2;
						next if(/^$/);
						my ($k, $v3) = split('&',$v2);
						push @{ $temp{$k} }, $v3;

					}
					for my $k (sort keys %temp) {

						my $s=join ',', @{ $temp{$k} };
						#printf "%s => %s\n", $k, join ',', @{ $temp{$k} };
						$final{$k}=$s;

					}

					#@list=sort keys %temp;
					foreach my $i (@value)
					{
						if (exists $final{$i}){
							my $p = lc($final{$i});
							#my $j="$p"."="."$temp{$i}";

							###DEBUG###print "the p=$p\n";
							push(@{$temp1{$key}}, $p);
						}
						else{ 
							push (@{$missedcounter{$key}},$i);
						}
					} 
				}
				foreach my $key(sort keys %temp1)
				{
					my @arr=sort @{$temp1{$key}};
					my $j= join(',', uniq2(@arr));
					$finalstring{$key}=$j;
				}
			}
		}

	}
	
	my %finalstring1=();
	foreach my $key (sort keys %finalstring)
	{
		my $k=$key;
		my @arr=undef;
		my $s= $finalstring{$key};
		###print "temp $key ==> $finalstring{$key}\n";
		$k=~s/:.*/_RAW/;
		push(@{$finalstring1{$k}},$s );
	}
	my %finalstring2=();

	foreach my $key (sort keys %finalstring1)
	{
		###print "semi $key ==> $finalstring1{$key}\n";
		 my $s=join(',',@{$finalstring1{$key}});
		 
		 my @arr=split(',',$s);
		 my $j= join(',', uniq2(@arr)) . "\n";
		 ###print "j==$j\n";
		 $finalstring2{$key}=$j;
	 }
	###print "the final string\n";
	my %sql=();
	foreach my $key( sort keys %finalstring2)
	{
		my @arr=undef;
		###print "final $key ==> $finalstring2{$key}\n";
		my $i=$finalstring2{$key};
		my @array=split(',',$i);
		my $modval;
		foreach my $j( sort @array){
			$j=~s/=.*//g;
			push (@arr,$j);
		}	 
		$modval=join(',',@arr);
		$sql{$key}=$modval;
	}
	return(\%finalstring2,\%sql,\%missedcounter); 
}


#modify();
#get the final DataStructure in the sameformat as DB
sub finalDatastructure{
my $a=shift;
my %DBhash=();
my %hash1=();
my %hash2=();
my %hash3=();
my %hash4=();
my ($test1,$test2,$test3) =modify($a);
my %tablestring = %$test1;

foreach my $key (sort keys %tablestring) {
	
	     
	    
	    my $v=$tablestring{$key};
	
		
		  my @value=split(',',$v);
			foreach my $v1 (@value)
			{	
			 next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			
			  if($v1=~/=PEG#0/i)
			  {
			   $v1=~s/PEG#0/1/gi;
			   ##print " the couner:$v1\n";
			
               }
			    elsif($v1=~/=PEG#8/i)
			  {
			   $v1=~s/PEG#8/1.0000/gi;
			   ##print " the couner:$v1\n";
			
               }
			   
			   elsif($v1=~/=GAUGE#8/i)
			   {
			   $v1=~s/=GAUGE#8/=1.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#4/i)
			   {
			   $v1=~s/=GAUGE#4/=1.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#0/i)
			   {
			   $v1=~s/=GAUGE#0/=1/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=VECTOR#8/i)
			   {
			   $v1=~s/=VECTOR#8/=1.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=VECTOR#0/i)
			   {
			   $v1=~s/=VECTOR#0/=1/gi;
			    ##print " the couner:$v1\n";
               }
			  elsif($v1=~/=CMVECTOR#8/i)
			   {
			   $v1=~s/=CMVECTOR#8/=1.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=CMVECTOR#0/i)
			   {
			   $v1=~s/=CMVECTOR#0/=1/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
		  my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash1{$key}=$modval;
	      
	}
	
	foreach my $key (sort keys %tablestring) {
	
	
	    
	    my $v=$tablestring{$key};
	
		 $_=$v;
		 
		  my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG#0/i)
			  {
			   $v1=~s/PEG#0/2/gi;
			   ##print " the couner:$v1\n";
			
               }
			   elsif($v1=~/=PEG#8/i)
			  {
			   $v1=~s/PEG#8/2.0000/gi;
			   ##print " the couner:$v1\n";
			
               }
			   
			   elsif($v1=~/=GAUGE#8/i)
			   {
			   $v1=~s/=GAUGE#8/=2.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#4/i)
			   {
			   $v1=~s/=GAUGE#4/=2.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#0/i)
			   {
			   $v1=~s/=GAUGE#0/=2/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=VECTOR#8/i)
			   {
			   $v1=~s/=VECTOR#8/=2.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=VECTOR#0/i)
			   {
			   $v1=~s/=VECTOR#0/=2/gi;
			    ##print " the couner:$v1\n";
               }
			  elsif($v1=~/=CMVECTOR#8/i)
			   {
			   $v1=~s/=CMVECTOR#8/=2.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=CMVECTOR#0/i)
			   {
			   $v1=~s/=CMVECTOR#0/=2/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash2{$key}=$modval;
	      
	}
	foreach my $key (sort keys %tablestring) {
	
	
	    
	    my $v=$tablestring{$key};
	
		
		  my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG#0/i)
			  {
			   $v1=~s/PEG#0/3/gi;
			   ##print " the couner:$v1\n";
			
               }
			     elsif($v1=~/=PEG#8/i)
			  {
			   $v1=~s/PEG#8/3.0000/gi;
			   ##print " the couner:$v1\n";
			
               }
			   
			   elsif($v1=~/=GAUGE#8/i)
			   {
			   $v1=~s/=GAUGE#8/=3.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#4/i)
			   {
			   $v1=~s/=GAUGE#4/=3.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#0/i)
			   {
			   $v1=~s/=GAUGE#0/=3/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=VECTOR#8/i)
			   {
			   $v1=~s/=VECTOR#8/=3.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=VECTOR#0/i)
			   {
			   $v1=~s/=VECTOR#0/=3/gi;
			    ##print " the couner:$v1\n";
               }
			  elsif($v1=~/=CMVECTOR#8/i)
			   {
			   $v1=~s/=CMVECTOR#8/=3.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=CMVECTOR#0/i)
			   {
			   $v1=~s/=CMVECTOR#0/=3/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
	

		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash3{$key}=$modval;
	      
	}
	foreach my $key (sort keys %tablestring) {
	
	
	    
	    my $v=$tablestring{$key};
	
		
		  my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG#0/i)
			  {
			   $v1=~s/PEG#0/4/gi;
			   ##print " the couner:$v1\n";
			
               }
			    elsif($v1=~/=PEG#8/i)
			  {
			   $v1=~s/PEG#8/4.0000/gi;
			   ##print " the couner:$v1\n";
			
               }
			   
			   elsif($v1=~/=GAUGE#8/i)
			   {
			   $v1=~s/=GAUGE#8/=4.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#4/i)
			   {
			   $v1=~s/=GAUGE#4/=4.0000/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=GAUGE#0/i)
			   {
			   $v1=~s/=GAUGE#0/=4/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=VECTOR#8/i)
			   {
			   $v1=~s/=VECTOR#8/=4.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=VECTOR#0/i)
			   {
			   $v1=~s/=VECTOR#0/=4/gi;
			    ##print " the couner:$v1\n";
               }
			  elsif($v1=~/=CMVECTOR#8/i)
			   {
			   $v1=~s/=CMVECTOR#8/=4.0000/gi;
			    ##print " the couner:$v1\n";
               }
			    elsif($v1=~/=CMVECTOR#0/i)
			   {
			   $v1=~s/=CMVECTOR#0/=4/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
	

		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash4{$key}=$modval;
	      
	}
	$DBhash{"00"} = \%hash1;
	$DBhash{"15"} = \%hash2;
	$DBhash{"30"} = \%hash3;
	$DBhash{"45"} = \%hash4;
	
	###print "the dbhash\n";
	###foreach my $key (sort keys %DBhash) {
	#print $key . " : " . %DBhash->{$key} . "\n";
	 
	
	###foreach my $k (sort keys %{ $DBhash{$key} }) {
		###print $key . "-" .  $k . "=>" . %{$DBhash{$key}}->{$k} . "\n"; 
	###}
	###}
return \%DBhash;
 }
 
#get the final sql
sub getsql{
        my $a=shift;
	my ($test1,$test2,$test3) =modify($a);
	my %hash_counters = %$test2;
	my %tstring=();
	my %hash=();
	my @SQL_FILES_LIST = ();
	my $TMP_FILE;
	#my @array=undef;
	#my @arraysort=undef;
	#my $Stringsql=undef;
	my $sql=undef;
	###print "the hash for sql\n";
	$_=$a;
my $sn=undef;
if(/rbs|rxi/)
{
$sn="SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1"."$a"."1";
}
if(/lte/)
{
$sn="SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1"."ERBS"."1";

}
if(/rnc/)
{
$sn="SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1";
}
if(/sgsn/)
{
$sn="SGSN01";
}
if(/sgsnmme/)
{
$sn="SGSNM01";
}
if(/cpg/)
{
$sn="CPG01";
}
if(/edgerouter/)
{
$sn="EdgeRtr01";
}
if(/mlppp/)
{
$sn="MLPPP01";
}
if(/smartmetro/)
{
$sn="SmartMetro01";
}
if(/bsc_apg/)
{
$sn="BAA01";
}
if(/bsc_iog/)
{
$sn="BIE01";
}
if(/msc_iog/)
{
$sn="MIE001";
}
if(/msc_apg/)
{
$sn="MAA01";
}
if(/stn_Tcu/)
{
$sn="STN-TCU-A001";

}
if(/stn_pico/)
{
$sn="STN-PICO-A001";

}
if(/stn_siu/)
{
$sn="STN-SIU-A001";

}

if(/mrfc/)
{
$sn="MRFC01";
}
if(/cscf/)
{
$sn="CSCF01";
}
if(/ims/)
{
$sn="IMS01";
}

if(/ipworks/)
{
$sn="IPWk01";
}

if(/sbg/)
{
$sn="ISSBG01";
}
if(/sgw|pgw|Node|mbm_sgw/)
{
$sn="ManagedElement"."="."GGSN01";
}
if(/ggsn/)
{
$sn="SubNetwork=ONRM_ROOT_MO,SubNetwork"."="."NetSim303_GGSN,ManagedElement=GGSN01";
}
	foreach my $key (sort keys %hash_counters)
	{
		###print "$key =>$hash_counters{$key}\n";
		my $date=$DATETIMEWARP;
		my $sql=undef;
        if($key=~/DC_E_RAN_.*_V_RAW|DC_E_RBS_.*_V_RAW|DC_E_PRBS_.*_V_RAW/i)
		{
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_SGSN_.*_RAW/i)
		{
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and SGSN='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_REDB_.*_RAW/i)
		{
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and NE_NAME='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_BSS_.*_RAW|DC_E_CNAXE_.*_RAW/i)
		{
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and SN='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		
		elsif($key=~/DC_E_IMS_.*_RAW/i)
		{     
	            next if ($key=~/^DC_E_IMS_IPW_.*/i);	
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and g3ManagedElement='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		
		elsif($key=~/DC_E_IMS_IPW_.*_RAW/i)
		{
	            	
	        $sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and NE_NAME='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		
		elsif($key=~/DC_E_IMSBG_.*_RAW/i)
		{
	            	
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and NE_ID='$sn' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif ($key=~/DC_E_CPP_.*_RAW/i)
		{  $_=$key;
		    if(/DC_E_CPP_.*_V_RAW/)
			
			{
			print "the cpp vector table :$key";
			$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='$sn' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};}
			else
			{
			print "the cpp normal table :$key";
			$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='$sn' and rowstatus='LOADED' };
			
			}
			
		}
		elsif ($key=~/DC_E_STN_.*_RAW/i){
			$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date' and NE_NAME='$sn' and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_GGSN_.*_RAW/i)
		{
			$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED' and NEDN='$sn' };
		}
		else{
			if ($key ne "")
			{
				$sql=qq{select MIN_ID $hash_counters{$key} from $key where HOUR_ID=10 and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
			}
			else
			{
				print "Table $key empty..\n";
			}
		}
		$hash{$key}=$sql;
	}
	
	my @SQLFILES = glob "sql*txt";
	unlink @SQLFILES;
	
	my $count=undef;
	my $cnt = 0;
	my $hsize = keys %hash;
	my $fsize=50;
	my $init=0;
	print "Number of Keys in Hash : $hsize\n";
	if ( $hsize > $fsize ) {
		my @list=sort keys %hash;
		print "Hash Size : " . scalar @list . "\n";
		my $div = ($hsize / $fsize);
		my $mod = ($hsize % $fsize);
		if (index($div, ".") != -1) {
			$count = substr($div, 0, index($div, "."));
			my $tmp = substr($div, (index($div, ".")+1), length($div));
			if ( $tmp > 0 ) {
				$count = $count+1;
			}
			
			my $j;
			for($j=1;$j<=$count;$j++)
	        {
		        $TMP_FILE = "sql"."$a"."$j".".txt";
				
				if ( $j==$count ) {
					$fsize = $hsize;
				}
				
				open(EDT,"> $TMP_FILE");
				
				my $k;
				for($k=$init;$k<$fsize;$k++)
				{
					###print $list[$k] . "=>" . $hash{$list[$k]} . "\n";
					#print "$key =>$hash{$key}\n";
 
					print EDT $list[$k] . ":" . $hash{$list[$k]} . "\n";
					#print EDT "$key:$hash{$key}\n";
				}
				close(EDT);
				$fsize=$fsize+50;
				$init=$k;
				$SQL_FILES_LIST[$cnt]=$TMP_FILE;
				$cnt = $cnt+1;
				print "$TMP_FILE file created..\n";
				#print "Mis : $fsize : $init : $cnt : $j : $k\n";
			}
		}
	}
	else
	{
		$TMP_FILE = "sql"."$a"."1.txt";
		print "$TMP_FILE file created..\n";
		open(EDT,"> $TMP_FILE");
		foreach my $key (sort keys %hash)
		{
			###print "$key =>$hash{$key}\n";

			print EDT "$key:$hash{$key}\n";
		}
		close(EDT);
		$SQL_FILES_LIST[$cnt]=$TMP_FILE;
	}

return @SQL_FILES_LIST;
}


sub readDBFile
{
	
	my $linenumber;
	my %DBhash;
	my %rowHash1;
	my %rowHash2; 
	my %rowHash3;
	my %rowHash4;
	my %rowHash5;
	my $val='';
	my $hashID = '';

	my @DB_FILES_LIST = glob "DB_XML*";
	
	foreach my $DB_FILE (@DB_FILES_LIST) {
		print "DBFile : $DB_FILE\n";
		my @lines = read_file($DB_FILE);
		$linenumber = 0;
	
		foreach (@lines) {
			$linenumber++;
			$val = '';
			if(($linenumber > 2) && ($linenumber < $#lines)) { 	  
				$_ =~ s/[\/><]//g;
				my @fields = split " " , $_;
				my $key = $fields[0];    
		
				for my $data (1..$#fields) {
					$fields[$data] =~ s/[\"]//g;
					if (index($fields[$data], "min_id") != -1) {
						my @t = split "=",$fields[$data];
						$hashID = $t[1];
						
					}
					else {
						if ($val eq '') {
							$val = $fields[$data];
						}
						else {
							$val = $val . "," . $fields[$data];
						}
					}
				}
			if ($hashID eq "0") {
				$rowHash1{$key} = $val;
			}
			elsif ($hashID eq "15") {
				$rowHash2{$key} = $val;
			}
			elsif ($hashID eq "30") {
				$rowHash3{$key} = $val;
			}
			elsif ($hashID eq "45") {
				$rowHash4{$key} = $val;
			}
			elsif ($hashID eq '') {
			
			   print "the hashID is $hashID\n";
				$rowHash5{$key} = $val;
			}
			}
		}
		
		$DBhash{"00"} = \%rowHash1;
		$DBhash{"15"} = \%rowHash2;
		$DBhash{"30"} = \%rowHash3;
		$DBhash{"45"} = \%rowHash4;
	}
	return (\%DBhash,\%rowHash5);
}

sub parse
{
        my($line) = @_;
        my @list = split ",",$line;
        my %hash = ();

        foreach my $data (@list) {
                my @sublist = split "=",$data;
				my $cntr = $sublist[1];
				if (index($cntr, ".") != -1) {
					$cntr = substr($cntr, 0, index($cntr,".")+2);
				}
                $hash{$sublist[0]} = $cntr;
        }

        return %hash;
}


sub compareHash
{
        my($h1,$h2)= @_;

        my %csvhash = %$h1;
        my %dbhash = %$h2;
        my $diff = '';
        my $cnt=0;

        while ( (my $key,my $value) = each %csvhash ) {
                if (! exists($dbhash{$key}) ) {
                        if ($diff eq '') {
                                $diff = "$key=$value,";
                        } else {
                                $diff = $diff . ":" . "$key=$value,";
                        }
                }
		else {
			my $dbValue = %dbhash->{$key};
                	if ($value ne $dbValue) {
                        	if ($diff eq '') {
                                	$diff = "$key=$value,$key=$dbValue";
                        	} else {
                                	$diff = $diff . ":" . "$key=$value,$key=$dbValue";
                        	}
			}
                }
        }
        return $diff;
}

sub compare {
	my($h1,$h2)= @_;

        my %csvhash = %$h1;
        my %dbhash = %$h2;
	my %res = ();
	
	foreach my $rop (sort keys %csvhash) {
                while ((my $table, my $csvCounter) = each %{$csvhash{$rop}}) {
			if (! exists($dbhash{$rop}{$table}) ) {
				$res{"$rop-$table"} = ''; 
			}
			else {
				#print "\t\tCSV HASH : " . $csvCounter . "\n";
				#print "\t\tDB HASH : " . $dbhash{$rop}{$table} . "\n";
		
				my %csvCounterHash = parse($csvCounter);
				my %dbCounterHash = parse($dbhash{$rop}{$table});

				my $mismatch = compareHash(\%csvCounterHash,\%dbCounterHash);
				if ( $mismatch ne '' ) {
					$res{"$rop-$table"} = $mismatch;
				}
			}
                }
                print "\n\n";
        }
	return %res;
}
#####################################################################################
sub loading
{
			my $a=shift;
			my $result="";
			my @SQL_FILE_LIST =getsql($a);
			my ($test1,$test2,$test3) =modify($a);
			my %missedcounters=%$test3;
			my @missedtags=();
			($test1,$test2,@missedtags)=getTableCounters_FromCsv($a);
			my ($cHash) = finalDatastructure($a);
			my %CSV_HASH = %$cHash;

			my @DB_XML_FILES = glob "DB_XML*";
			unlink @DB_XML_FILES;

			foreach my $SQL_FILE (@SQL_FILE_LIST) 
			{
				print "SQL_FILE LIST : $SQL_FILE\n";
				###To Debug the generated sql query file 
				###my $tmp=$SQL_FILE . "bkp";
				###my $t=executeThis("cp $SQL_FILE $tmp");	
				system("perl readDB.t $SQL_FILE");
			}
			($test1,$test2)=readDBFile();
			my %DB_HASH=%$test1;
			my %result=compare(\%CSV_HASH,\%DB_HASH);

			### DEBUG
			#while ((my $tab, my $mis) = each %result) 
			#{
			#	print "Data Validation Res : $tab : $mis\n";
			#}

			$result.="<br><br>\n";
			if (!%result && !%missedcounters && $#missedtags==0)
			{
				$result.=qq{<td><font color=green ; size = 4> <center> <b> PASS  </b></td></tr></table> <br>};
			}

			else
			{	
				$result.=qq{<td><font color=red ; size = 4 > <center> <b> FAIL  </b></td></tr></table> <br>	};
			my $count=undef;
			my $countempty = (grep { /^$/ } values(%result));
			$count=$countempty- scalar(values(%result));
			print $count;
			if ($#missedtags > 0)
			{
				
				my $rowspan = scalar @missedtags;
				#$rowspan=$rowspan-1;
				shift @missedtags;
				$result.=qq{<table  BORDER="3" CELLSPACING="0" CELLPADDING="3" WIDTH="50%" > <tr><td> <b> <font color=MidnightBlue ; size = 2 > <center> List of tagids missed </b> </td> <td> <center> };	
				$result.= "".join("", map { "${_}," } @missedtags)."";
				$result.="</td></tr></table>";
			}


			if (%missedcounters)
			{	
				$result.=qq{<br> <font color=MidnightBlue ; size = 2 > <center> <b> List of Counters not implemented in their respective tables </b><br>};
			
				foreach my $key (keys %missedcounters)
				{  	
					my $value=$missedcounters{$key};
					my @value1=sort @$value;
					my $rowspan = scalar @value1;
					$rowspan=$rowspan-1;
					$result.=qq{<table align="left" BORDER="3" CELLSPACING="0" CELLPADDING="1" WIDTH="50%" > <tr><td>  <b> <font color=MidnightBlue ; size = 2 > <center> $key  <b> </td><td> <center>};	
					$result.= "".join("", map { "${_}," } @value1)."<tr>";
					$result.="</td></tr></table>";
				}
			}	


		 if(%result)
		{
			$result.="<br><br>\n";
			$result.=qq{<table border="0"><tr><th> <font color=MidnightBlue ; size = 2 > Tables with no data for entire Rop </th></tr></table>};
			$result.="<br>";
			my %hash1=();
			my %hash2=();
			my %hash3=();
			my %hash4=();
				  
				  
			foreach my $key (keys %result)
			{	 
				if ($key=~/^00-.*$/)
				{ 
				$hash1{$key}=$result{$key}
				};
				if ($key=~/^15-.*$/)
				{ 
				$hash2{$key}=$result{$key}
				};
				if ($key=~/^30-.*$/)
				{ 
				$hash3{$key}=$result{$key}
				};
				if ($key=~/^45-.*$/)
				{
				$hash4{$key}=$result{$key}
				};
			}
				   
			my @hasharray=undef;
			push(@hasharray,\%hash1);
			push(@hasharray,\%hash2);
			push(@hasharray,\%hash3);
			push(@hasharray,\%hash4);
			my %hash=();
			foreach my $j (sort @hasharray)
			{
				$_=$j;
				next if(/^$/);
				print " the hash $j";
				my $hashref=$j;
				%hash =%{$hashref};

				#my $min=~s/=.*$//g;
				if(%hash)
				{
					my @min = grep { $_ =~ /^.*-DC_.*$/ } keys %hash;
					my ($m,$t)=split('-',$min[0]);
					$result.="<br>\n";
					my @arrayemp=undef;
					foreach my $key (keys %hash)
					{
						$_=$hash{$key};
						if(/^$/)
						{
						   $key=~s/^.*-//g;
						   print $key;
						   push(@arrayemp,$key);
						}
						 else
						{
							my $k=$key;
							$k=~s/^.*-//g;
							$result.="<h3><b>$k</b></h3>\n\n";
							$result.="<br><br>\n";
							$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
									<tr>
									<th>Counters missed in DB</th>
									<th>Counters with value mismatch</th>
									<th>Counter not loaded </th>
									</tr>
										};
								
							my @array=undef;
							my @array1=undef;
							my @array2=undef;
							my $value=$result{$key};
							my @values=split(':',$value);
							foreach my $i(@values)
							{

								if ($i=~/^\w+=\d+$/ || $i=~/^\w+=\d+\.\d+$/)
								{
								my @arr=split('=',$i);
								push(@array,$arr[0]);
								}
								if($i=~/^\w+=.*,\w+=.*$/)
								{  my @arr=split('=',$i);
									push(@array1,$arr[0]);
								}
								if($i=~/^\w+=.*,\w+=$/)
								{ 
								my @arr=split('=',$i);
								push(@array2,$arr[0]);
								}
							}					
							$result.=qq{
									<tr>
									<td>@array</td>
									<td>@array1</td>
									<td>@array2</td>
									</tr>
									};
							$result.=qq{</table>};
							$result.="<br><br>\n";
						}
					}
					if (scalar @arrayemp !=0)			
					{	
					my $rowspan = scalar @arrayemp;
					$rowspan=$rowspan-1;
					@arrayemp = sort @arrayemp;
					shift @arrayemp;
					$result.=qq{<table BORDER="3" CELLSPACING="0" CELLPADDING="1" WIDTH="25%" > <tr><td > <b> <font color = Midnightblue> 10:$m  </td><td>};	    
					$result.= "".join("", map { "${_}," }  @arrayemp)."";
					$result.="</td></tr></table>";   
					}	
				}				
			}
		}
	}
	
return $result;
}
sub dataloading{
 #print "loading\n";
my @array= ();
my $result="";
#my $host=getHostName();
#my @rack=("atrcx1196","atclvm623","atrcx893","atrcx1298vm1","atrcx1298vm2","atrcx1298vm3","atrcx1299esx","atrcx1300vm1","atrcx1300vm2","atrcx1300vm3","atrcx1017","atrcx1328","atrcx1195","atrcx1057","atclvm570");
#my @blade=("atrcxb1867","atrcxb1310","atrcxb1309","atrcxb1308","atrcxb1360","atrcxb1335","atrcxb2286");
#my @multiblade=("atrcxb1641","atrcxb2953","atrcxb1466");
#if ( grep $_ eq $host, @rack )
#{
 #print "this is rack\n";
 #@array=("mtas","ggsn","pgw","sgw","Node","mbm_sgw","cudb","msc_iog","msc_apg","mgw","sgsn","sgsnmme");
#} 
#elsif ( grep $_ eq $host, @blade )
#{
  #print "this is blade\n";
 #@array=("stn_Tcu","stn_pico","stn_siu","tdrnc","rnc","rxi","rbs","tdrbs","LTElte_COMMON","WCDMA_COMMON","mlppp","smartmetro","edgerouter","cpg");
#}
#elsif ( grep $_ eq $host, @multiblade )
#{
#  print "this is blade\n";
# @array=("cscf","mrfc","ims","ipworks","hss","sbg","sasn_sara","sasn","dsc"); 
#}
#else
#{
 #  print "not in the list\n";
 #  @array=undef;
 #}
#@array=("hss","msc_iog","msc_apg","edgerouter","sasn");
###@array=("hss","ggsn","pgw","sgw","Node","mbm_sgw","cudb","msc_iog","msc_apg","mgw","sgsn","sgsnmme","stn_Tcu","stn_pico","stn_siu","tdrnc","rnc","rxi","rbs","tdrbs","LTElte_COMMON","WCDMA_COMMON","mlppp","smartmetro","edgerouter","cpg","cscf","mrfc","ims","ipworks","hss","sbg","sasn_sara","sasn","dsc");
######@array=("dsc","cpg","hss");


if (@epfg_techPacks != undef)
{
	my $tp="";
	my $substr="|";
	for my $tps (@epfg_techPacks)
	{
		$_=$tps;
		next if(/^$/);
		$tp=$dataValidationTPs{$tps};
		next if($tp eq "");
		push @array, $tp;
	}
	push @array, "WCDMA_COMMON";
	push @array, "smartmetro";
	@array=uniqArr(@array);
}

if (@array==undef)
{
	print "Retrieve list of TP's for Data Validation.. (List not initialized)\n";
	@array=("hss","ggsn","pgw","sgw","Node","mbm_sgw","cudb","msc_iog","msc_apg","mgw","sgsn","sgsnmme","stn_Tcu","stn_pico","stn_siu","tdrnc","rnc","rxi","rbs","tdrbs","LTElte_COMMON","WCDMA_COMMON","mlppp","smartmetro","edgerouter","cpg","cscf","mrfc","ims","ipworks","hss","sbg","sasn_sara","sasn","dsc","smpc","gmpc");
}

print "  Array input is 222222222222222  :: @array \n";

foreach my $i (@array)
{
print "\nNode : $i\n";
$_=$i;
next if(/^$/);
if($i=~/^LTElte_COMMON$/)
{
$result.= qq{<br><br><hr> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" > <tr><th><td> <center> <b> PRBS lte</td>};
}
elsif($i=~/^WCDMA_COMMON$/)
{

$result.= qq{<br><br><hr> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" > <tr><th><td> <center> <b> PRBS wcdma</td>};
}
else{
my $i1= uc $i;
$result.= qq{<br><br><hr> <table  BORDER="3" CELLSPACING="2" CELLPADDING="3" WIDTH="50%" > <tr><th><td><b> <center> <font color = Midnightblue ; size = 4> $i1 </td>};
}
$result.=loading($i);
}
 return $result;
}
#####################################################################################

sub getdatetime{
my $yesterdaysTime=strftime "%Y%m%d-%H:%M:%S",localtime(time() - 24*60*60) ;
my $hour = `echo $yesterdaysTime -s|cut -c 10,11`;
chomp($hour);
my $day = `echo $yesterdaysTime -s|cut -c 7,8`;
chomp($day);
my $month = `echo $yesterdaysTime -s|cut -c 5,6`;
chomp($month);
my $year = `echo $yesterdaysTime -s|cut -c 1-4`;
chomp($year);

return sprintf "%02d-%02d-%4d",$day,$month,$year;
}
########################################################################################
##############################################
#get today's delivered tp or module
##############################################
sub delivered_feature{
print "Executing Delivered Feature.. \n";

my $yesterdaysTime=strftime "%d-%b-%Y",localtime(time() - 24*60*60) ;
my $day=`echo $yesterdaysTime | cut -d'-' -f1`;
my @sprint=`head -1 /eniq/admin/version/eniq_status | awk '{print \$2}' | cut -d'_' -f4`;

print "Yesterday Time : $yesterdaysTime	- 	Day : $day\n";
print "Sprint : $sprint[0]\n";

my $hashref=MAPCSV();
my %hash=();
%hash=%$hashref;
###print "Conents of Hash .........\n";
###foreach my $key (keys %hash)
###{
###print "Test Key : $key=>$hash{$key}\n";
###}

print "Packages verified from : $yesterdaysTime\n";
print "Command : ct lsh  -since $yesterdaysTime  | grep -i \"$sprint[0]\"";
print "\n";

my $script=qq{ 
(
 sleep 5 ;
 echo "/usr/atria/bin/cleartool setview stats_rt_dyn_view"; sleep 5 ;
 echo "cd /vobs/dm_eniq/AT_delivery/container"; sleep 2 ;
 echo "/usr/atria/bin/cleartool lsh  -since $yesterdaysTime  | grep -i \"$sprint[0]\" " ; sleep 6 ;
 echo "exit\n";
) |  ssh eniqdmt\@selix069.lmera.ericsson.se
};
     my @res=executeThis($script); 
     print "the script is $script";
    print "the commands are : \n";
	
	print "\n Cleartool Result : \n";
	for my $j (@res) {
		print "CT O/P	:	$j\n";
	}
	
	
my @result=undef;

foreach my $i (@res){
	 if ($i =~/^.*create\s+version.*$/)
		
		 { 
		  my @tps=split(/\s+/,$i);
		  foreach my $tp (@tps){
		  if ($tp=~/^".*\..*\@\@.*"$/)
		   {
		    $tp=~s/"//g;
			$tp=~s/\s+//g;
			$tp=~s/\@\@\/main\/.*//;
		   
		  print "the mod tp is $tp \n";
		   if(exists $hash{$tp})
		     {
			   push(@result,$hash{$tp});
			   
			 }
			 
			} 
		}
}
}
print "list is @result\n";
my $resstring=join(";",@result);
my @finalresult=split(";",$resstring);
my @final=undef;
my @tp_list=undef;
foreach my $i (@finalresult)
{
 print "the tp is $i\n";
 $i=~s/\s+//g;
 push(@final,$i);
}
print "finallist is".uniq(@final)."\n";

if (grep $_=~/All/i,uniq(@final))
{
@tp_list=Divide_Techpacks();
print "\n\ndelivered_feature -> Divide_Techpacks\n";
}
else
{
@tp_list=uniq(@final);
print "\n\ndelivered_feature -> uniq-final\n";
}
return @tp_list;
}
#########################################################
#read and map from the dependency matrix
#########################################################
sub MAPCSV{
my $file="/eniq/home/dcuser/ListOfPackages.csv";
open(F, $file) or die "Unable to open $file: $!\n";
my @fields=undef;
my $count=0;
my %desiredColumns=();
my %columnContents=();
my @names=();
my @trigger=();
my $name=undef;
my $trig=undef;
while(my $line=<F>){
$count++;
$line=~s/\r//g;
#print "$line is the line\n";
$line=~s/\"//g;
@fields=split(",",$line);
my $colCount = 0;

if($count==1)
{
foreach my $i (@fields)
{ 

 $colCount++;
  if($i=~/^Name$/)
  {
   $name=$colCount;
   $desiredColumns{$colCount} = 1;
   #print "its name\n";
   }
 if($i=~/^Trigger/)
  {
   #print "its trigger\n";
   $trig=$colCount;
   $desiredColumns{$colCount} = 1;
   }


}
}
  else {
	
    #next if(/^#/);
    # Not the header row.  Parse the body of the file.
    foreach my $field (@fields) {
      $colCount++;
	  $field=~s/^M//g;
	    $field=~s/\s+//g;
      if ( exists $desiredColumns{$colCount}) {
       
        push(@{$columnContents{$colCount}}, $field);
      }
	  
	  
    }
  }


}
close(F);
foreach my $key (sort keys %columnContents) {
	if ($key==$name){
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	#next if(/^$/);
	push(@names,$i);
	#print "tagids are:@tagid\n";
	}
  }
  }
  foreach my $key (sort keys %columnContents) {
	if ($key==$trig){
	
	foreach my $i (@{$columnContents{$key}}){
	$_=$i;
	#next if(/^$/);
	push(@trigger,$i);
	#print "tagids are:@tagid\n";
	}
  }
  }
my %hash=();
for (my $j =0; $j <=$#names; $j++) 
 {
 $names[$j]=~s/\s+//g;
 $hash{ $names[$j] }=$trigger[$j];
 }
###print "the csvhash .........\n";
###foreach my $key (keys %hash)
###{
###print "$key=>$hash{$key}\n";
###}
return \%hash;
}
########################################################################################
#SOEM Scalibility Check
#this corresponding to the jira http://jira-oss.lmera.ericsson.se/i#browse/EQEV-14577
########################################################################################
sub Soem_Scalibility
{

my  $result=qq{
<h3>Checks if below mentioned files are updated as required</h3>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>FILE OR DIRECTORY</th>
     <th>STATUS</th>
     <th>RESULT</th>
   </tr>
};
my %hash=(  "/eniq/sw/conf/niq.rc","PMDATA_SOEM_DIR=/eniq/data/pmdata_soem|export PMDATA_SOEM_DIR" ,
			"/eniq/installation/config/niq.rc" , "PMDATA_SOEM_DIR=/eniq/data/pmdata_soem|export PMDATA_SOEM_DIR", 
			"/eniq/installation/core_install/templates/stats/niq.rc" , "PMDATA_SOEM_DIR=<CHANGE><ENIQ_BASE_DIR>/data/pmdata_soem|export PMDATA_SOEM_DIR",
			"/eniq/installation/core_install/templates/events/niq.rc" , "PMDATA_SOEM_DIR=<CHANGE><ENIQ_BASE_DIR>/data/pmdata_soem|export PMDATA_SOEM_DIR",
			"/eniq/admin/bin/engine" , "DPMDATA_SOEM_DIR=\$\{PMDATA_SOEM_DIR\}",
			"/eniq/data/pmdata_soem/" , "exists",
			"/eniq/installation/config/service_names" , "mediator",
			"/eniq/sw/conf/service_names" ,"mediator",
			"/eniq/sw/platform" , "nomediator",
			"/eniq/sw/bin" , "nomediator",
			"/eniq/log/sw_log/" , "nomediator",
			"/eniq/mediator","nonexist",
			"/eniq/data/pmdata_twamp","nonexist",
			"/etc/hosts" , "mediator",
			"/eniq/installation/core_install/templates/stats/storage_ini" , "\[Storage_NAS_PMDATA_SOEM\]|FS_NAME=pmdata_soem|FS_SIZE=5g|NFS_HOST=nas7|SHARE_PATH=/vx/<CHANGE><ENIQ_POOL_ID>-pmdata_soem|MOUNT_PATH=<CHANGE><ENIQ_BASE_DIR>/data/pmdata_soem|NFS_SHARE_OPTIONS=\"rw,no_root_squash\"|SNAP_TYPE=optim|STAGE=install_ENIQ_platform",
			"/eniq/installation/core_install/templates/events/storage_ini" , "\[Storage_NAS_PMDATA_SOEM\]|FS_NAME=pmdata_soem|FS_SIZE=5g|NFS_HOST=nas7|SHARE_PATH=/vx/<CHANGE><ENIQ_POOL_ID>-pmdata_soem|MOUNT_PATH=<CHANGE><ENIQ_BASE_DIR>/data/pmdata_soem|NFS_SHARE_OPTIONS=\"rw,no_root_squash\"|SNAP_TYPE=optim|STAGE=install_ENIQ_platform",
			"/eniq/installation/config/SunOS.ini" , "path=/eniq/data/pmdata_soem|perms=0755|user=dcuser|group=dc5000|mediator");
		  
foreach my $key (sort keys %hash)	{
next if($key=~/^$/);
next if( $hash{$key}=~/^$/ );
my @status=undef;
#print "$key => $hash{$key}\n";

$result.="<tr><td>$key</td>";

if($hash{$key}=~/exists/)
{
 print "CASE1\n"; 

     if(-d $key)
	   {
	     
		 
		 $result.="<td>Filesystem Exists</td><td><font color=006600><b>PASS</b></td></tr>";
	   }
	 else{
          $result.="<td>Filesystem Does not exist</td><td><font color=ff0000><b>FAIL</b></td></tr>";
		 
        }	 

}
elsif($hash{$key}=~/nonexist/)
{
 @status=split("\/",$key); 
 print "CASE2\n"; 
  if (-d $key)
	   {
	     $result.="<td>$status[$#status] directory not removed</td><td><font color=ff0000><b>FAIL</b></td></tr>";
	   }
	 else{
          
		
		$result.="<td>$status[$#status] directory  removed</td><td><font color=006600><b>PASS</b></td></tr>";
        }	 

}
elsif($key=~/engine/)

{
  print "CASE5\n"; 
 
  @status=`grep -c '$hash{$key}' $key`;
	if(grep $_==0,@status)
	   {
	     $result.="<td>pmdata_soem paramater does not exist</td><td><font color=ff0000><b>FAIL</b></td></tr>";
	   }
	 else{
          
		
		$result.="<td>pmdata_soem paramater exists</td><td><font color=006600><b>PASS</b></td></tr>";
        } 
}
elsif($hash{$key}=~/mediator/)
{
print "CASE3\n"; 
 if($hash{$key}=~/nomediator/)
{
   @status=`ls $key | grep -c 'mediator'`;
     if($status[0]==0)
	   {
	     $result.="<td>No mediator entry </td><td><font color=006600><b>PASS</b></td></tr>";
	   }
	 else{
          $result.="<td>Mediator exists</td><td><font color=ff0000><b>FAIL</b></td></tr>";
        } 
}
else
{
  @status=`grep -ci '$hash{$key}' $key `;
     if($status[0]==0)
	   {
	     $result.="<td>Mediator services removed</td><td><font color=006600><b>PASS</b></td></tr>";
	   }
	 else{
          $result.="<td>Mediator services not removed</td><td><font color=ff0000><b>FAIL</b></td></tr>";
        } 
}
}
elsif($key=~/storage_ini/)
{ 
 print "CASE4\n"; 
 my @res=undef;
 my @split_values= split(/\|/,$hash{$key});
 foreach my $i (@split_values)
 {
  $_=$i;
  next if(/^$/);
  my @status1=`grep -l '$i' $key* | wc -l`;
  if($status1[0]==5)
   {
       push (@res,$i);
   
    }
 }
 if ($#res >=8)
   {
	     $result.="<td> SOEM block present</td><td><font color=006600><b>PASS</b></td></tr>";
	   }
else{
 $result.="<td>No soem block</td><td><font color=ff0000><b>FAIL</b></td></tr>";

}
}
elsif ($key=~/SunOS.ini/)
 { 
 print "CASE6\n"; 
 my @res=undef;
 my @med=();
 my @split_values= split(/\|/,$hash{$key});
 foreach my $i (@split_values)
 {
  print "the vaules :$i\n";
  $_=$i;
  next if(/^$/);
  my @status=`grep -c '$i' $key`;
  if($status[0]!=0)
   {
       push (@res,$i);
   
    }
  else{
  push(@med,$i)
 
 }
 
 }

 if ($#res >=3 && !@med)
   {
	     $result.="<td> SOEM BLOCK PRESENT & mediator</td><td><font color=006600><b>PASS</b></td></tr>";
	   }


else{
if($#res < 3  && !@med)
{
 $result.="<td>No SOEM BLOCK NOT PRESENT& no mediator entry/td><td><font color=ff0000><b>FAIL</b></td></tr>";

}
elsif($#res<3){
 $result.="<td>SOEM BLOCK NOT PRESENT</td><td><font color=ff0000><b>FAIL</b></td></tr>";
 }
 elsif(@med)
 {
   $result.="<td>Mediator not removed</td><td><font color=ff0000><b>FAIL</b></td></tr>";
 
 }

}
}
else{
  print "CASE7\n"; 
  @status=`egrep -c '$hash{$key}'  $key`;
  
         if($status[0] == 0)
	   {
	     $result.="<td>pmdata_soem parameter does not exists/td><td><font color=006600><b>PASS</b></td></tr>";
	   }
	 else{
         my @split_values= split(/\|/,$hash{$key});
		 my $num=$split_values[$#split_values] + 1 ;
		   if($status[0] >=  $num)
					{ $result.="<td>pmdata_soem parameter  exist</td><td><font color=006600><b>PASS</b></td></tr>";}
		    else{
              $result.="<td>pmdata_soem parameter does not exist</td><td>FAIL</td></tr>";}			
        }	 
}
print "The status @status\n";

}

$result.="</table>";

$result.="<br><br>\n";

 $result.=qq{
<h2>Check AdminUi for Mediator</h2>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>AdminUI Links</th>
     <th>STATUS</th>
     <th>RESULT</th>
   </tr>
};
my @array=("https://localhost:8443/adminui/servlet/LoaderStatusServlet","https://localhost:8443/adminui/servlet/EditLogging");
foreach my $i (@array){
$_=$i;
$result.="<tr><td>$i</td>";
next if(/^$/);
`rm status.html`;
 system("$WGET --quiet --no-check-certificate -O /eniq/home/dcuser/status.html --keep-session-cookies --load-cookies /eniq/home/dcuser/cookies2.txt \"$i\"");
 my @status=executeThis("grep -ci 'mediator' /eniq/home/dcuser/status.html");
 if($status[0]==0)
 { $result.="<td>No mediator </td><td><font color=006600><b>PASS</b></td></tr>";}
 else{
  $result.="<td>Mediator exists </td><td><font color=ff0000><b>FAIL</b></td></tr>";}
   }
   $result.="</table>";
$result.="<br><br>\n";

$result.=qq{
<h2>Check Snapshots for Mediator</h2>
<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
   <tr>
     <th>Deployment</th>
     <th>STATUS</th>
     <th>RESULT</th>
   </tr>
};
my @cmd=`grep -ci 'nas' /etc/hosts`;
my $script=undef;
print "the cmd $cmd[0]\n";
if($cmd[0]==0)
{
 $result.="<tr><td>Rack Snapshots</td>";
 $script=qq{
(
 sleep 2;
 echo "root"; sleep 2;
 echo  "shroot"; sleep 2;
 echo  "bash"; sleep 2;
 echo "bash ./manage_zfs_snapshots.bsh -a create -f ALL -n 123" ; sleep 5;
 echo  "No"; sleep 2;
 echo "exit\n";
) | telnet localhost
};
}
else{
$result.="<tr><td>Blade Snapshots</td>";
 $script=qq{
(
 sleep 2;
 echo "root"; sleep 2;
 echo  "shroot"; sleep 2;
 echo  "bash"; sleep 2;
 echo "bash ./manage_zfs_snapshots.bsh -a create -f ALL -n 123" ; sleep 5;
 echo  "No"; sleep 5;
 echo "bash ./manage_nas_snapshots.bsh -a create -f ALL -n 123" ; sleep 5;
 echo  "No"; sleep 2;
 echo "exit\n";
) | telnet localhost
};
}
my @res_snap=executeThis($script);
if (grep $_=~/mediator/i,@res_snap)
  { $result.="<td>Mediator exists</td><td><font color=ff0000><b>FAIL</b></td></tr>";}
 
 else
 
 { $result.="<td>No mediator </td><td><font color=006600><b>PASS</b></td></tr>";}
$result.="</table>";
}
############################################################
#checks size of filesystem dbspace
############################################################
sub Sizecheck{
	my $result.="<br><br>\n";
	my $res_fail .= "<br><br>\n";
	my $DBUSER="DBA";
	my $DBPWD="sql";
	my $DBBASE="dwhdb";

	my $SQLFILE="serverStatus.sql";
	my $OUTPUTFILE="serverStatus.out";

	`echo 'sp_iqstatus' > $SQLFILE`;
	`echo 'go' >> $SQLFILE`;

	`chmod 750 $SQLFILE`;

	
	#Update for  Subase IQ16 changes iqisql to isql
	`$sybase_dir -U$DBUSER -P$DBPWD -S$DBBASE -w7000 -i $SQLFILE -o $OUTPUTFILE`;
	my $percentage=`cat $OUTPUTFILE | grep "Main IQ Blocks" | awk -F"," '{print \$2}' | awk -F"=" '{print \$1}' | sed 's/^ *//'`; 
	my $usedSpace=`cat $OUTPUTFILE | grep "Main IQ Blocks" | awk -F"," '{print \$2}' | awk -F"=" '{print \$2}'`;

	`rm $SQLFILE $OUTPUTFILE`;

	print "Used DB Space : $usedSpace [$percentage] \n";
		
	`df -kh > fileSystemSize.out`;
	 open(F, "<fileSystemSize.out");
	my $count=0;
	my %hash=();

	while (my $line=<F>)
	{
		$count++;
		my @strArray=split(/\s+/,$line);
		my $size=$strArray[4]; 
		
			if ( $size=~/^.*%/ )
			{
				 $size=~s/%//g;
				 next if ($size=~/^\d$/);
				 #print "$strArray[0] :::: $size \n";
				if ( $size gt 75 )				
				{				
					#print "$strArray[0] $strArray[4] \n";
					$hash{$strArray[0]}=$strArray[4];	
				}
			}
	}
	`rm fileSystemSize.out`;

	if (!%hash)
	{

	$result.=qq{<td><font size = 2 color=006600><b> <br> PASS <font color=black></b> (No filesystem greater than 75%) <br>
			<br>Used DBspace:     <font size = 2 > $usedSpace</br>
			Percentage   :     <font size = 2 > $percentage</td></tr>};
	}
	else{
	$result.=qq{<td><font size = 3 color=red><b> FAIL </font> <font color=black></b> <br> 
			<br>Used DBspace	:     <font size = 2 > $usedSpace</br>
				Percentage Used	:     <font size = 2 > $percentage</td></tr>};
	$result.="<br><br>\n";
	
	$result.=qq{</table> <br> <br> <font> The following file systems are above 75% usage 
					<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="45%"> <tr> <th> <font size = 2 > Filesystem </th><th> <font size = 2 > SIZE </th>};
						
	$res_fail .= $result;
	foreach my $key (keys %hash)
	{
	$result.=qq{<tr><td>$key</td><td>$hash{$key}</td></tr>};
	$res_fail .= qq{<tr><td>$key</td><td>$hash{$key}</td></tr>};
		}
	}
	return $result, $res_fail;
} 

##########################################################################
#lists epfg nodes correponding to delivered feature
##########################################################################
sub delivered_nodes{
my @dev_tps=delivered_feature();# stores the delivered tps
print "the deb tps :@dev_tps\n";
my %hash=();
%hash=("DC_E_CPP","RNC|Wran-RBS|Wran-RXI|WRAN-LTE",
		"DC_E_RBS","Wran-RBS",
		"DC_E_RAN","RNC",
		"DC_E_BSS","BSC-APG|BSC-IOG|HLR-APG|HLR-IOG",
		"DC_E_CNAXE","MSC-BC|MSC-IOG",
		"DC_E_ERBS","WRAN-LTE",
		"DC_E_STN","STN-PICO|STN-SIU|STN-TCU",
		"DC_E_SAPC","SAPC",
		"DC_E_SASN","SASN",
		"DC_E_SASN-SARA","SASN-SARA",
		"DC_E_SGSN","SGSN|SGSN-MME",
		"DC_E_IMS","IMS|CSCF|MRFC",
		"DC_E_IMS_IPW","IPWORKS",
		"DC_E_IMSSBG","SBG",
		"DC_E_IMSGW_MGW","MGW",
		"DC_E_REDB","EDGE-ROUTER|CPG|MLPPP",
		"DC_E_DSC","DSC",
		"DC_E_HSS","HSS",
		"DC_E_CPG","CPG",
		"DC_E_TDRNC","TD-RNC",
		"DC_E_TDRBS","TD-RBS",
		"DC_E_MTAS","MTAS",
		"DC_E_IPPROBE","TWAMP",
		"DC_E_MGW","MGW",
		"DC_E_CMN_STS","BSC-APG|BSC-IOG|MSC-IOG|MSC-APG",
		"DC_E_CUDB","CUDB",
		"DC_E_GGSN","PGW|SGW|GGSN"
	);
	my @node_array=();
foreach my $i (@dev_tps)	
{
 $_=$i;
 next if(/^$/);
 $i=~s/\r//g;
 $i=~s/\s+//g;
 if (exists $hash{$i})
	{
	  my @nodes=split(/\|/,$hash{$i});
	  foreach my $j (@nodes)
	  {
		next if(/^$/);
		push(@node_array,$j);  
	  }
	}
else{
	print "\nthe techpack $i doesn't have epfg support\n";
}	
}
return uniq(@node_array);
}
###################################################################################
#testcase to check column number in th dwhdb is same as the dataitem table in repdb
#as per the tr HS23346
###################################################################################
sub getColNumfromrepdb
 {
  my $table=shift;
  $table=~s/_RAW/:/i;
  my %hash=();
  #DB Connection
 my $connstr = 'ENG=repdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2641};;UID=dwhrep;PWD=dwhrep';

my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
my $sel_statement ="select distinct DATANAME,COLNUMBER from dataitem where dataformatid like '%table%'and substr(dataformatid,0,charindex(')',DATAFORMATID)+1) in (select versionid from tpactivation)";
 my( $row, $sth ) = undef;
$sth = $dbh->prepare($sel_statement);
$sth->execute;

  while( $row = $sth->fetch ) {
	 #print " vendor @$row[0]\n";
	 $hash{@$row[0]}=@$row[1];
	}
	   $sth->finish;
	   
	   return (\%hash); 
}
########################################################################
#get column id for each column from systable n syscolumn
########################################################################
sub getColIdFromDwhdb
{
  my $table=shift;
 my %hash=();
  #DB Connection
 my $connstr = 'ENG=repdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2641};;UID=dwhrep;PWD=dwhrep';

my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
my $sel_statement ="select column_name,column_id from syscolumn a,systable b where b.table_name like '$table' and 
a.table_id=b.table_id order by column_id";
 my( $row, $sth ) = undef;
$sth = $dbh->prepare($sel_statement);
$sth->execute;

  while( $row = $sth->fetch ) {
	 #print " vendor @$row[0]\n";
	 $hash{@$row[0]}=@$row[1];
	}	
	   $sth->finish;
	   
	   return (\%hash); 
}  
################################################
sub CompareColNos
{
 my $result="";
 foreach my $tp (@tpini)
{
 
   $_=$tp;
   next if(/^$/);
   $result.="<h3>$tp</h3><BR>\n";
   # my $j=0;
   #$result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><th>No of tables with duplicate or suspected rowstatus</th><th>RESULT</th></tr>\n};
	 my %hash_table=();  
     my @propertables=();
 my @tables= getAllTables4TP($tp);
foreach my $table (@tables)
    {   
	    my @loaded=undef;
        $_=$table;
        next if(/^$/);
        next if(/ /);
        next if(/affected/);
		next if($table=~/SQL Anywhere Error /);
	    next if($table=~/Msg \d/);
		next if($table=~/ Msg \d/);
        next if(/_DAY/);
        next if(!/_RAW/);
		my @mismatch=();	
       my $test1=getColIdFromDwhdb($table);
	   my $test2=getColNumfromrepdb($table);
	   my %hash_dwhdb=%$test1;
	   my %hash_repdb=%$test2;
	   foreach my $key (keys %hash_dwhdb)
	   {
	     if(exists $hash_repdb{$key})
		    {
			   if ($hash_repdb{$key}!=$hash_dwhdb{$key})
				{
				   push (@mismatch,$key);
				}
			}
	   }
	   if(!@mismatch)
	   {
	    push(@propertables,$table)
	   }
       else{
	     foreach my $i (@mismatch)
		 {
		    push @{ $hash_table{$table} }, $i;
		 }
	   }
}
if(!%hash_table)
{
$result.="<h3>No table with column number mismatch with Repdb<h3>";
}
else{
$result.="<h3>Following are the tables with column number mismatch with Repdb<h3>";
$result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><th>TABLE</th><th>COLUMNS</th></tr>\n};
foreach my $key (keys %hash_table)
{
 $_=$key;
 next if(/^$/); 
 $key=~s/^/<tr><td>/;
 $key=~s/$/<\/td>/;
 $result.=$key;
 my @array=@{$hash_table{$key}};
 my $string=join(",",@array);
 $string=~s/^,//;
 $string=~s/^/<td>/;
 $string=~s/$/<\/td><\/tr>/;
 $result.=$string;

}
$result.=</table>;
}
}
return $result;

}
######################################################################################
#the aggregation function 
######################################################################################
sub data_aggregation{
my $result="";
my @array=("DC_E_CPP");
foreach my $i (@array)
{
$_=$i;
next if(/^$/);
my %hash=();
my %raw=();
my @table=();
my @deltarr=();
print "the tp is $i\n";
$result.="<H2 ALIGN=LEFT>TECHPACK:: $i</H2>\n";
my $deltaref=DeltaSupport($i);
my ($rawref)=getAllRawTables($i,\@deltarr);
%hash=%$deltaref;#get tables from MeasurementDeltaCalcSupport and corresponding vendor release
%raw=%$rawref;#get all tables for all tps and corrsponding columns in array
my @delta=();
my @total=();
@delta=keys %hash;#stores total no of tables in  MeasurementDeltaCalcSupport table
@total=keys %raw;#stores total no of tables
my $totalcount=$#total+1;#total no of tables
$result.="<table><tr><td><b>the total no of tables :</b><font color=ff0000>$totalcount</font></td></tr></table>";
my @nodeltarr=();
if (!%hash)
{
 print "the techpack has no delta support\n";
 $result.=qq{<H3 ALIGN=CENTER>the techpack has no delta support</H3>};
 $result.=qq{<H3 ALIGN=CENTER>Aggregation Details</H3>};
 $result.=Aggregation($i, \@deltarr,\@nodeltarr);
}
else{
 my @vendor=();
 @vendor=getLatestVendor($i);#gets the latest vendor release
 print "the vendor is $vendor[$#vendor] \n";

 foreach my $key (sort keys %hash)
 {
  print "The table :$key\n";
  my @value=undef;
  @value=@{$hash{$key}};
  print "the value is @value\n";
  if ( grep $_ eq $vendor[$#vendor], @value )
   {     
      print "the table has no del supp\n"
	}
   else{
       
	   push(@deltarr,$key);
   }
	
  } 
   print "the value is @deltarr\n";
  if(!@deltarr) 
   
{
  #print "here\n";
  print "the techpack has no delta support\n";
  $result.=qq{<H3 ALIGN=LEFT>the techpack has no delta support </H3>};
   $result.=qq{<H3 ALIGN=CENTER>Aggregation Details</H3>};
   $result.=Aggregation($i,\@deltarr,\@nodeltarr);
  
}
else{
my $deltano=$#deltarr+1;
print "the no of tables with delta support:$deltano\n";
print "@deltarr\n";
$result.="<table><tr><td><b>the no of tables with delta support :</b><font color=ff0000>$deltano</font></td></tr></table>";
$result.=qq{<H3 ALIGN=CENTER>Delta Calculation Details</H3>};

$result.=DeltaCalc( $i,\@deltarr);
$result.=RowCount($i,\@deltarr);
foreach my $i (@total)
{
if(grep{ $_  ne $i} @deltarr)
{
push(@nodeltarr,$i);

}
}

$result.=Aggregation($i,\@deltarr,\@nodeltarr);
 }

}
}
 return $result;
}
################################################################
#Check the whether the TP has delta support
################################################################

sub DeltaSupport{


  my $tp= shift;
  my @insert=undef;
  my %hash=();
  my %final=();
  
  #DB Connection
 my $connstr = 'ENG=repdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2641};;UID=dwhrep;PWD=dwhrep';

my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
my $sel_statement=undef;
$sel_statement ="select SUBSTR(A.TYPEID,CHARINDEX(')',TYPEID)+3)||'_RAW', A.VENDORRELEASE from MeasurementDeltaCalcSupport A, where VENDORRELEASE <> 'NODELTA' and VERSIONID  in (select VERSIONID from TPActivation WHERE TECHPACK_NAME = '$tp')";
 my( $row, $sth ) = undef;
$sth = $dbh->prepare($sel_statement);
$sth->execute;


  while( $row = $sth->fetch ) {
	 #print " delta @$row[0]\n";
	 push @{ $hash{@$row[0]} }, @$row[1];
	}	
	   $sth->finish;
	   return(\%hash); 
}

################################################
#Gets vendor release for which delta support is there
###################################################
sub getLatestVendor{
        my $tp= shift;
        my @insert=undef;
        #DB Connection
        my $connstr = 'ENG=repdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2641};;UID=dwhrep;PWD=dwhrep';

        my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
        my $sel_statement=undef;
        my @sprint=executeThis("head -1 /eniq/admin/version/eniq_status | awk -F\" \" '{print \$2}'|awk -F\"_\" '{print \$4}'|awk -F\".\" '{print \$1}'");
        my $res="\%"."$sprint[0]"."\%";
        $res=~s/\s+\%/\%/;
        $sel_statement ="select MAX(VENDORRELEASE) from SupportedVendorRelease where VERSIONID in (select VERSIONID from TPActivation WHERE TECHPACK_NAME = '$tp') and VENDORRELEASE like '$res'";
        my( $row, $sth ) = undef;
        $sth = $dbh->prepare($sel_statement);
        $sth->execute;

        while( $row = $sth->fetch ) {
                print "vendor @$row[0]\n";
                push @insert, @$row[0];
        }
        my @vendor=();
        foreach my $i (@insert)
        {
                next if(/^$/);
                push(@vendor,$i);
        }

        $sth->finish;
        return @vendor;
}

################################################
#get all tables for a TP using DBD::SQLAnywhere
###############################################
sub getAllRawTables{
my ($tp,$table)=@_;
my @tabarr=();
@tabarr=@$table;
  my @insert=undef;
  #DB Connection
 my $connstr = 'ENG=dwhdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2640};;UID=dc;PWD=dc';

my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
my $sel_statement=undef;
if(!@tabarr){
$sel_statement ="select A.Table_name, B.column_name from SYSTABLE  A,SYSCOLUMN B where   B.table_id = A.table_id and A.table_type like 'VIEW'and A.Table_name like ('$tp%')and A.Table_name like ('%RAW') and A.creator=103";
 }
 
else{
 my @tabmod=();
 foreach my $i(@tabarr){
 
 $_=$i;
 next if(/^$/);
 $i=~s/^/'/g;
 $i=~s/$/'/g;
 push (@tabmod,$i);
 
 }
 my $string=join(',',@tabmod);
 $string=~s/^,//;
 #$string=~s/,$/$/;
 
 
 $sel_statement ="

select A.Table_name, B.column_name from SYSTABLE  A,SYSCOLUMN B where   B.table_id = A.table_id and A.table_type like 'VIEW'and A.Table_name like ('$tp%RAW')and A.Table_name in ($string) and A.creator=103";
  
 }
 
 my %hash=();
 my( $row, $sth ) = undef;
$sth = $dbh->prepare($sel_statement);
$sth->execute;
  while( $row = $sth->fetch ) {
	 #print " total @$row[0]\n";
	 push @{ $hash{@$row[0]} }, uniq(@$row[1]);
	}

	
	   $sth->finish;
	   return(\%hash); 

}
#################################################################################
#Get counter type and datscale and  time aggregation from repdb
#################################################################################
sub getDetailsFromRepdb{
  my ($tp,$table)=@_;
  my @tabarr=();
  @tabarr=@$table;
 
  my %hash=();
  #DB Connection


 my $connstr='ENG=repdb;CommLinks=tcpip{host=atrx893.athem.eei.ericsson.se;port=2641};;UID=dwhrep;PWD=dwhrep';

my $dbh = DBI->connect( "DBI:SQLAnywhere:$connstr", '', '', {AutoCommit => 0} );
my $sel_statement=undef;
  if(!@tabarr){
$sel_statement ="select SUBSTR(TYPEID,CHARINDEX(')',TYPEID)+3)||'_RAW',DATANAME||'='||COUNTERTYPE||':'||TIMEAGGREGATION||'#'||DATASCALE from MeasurementCounter
where  COUNTERTYPE in ('PEG','VECTOR','CMVECTOR','GAUGE') and TYPEID  in
(
select TYPEID from MeasurementCounter  where
 SUBSTR(TYPEID,0,CHARINDEX(')',TYPEID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME='$tp'))";}
 
 else{
 my @tabmod=();
 foreach my $i(@tabarr){
 
 $_=$i;
 next if(/^$/);
 $i=~s/^/'/g;
 $i=~s/$/'/g;
 push (@tabmod,$i);
 
 }
 my $string=join(',',@tabmod);
 $string=~s/^,//;
 #$string=~s/,$/$/;
 $sel_statement ="select SUBSTR(TYPEID,CHARINDEX(')',TYPEID)+3)||'_RAW',DATANAME||'='||COUNTERTYPE||':'||TIMEAGGREGATION||'#'||DATASCALE from MeasurementCounter
where  COUNTERTYPE in ('PEG','VECTOR','CMVECTOR','GAUGE') and SUBSTR(TYPEID,CHARINDEX(')',TYPEID)+3)||'_RAW' in ($string) and TYPEID  in
(
select TYPEID from MeasurementCounter  where
 SUBSTR(TYPEID,0,CHARINDEX(')',TYPEID)+1) in (select VERSIONID from TPActivation WHERE TECHPACK_NAME='$tp'))";}
 
 my( $row, $sth ) = undef;
$sth = $dbh->prepare($sel_statement);
$sth->execute;


while( $row = $sth->fetch ) {
	 #print " total @$row[0]\n";
	 push @{ $hash{@$row[0]} }, @$row[1];
	}
	$sth->finish;
  return(\%hash); 

}
##########################################################################################
sub getAggDS{
my ($tp,$table)=@_;
my ($test1)=getAllRawTables($tp,$table);
my $test2=getDetailsFromRepdb($tp,$table);
my %dwhtable=%$test1;
my %reptable=%$test2;
my %agg=();
#print "the tablehash........";
foreach my $key (keys %dwhtable)#loops through each raw table in dwhdb
{
  my @value1=@{$dwhtable{$key}};#stores columns in each raw table in an array
 # print "$key==>$dwhtable{$key}\n";
  my %final=();
  if (exists $reptable{$key})#checks if same table entry exists in repdb
  {
  my @value=@{$reptable{$key}};#stores the string say countername=PEG:SUM#0
  foreach my $i (@value)
  {
   print "the i=$i\n";
   my ($k,$v)=split('=',$i);
   my $lk=lc($k);
    $final{$lk}=$v;  
   
  }
    foreach my $v2 (@value1){
	 my $l=lc($v2);
     if (exists $final{$l}){
            my $j="$l"."="."$final{$l}";
		 
		   #print "the j is =$j\n";
          push(@{$agg{$key}}, $j);
  
  
  
  }
  }
  
  
}
}
  my %aggfinal=();
 for my $k (sort keys %agg) {
 
  my $s=join ',', @{ $agg{$k} };
 
  $aggfinal{$k}=$s;
  
} 

###print "this is my agglist\n";
###for my $k (sort keys %aggfinal) {
###print "$k=>$aggfinal{$k}\n";
###}
return(\%aggfinal); 
}
##############################################################################
#get the sql query for day tables 
##############################################################################
sub getAggSql
{
 my ($tp,$table)=@_;
 
 my $test=getAggDS($tp,$table);
 my %hash=%$test;
 my %hash_counters=();
 my $date=$DATETIMEWARP;
 my %hash1=();
 foreach my $key (sort keys %hash)
{
 next if ($key=~/^$/);
 my $value=$hash{$key};
 $key=~s/_RAW/_DAY/g;
 my @valarr=undef;
 my @val=split(',',$value);
 foreach my $v (@val)
 {
 $v=~s/=.*//g;
 push (@valarr,$v);
 
 }
 my $value1=join(',',@valarr);
 $value1=~s/^,//;
 $hash_counters{$key}=$value1;

}
my @SQL_FILES_LIST = ();
	my $TMP_FILE;
	my $sql=undef;
	###print "the hash for sql\n";

	foreach my $key (sort keys %hash_counters)
	{
		###print "$key =>$hash_counters{$key}\n";
		
		my $sql=undef;
		$_=$key;
		
        if($key=~/DC_E_RAN_.*_V_DAY|DC_E_RBS_.*_V_DAY|DC_E_PRBS_.*_V_DAY/i)
		{
	        	$sql=qq{select $hash_counters{$key} from $key where  and CONVERT(CHAR(8),DATE_ID,112) ='$date' and DCVECTOR_INDEX=1 };
		}
		elsif($key=~/DC_E_SGSN_.*_DAY/i)
		{
	        	$sql=qq{select  $hash_counters{$key} from $key where  SGSN='SGSN01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
		}
		elsif($key=~/DC_E_REDB_.*_DAY/i)
		{
	       if($key=~/DC_E_REDB_.*_CLASS_COUNT|DC_E_REDB_FRAME.*_COUNT|DC_E_REDB_ATM_COUNT|DC_E_REDB_CHANNEL_COUNT/i)
			{	
		
	        	$sql=qq{select  $hash_counters{$key} from $key where   NE_NAME='CPG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
		    }
			else
			{	
		
	        	$sql=qq{select  $hash_counters{$key} from $key where   NE_NAME='EdgeRtr01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
		    }
		}
		elsif($key=~/DC_E_BSS_.*_DAY/i)
		{
	        	$sql=qq{select  $hash_counters{$key} from $key where  SN='BAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
		}
		elsif($key=~/DC_E_CNAXE_.*_DAY/i)
		{
	        	$sql=qq{select  $hash_counters{$key} from $key where  SN='MAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
		}
		
		elsif($key=~/DC_E_IMS_.*_DAY/i)
		{     
	           if(/DC_E_IMS_CSCF.*_DAY/)
				{	
	        	$sql=qq{select  $hash_counters{$key} from $key where  g3ManagedElement='CSCF01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
				}
				elsif(/DC_E_IMS_IPW_.*_DAY/i)
				{
				 
				 $sql=qq{select  $hash_counters{$key} from $key where  g3ManagedElement='IPWk01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
				}
				else
				{
				$sql=qq{select  $hash_counters{$key} from $key where  g3ManagedElement='IMS01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  };
				}
				
		}
		
	
		elsif($key=~/DC_E_IMSBG_.*_day/i)
		{
	            	
	        	$sql=qq{select  $hash_counters{$key} from $key where  NE_ID='ISSBG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date' };
		}
		elsif ($key=~/DC_E_CPP_.*_DAY/i)
		{  $_=$key;
		    if(/DC_E_CPP_.*_V_COUNT/)
			
			{
			print "the cpp vector table :$key";
			$sql=qq{select  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1' and DCVECTOR_INDEX=1 };}
			else
			{
			print "the cpp normal table :$key";
			$sql=qq{select  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1'};
			
			}
			
		}
		else{
			$sql=qq{select  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' };
		}
		$hash1{$key}=$sql;
	}
	
	my @SQLFILES = glob "sql*txt";
	unlink @SQLFILES;
	
	my $count=undef;
	my $cnt = 0;
	my $hsize = keys %hash1;
	my $fsize=50;
	my $init=0;
	print "Number of Keys in Hash : $hsize\n";
	if ( $hsize > $fsize ) {
		my @list=sort keys %hash1;
		print "Hash Size : " . scalar @list . "\n";
		my $div = ($hsize / $fsize);
		my $mod = ($hsize % $fsize);
		if (index($div, ".") != -1) {
			$count = substr($div, 0, index($div, "."));
			my $tmp = substr($div, (index($div, ".")+1), length($div));
			if ( $tmp > 0 ) {
				$count = $count+1;
			}
			
			my $j;
			for($j=1;$j<=$count;$j++)
	        {
		        $TMP_FILE = "sql"."$j".".txt";

				if ( $j==$count ) {
					$fsize = $hsize;
				}
				
				open(EDT,"> $TMP_FILE");
				
				my $k;
				for($k=$init;$k<$fsize;$k++)
				{
					###print $list[$k] . "=>" . $hash1{$list[$k]} . "\n";
					#print "$key =>$hash{$key}\n";
 
					print EDT $list[$k] . ":" . $hash1{$list[$k]} . "\n";
					#print EDT "$key:$hash{$key}\n";
				}
				close(EDT);
				$fsize=$fsize+50;
				$init=$k;
				$SQL_FILES_LIST[$cnt]=$TMP_FILE;
				$cnt = $cnt+1;
				###print "Mis : $fsize : $init : $cnt : $j : $k\n";
			}
		}
	}
	else
	{
		$TMP_FILE = "sql1.txt";
		open(EDT,"> $TMP_FILE");
		foreach my $key (sort keys %hash1)
		{
			###print "$key =>$hash1{$key}\n";

			print EDT $key . ":" . $hash1{$key} . "\n";
		}
		close(EDT);
		$SQL_FILES_LIST[$cnt]=$TMP_FILE;
	}

return @SQL_FILES_LIST;
}
#############################################################################################################################
#For the day tables without delta support
#############################################################################################################################
sub FinalNODeltaAggstructure{
my ($tp,$table)=@_;
my $test=getAggDS($tp,$table);
my %hash=%$test;
my %aggfinal=();
my %agghash=();
foreach my $key (sort keys %hash)
{
  my $value=$hash{$key};
  $key=~s/_RAW/_DAY/gi;
 
  $agghash{$key}=$value;
   
}
foreach my $key (sort keys %agghash)
{ 

  ###print "the day table is :$key=>$agghash{$key} \n";
 my @value1=undef;
 my @array=undef;
 my @value=split(',',$agghash{$key});
 foreach my $v (@value){
   if($v=~/=.*:SUM#.*/i)
     {
	   $v=~s/=.*:SUM/=10/gi;
	   

	  }
    elsif($v=~/=.*:AVG#.*/i)
     {
	   $v=~s/=.*:AVG/=2.5/gi;
	   

	  }
   elsif($v=~/=.*:MAX#.*/i)
     {
	   $v=~s/=.*:MAX/=4/gi;
	   

	  }
my $n1=undef;	  
my($a,$b)=split('#',$v);
if ($b==0)
{
  $n1=$a;
  print "here\n";
}

else{
 $n1="$a".".";
for(my $i=0;$i<$b;$i++)
{
  $n1="$n1"."0"
  
  
}

}
push @value1,$n1;	  
	  
   
  } 
 foreach my $value (@value1)
{
if($value=~/^.*=2\.5\..*/)
{
 $value=~s/2\.5\./2\.5/g;
}
push (@array,$value);
 }
 my $modval=join(',',@array);
$aggfinal{$key}=$modval;  
   

}
print "my final aggregation\n";
my %aggfinal1=();
foreach my $key (sort keys %aggfinal)
{
  my $value=$aggfinal{$key};
  if($value=~/^,,.*$/)
  {
    $value=~s/^,,//g;
  }
  if($value=~/^,.*$/)
   {
    $value=~s/^,//g;
   }
   $aggfinal1{$key}=$value;
  }
###foreach my $key (sort keys %aggfinal1)
###{
###  print "$key=>>>>>>$aggfinal1{$key}\n";
###}
return (\%aggfinal1);
}
######################################################################################################
sub getDeltaHash{
my ($tp,$table)=@_;
my $test=getAggDS($tp,$table);
my %hash=%$test;
my %aggfinal=();
my %agghash=();
my %aggfinal1=();
my %DBhash=();
my %hash1=();
my %hash2=();
my %hash3=();
foreach my $key (sort keys %hash)
{
  my $value=$hash{$key};
  $key=~s/_RAW/_COUNT/gi;
  print "the Count table is :$key\n";
  $agghash{$key}=$value;
   
}
foreach my $key (sort keys %agghash)
{ 

 my @value1=undef;
 my @value=split(',',$agghash{$key});
 foreach my $v (@value){
  my $n1=undef;	  
my($a,$b)=split('#',$v);
if ($b==0)
{
  $n1="$a"."#";
  print "here\n";
}

else{
 $n1="$a"."#".".";
for(my $i=0;$i<$b;$i++)
{
  $n1="$n1"."0"
  
  
}

}
push @value1,$n1;	  
	  
   
  } 
 my $modval=join(',',@value1);
$aggfinal{$key}=$modval;  
   

}
print "my final aggregation\n";
%aggfinal1=();
foreach my $key (sort keys %aggfinal)
{
  my $value=$aggfinal{$key};
  if($value=~/^,,.*$/)
  {
    $value=~s/^,,//g;
  }
  if($value=~/^,.*$/)
   {
    $value=~s/^,//g;
   }
   $aggfinal1{$key}=$value;
  }
###foreach my $key (sort keys %aggfinal1)
###{
  ###print "$key=>>>>>>$aggfinal1{$key}\n";
###}
foreach my $key (sort keys %aggfinal1 ) {
	
	
	    
	    my $v=$aggfinal1{$key};
		my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG:.*#/i)
			  {
			   $v1=~s/PEG:.*#/1/gi;
			   ##print " the couner:$v1\n";
			
               }
			  
			   elsif($v1=~/=GAUGE:.*#/i)
			   {
			   $v1=~s/=GAUGE:.*#/=2/gi;
			    ##print " the couner:$v1\n";
               }
			   
			   elsif($v1=~/=VECTOR:.*#/i)
			   {
			   $v1=~s/=VECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=CMVECTOR:.*#/i)
			   {
			   $v1=~s/=CMVECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }

		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash1{$key}=$modval;
	}

	foreach my $key (sort keys %aggfinal1 ) {
    
	    my $v=$aggfinal1{$key};
		my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG:.*#/i)
			  {
			   $v1=~s/PEG:.*#/1/gi;
			   ##print " the couner:$v1\n";
			
               }
			  
			   elsif($v1=~/=GAUGE:.*#/i)
			   {
			   $v1=~s/=GAUGE:.*#/=3/gi;
			    ##print " the couner:$v1\n";
               }
			   
			   elsif($v1=~/=VECTOR:.*#/i)
			   {
			   $v1=~s/=VECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=CMVECTOR:.*#/i)
			   {
			   $v1=~s/=CMVECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash2{$key}=$modval;
	      
	}

foreach my $key (sort keys %aggfinal1 ) {
    
	    my $v=$aggfinal1{$key};
		my @value=split(',',$v);
			foreach my $v1 (@value)
				{	
			next if ($v1=~/^.*=#.*$/i);
			next if ($v1=~/^.*=key#.*$/i);
			  if($v1=~/=PEG:.*#/i)
			  {
			   $v1=~s/PEG:.*#/1/gi;
			   ##print " the couner:$v1\n";
			
               }
			  
			   elsif($v1=~/=GAUGE:.*#/i)
			   {
			   $v1=~s/=GAUGE:.*#/=4/gi;
			    ##print " the couner:$v1\n";
               }
			   
			   elsif($v1=~/=VECTOR:.*#/i)
			   {
			   $v1=~s/=VECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               }
			   elsif($v1=~/=CMVECTOR:.*#/i)
			   {
			   $v1=~s/=CMVECTOR:.*#/=1/gi;
			    ##print " the couner:$v1\n";
               } 
		   
	      }
	

		   my @array=sort @value;
		  my $modval=join(',',@array);
		  $hash3{$key}=$modval;
	      
	}
	$DBhash{"15"} = \%hash1;
	$DBhash{"30"} = \%hash2;
	$DBhash{"45"} = \%hash3;
	
	###print "the dbhash\n";
	###foreach my $key (sort keys %DBhash) {
	#print $key . " : " . %DBhash->{$key} . "\n";
	 
	
	###foreach my $k (sort keys %{ $DBhash{$key} }) {
	###	print $key . "-" .  $k . "=>" . %{$DBhash{$key}}->{$k} . "\n"; 
	###}
	###}
return \%DBhash;
}
################################################################
sub getCountSql{
 my ($tp,$table)=@_;
	my $test=getAggDS($tp,$table);
 my %hash=%$test;
 my %hash_counters=();
 my %hash1=();
 my $date=$DATETIMEWARP;
 foreach my $key (sort keys %hash)
{
 next if ($key=~/^$/);
 my $value=$hash{$key};
 $key=~s/_RAW/_COUNT/g;
 my @valarr=undef;
 my @val=split(',',$value);
 foreach my $v (@val)
 {
 $v=~s/=.*//g;
 push (@valarr,$v);
 
 }
 my $value1=join(',',@valarr);
 
 $hash_counters{$key}=$value1;
 
}
	my @SQL_FILES_LIST = ();
	my $TMP_FILE;
	
	my $sql=undef;
	###print "the hash for sql\n";
	#$_=$a;
my $sn=undef;
	foreach my $key (sort keys %hash_counters)
	{
		###print "$key =>$hash_counters{$key}\n";
		my $sql=undef;
            if($key=~/DC_E_RAN_.*_V_COUNT|DC_E_RBS_.*_V_COUNT|DC_E_PRBS_.*_V_COUNT/i)
		{
	        	$sql=qq{select MIN_ID $hash_counters{$key} from $key where  and CONVERT(CHAR(8),DATE_ID,112) ='$date' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_SGSN_.*_COUNT/i)
		{
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  SGSN='SGSN01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_REDB_.*_COUNT/i)
		{
	       if($key=~/DC_E_REDB_.*_CLASS_COUNT|DC_E_REDB_FRAME.*_COUNT|DC_E_REDB_ATM_COUNT|DC_E_REDB_CHANNEL_COUNT/i)
			{	
		
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where   NE_NAME='CPG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		    }
			else
			{	
		
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where   NE_NAME='EdgeRtr01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		    }
		}
		elsif($key=~/DC_E_BSS_.*_COUNT/i)
		{
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  SN='BAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_CNAXE_.*_COUNT/i)
		{
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  SN='MAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}		
		elsif($key=~/DC_E_IMS_.*_COUNT/i)
		{     
	           if(/DC_E_IMS_CSCF.*_COUNT/)
				{	
	        	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  g3ManagedElement='CSCF01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}
				elsif(/DC_E_IMS_IPW_.*_COUNT/i)
				{
				 
				 $sql=qq{select MIN_ID  $hash_counters{$key} from $key where  g3ManagedElement='IPWk01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}
				else
				{
				$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  g3ManagedElement='IMS01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}				
		}		
		elsif($key=~/DC_E_IMSBG_.*_COUNT/i)
		{            	
	       	$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  NE_ID='ISSBG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date' and rowstatus='LOADED'};
		}
		elsif ($key=~/DC_E_CPP_.*_COUNT/i)
		{  $_=$key;
		    if(/DC_E_CPP_.*_V_COUNT/)
			{
				print "the cpp vector table :$key";
				$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};}
			else
			{
				print "the cpp normal table :$key";
				$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1' and rowstatus='LOADED'};
			}
		}
		else{
			$sql=qq{select MIN_ID  $hash_counters{$key} from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and rowstatus='LOADED'};
		}
		$hash1{$key}=$sql;
	}
	
	my @SQLFILES = glob "sql*txt";
	unlink @SQLFILES;
	
	my $count=undef;
	my $cnt = 0;
	my $hsize = keys %hash1;
	my $fsize=50;
	my $init=0;
	print "Number of Keys in Hash : $hsize\n";
	if ( $hsize > $fsize ) {
		my @list=sort keys %hash1;
		print "Hash Size : " . scalar @list . "\n";
		my $div = ($hsize / $fsize);
		my $mod = ($hsize % $fsize);
		if (index($div, ".") != -1) {
			$count = substr($div, 0, index($div, "."));
			my $tmp = substr($div, (index($div, ".")+1), length($div));
			if ( $tmp > 0 ) {
				$count = $count+1;
			}
			
			my $j;
			for($j=1;$j<=$count;$j++)
	        {
		        $TMP_FILE = "sql"."$j".".txt";

				if ( $j==$count ) {
					$fsize = $hsize;
				}
				
				open(EDT,"> $TMP_FILE");
				
				my $k;
				for($k=$init;$k<$fsize;$k++)
				{
					print $list[$k] . "=>" . $hash1{$list[$k]} . "\n";
					#print "$key =>$hash{$key}\n";
 
					print EDT $list[$k] . ":" . $hash1{$list[$k]} . "\n";
					#print EDT "$key:$hash{$key}\n";
				}
				close(EDT);
				$fsize=$fsize+50;
				$init=$k;
				$SQL_FILES_LIST[$cnt]=$TMP_FILE;
				$cnt = $cnt+1;
				print "Mis : $fsize : $init : $cnt : $j : $k\n";
			}
		}
	}
	else
	{
		$TMP_FILE = "sql1.txt";
		open(EDT,"> $TMP_FILE");
		foreach my $key (sort keys %hash1)
		{
			###print "$key =>$hash1{$key}\n";

		print EDT $key . "=>" . $hash1{$key} . "\n";
		}
		close(EDT);
		$SQL_FILES_LIST[$cnt]=$TMP_FILE;
	}

return @SQL_FILES_LIST;
}
############################################################################################################
#Check Delta Calulation
############################################################################################################
sub DeltaCalc{
my ($tp,$table)=@_;

my $result="";
$result.=qq{<h2>Validating Delta Calculation</h2>};
my @SQL_FILE_LIST =getCountSql($tp,$table);
my ($cHash) = getDeltaHash($tp,$table);
my %CSV_HASH = %$cHash;

my @DB_XML_FILES = glob "DB_XML*";
unlink @DB_XML_FILES;

foreach my $SQL_FILE (@SQL_FILE_LIST) {
	print "SQL_FILE : $SQL_FILE\n";
	system("perl readDB.t $SQL_FILE");
}
my ($test1,$test2)=readDBFile();
my %DB_HASH=%$test1;

my %MOD_HASH=();
while ((my $key, my $value) = each %DB_HASH) {
	my %hash=%$value;
	next if (!%hash);
	$MOD_HASH{$key}=$value;
}
while ((my $tab, my $mis) = each %MOD_HASH) {
	print "MODHASH  $tab : $mis\n";
}
my %diff=compare(\%CSV_HASH,\%MOD_HASH);

while ((my $tab, my $mis) = each %diff) {
	print "$tab : $mis\n";
}
$result.="<br><br>\n";

if (!%diff)
{
$result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>
                        <th align="center">RESULT ::</th>
                        <th>PASS</th>

           </tr></table>};
		 

}
else{
	
 $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>
                        <th align="center">RESULT ::</th>
                        <th>FAIL</th>
           </tr></table>};

$result.="<br><br>\n";
$result.=qq{<h2> Failed Instances :: </h2>};
$result.="<br><br>\n";
         $result.="<br><br>\n";
         $result.=qq{<table border="0"><tr><th>ROP wise details of the table</th></tr></table>};
		 $result.="<br>\n";
		  my %hash1=();
		  my %hash2=();
		  my %hash3=();
		  my %hash4=();
          
		  foreach my $key (keys %diff)
		  {	 
		   
		    if ($key=~/^15-.*$/)
				{ $hash2{$key}=$diff{$key}};
				if ($key=~/^30-.*$/)
				{ $hash3{$key}=$diff{$key}};
				if ($key=~/^45-.*$/)
				{ $hash4{$key}=$diff{$key}};
		   }
		   
		   my @hasharray=undef;
		  
		   push(@hasharray,\%hash2);
		   push(@hasharray,\%hash3);
		   push(@hasharray,\%hash4);
		   my %hash=();
		    foreach my $j (sort @hasharray)
		   {
		    $_=$j;
			next if(/^$/);
		    print " the hash $j";
			 my $hashref=$j;
			 %hash =%{$hashref};
			
			 #my $min=~s/=.*$//g;
		   if(%hash){
		   my @min = grep { $_ =~ /^.*-DC_.*$/ } keys %hash;
		   my ($m,$t)=split('-',$min[0]);
		   $result.=qq{<table border="0"><tr><th>Time  ::  10:$m</th></tr></table>};
		   
		   $result.="<br>\n";
		   my @arrayemp=undef;
		   foreach my $key (keys %hash)
				{
				 $_=$hash{$key};
				 if(/^$/)
				 {
				   $key=~s/^.*-//g;
				   print $key;
				   push(@arrayemp,$key);
				 }
				 else{
						my $k=$key;
						$k=~s/^.*-//g;
						$result.="<h3><b>$k</b></h3>\n\n";
						$result.="<br><br>\n";
  
 $result.=qq{<table  BORDER="1"
CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>

						<th>Counters missed in DB</th>

                         <th>Counters with value mismatch</th>

						<th>Counter with Null Values </th>
                       </tr>
                        };
						
									my @array=undef;
									my @array1=undef;
									my @array2=undef;
									my $value=$diff{$key};
									my @values=split(':',$value);
                                foreach my $i(@values)
{
                if ($i=~/^\w+=\d+$/ || $i=~/^\w+=\d+\.\d+$/){

                 my @arr=split('=',$i);
                 push(@array,$arr[0]);

                 }
                                if($i=~/^\w+=\d+,\w+=\d+$/ || $i=~/^\w+=\d+\.\d+,\w+=\d+\.\d+$/)
                                {  my @arr=split('=',$i);
                                    push(@array1,$arr[0]);
                                }

                                 if($i=~/^\w+=.*,\w+=$/)
                                { my @arr=split('=',$i);
                                    push(@array2,$arr[0]);
                                }


      }

			$result.=qq{
                       <tr>

						<td>@array</td>

                         <td>@array1</td>

							<td>@array2</td>
                       </tr>
                        };
                $result.=qq{</table>};
                $result.="<br><br>\n";
			
			 
				 }
			 
				}
				
	if (scalar @arrayemp !=0)			
	{			
 	$result.=qq{<table border="0"><tr><th>List of COUNT tables with no data for the entire rop</th></tr></table>};	    
	$result.="<br><br>\n";
	$result.= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" >};

$result.= "<tr>".join("", map { "<td>${_}</td>" } @arrayemp)."</tr>\n";

$result.="</table>";
		   
	}	
}	
}			
}
return $result;
}
#################################################################################
#Get aggstructure for the tables with delta support
##################################################################################

sub FinalDeltaAggstructure{
my ($tp,$table)=@_;
my $test=getAggDS($tp,$table);
my %hash=%$test;
my %aggfinal=();
my %agghash=();
foreach my $key (sort keys %hash)
{
  my $value=$hash{$key};
  $key=~s/_RAW/_DAY/gi;
  print "the day table is :$key\n";
  $agghash{$key}=$value;
   
}
foreach my $key (sort keys %agghash)
{ 

 my @value1=undef;
 my @array=undef;
 my @value=split(',',$agghash{$key});
 foreach my $v (@value){
   if($v=~/=PEG:SUM#.*/i)
     {
	   $v=~s/PEG:SUM/3/gi;
	  }
    elsif($v=~/=PEG:AVG#.*/i)
     {
	   $v=~s/PEG:AVG/1/gi;
	   

	  }
   elsif($v=~/=PEG:MAX#.*/i)
     {
	   $v=~s/PEG:MAX/1/gi;
	   

	  }
	  if($v=~/=GAUGE:SUM#.*/i)
     {
	   $v=~s/GAUGE:SUM/9/gi;
	   

	  }
    elsif($v=~/=GAUGE:AVG#.*/i)
     {
	   $v=~s/GAUGE:AVG/3/gi;
	   

	  }
   elsif($v=~/=GAUGE:MAX#.*/i)
     {
	   $v=~s/PEG:MAX/4/gi;
	   

	  }
my $n1=undef;	  
my($a,$b)=split('#',$v);
if ($b==0)
{
  $n1=$a;
  print "here\n";
}

else{
 $n1="$a".".";
for(my $i=0;$i<$b;$i++)
{
  $n1="$n1"."0"
   
}

}
push @value1,$n1;	  
  
  } 
 foreach my $value (@value1)
{
if($value=~/^.*=2\.5\..*/)
{
 $value=~s/2\.5\./2\.5/g;
}
push (@array,$value);
 }
 my $modval=join(',',@array);
$aggfinal{$key}=$modval;  
   
}
print "my final aggregation delta\n";
my %aggfinal1=();
foreach my $key (sort keys %aggfinal)
{
  my $value=$aggfinal{$key};
  if($value=~/^,,.*$/)
  {
    $value=~s/^,,//g;
  }
  if($value=~/^,.*$/)
   {
    $value=~s/^,//g;
   }
   $aggfinal1{$key}=$value;
  }
###foreach my $key (sort keys %aggfinal1)
###{
###  print "$key=>>>>>>$aggfinal1{$key}\n";
###}
return (\%aggfinal1);
}
############################################################################
#Aggregation of day tables
############################################################################
sub Aggregation{
my $result="";
my ($tp,$deltable,$table)=@_;
my @tabarray=();
my @deltarray=();
@tabarray=@$table;
@deltarray=@$deltable;
my @SQL_FILE_LIST =();
my $cHash=undef;
my $cHash1=undef;
my %CSV_HASH=();
if(!@tabarray && !@deltarray){
$cHash = FinalNODeltaAggstructure($tp,$table);
@SQL_FILE_LIST =getAggSql($tp,$table);
%CSV_HASH = %$cHash;
}
else{
$cHash1=FinalDeltaAggstructure($tp,$deltable);
$cHash = FinalNODeltaAggstructure($tp,$table);
my @a1=getAggSql($tp,$table);
my @a2=getAggSql($tp,$deltable);
@SQL_FILE_LIST= (@a1, @a2);
my %hash1= %$cHash;
my %hash2 =%$cHash1;
%CSV_HASH = (%hash1, %hash2);

}

my @DB_XML_FILES = glob "DB_XML*";
unlink @DB_XML_FILES;

foreach my $SQL_FILE (@SQL_FILE_LIST) {
	print "SQL_FILE : $SQL_FILE\n";
	system("perl readDB.t $SQL_FILE");
}
print "\n";
my($test,$test1)=readDBFile();
my %DB_HASH= %$test1;
print "the DBHASH>>>>>>\n";
while ((my $tab, my $mis) = each %DB_HASH) {
	print "$tab : $mis\n";
}

my %result=compareAgg(\%CSV_HASH,\%DB_HASH);

print "the agg compare\n";
while ((my $tab, my $mis) = each %result) {
	print "$tab : $mis\n";
}

$result.="<br><br>\n";


if (!%result)
{

$result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>
                        <th align="center">RESULT ::</th>
                        <th>PASS</th>

           </tr></table>};
		   print "paSS\n";

}



else{
 print "fail\n";
	
 $result.=qq{<table  BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>
                        <th align="center">RESULT ::</th>
                        <th>FAIL</th>

           </tr></table>};

$result.="<br><br>\n";
$result.=qq{<h2> Failed Instances :: </h2>};
$result.="<br><br>\n";
 my @nonagg=();
foreach my $key (keys %result)
				{
				
				
	if($result{$key}=~/^$/){
		###print "the key with empty value $key=>$result{$key}\n";
		push (@nonagg,$key)
	}
else {
				        my $k=$key;
						
	 $result.=qq{Failed instances for the Table :$key};	 
  
 $result.=qq{<table  BORDER="1"
CELLSPACING="0" CELLPADDING="0" WIDTH="50%" >
                       <tr>
						<th>Counters wrongly aggregated</th>

						<th>Counters not aggregated </th>
                       </tr>
                        };
						my @array1=undef;
						my @array2=undef;
						my $value=$result{$key};
						my @values=split(':',$value);
                           foreach my $i(@values)
							{
                                if($i=~/^\w+=.*,\w+=.*$/)
                                {  my @arr=split('=',$i);
                                    push(@array1,$arr[0]);
                                }

								if($i=~/^\w+=.*,\w+=$/)
                                { my @arr=split('=',$i);
                                    push(@array2,$arr[0]);
                                }
      }

			print "The array @array1\n"	;		
						
			$result.=qq{
                       <tr>

				            <td>@array1</td>

							<td>@array2</td>
                       </tr>
                        };
                $result.=qq{</table>};
                $result.="<br><br>\n";
		 
				 }			 
}
if(@nonagg)
{
print "the list\n";
$result.="<br><br>\n";
	print "@nonagg\n";
	$result.=qq{<table border="0"><tr><th>List of non agggregated table </th></tr></table>};	    
	$result.="<br>\n";
	$result.= qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" >};

$result.= "<tr>".join("", map { "<td>${_}</td>" } @nonagg)."</tr>\n";

$result.="</table>";

}
}
return $result;
}
##################################################################
sub compareAgg {
	my($h1,$h2)= @_;

        my %csvhash = %$h1;
        my %dbhash = %$h2;
	my %res = ();
            while ((my $table, my $csvCounter) = each %csvhash) {
			if (! exists($dbhash{$table}) ) {
				$res{"$table"} = ''; 
			}
			else {
				#print "\t\tCSV HASH : " . $csvCounter . "\n";
				#print "\t\tDB HASH : " . $dbhash{$rop}{$table} . "\n";
		
				my %csvCounterHash = parseAgg($csvCounter);
				my %dbCounterHash = parseAgg($dbhash{$table});

				my $mismatch = compareAggHash(\%csvCounterHash,\%dbCounterHash);
				if ( $mismatch ne '' ) {
					$res{"$table"} = $mismatch;
				}
			}
                }
                print "\n\n";
      
	return %res;
}
############################################################################################

sub compareAggHash
{
        my($h1,$h2)= @_;

        my %csvhash = %$h1;
        my %dbhash = %$h2;
        my $diff = '';
        my $cnt=0;

        while ( (my $key,my $value) = each %csvhash ) {
               
		
			my $dbValue = %dbhash->{$key};
                	if ($value ne $dbValue) {
                        	if ($diff eq '') {
                                	$diff = "$key=$value,$key=$dbValue";
                        	} else {
                                	$diff = $diff . ":" . "$key=$value,$key=$dbValue";
                        	}
			}
                
        }
        return $diff;
}
#################################################################################
sub getCountRows{
 my ($tp,$table)=@_;
	my $test=getAggDS($tp,$table);
 my %hash=%$test;
 my %hash_counters=();
 #my %hash_counters=();
 my %hash1=();
 my $date=$DATETIMEWARP;
 foreach my $key (sort keys %hash)
{
 next if ($key=~/^$/);
 my $value=$hash{$key};
 $key=~s/_RAW/_COUNT/g;
 my @valarr=undef;
 my @val=split(',',$value);
 foreach my $v (@val)
 {
 $v=~s/=.*//g;
 push (@valarr,$v);
 
 }
 my $value1=join(',',@valarr);
 
 $hash_counters{$key}=$value1;

}
	my @SQL_FILES_LIST = ();
	my $TMP_FILE;
	
	my $sql=undef;
	###print "the hash for sql\n";
	#$_=$a;
my $sn=undef;



	foreach my $key (sort keys %hash_counters)
	{
		###print "$key =>$hash_counters{$key}\n";
		my $sql=undef;
            if($key=~/DC_E_RAN_.*_V_COUNT|DC_E_RBS_.*_V_COUNT|DC_E_PRBS_.*_V_COUNT/i)
		{
	        	$sql=qq{select count(*) from $key where  and CONVERT(CHAR(8),DATE_ID,112) ='$date' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_SGSN_.*_COUNT/i)
		{
	        	$sql=qq{select count(*) from $key where  SGSN='SGSN01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_REDB_.*_COUNT/i)
		{
	       if($key=~/DC_E_REDB_.*_CLASS_COUNT|DC_E_REDB_FRAME.*_COUNT|DC_E_REDB_ATM_COUNT|DC_E_REDB_CHANNEL_COUNT/i)
			{	
		
	        	$sql=qq{select count(*) from $key where   NE_NAME='CPG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		    }
			else
			{	
		
	        	$sql=qq{select count(*) from $key where   NE_NAME='EdgeRtr01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		    }
		}
		elsif($key=~/DC_E_BSS_.*_COUNT/i)
		{
	        	$sql=qq{select count(*) from $key where  SN='BAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		elsif($key=~/DC_E_CNAXE_.*_COUNT/i)
		{
	        	$sql=qq{select count(*) from $key where  SN='MAA01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
		}
		
		elsif($key=~/DC_E_IMS_.*_COUNT/i)
		{     
	           if(/DC_E_IMS_CSCF.*_COUNT/)
				{	
	        	$sql=qq{select count(*) from $key where  g3ManagedElement='CSCF01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}
				elsif(/DC_E_IMS_IPW_.*_COUNT/i)
				{
				 
				 $sql=qq{select count(*) from $key where  g3ManagedElement='IPWk01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}
				else
				{
				$sql=qq{select count(*) from $key where  g3ManagedElement='IMS01' and CONVERT(CHAR(8),DATE_ID,112) ='$date'  and rowstatus='LOADED'};
				}
		}
	
		elsif($key=~/DC_E_IMSBG_.*_COUNT/i)
		{
	            	
	        	$sql=qq{select count(*) from $key where  NE_ID='ISSBG01' and CONVERT(CHAR(8),DATE_ID,112) ='$date' and rowstatus='LOADED'};
		}
		elsif ($key=~/DC_E_CPP_.*_COUNT/i)
		{  $_=$key;
		    if(/DC_E_CPP_.*_V_COUNT/)
			
			{
			print "the cpp vector table :$key";
			$sql=qq{select count(*) from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1' and DCVECTOR_INDEX=1 and rowstatus='LOADED'};}
			else
			{
			print "the cpp normal table :$key";
			$sql=qq{select count(*) from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and SN='SubNetwork=ONRM_ROOT_MO,SubNetwork=RNC1,MeContext=RNC1' and rowstatus='LOADED'};
			
			}
			
		}
		else{
			if ($key ne "")
			{
				$sql=qq{select count(*) from $key where  CONVERT(CHAR(8),DATE_ID,112) ='$date' and rowstatus='LOADED'};
			}
			else
			{
				print "Empty Key..\n";
			}
		}
		$hash1{$key}=$sql;
	}

	
	my @SQLFILES = glob "sql*txt";
	unlink @SQLFILES;
	
	my $count=undef;
	my $cnt = 0;
	my $hsize = keys %hash1;
	my $fsize=50;
	my $init=0;
	print "Number of Keys in Hash : $hsize\n";
	if ( $hsize > $fsize ) {
		my @list=sort keys %hash1;
		print "Hash Size : " . scalar @list . "\n";
		my $div = ($hsize / $fsize);
		my $mod = ($hsize % $fsize);
		if (index($div, ".") != -1) {
			$count = substr($div, 0, index($div, "."));
			my $tmp = substr($div, (index($div, ".")+1), length($div));
			if ( $tmp > 0 ) {
				$count = $count+1;
			}
			
			my $j;
			for($j=1;$j<=$count;$j++)
	        {
		        $TMP_FILE = "sql"."$j".".txt";

				if ( $j==$count ) {
					$fsize = $hsize;
				}
				
				open(EDT,"> $TMP_FILE");
				print "TMP_FILE created : $TMP_FILE\n";
				
				my $k;
				for($k=$init;$k<$fsize;$k++)
				{
					###print $list[$k] . "=>" . $hash1{$list[$k]} . "\n";
					#print "$key =>$hash{$key}\n";
 
					print EDT $list[$k] . ":" . $hash1{$list[$k]} . "\n";
					#print EDT "$key:$hash{$key}\n";
				}
				close(EDT);
				$fsize=$fsize+50;
				$init=$k;
				$SQL_FILES_LIST[$cnt]=$TMP_FILE;
				$cnt = $cnt+1;
				###print "Mis : $fsize : $init : $cnt : $j : $k\n";
			}
		}
	}
	else
	{
		$TMP_FILE = "sql1.txt";
		open(EDT,"> $TMP_FILE");
		foreach my $key (sort keys %hash1)
		{
			###print "$key =>$hash1{$key}\n";

		print EDT $key . "=>" . $hash1{$key} . "\n";
		}
		close(EDT);
		$SQL_FILES_LIST[$cnt]=$TMP_FILE;
	}

return @SQL_FILES_LIST;
}
##################################################################################33
sub RowCount{
my $result="";
my ($tp,$deltable)=@_;
my @SQL_FILE_LIST =();
@SQL_FILE_LIST=getCountRows($tp,$deltable);
my @DB_XML_FILES = glob "DB_XML*";
unlink @DB_XML_FILES;
my @table=();
$result.="<h2>Following count tables for the techpack $tp have more than 3 rows for a MOID <h2>";
$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><th>Tables</th></tr>};
foreach my $SQL_FILE (@SQL_FILE_LIST) {
	print "SQL_FILE : $SQL_FILE\n";
	system("perl readDB.t $SQL_FILE");
}
	my @DB_FILES_LIST = glob "DB_XML*";
	
	foreach my $DB_FILE (@DB_FILES_LIST) {
	
		my @lines = read_file($DB_FILE);
		my $linenumber = 0;
	
		foreach (@lines) {
			$linenumber++;
			
			if(($linenumber > 2) && ($linenumber < $#lines)) { 	  
				$_ =~ s/[\/><]//g;
				my @fields = split " " , $_;
				my $key = $fields[0];    
		        $fields[1]=~s/count\(\)=//g;
				$fields[1]=~s/\"//g;
				$fields[1]=~s/\s+//;
				my $value=$fields[1];
				print "the count is $value and $key \n";
				if($value > 3)
				{
				  push(@table,$key);
				 }
				
			   }
			}
}
if(@table)
{
$result.="<h2>Following count tables for the techpack $tp have more than 3 rows for a MOID <h2>";
$result.=qq{<table  BORDER="1" CELLSPACING="0" CELLPADDING="0" WIDTH="50%" ><tr><th>Tables</th></tr>};
$result.= "<tr>".join("", map { "<td>${_}</td>" } @table)."</tr>\n";
$result.=</table>;
}
#$result.=</table>;
}

#########################################################
# This subroutine 'comboTC' writes the HTML Log output  #
# of all the merged TestCase logs						#
#########################################################

sub comboTC
{
	my $report_body = shift;
	my $count = shift;
	my $Rep = shift;
	my $End = shift;
	my $combo = shift;
	my %combo_TC = (
		"verifyUniverses","Universe_and_Alarm_Report_Verification",
		"adminUI","ADMINUI_PLATFORM_CHECKS",
		"server","Sanity_Directory_Scripts_Check",
		"verifytopology","VERIFY TOPOLOGY TABLES",
		);
	my $fail =()= $count =~ /_FAIL_+/g;
	my $pass =()= $count =~ /_PASS_+/g;
	$Rep .= getEndTimeHeader_Combo($pass,$fail,$End);
	if ($fail == 0)
	{
		$Rep .= "<p><font size=8 color=006600><b>NO FAILED TESTCASES</b></font></p>";
	}
	else
	{
		$Rep .= $report_body;
	}
	$Rep.= getHtmlTail();
	if ($count ne "")
	{
		my $file = writeHtml($combo_TC{$combo},$Rep);
		print "$combo_TC{$combo}: PASS- $pass FAIL- $fail\n"; 
		print "PARTIAL FILE: $file\n";
	}
	
}

#####################################################################
# The subroutine 'set_cfg' changes the dwhdb.cfg amd repdb.cfg file #
# to 200 DB connections. The subroutine 'unset_cfg' changes the     #
# dwhdb.cfg amd repdb.cfg file back to default 100 DB connections   #
#####################################################################

sub set_cfg
{
	my $undef_cfg=undef;

	my $delim = `echo \$PS1`;
	chomp($delim);
	$delim = substr($delim,-2);

	my $exp = new Expect;
	
	system("/usr/bin/chmod 777 /eniq/database/dwh_main/dwhdb.cfg");

	open(FILEOPEN,'/eniq/database/dwh_main/dwhdb.cfg');
	my @array =<FILEOPEN>;
	chomp(@array);
	close (FILEOPEN);

	open(FILEOPEN1,'>/eniq/database/dwh_main/dwhdb.cfg');
	foreach (@array)
	{
		chomp($_);
		if( $_ =~ s/-gm.+/-gm 300/ )
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
		else 
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
	}
	close(FILEOPEN1);

	system("/usr/bin/chmod 440 /eniq/database/dwh_main/dwhdb.cfg");
	
	system("/usr/bin/chmod 777 /eniq/database/rep_main/repdb.cfg");
	
	open(FILEOPEN,'/eniq/database/rep_main/repdb.cfg');
	@array =<FILEOPEN>;
	chomp(@array);
	close (FILEOPEN);
	
	open(FILEOPEN1,'>/eniq/database/rep_main/repdb.cfg');
	foreach (@array)
	{
		chomp($_);
		if( $_ =~ s/-gm.+/-gm 300/ )
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
		else 
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
	}
	close(FILEOPEN1);

	system("/usr/bin/chmod 440 /eniq/database/rep_main/repdb.cfg");
	
	$exp->spawn("/usr/bin/bash");
	
	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("su - root\r");}]);
	$exp->expect(5);
	
	$exp->expect($undef_cfg, [":", sub {$exp = shift; $exp->send("shroot\r");}]);
	$exp->expect(2);

	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("cd /eniq/admin/bin\r");}]);
	$exp->expect(2);

	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("bash ./manage_deployment_services.bsh -a restart -s ALL\r");}]);
	$exp->expect(5);

	$exp->expect($undef_cfg, [":", sub {$exp = shift; $exp->send("Yes\r");}]);
	$exp->expect(100);
	
	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("su - dcuser\r");}]);
	$exp->expect(5);
}

sub unset_cfg
{
	my $undef_cfg=undef;

	my $delim = `echo \$PS1`;
	chomp($delim);
	$delim = substr($delim,-2);

	my $exp = new Expect;
	
	system("/usr/bin/chmod 777 /eniq/database/dwh_main/dwhdb.cfg");

	open(FILEOPEN,'/eniq/database/dwh_main/dwhdb.cfg');
	my @array =<FILEOPEN>;
	chomp(@array);
	close (FILEOPEN);

	open(FILEOPEN1,'>/eniq/database/dwh_main/dwhdb.cfg');
	foreach (@array)
	{
		chomp($_);
		if( $_ =~ s/-gm.+/-gm 100/ )
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
		else 
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
	}
	close(FILEOPEN1);

	system("/usr/bin/chmod 440 /eniq/database/dwh_main/dwhdb.cfg");
	
	system("/usr/bin/chmod 777 /eniq/database/rep_main/repdb.cfg");
	
	open(FILEOPEN,'/eniq/database/rep_main/repdb.cfg');
	@array =<FILEOPEN>;
	chomp(@array);
	close (FILEOPEN);
	
	open(FILEOPEN1,'>/eniq/database/rep_main/repdb.cfg');
	foreach (@array)
	{
		chomp($_);
		if( $_ =~ s/-gm.+/-gm 100/ )
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
		else 
		{
			print FILEOPEN1 $_ ;
			print FILEOPEN1 "\n";
		}
	}
	close(FILEOPEN1);

	system("/usr/bin/chmod 440 /eniq/database/rep_main/repdb.cfg");
	
	$exp->spawn("/usr/bin/bash");
	
	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("su - root\r");}]);
	$exp->expect(5);
	
	$exp->expect($undef_cfg, [":", sub {$exp = shift; $exp->send("shroot\r");}]);
	$exp->expect(2);

	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("cd /eniq/admin/bin\r");}]);
	$exp->expect(2);

	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("bash ./manage_deployment_services.bsh -a restart -s ALL\r");}]);
	$exp->expect(5);

	$exp->expect($undef_cfg, [":", sub {$exp = shift; $exp->send("Yes\r");}]);
	$exp->expect(100);
	
	$exp->expect($undef_cfg, [$delim, sub {$exp = shift; $exp->send("su - dcuser\r");}]);
	$exp->expect(5);
}

#####################################################################
# The subroutine 'getMwsPath' will get the path to the platform and #
# feature modules which are stored in the MWS server for the        #
# current CI run													#
#####################################################################
sub getMwsPath{
	my $mwsPath = '/net/10.45.192.153/JUMP/ENIQ_STATS/ENIQ_STATS/';
	my $plat = "";
	my $feat = "";
	my $mwsip = "";
	open(MWSPROPS, '< /eniq/home/dcuser/mws.properties') or warn("Cannot read mws.properties file!!\n");
	my @mwsFile = <MWSPROPS>;
	chomp(@mwsFile);
	close MWSPROPS;
	foreach my $path (@mwsFile){
		$_ = $path;
		if(/^Platform=/){
			my @input = split("=",$path);
			$plat = $input[1];
		}
		if(/^Feature=/){
			my @input = split("=",$path);
			$feat = $input[1];
		}
		if(/^MWS IP=/){
			my @input = split("=",$path);
			$mwsip = $input[1];
		}
	}
	$mwsPath = '/net/'.$mwsip.'/JUMP/ENIQ_STATS/ENIQ_STATS/';
	$plat = $mwsPath.$plat;
	$feat = $mwsPath.$feat;
	return ($plat,$feat);
}

#####################################################################
# The subroutine 'getDBPassword' will get the password according to #
# the username provided using the 'dbusers' utility that is         #
# present in '/eniq/sw/installer'									#
#####################################################################
sub getDBPassword{
	my $user = $_[0];
	my $dbusers = "/eniq/sw/installer/dbusers";
	my $dwhconn = "";
	
	if($user eq "dc"){
		$dwhconn = "dwh";
	}
	elsif($user eq "dwhrep"){
		$dwhconn = "dwhrep";
	}
	elsif($user eq "etlrep"){
		$dwhconn = "etlrep";
	}
	
	my $pwd = `$dbusers $user $dwhconn`;
	
	return $pwd;
}

#####################################END OF RT SCRIPT###############################################