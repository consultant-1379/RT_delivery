#!/bin/bash

cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

for file in "$SIMPATH/sim_feature_test/testFiles/preSDPThirdROP/*"
do
	cp $file /var/opt/fds/statistics
done
echo "Finished loading SDP with > 30 files"



