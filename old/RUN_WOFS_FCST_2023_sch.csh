#!/bin/csh 
#
#-----------------------------------------------------------------------
# Script to Run Forecast
#-----------------------------------------------------------------------

source /scratch/home/Thomas.Jones/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}
set echo

setenv tfcst_min 360
setenv hst 5 #5 15
setenv pcp 5 # 15, 60

########### LOOP THROUGH FORECAST START TIMES

#foreach btime ( 1700 1730 1800 1830 1900 1930 2000 2030 2100 2130 2200 2230 2300 2330 0000 0030 0100 0130 0200 0230 0300 )
#foreach btime ( 1900 1930 2000 2030 2100 2130 2200 2230 2300 2330 0000 0030 0100 0130 0200 0230 0300 )
#foreach btime ( 0000 0100 0200 0300 )
#foreach btime ( 1700 1800 1900 )
#foreach btime ( 1700 )
#foreach btime ( 0000 0100 0200 0300 )
foreach btime ( 1700 1800 1900 2000 2100 2200 2300 0000 0100 0200 0300 )
#foreach btime ( 2000 2100 2130 2200 2230 2300 0000 0100 0200 0300  )

set hhh  = `echo $btime | cut -c1`
set mmm  = `echo $btime | cut -c3`

setenv fcst_start ${runDay}${btime}
if ( ${hhh} == 0) then
   setenv fcst_start ${nxtDay}${btime}
endif

#setenv FCST_DIR /work/Thomas.Jones/gsi/FCST/${event}/

### WAIT TO SEE IF THIS ANALYSIS TIME IS COMPLETE
 while ( ! -e ${FCST_DIR}/analysis_${fcst_start}_done )
     echo "WAITING FOR ANALYSIS TO FINISH:" ${fcst_start}
     sleep 60
 end

touch ${FCST_DIR}/fcst_${fcst_start}_start

sleep 1

setenv FCSTHR_DIR ${FCST_DIR}/${btime}

mkdir ${FCSTHR_DIR}
cd ${FCSTHR_DIR}

####################################################################################################
# SET UP TIME CONSTRUCTS/VARIABLES
####################################################################################################

cp ${RUNDIR}/input.nml ./input.nml

set fcst_cut = `echo $fcst_start | cut -c1-10`

set gdate1 = `echo ${fcst_cut} 1 -g | ${RUNDIR}/advance_time`
set gdate2 = `echo ${fcst_cut} 4 -g | ${RUNDIR}/advance_time`

set START_YEAR  = `echo $fcst_start | cut -c1-4`
set START_MONTH = `echo $fcst_start | cut -c5-6` 
set START_DAY   = `echo $fcst_start | cut -c7-8`
set START_HOUR  = `echo $fcst_start | cut -c9-10`
set START_MIN   = `echo $fcst_start | cut -c11-12`


if ( ${mmm} == 0 ) then
  setenv tfcst_min 360
  setenv hst 360
#  setenv tfcst_min 180
#  setenv hst 180
 set END_STRING = `echo ${fcst_start} 21600s -w | ${RUNDIR}/advance_time`
else
  setenv tfcst_min 180
  setenv hst 180
  set END_STRING = `echo ${fcst_start} 10800s -w | ${RUNDIR}/advance_time`
endif

#set END_STRING = `echo ${fcst_start} 10800s -w | ${RUNDIR}/advance_time`
set END_YEAR  = `echo $END_STRING | cut -c1-4`
set END_MONTH = `echo $END_STRING | cut -c6-7`
set END_DAY   = `echo $END_STRING | cut -c9-10`
set END_HOUR  = `echo $END_STRING | cut -c12-13`
set END_MIN   = `echo $END_STRING | cut -c15-16`

#
set member = 1
while($member <= ${FCST_SIZE})

    ${REMOVE} -fr ENS_MEM_${member}
    mkdir ENS_MEM_${member}
    cd ENS_MEM_${member}/
    if ( -e namelist.input) ${REMOVE} namelist.input
    ${REMOVE} rsl.* fcstModel.sed 

    cat >! fcstModel.sed << EOF
         /run_minutes/c\
         run_minutes                = ${tfcst_min},
         /start_year/c\
         start_year                 = 2*${START_YEAR},
         /start_month/c\
         start_month                = 2*${START_MONTH},
         /start_day/c\
         start_day                  = 2*${START_DAY},
         /start_hour/c\
         start_hour                 = 2*${START_HOUR},
         /start_minute/c\
         start_minute               = 2*${START_MIN},
         /start_second/c\
         start_second               = 2*00,
         /end_year/c\
         end_year                   = 2*${END_YEAR},
         /end_month/c\
         end_month                  = 2*${END_MONTH},
         /end_day/c\
         end_day                    = 2*${END_DAY},
         /end_hour/c\
         end_hour                   = 2*${END_HOUR},
         /end_minute/c\
         end_minute                 = 2*${END_MIN},
         /end_second/c\
         end_second                 = 2*00,
         /fine_input_stream/c\
         fine_input_stream          = 2*0,
         /history_interval/c\
         history_interval           = 5, 
         /frames_per_outfile/c\
         frames_per_outfile         = 2*1,
         /reset_interval1/c\
         reset_interval1            = ${pcp},
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
         j_parent_start             = 0,
         /parent_time_step_ratio/c\
         parent_time_step_ratio     = 1, 5,
         /use_adaptive_time_step/c\
         use_adaptive_time_step     = .false.,
	 /numtiles/c\
         numtiles                   = 1,
         /nproc_x/c\
         nproc_x                    = -1,
         /nproc_y/c\
         nproc_y                    = -1,
	 /sf_sfclay_physics/c\
         sf_sfclay_physics          = 5,
	 /sf_surface_physics/c\
	 sf_surface_physics         = ${lsm}, ${lsm},
         /num_soil_layers/c\
         num_soil_layers            = ${num_soil_levels},
         /bl_pbl_physics/c\
         bl_pbl_physics             = 5, 5,
         /ra_lw_physics/c\
         ra_lw_physics              = 4, 4,
         /ra_sw_physics/c\
         ra_sw_physics              = 4, 4,
         /icloud_bl/c\
         icloud_bl                  = 1,
	 /nssl_cccn/c\
         nssl_cccn                  = 1.25e9,
         /radt/c\
         radt                       = 5,
         /prec_acc_dt/c\
         prec_acc_dt                = ${pcp},
         /aer_opt/c\
         aer_opt                    = ${aer_opt},
         /skebs/c\
         skebs                      = 0,
         /spp_pbl/c\
         spp_pbl                    = 0,
         /spp_lsm/c\
         spp_lsm                    = 0,
EOF

sed -f fcstModel.sed ${NAME_DIR}/namelist.input.member${member} >! namelist.input
     #sed -f fcstModel.sed /home/Thomas.Jones/WOFS_DART/templates/namelists.WOFS.fcst/namelist.input.member${member} >! namelist.input
#
    ln -sf ${RUNDIR}/WRF_RUN/* .
#
#  Run wrf.exe to generate forecast
#
   echo "#\!/bin/csh"                                                          >! ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo "#=================================================================="  >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "-J enkf_fcst${member}"                                      >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "-o ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.log"  >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "-e ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.err"  >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job 
   echo '#SBATCH' "-p batch"                                                   >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "-J enkf_fcst${member}"                                      >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "-n ${WRF_FCORES}"                                           >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH' "--exclusive"                                                >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   ##echo '#SBATCH' "--mem-per-cpu=5G"                                           >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo '#SBATCH -t 1:30:00'                                                   >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   echo "#=================================================================="  >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job

   cat >> ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job << EOF

   source /scratch/home/Thomas.Jones/WOFenv_dart
   source ${TOP_DIR}/realtime.cfg.${event}

   #module load compiler/latest
   #module load hpcx-ompi-intel-classic

   module load nvhpc-nompi/23.9
   module load hpcx-mt-ompi-nvidia

   set echo

   cd \${SLURM_SUBMIT_DIR}

   cd ${FCSTHR_DIR}/ENS_MEM_${member}

   ${COPY} ${RUNDIR}/mem${member}/wrfbdy_d01.${member} ./wrfbdy_d01
   ${COPY} ${RUNDIR}/${fcst_start}/wrfinput_d01.${member} ./wrfinput_d01
   ${COPY} ${TEMPLATE_DIR}/forecast_vars_d01.txt ./

   sleep 3

   time srun  ${EXEDIR}/wrf.exe
   #time mpirun ${EXEDIR}/wrf.exe

EOF

   chmod +x ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   sbatch  ${FCSTHR_DIR}/ENS_MEM_${member}/enkf_fcst${member}.job
   sleep 1

   @ member++
   cd ../

end

#touch ${FCSTHR_DIR}/fcst_${fcst_start}_done
sleep 750

end

####################################################################################################
#
echo '       ************* RUN IS COMPLETE **************       '
#
####################################################################################################
#
exit (0)
#
####################################################################################################
