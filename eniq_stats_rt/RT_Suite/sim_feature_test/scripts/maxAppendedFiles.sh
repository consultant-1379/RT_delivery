#!/bin/bash

DESTDIR="/var/opt/fds/statistics"
INPUTDIR="/eniq/sw/platform/sim-R1C20b40/sim_feature_test/testFiles/maxFilesForAppended/*"




for file in $INPUTDIR
do
	cp $file $DESTDIR
done

echo "Finished inputting max files for Appended MAx file collection test case"

