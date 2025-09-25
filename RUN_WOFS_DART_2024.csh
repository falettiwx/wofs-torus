#!/bin/csh
#
set echo
#
########################################################################
#
# WOFS_main.csh - script that is the driver for the
#                  WOFS system on the NSSL CRAY HPC
########################################################################

source /home/william.faletti/wof-torus/torusenv
source ${TOP_DIR}/realtime.cfg.${event}
#set RADFILE = /scratch/tajones/realtime/radar_files/radars.${event}.csh
#source ${RADFILE}

set echo

#set endhr = `echo ${edate_bc} | cut -c12-13`
#set endhr1 = `expr $endhr \- 1`
#set endhr2 = `printf "%02d" $endhr1`


### Modified 5/14/2025 by Billy Faletti to allow dBZ assim in input.nmls every n cycles

set endstamp =  `echo "${edate_bc} ${ITVL_SEC} seconds  ago" | tr '_' ' '`
set endstamp = `date -d "$endstamp"`
set endhr =  `echo ${endstamp} | cut -c12-13`
set endmin = `echo ${endstamp} | cut -c15-16`

set startstamp =  `echo "${sdate_bc} ${cycle} minutes" | tr '_' ' '`
set startstamp = `date -d "$startstamp"`
set starthr =  `echo $startstamp | cut -c12-13`
set startmin = `echo $startstamp | cut -c15-16`

set datea = ${startdate}
set datef = ${nxtDay}${endhr}${endmin}#202205240206
set cstart = ${starthr}${startmin} # cycling start (start time + cycling interval)

set initdate_sec =  `echo "${sdate_bc}" | tr '_' ' '`
set initdate_sec = `date -d "$initdate_sec" +%s`

@ n_ref = ( ${cycle_ref} / ${cycle} ) # automates num of cycles b/w reflectivity assim.

echo cycle_ref is $cycle_ref
echo cycle is $cycle
echo n_ref is $n_ref 

#set datea = ${event}1615
#set datef = ${event}1600
#set datea = ${nxtDay}0315
#set datef = ${nxtDay}0300

while ( 1 == 1 )

    if ( ${datea} == ${runDay}${cstart} ) then # if cycle time is run start time
        cp ${SCRIPTDIR}/add_noise_py2.csh ${RUNDIR}
    endif

    cd $RUNDIR


    set datea_date =  `echo $datea | cut -c1-8`
    set datea_hr = `echo $datea | cut -c9-10`
    set datea_min = `echo $datea | cut -c11-12`
    set datea_sec = `echo "$datea_date ${datea_hr}:${datea_min}"`
    set datea_sec = `date -d "$datea_sec" +%s`
    @ remainder = ( ($datea_sec - $initdate_sec) / 60 ) % ($n_ref * $cycle)

    echo Remainder for $datea is $remainder

    # Copy in correct DART input.nml (no inflation at t=0)        
    if ( ${datea} == ${startdate} ) then
       if ( ${cycle_ref} < 999 ) then
          cp ${TEMPLATE_DIR}/input.nml.init.ref ${RUNDIR}/input.nml # initialization cycle with reflectivity assimilation
       else
          cp ${TEMPLATE_DIR}/input.nml.init ${RUNDIR}/input.nml # initialization cycle without reflectivity
       endif
    else if ( $remainder == 0 ) then
       cp ${TEMPLATE_DIR}/input.nml.cycle.ref ${RUNDIR}/input.nml # assimilate reflectivity every nth cycle
    else
       cp ${TEMPLATE_DIR}/input.nml.cycle ${RUNDIR}/input.nml  # regular cycle without reflectivity
    endif

    rm ${SEMA4}/wrf_done*
    rm ${SEMA4}/mem*_blown


     #  Link to the prior state, copy the obs, wrfinput, input.nml files
        set datep  =  `echo  $datea -${cycle}m | ${RUNDIR}/advance_time` 
        echo $datep
        set daten  =  `echo  $datea ${cycle}m | ${RUNDIR}/advance_time`
        echo $daten
        set gdate  = `echo $datea 0 -g | ${RUNDIR}/advance_time`
        echo $gdate
        set gdatef = `echo  $datea ${cycle}m -g | ${RUNDIR}/advance_time`
        echo $gdatef
        set wdate  =  `echo  $datea 0 -w | ${RUNDIR}/advance_time`
        echo $wdate

	set startyear  = `echo ${datea} | cut -c1-4`
        set startmonth = `echo ${datea} | cut -c5-6`
        set startday   = `echo ${datea} | cut -c7-8`
        set starthour  = `echo ${datea} | cut -c9-10`
        set startmin   = `echo ${datea} | cut -c11-12`

        #LINK OBS FILE TO RUN DIRECTORY
        #${LINK} /scratch/wof-torus/obs/obs_seq_RF_${startyear}${startmonth}${startday}_${starthour}${startmin}.out obs_seq.out #Previous naming conv. 
	${LINK} /scratch/wof-torus/obs/obs_seq.${startyear}${startmonth}${startday}${starthour}${startmin}.out obs_seq.out

     # GET inflation files ready
     if ( ${datea} != ${startdate} ) then
        ${LINK} ${RUNDIR}/${datep}/output_priorinf_mean.nc.${datep} ./input_priorinf_mean.nc
        ${LINK} ${RUNDIR}/${datep}/output_priorinf_sd.nc.${datep} ./input_priorinf_sd.nc
     endif

     ${LINK} ${RUNDIR}/mem1/wrfinput_d01.1 wrfinput_d01

     #  run filter to generate the analysis
     echo "#\!/bin/csh"                                                          >! wof_filter.job
     echo "#=================================================================="  >> wof_filter.job
     echo '#SBATCH' "-J wof_filter"                                              >> wof_filter.job
     echo '#SBATCH' "-o wof_filter.log"                                          >> wof_filter.job
     echo '#SBATCH' "-e wof_filter.err"                                          >> wof_filter.job
     echo '#SBATCH' "-p batch"                                                   >> wof_filter.job
     #echo '#SBATCH' "--nodelist=cn[1-15]"                                       >> wof_filter.job
     echo '#SBATCH' "--exclude=cn36  "                                           >> wof_filter.job
     echo '#SBATCH' "--exclusive"                                                >> wof_filter.job
     ##echo '#SBATCH' "--mem-per-cpu=5G"                                           >> wof_filter.job
     #echo '#SBATCH' "--ntasks-per-node=72"                                       >> wof_filter.job
     echo '#SBATCH' "-n ${FILTER_CORES}"                                         >> wof_filter.job
     echo '#SBATCH' "-t ${FILTER_TIMEOUT}"                                       >> wof_filter.job
     echo "#================================================================="   >> wof_filter.job

     cat >> ${RUNDIR}/wof_filter.job << EOF

     set echo
     
     setenv OMPI_MCA_coll_hcoll_enable 0 # added 12/4/24 suggested to try to solve WRF domain errors

     set start_time = \`date +%s\`
     
     echo "host is " \`hostname\`
     
     cd ${RUNDIR}

     srun ${RUNDIR}/WRF_RUN/filter

     sleep 1

     if ( -e obs_seq.final )  then
        touch filter_done
     endif     

     set end_time = \`date  +%s\`
     @ length_time = \$end_time - \$start_time
     echo "duration = \$length_time"

EOF
   
     chmod +x wof_filter.job  
     sbatch wof_filter.job

     echo $filter_time
     set filter_thresh = `echo $filter_time | cut -b3-4`
     echo $filter_thresh
     @ filter_thresh = `expr $filter_thresh \+ 0` * 60 + `echo $filter_time | cut -b1-1` * 3600

     set submit_time = `date +%s`

     sleep 10

     while ( ! -e filter_done )

	# Check the timing.  If it took longer than the time allocated, abort.
	if ( -e filter_started ) then

           set start_time = `head -1 filter_started`
           set end_time = `date  -u +%s`

           @ total_time = $end_time - $start_time
           if ( $total_time > $filter_thresh ) then

              echo "Time exceeded the maximum allowable time.  Exiting."
              touch ABORT_STEP
	      ${REMOVE} filter_started
              exit

           endif

        else 

            sleep 5
            set cur_time = `date +%s`
            @ wait_time = $cur_time - $submit_time
#            if ( $wait_time > $filter_start_thresh ) then
	#            if ( $wait_time > 21600 ) then
	#       echo "Houston, we've had a problem. Resubmitting"
	#       sbatch wof_filter.job
	#    endif

	endif     
	sleep 5

     end
     echo "EXIT FILTER"

     ${REMOVE} wof_filter.job filter_started filter_done obs_seq.out

     echo "Listing contents of rundir before moving to output at "`date`
    # ls -l *.nc blown* dart_log* filter_* input.nml obs_seq* *inf_ic* 

    #  Convert obs_final to netcdf and save
    srun ${RUNDIR}/WRF_RUN/obs_seq_to_netcdf
    sleep 2
    ${MOVE} obs_epoch_001.nc ${RUNDIR}/OBSOUT/obs_seq.nc.${datea}

    #  Move inflation files to storage directories
    ${MOVE} preassim_mean.nc ${RUNDIR}/${datea}/preassim_mean.nc.${datea}
    ${MOVE} preassim_sd.nc ${RUNDIR}/${datea}/preassim_sd.nc.${datea}
    ${MOVE} output_mean.nc ${RUNDIR}/${datea}/output_mean.nc.${datea}
    ${MOVE} output_sd.nc ${RUNDIR}/${datea}/output_sd.nc.${datea}
    ${MOVE} output_priorinf_mean.nc ${RUNDIR}/${datea}/output_priorinf_mean.nc.${datea}
    ${MOVE} output_priorinf_sd.nc ${RUNDIR}/${datea}/output_priorinf_sd.nc.${datea}
     ${MOVE} obs_seq.final ${RUNDIR}/${datea}/obs_seq.final.${datea}
     ${MOVE} wof_filter.log ${RUNDIR}/${datea}/wof_filter.log.${datea}
     ${MOVE} wof_filter.err ${RUNDIR}/${datea}/wof_filter.err.${datea}

    sleep 1

     ${REMOVE} output_*
     ${REMOVE} preassim_*

     #  Integrate ensemble members to next analysis time
     echo "#\!/bin/csh"                                                          >! ${RUNDIR}/wof_adv_mem.job
     echo "#=================================================================="  >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-J wof_adv_mem\%a"                                          >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-o wof_adv_mem\%a.log"                                      >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-e wof_adv_mem\%a.err"                                      >> ${RUNDIR}/wof_adv_mem.job
     #echo '#SBATCH' "--exclusive"                                                >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "--exclude=cn36  "                                           >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "--mem-per-cpu=5G"                                           >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-p batch"                                                   >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-n ${WRF_CORES}"                                            >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-t 0:45:00"                                                 >> ${RUNDIR}/wof_adv_mem.job
     echo "#=================================================================="  >> ${RUNDIR}/wof_adv_mem.job   

     cat >> ${RUNDIR}/wof_adv_mem.job << EOF

     source /home/william.faletti/wof-torus/torusenv
     source ${TOP_DIR}/realtime.cfg.${event}

     set echo

     set start_time = \`date +%s\`
     echo "host is " \`hostname\`
     cd ${RUNDIR}

     
     #  copy files to appropriate location
     echo \$start_time >& start_member_\${SLURM_ARRAY_TASK_ID}
     # here we are recycling the wrfout files so it should already exist
     if ( -d ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID} ) then
        cd ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID}
     else
        rm -rf ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID}  >& /dev/null
        mkdir -p ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID}
     cd ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID}
     endif


     #integrate the model forward in time
     cd ${RUNDIR}
     ${SCRIPTDIR}/advance_model_rto_smoke_tor.csh \${SLURM_ARRAY_TASK_ID} 1 ${datea}

     ${MOVE} ${RUNDIR}/advance_temp\${SLURM_ARRAY_TASK_ID}/rsl.out.integration ${RUNDIR}/${datea}/rsl.out.integration.\${SLURM_ARRAY_TASK_ID}

     set end_time = \`date  +%s\`
     @ length_time = \$end_time - \$start_time
     echo "duration = \$length_time"
EOF

     sbatch --array=1-${ENS_SIZE}  wof_adv_mem.job

     cd ${RUNDIR}

     #  check to see if all of the ensemble members have advanced
    
     # KHK 3-13-2013 Added means to resubmit if a job fails and compute a replacement member if it blows up
     set advance_start_thresh = `echo $advance_start | cut -b3-4`
     @ advance_start_thresh = `expr $advance_start_thresh \+ 0` * 60 + `echo $advance_start | cut -b1-1` * 3600 

     set advance_thresh = `echo $advance_time | cut -b3-4`
     @ advance_thresh = `expr $advance_thresh \+ 0` * 60 + `echo $advance_time | cut -b1-1` * 3600 

     set n = 1
     while ( $n <= $ENS_SIZE )

	set ensstring = `echo $n + 10000 | bc | cut -b2-5`
	set keep_trying = true

	while ( $keep_trying == 'true' )

           set submit_time = `date +%s`

           #  Wait for the script to start
           while ( ! -e start_member_${n} )

       	         sleep 20

                 set cur_time = `date +%s`
                 @ len_time = $cur_time - $submit_time

           end

           set start_time = `head -1 start_member_${n}`
           echo "Member $n has started. Start time $start_time"

           #  Wait for the output file
           while ( 1 == 1 && -e start_member_${n} )

              set start_time = `head -1 start_member_${n}`
              set current_time = `date  -u +%s`
              @ length_time = $current_time - $start_time

              if ( -e ${SEMA4}/wrf_done${n} ) then

        	 #  If the output file already exists, move on
        	 set keep_trying = false
        	 break

              else if ( -e ${SEMA4}/mem${n}_blown ) then
		   #sbatch --array=${n} ${SCRIPTDIR}/wof_adv_mem_rto_bl.csh 
                   sbatch --array=${n} wof_adv_mem.job
		   rm ${SEMA4}/mem${n}_blown   
              endif
              sleep 5

           end

	end
	
	#${REMOVE} start_member_${n} wof_adv_mem${n}.log wof_adv_mem${n}.err
	${REMOVE} start_member_${n} 

	@ n++

     end

     touch ${FCST_DIR}/analysis_${datea}_done

     #${MOVE} obs_seq.final ${RUNDIR}/${datea}/obs_seq.final.${datea}
     #${MOVE} wof_filter.log ${RUNDIR}/${datea}/wof_filter.log.${datea}
     #${MOVE} wof_filter.err ${RUNDIR}/${datea}/wof_filter.err.${datea}

     grep cfl advance_temp*/rsl* > ${RUNDIR}/${datea}/cfl_log.${datea}

     #${REMOVE} wof_filter.err
     ${REMOVE} wof_adv_mem.job dart_log*

     # Advance to the next time if this is not the final time
     if ( $datea == $datef ) then
          echo "Script exiting normally"
        # CLEAN UP AND MOVE FINAL THINGS
          exit
     else
          echo "Starting next time"
          set datea  =  `echo  ${datea} ${cycle}m | ${RUNDIR}/advance_time`
     endif

     @ loop++

end     # END CYCLE WHILE LOOP

exit (0)
