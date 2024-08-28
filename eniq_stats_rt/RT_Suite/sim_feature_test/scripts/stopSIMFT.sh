#!/bin/bash

kill $(ps -ef | grep '[s]im') | nawk '{ print $2 }')

echo 'All sim feature test processes have been killed'
