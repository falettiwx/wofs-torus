#!/bin/csh

set echo

source /home/william.faletti/wof-torus/torusenv
source /scratch/wof-torus/realtime.cfg.${event}

#CLEAN UP OLD STUFF
rm -R ${RUNDIR}/advance_temp*
rm -R ${RUNDIR}/OBSOUT
#rm ${RUNDIR}/*nc
rm ${RUNDIR}/*err
rm ${RUNDIR}/*csh
rm ${RUNDIR}/*job
rm ${RUNDIR}/*log
rm ${RUNDIR}/*done
rm ${RUNDIR}/obs_seq.*
rm ${RUNDIR}/start_*
rm ${RUNDIR}/blown_*
rm ${RUNDIR}/last*
rm ${RUNDIR}/finish*
rm ${RUNDIR}/cfl*
rm ${RUNDIR}/dart_log*
rm ${RUNDIR}/input*nc
rm ${RUNDIR}/output_*nc
rm ${RUNDIR}/preas*nc

mkdir ${RUNDIR}/OBSOUT

foreach dir ( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 )
  mkdir ${RUNDIR}/advance_temp${dir}
  cp ${RUNDIR}/mem${dir}/wrfinput_d01.${dir} ${RUNDIR}/advance_temp${dir}/wrfinput_d01
  #cp ${RUNDIR}/mem${dir}/wrfbdy_d01.${dir} wrfbdy_d01
  cp ${RUNDIR}/advance_temp${dir}/wrfinput_d01 ${RUNDIR}/advance_temp${dir}/wrfinput_d01_orig
end

#foreach dir ( 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 )

#mkdir ${RUNDIR}/advance_temp${dir}

#cp ${RUNDIR}/mem${dir}/wrfinput_d01_ic ${RUNDIR}/advance_temp${dir}/wrfinput_d01
#cp ${RUNDIR}/advance_temp${dir}/wrfinput_d01 ${RUNDIR}/advance_temp${dir}/wrfinput_d01_orig

#end

exit (0)
