#!/bin/csh
#
set echo
#
########################################################################
#
# NEWSe_main.csh - script that is the driver for the
#                  NEWSe system on the NSSL CRAY HPC
########################################################################

source /scratch/home/Thomas.Jones/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

set echo
#set datea = ${startdate}
set datef = ${nxtDay}0000

set datea = ${event}1600
#set datef = ${event}1545

while ( 1 == 1 )

    if ( ${datea} == ${runDay}1515 ) then
        cp ${SCRIPTDIR}/add_noise.csh ${RUNDIR}
    endif

    cd $RUNDIR

    # Copy in correct DART input.nml (no inflation at t=0)        
    if ( ${datea} == ${startdate} ) then
       cp ${TEMPLATE_DIR}/input.nml.init.tb ${RUNDIR}/input.nml
    else
       cp ${TEMPLATE_DIR}/input.nml.cycle.tb ${RUNDIR}/input.nml 
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

        #LINK OBS FILE TO RUN DIRECTORY
        ${LINK} ${OBSDIR}/combo/obs_seq.${datea} obs_seq.out   


     if ( ${datea} != ${startdate} ) then
        ${LINK} ${RUNDIR}/${datep}/output_priorinf_mean.nc.${datep} ./input_priorinf_mean.nc
        ${LINK} ${RUNDIR}/${datep}/output_priorinf_sd.nc.${datep} ./input_priorinf_sd.nc
     endif

     ${LINK} ${RUNDIR}/ic1/wrfinput_d01_ic wrfinput_d01

     #  run filter to generate the analysis
     echo "#\!/bin/csh"                                                          >! wof_filter.job
     echo "#=================================================================="  >> wof_filter.job
     echo '#SBATCH' "-J wof_filter"                                              >> wof_filter.job
     echo '#SBATCH' "-o wof_filter.log"                                          >> wof_filter.job
     echo '#SBATCH' "-e wof_filter.err"                                          >> wof_filter.job
     echo '#SBATCH' "-p batch"                                                   >> wof_filter.job
     echo '#SBATCH' "--exclusive"                                                >> wof_filter.job
     ##echo '#SBATCH' "--mem-per-cpu=5G"                                           >> wof_filter.job
     echo '#SBATCH' "-n ${FILTER_CORES}"                                         >> wof_filter.job
     echo '#SBATCH' "-t 0:45:00"                                                 >> wof_filter.job
     echo "#================================================================="   >> wof_filter.job

     cat >> ${RUNDIR}/wof_filter.job << EOF

     module load compiler/latest
     module load mkl/latest
     module load hmpt/2.27
     module load dpl/latest 

     set echo

     set start_time = \`date +%s\`
     echo "host is " \`hostname\`
     cd ${RUNDIR}

     srun --mpi=pmi2 ${RUNDIR}/WRF_RUN/filter
     sleep 1

     if ( -e obs_seq.final )  then
        touch filter_done
     endif     

     set end_time = \`date  +%s\`
     @ length_time = \$end_time - \$start_time
     echo "duration = \$length_time"

EOF
   
     chmod +x wof_filter.job  
     sbatch --exclude=cn14 wof_filter.job

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
            if ( $wait_time > 21600 ) then
               echo "Houston, we've had a problem. Resubmitting"
               sbatch wof_filter.job
            endif

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
    ${MOVE} output_mean.nc ${RUNDIR}/${datea}/output_mean.nc.${datea}
    ${MOVE} output_sd.nc ${RUNDIR}/${datea}/output_sd.nc.${datea}
    ${MOVE} output_priorinf_mean.nc ${RUNDIR}/${datea}/output_priorinf_mean.nc.${datea}
    ${MOVE} output_priorinf_sd.nc ${RUNDIR}/${datea}/output_priorinf_sd.nc.${datea}

     ${REMOVE} output_*
     ${REMOVE} preassim_*

     #  Integrate ensemble members to next analysis time
     echo "#\!/bin/csh"                                                          >! ${RUNDIR}/wof_adv_mem.job
     echo "#=================================================================="  >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-J wof_adv_mem\%a"                                          >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-o wof_adv_mem\%a.log"                                      >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-e wof_adv_mem\%a.err"                                      >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "--mem-per-cpu=5G"                                           >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-p batch"                                                   >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-n ${WRF_CORES}"                                            >> ${RUNDIR}/wof_adv_mem.job
     echo '#SBATCH' "-t 0:45:00"                                                 >> ${RUNDIR}/wof_adv_mem.job
     echo "#=================================================================="  >> ${RUNDIR}/wof_adv_mem.job   

     cat >> ${RUNDIR}/wof_adv_mem.job << EOF

     source /scratch/home/thomas.jones/WOFenv_dart
     source ${TOP_DIR}/realtime.cfg.${event}

     module load compiler/latest
     module load mkl/latest
     module load hmpt/2.27
     module load dpl/latest 

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
     ${SCRIPTDIR}/advance_model_rto.csh \${SLURM_ARRAY_TASK_ID} 1 ${datea}

     set end_time = \`date  +%s\`
     @ length_time = \$end_time - \$start_time
     echo "duration = \$length_time"
EOF

     sbatch --array=1-${ENS_SIZE} --exclude=cn14 wof_adv_mem.job

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
 
                 if ( $len_time > $advance_start_thresh ) then

                    sbatch wof_adv_mem${n}.job
                    echo "Resubmitting job that never started"
                   
                    sleep 5
                 
                 endif

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
                   sbatch --array=${n} ${SCRIPTDIR}/wof_adv_mem_rto_bl.csh 
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

     ${MOVE} obs_seq.final ${RUNDIR}/${datea}/obs_seq.final.${datea}
     ${MOVE} wof_filter.log ${RUNDIR}/${datea}/wof_filter.log.${datea}
     ${MOVE} wof_filter.err ${RUNDIR}/${datea}/wof_filter.err.${datea}

     grep cfl advance_temp*/rsl* > cfl_log.${datea}

     #${REMOVE} wof_filter.err

     ${REMOVE} wof_adv_mem.job

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
