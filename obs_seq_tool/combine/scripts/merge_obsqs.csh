#!/bin/tcsh

source obsqenv

	# DART epoch time is 1601-01-01 (Gregorian calendar because why not I guess)
set epochdate=`date +'%s' -d '1600-12-31'`

	#clean up old obs_seq directories 
rm -r ${COMBINEDIR}/obsq_*
#------------------------------------------------------------------------

# Dynamically define remaining variables

	# define obs window for cycle
set cycle_sec=`expr ${cycle} \* 60`
set cycle_window=`expr ${cycle_sec} / 2`

	# parse start date/time info
set inityr=`echo ${init_time} | cut -c1-4`
set initmon=`echo ${init_time} | cut -c5-6`
set initday=`echo ${init_time} | cut -c7-8`
set inithr=`echo ${init_time} | cut -c9-10`
set initmin=`echo ${init_time} | cut -c11-12`
	# parse end date/time info
set endyr=`echo ${end_time} | cut -c1-4`
set endmon=`echo ${end_time} | cut -c5-6`
set endday=`echo ${end_time} | cut -c7-8`
set endhr=`echo ${end_time} | cut -c9-10`
set endmin=`echo ${end_time} | cut -c11-12`

	# create start/end date/time objects
set sdate=${inityr}-${initmon}-${initday}_${inithr}:${initmin}:00
set edate=${endyr}-${endmon}-${endday}_${endhr}:${endmin}:00

#------------------------------------------------------------------------

# Parse start/end timestamps to loop through cycle times
        # define start time using date command
set curr_tstamp =  `echo "${sdate}" | tr '_' ' '`
set curr_tstamp = `date -d "$curr_tstamp" "+%F %T"`
        # similarly define end time (final analysis time + 1 cycling interval to stop while loop)
set end_tstamp =  `echo "${edate}" | tr '_' ' '`
set end_tstamp = `date -d "$end_tstamp ${cycle} minutes" "+%F %T"`


# Create obs_seq.outs
	# create obs_seqs by while looping through cycle times
while ( "$curr_tstamp" != "$end_tstamp" )

	# create cycle time string for obs_seq.out
   set stryr =  `echo $curr_tstamp | cut -c1-4`
   set strmo =  `echo $curr_tstamp | cut -c6-7`
   set strday = `echo $curr_tstamp | cut -c9-10`
   set strhr =  `echo $curr_tstamp | cut -c12-13`
   set strmin = `echo $curr_tstamp | cut -c15-16`

	# create run directory and copy files to it, also create output directory
   set ITER_DIR=${COMBINEDIR}/obsq_${stryr}${strmo}${strday}${strhr}${strmin}
   mkdir -p ${ITER_DIR} ${OUTDIR}

   cp ${EXEDIR}/input.nml ${EXEDIR}/obsflist ${EXEDIR}/obs_sequence_tool ${SCRIPTDIR}/run_obsq_tool.job ${SCRIPTDIR}/obsqenv ${ITER_DIR}
 
	# define start and end of obs collection window 
   set obs_start=`date -d "$curr_tstamp ${cycle_window} seconds ago" "+%F %T"`
   set obs_end=`date -d "$curr_tstamp ${cycle_window} seconds" "+%F %T"`
   
   	# find window start/end times to insert into namelist
   	#	days since epoch, seconds since midnight
   set obs_startday=`echo $obs_start | cut -c1-10`
   set obs_startday=`date +%s -d $obs_startday`
   set diff_startday=`expr $obs_startday - $epochdate`
   set diff_startday=`expr $diff_startday / 86400`
   
   set obs_endday_=`echo $obs_end | cut -c1-10`
   set obs_endday=`date +%s -d $obs_endday_`
   set diff_endday=`expr $obs_endday - $epochdate`
   set diff_endday=`expr $diff_endday / 86400`

   set obs_startsec=`date -d "$obs_start" +%s`
   set diff_startsec=`expr $obs_startsec - $obs_startday`

   set obs_endsec=`date -d "$obs_end" +%s`
   set diff_endsec=`expr $obs_endsec - $obs_endday`

	# update curr_tstamp for while loop
   set curr_tstamp = `date -d "$curr_tstamp ${cycle} minutes" "+%F %T"`

	# Update lines in input.nml containing obsq filename and time thresholding info
   sed -i "/filename_out/c\   filename_out      = 'obs_seq.${stryr}${strmo}${strday}${strhr}${strmin}.out'," ${ITER_DIR}/input.nml
   sed -i "/first_obs_days/c\   first_obs_days    = $diff_startday," ${ITER_DIR}/input.nml
   sed -i "/first_obs_seconds/c\   first_obs_seconds = $diff_startsec," ${ITER_DIR}/input.nml
   sed -i "/last_obs_days/c\   last_obs_days     = $diff_endday," ${ITER_DIR}/input.nml
   sed -i "/last_obs_seconds/c\   last_obs_seconds  = $diff_endsec," ${ITER_DIR}/input.nml

	# Run obs_sequence_tool
   sbatch ${ITER_DIR}/run_obsq_tool.job ${ITER_DIR}
 
   sleep 0.5s
  
end

# Wait for obs_seq generation to finish

	# set counter for number of obs_seqs finished vs total
set num_dirs=`find ${COMBINEDIR} -type d -mindepth 1 -printf '1'  | wc -c`
set num_done=`ls -l ${COMBINEDIR}/obsq_*/obsq_done | egrep -c '^-'`

	# loop until counter matches total number of obs_seqs
while ( ${num_done} != ${num_dirs} )
   
   #echo "num_done = ${num_done}"
   #echo "num_dirs = ${num_dirs}"
   sleep 10
   echo "Waiting for obs_seq generation to finish"
   set num_done=`ls -l ${COMBINEDIR}/obsq*/obsq_done | egrep -c '^-'`

end

# Once finished, move all obs_seqs to output directory
mv ${COMBINEDIR}/obsq_*/obs_seq.*.out ${OUTDIR}

echo "Obs_seq script finished"


