#!/bin/bash


cd /eniq/sw/platform/sim*
SIMPATH=$(pwd)

#SIMPATH=/eniq/sw/platform/sim-R1C20b40


JAVA=/eniq/sw/runtime/jdk1.7.0_80/jre/bin/java
JYTHON="$SIMPATH/sim_feature_test/jython.jar"
SIM="$SIMPATH/sim_feature_test/sim.jar"
SIMFT="$SIMPATH/sim_feature_test/simft.jar"
MAINCLASS="com.ericsson.sim.featureTest.engine.Engine"

CPATH=$JYTHON:$SIM:$SIMFT

$JAVA -cp $CPATH $MAINCLASS >/dev/null 2>&1 &