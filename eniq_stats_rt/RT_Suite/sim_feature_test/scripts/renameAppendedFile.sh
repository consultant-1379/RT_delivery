#!/bin/bash

DATE=$(date +-20%y-%m-%d-0000.stat)

cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

AIR="$SIMPATH/sim_feature_test/testFiles/preFirstROP/FSC*"
VS="$SIMPATH/sim_feature_test/testFiles/preFirstROP/AUV*"

PATHAIR="$SIMPATH/sim_feature_test/testFiles/preFirstROP/"
PATHVS="$SIMPATH/sim_feature_test/testFiles/preFirstROP/"

for f in $AIR
do
	file=$f
done


for f in $VS 
do
	file2=$f
done

while IFS='/' read -ra D
do
	name="${D[8]}"
done <<<"$file"



while IFS='/' read -ra D
do
		
	name2="${D[8]}"
	
done <<<"$file2"

HYPEN="-"

while IFS='-' read -ra D
do
	newName="${D[0]}$HYPEN${D[1]}$DATE"
done <<<"$name"

while IFS='-' read -ra D
do
	newName2="${D[0]}$HYPEN${D[1]}$DATE"
done <<<"$name2"

mv $file "$PATHAIR$newName"
mv $file2 "$PATHVS$newName2"

echo "Updated the AIR and VS node files to todays date"