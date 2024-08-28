#!/bin/bash

cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

IVRFILES="$SIMPATH/sim_feature_test/testFiles/preThirdROP/*XMLIVR"
OCCFILES="$SIMPATH/sim_feature_test/testFiles/preThirdROP/*.xml"
CCNFILES="$SIMPATH/sim_feature_test/testFiles/preThirdROP/*CcnCounters"
DIAFILES="$SIMPATH/sim_feature_test/testFiles/preThirdROP/*Diameter*"
PLAFILES="$SIMPATH/sim_feature_test/testFiles/preThirdROP/*PlatformMeasures"

SRCPLA="/opt/telorb/axe/tsp/NM/PMF/reporterLogs/PlatformMeasures"
SRCOCC="/opt/occ/var/performance/pm3gppXml"
SRCIVR="/var/opt/vxml-ivr/env_prod/reports"
SRCCNT="/opt/telorb/axe/tsp/NM/PMF/reporterLogs/CcnCounters"
SRCDIA="/opt/telorb/axe/tsp/NM/PMF/reporterLogs/DiameterMeasures"
for file in $IVRFILES
do
	cp $file $SRCIVR
done

for file in $OCCFILES
do
	cp $file $SRCOCC
done

for file in $CCNFILES
do
	cp $file $SRCCNT
done

for file in $DIAFILES
do
	cp $file $SRCDIA
done

for file in $PLAFILES
do
	cp $file $SRCPLA
done


echo "Successfully loaded files for max rop test casees"

