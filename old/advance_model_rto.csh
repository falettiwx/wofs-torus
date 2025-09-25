#!/bin/csh
### advance_model.csh
#
set echo
#
# DART software - Copyright 2004 - 2011 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id: advance_model.csh 4945 2011-06-02 22:29:30Z thoar $
#
# Shell script to run the WRF model from DART input.
# where the model advance is executed as a separate process.
#
# This script performs the following:
# 1.  Copies or links the necessary files into the temporary directory
# 2.  Updates LBCs
# 3.  Writes a WRF namelist from a template
# 4.  Runs WRF
# 5.  Checks for incomplete runs
#
#-------------------------------------------------------
# Dependencies (user responsibility)
#-------------------------------------------------------
#
# REQUIRED:
# 1. advance_time (from DART), located in your $CENTRALDIR
# 2. directory $CENTRALDIR/WRF_RUN containing all the WRF run-time files
# (typically files with data for the physics: LANDUSE.TBL, RRTM_DATA, etc
# but also anything else you want to link into the wrf-run directory.  If
# using WRF-Var then be.dat should be in there too.
# 3. wrf.exe, located in your $CENTRALDIR/WRF_RUN
# 4. A wrfinput_d01 file in your $CENTRALDIR.  
# 5. namelist.input in your $CENTRALDIR for use as a template.  This file 
# should include the WRF-Var namelists if you are using WRF-Var (v3.1++ required).
#
###
### Get initialization data	

source /scratch/home/thomas.jones/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

# Arguments are the process number of caller, the number of state copies
# belonging to that process, and the name of the filter_control_file for
# that process
set process = $1
set num_states = $2
set datea = $3

# Setting to vals > 0 saves wrfout files,
# will save all member output files <= to this value
set save_ensemble_member = 36
set delete_temp_dir = false

# set this to true if you want to maintain complete individual wrfinput/output
# for each member (to carry through non-updated fields)
set individual_members = true

# next line ensures that the last cycle leaves everything in the temp dirs
if ( $individual_members == true ) set delete_temp_dir = false
cd ${RUNDIR}
set  myname = $0
set WRFOUTDIR  = ${RUNDIR}/WRFOUT
set REMOVE = '/bin/rm -vf'
set REMOVEDIR = '/bin/rm -vrf'
set COPY = '/bin/cp -p'
set MOVE = '/bin/mv -f'
set LN = '/bin/ln -sf'
unalias cd
unalias ls

# if process 0 go ahead and check for dependencies here
if ( $process == 0 ) then

 if ( ! -x ${RUNDIR}/advance_time ) then
     echo ABORT\: advance_model.csh could not find required executable dependency ${RUNDIR}/advance_time
     exit 1
   endif

   if ( ! -d WRF_RUN ) then
      echo ABORT\: advance_model.csh could not find required data directory ${RUNDIR}/WRF_RUN, which contains all the WRF run-time input files
      exit 1
   endif

endif # process 0 dependency checking

# set this flag here if the radar additive noise script is found
if ( -e ${RUNDIR}/add_noise.csh ) then
   set USE_NOISE = 1
else
   set USE_NOISE = 0
endif

# give the filesystem time to collect itself
sleep 2

# Each parallel task may need to advance more than one ensemble member.
# This control file has the actual ensemble number, the input filename,
# and the output filename for each advance.  Be prepared to loop and
# do the rest of the script more than once.
set state_copy = 1

while($state_copy <= $num_states)

   set ensemble_member = $process

   set infl = 0.0

   #  create a new temp directory for each member unless requested to keep and it exists already
   set temp_dir = "advance_temp${ensemble_member}"

   if ( ( -d $temp_dir ) & ( $individual_members == "true" ) ) then
      cd $temp_dir
      set rmlist = ( `ls -f | grep -v wrfbdy_d0?  | grep -v wrfinput_d0? | grep -v wrfinput_d0?_orig` )
      ${REMOVE} $rmlist
   else
      ${REMOVEDIR} $temp_dir >& /dev/null
      mkdir -p $temp_dir
      cd $temp_dir

      ${COPY} ${RUNDIR}/mem${ensemble_member}/wrfinput_d0? .
   endif

   #if ( ( -e ${SEMA4}/RunFcst ) && ( $ensemble_member <= 18 ) ) then

      #set FcstMin = `echo $fcstCycle | cut -b11-12`

      #if ( ( $FcstMin == "00" ) || ( $FcstMin == "30" ) ) then
  ${COPY} wrfinput_d01 ${RUNDIR}/${datea}/wrfinput_d01.${ensemble_member}
      #endif

   #endif

   # link WRF-runtime files (required) and be.dat (if using WRF-Var)
   ${LN} ${RUNDIR}/WRF_RUN/*       .

   # link DART namelist
   ${LN} ${RUNDIR}/input.nml       .


   echo $datea ${cycle}m -g > temp

   ${RUNDIR}/advance_time < temp > endtime
   
   set secday = `head -1 endtime`
   set targsecs = $secday[2]
   set targdays = $secday[1]
   set targkey = `echo "$targdays * 86400 + $targsecs" | bc`

   rm temp endtime

   echo $datea 0h -g > temp
  
   ${RUNDIR}/advance_time < temp > srttime
   
   set secday = `head -1 srttime`
   set wrfsecs = $secday[2]
   set wrfdays = $secday[1]
   set wrfkey = `echo "$wrfdays * 86400 + $wrfsecs" | bc`

   rm temp srttime


   echo $datea 0h -w > temp

   ${RUNDIR}/advance_time < temp > wrftime

   set cal_date    = `head -1 wrftime`
   set START_YEAR  = `echo $cal_date | cut -c1-4`
   set START_MONTH = `echo $cal_date | cut -c6-7`
   set START_DAY   = `echo $cal_date | cut -c9-10`
   set START_HOUR  = `echo $cal_date | cut -c12-13`
   set START_MIN   = `echo $cal_date | cut -c15-16`
   set START_SEC   = `echo $cal_date | cut -c18-19`
   
   set START_STRING = ${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:${START_MIN}:${START_SEC}

   rm temp wrftime

   set MY_NUM_DOMAINS = $domains
   set ADV_MOD_COMMAND = "srun --mpi=pmi2 ${RUNDIR}/WRF_RUN/wrf.exe"


   # radar additive noise option.  if shell script is available
   # in the centraldir, it will be called here.
   if ( $USE_NOISE ) then
      ${RUNDIR}/add_noise.csh $wrfsecs $wrfdays $state_copy $ensemble_member $temp_dir $RUNDIR $datea
   endif

   ###############################################################
   # Advance the model with new BC until target time is reached. #
   ###############################################################

   #while ( $wrfkey < $targkey )

      set INTERVAL_SS = '900'

      # Copy the boundary condition file to the temp directory.
      ${COPY} ${RUNDIR}/mem${ensemble_member}/wrfbdy_d01.${ensemble_member} wrfbdy_d01

      set INTERVAL_MIN = `expr $INTERVAL_SS \/ 60`

      echo ${START_STRING} ${INTERVAL_SS}s -w > temp
      ${RUNDIR}/advance_time < temp > time
      set END_STRING = `head -1 time` 
      set END_YEAR  = `echo $END_STRING | cut -c1-4`
      set END_MONTH = `echo $END_STRING | cut -c6-7`
      set END_DAY   = `echo $END_STRING | cut -c9-10`
      set END_HOUR  = `echo $END_STRING | cut -c12-13`
      set END_MIN   = `echo $END_STRING | cut -c15-16`
      set END_SEC   = `echo $END_STRING | cut -c18-19`

      # Update boundary conditions from existing wrfbdy files
      echo $infl | srun -n 1 --mpi=pmi2 ${RUNDIR}/WRF_RUN/update_wrf_bc >&! out.update_wrf_bc

      ${REMOVE} advModel.sed namelist.input
      cat >! advModel.sed << EOF
         /run_hours/c\
         run_hours                  = 0,
         /run_minutes/c\
         run_minutes                = 0,
         /run_seconds/c\
         run_seconds                = ${INTERVAL_SS},
         /start_year/c\
         start_year                 = ${START_YEAR},
         /start_month/c\
         start_month                = ${START_MONTH},
         /start_day/c\
         start_day                  = ${START_DAY},
         /start_hour/c\
         start_hour                 = ${START_HOUR},
         /start_minute/c\
         start_minute               = ${START_MIN},
         /start_second/c\
         start_second               = ${START_SEC},
         /end_year/c\
         end_year                   = ${END_YEAR},
         /end_month/c\
         end_month                  = ${END_MONTH},
         /end_day/c\
         end_day                    = ${END_DAY},
         /end_hour/c\
         end_hour                   = ${END_HOUR},
         /end_minute/c\
         end_minute                 = ${END_MIN},
         /end_second/c\
         end_second                 = ${END_SEC},
         /history_interval/c\
         history_interval           = ${INTERVAL_MIN},
         /time_step_fract_num/c\
         time_step_fract_num        = 0,
         /time_step_fract_den/c\
         time_step_fract_den        = 1,
         /max_dom/c\
         max_dom                    = $domains,
         /e_we/c\
         e_we                       = $grdpts_ew, 1,
         /e_sn/c\
         e_sn                       = $grdpts_ns, 1,
         /i_parent_start/c\
         i_parent_start             = 0, 1,
         /j_parent_start/c\
         j_parent_start             = 0, 1,
         /parent_time_step_ratio/c\
         parent_time_step_ratio     = 1, 5,
         /parent_grid_ratio/c\
         parent_grid_ratio          = 1, 5,
         /numtiles/c\
         numtiles                   = ${tiles},
         /nproc_x/c\
         nproc_x                    = $procx,
         /nproc_y/c\
         nproc_y                    = $procy,

EOF
# The EOF on the line above MUST REMAIN in column 1.

      sed -f advModel.sed ${TEMPLATE_DIR}/namelists.WOFS/namelist.input.member${ensemble_member} >! namelist.input


      #-------------------------------------------------------------
      #
      # HERE IS A GOOD PLACE TO GRAB FIELDS FROM OTHER SOURCES
      # AND STUFF THEM INTO YOUR wrfinput_d0? FILES
      #
      #------------------------------------------------------------
      
      # clean out any old rsl files
      if ( -e rsl.out.integration )  ${REMOVE} rsl.* 

      ${ADV_MOD_COMMAND} >>&! rsl.out.integration

      if ( -e rsl.out.0000 ) cat rsl.out.0000 >> rsl.out.integration

      set SUCCESS = `grep "wrf: SUCCESS COMPLETE WRF" rsl.out.integration | cat | wc -l`
      if ($SUCCESS == 0) then
         echo $ensemble_member >>! ${RUNDIR}/blown_${targdays}_${targsecs}.out
         touch ${SEMA4}/mem${ensemble_member}_blown
         exit -1

      endif

      sleep 2

      set dn = 1
      while ( $dn <= $MY_NUM_DOMAINS )

         #${COPY} wrfout_d0${dn}_${END_STRING} ${RUNDIR}/${datea}/wrffcst_d0${dn}_${END_STRING}_${ensemble_member}
         ${MOVE} wrfout_d0${dn}_${START_STRING} ${RUNDIR}/${datea}/wrfout_d0${dn}_${START_STRING}_${ensemble_member}
         ${MOVE} wrfout_d0${dn}_${END_STRING} wrfinput_d0${dn}

         sleep 2

         ${COPY} wrfinput_d0${dn} wrfinput_d0${dn}_orig

         @ dn ++
      end

      sleep 2

      set START_YEAR  = $END_YEAR
      set START_MONTH = $END_MONTH
      set START_DAY   = $END_DAY
      set START_HOUR  = $END_HOUR
      set START_MIN   = $END_MIN
      set START_SEC   = $END_SEC
      
   #end

   ##############################################
   # At this point, the target time is reached. #
   ##############################################

   sleep 1

   cd $RUNDIR

   #  delete the temp directory for each member if desired
   if ( $delete_temp_dir == true )  ${REMOVEDIR} ${temp_dir}
   echo "Ensemble Member $ensemble_member completed"

   # and now repeat the entire process for any other ensemble member that
   # needs to be advanced by this task.
   @ state_copy ++

end

touch ${SEMA4}/wrf_done${ensemble_member}

exit 0

# <next few lines under version control, do not edit>
# $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/models/wrf/shell_scripts/advance_model.csh $
# $Revision: 4945 $
# $Date: 2011-06-02 17:29:30 -0500 (Thu, 02 Jun 2011) $

