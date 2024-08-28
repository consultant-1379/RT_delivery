#!/bin/bash

cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

FILES="$SIMPATH/sim_feature_test/testFiles/preSecondROP/*"

SRCMIN="/export/home/minsat/DE"
SRCIVR="/var/opt/vxml-ivr/env_prod/reports"
SRCSTAT="/var/opt/fds/statistics"
SRCCCN="/opt/telorb/axe/tsp/NM/PMF/reporterLogs/"
SRCOCC="/opt/occ/var/performance/pm3gppXml"
CNT="CcnCounters"
DIA="DiameterMeasures"
PLA="PlatformMeasures"


i=0



DIRS=($SRCIVR $SRCOCC "$SRCCCN$PLA" "$SRCCCN$CNT" "$SRCCCN$DIA" $SRCMIN $SRCSTAT)

for file in $FILES
do
	cp $file ${DIRS[i]}
	let i=i+1
done
echo "Finished moving files for the second ROP collection"

