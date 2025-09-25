#!/bin/csh -f
#
set echo

source ~/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

echo "Starting Script Run_ICBCs.csh"

#setenv RUNDIR = /scratch/tajones/smoke/20230818/HRRR
#cd ${RUNDIR}

cd ${RUNDIR}/HRRR

rm namelist.input.template
${LINK} ${RUNDIR}/input.nml ${RUNDIR}/HRRR/input.nml
#
echo ${PWD}

set start_year    = `echo $sdate_bc |cut -c1-4`
set start_month   = `echo $sdate_bc |cut -c6-7`
set start_day     = `echo $sdate_bc |cut -c9-10`
set start_hour    = `echo $sdate_bc |cut -c12-13`
set start_minute  = `echo $sdate_bc |cut -c15-16`
set start_second  = `echo $sdate_bc |cut -c18-19`

set end_year    = `echo $edate_bc |cut -c1-4`
set end_month   = `echo $edate_bc |cut -c6-7`
set end_day     = `echo $edate_bc |cut -c9-10`
set end_hour    = `echo $edate_bc |cut -c12-13`
set end_minute  = `echo $edate_bc |cut -c15-16`
set end_second  = `echo $edate_bc |cut -c18-19`

### time interval between two analysis
set interval_seconds = 3600
#
#
cat > script.sed << EOF
/start_year/c \\
 start_year                          = $start_year, $start_year,
/start_month/c \\
 start_month                         = $start_month, $start_month,
/start_day/c \\
 start_day                           = $start_day, $start_day,
/start_hour/c \\
 start_hour                          = $start_hour, $start_hour,
/start_minute/c \\
 start_minute                        = $start_minute, $start_minute,
/start_second/c \\
 start_second                        = $start_second, $start_second,
/end_year/c \\
 end_year                            = $end_year, $end_year,
/end_month/c \\
 end_month                           = $end_month, $end_month,
/end_day/c \\
 end_day                             = $end_day, $end_day,
/end_hour/c \\
 end_hour                            = $end_hour, $end_hour,
/end_minute/c \\
 end_minute                          = $end_minute, $end_minute,
/end_second/c \\
 end_second                          = $end_second, $end_second,
/time_step_fract_num/c \\
 time_step_fract_num                 = 0,
/time_step_fract_den/c \\
 time_step_fract_den                 = 1,
/interval_seconds/c \\
 interval_seconds                    = $interval_seconds,
/max_dom/c \\
 max_dom                             = $domains,
/e_we/c \\
 e_we                                = $grdpts_ew, 1,
/e_sn/c \\
 e_sn                                = $grdpts_ns, 1,
/i_parent_start/c \\
 i_parent_start                      = 0, 1,
/j_parent_start/c \\
 j_parent_start                      = 0, 1,
/parent_grid_ratio/c \\
 parent_grid_ratio                   = 1, 5,
/parent_time_step_ratio/c\
 parent_time_step_ratio              = 1, 5,
/num_soil_layers/c\
 num_soil_layers                     = 0,

EOF

if ( ! -e namelist.input.template) cp ${TEMPLATE_DIR}/namelist.input.template.HRRR_smoke  namelist.input.template
###
    sed -f script.sed namelist.input.template > namelist.input

    # run real.exe, rename wrfinput_d01 and wrfbdy_d01
    # ------------------------------------------------
   
    echo "#\!/bin/csh"                                                                >! ${RUNDIR}/HRRR/icbc_bc1.job
    echo "#=================================================================="        >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "-J icbc_bc1"                                                      >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "-o ${RUNDIR}/HRRR/icbc_bc1.log"                                   >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "-e ${RUNDIR}/HRRR/icbc_bc1.err"                                   >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "-p batch"                                                         >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "--mem-per-cpu=5G"                                                 >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo '#SBATCH' "-n 24"                                                            >> ${RUNDIR}/HRRR/icbc_bc1.job 
    echo '#SBATCH -t 0:30:00'                                                         >> ${RUNDIR}/HRRR/icbc_bc1.job
    echo "#=================================================================="        >> ${RUNDIR}/HRRR/icbc_bc1.job

    cat >> ${RUNDIR}/HRRR/icbc_bc1.job << EOF

    source /scratch/home/thomas.jones/WOFenv_dart

    set echo


    cd ${RUNDIR}/HRRR

    #cp ${RUNDIR}/WRF_RUN/* .    
    #cp /home/Thomas.Jones/WOFS_GSI/Templates/SMOKE/gribmap.txt_smoke ./gribmap.txt

    sleep 2

    srun --mpi=pmi2 ${EXEDIR}/real.exe

    if ( ! -e wrfinput_d01) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfinput_d01 
    else if ( ! -e wrfbdy_d01  ) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfbdy_d01
    else
       echo Done with Input and Boundary files for BC1
       sleep 2
    endif

    touch ${SEMA4}/icbc1_done

    #${REMOVE} rsl*

EOF

 chmod +x ${RUNDIR}/HRRR/icbc_bc1.job
 sbatch ${RUNDIR}/HRRR/icbc_bc1.job

 sleep 1

exit (0)
###################################################################################################################
