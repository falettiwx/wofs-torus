#!/bin/csh

source /home/william.faletti/wof-torus/torusenv
source ${TOP_DIR}/realtime.cfg.${event}

cd $RUNDIR


echo "Starting the WPS for ICBCs process"
#/bin/csh ${SCRIPTDIR}/RUN_WPS_ICBCs.csh 
#>>&! ${logWPSBCs}
#exit(0)

echo "Starting the ICBC generation process"
rm -f ${SEMA4}/bc_mem*_done

set n = 1
while ( $n <= $HRRRE_BCS )
   echo "Creating ICBCs for Mem$n"
   ${SCRIPTDIR}/RUN_REAL_ICBCs.csh ${n} 
   #>>&! ${logREALBCs}

@ n++
end

while ( `ls -f ${SEMA4}/bc_mem*done | wc -l` != ${HRRRE_BCS} )
   sleep 5
   echo "Waiting for BC generation to finish"
end

touch ${SEMA4}/HRRRE_ICBCs_ready

exit (0)
