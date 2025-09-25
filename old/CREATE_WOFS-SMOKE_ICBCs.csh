#!/bin/tcsh

source ~/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

cd $RUNDIR


echo "Starting the WPS for BCs1 process"
#${SCRIPTDIR}/RUN_WPS-Smoke_ICBCs.csh 

echo "Creating Hourly Initial Conditions/Boundary Conditions (ICBC)"
${SCRIPTDIR}/RUN_Smoke_ICBCs.csh 


exit(0)

