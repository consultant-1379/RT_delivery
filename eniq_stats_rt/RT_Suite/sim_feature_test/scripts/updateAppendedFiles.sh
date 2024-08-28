#!/bin/bash

echo "RUNNING UPDATE MODIFICATION SCRIPT FOR APPENDED"

FILES="/var/opt/fds/statistics/*"


for f in $FILES 

do
 	touch $f
done
