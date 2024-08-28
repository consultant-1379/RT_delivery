#!/bin/bash

cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

for file in "$SIMPATH/sim_feature_test/testFiles/preMinsatThirdROP/*"
do
	cp $file /export/home/minsat/DE
done

echo "Finished loading MINSATss with >30 files"


