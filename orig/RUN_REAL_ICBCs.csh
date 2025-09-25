#!/bin/csh
#
set echo

source /home/wof-torus/torusenv
source ${TOP_DIR}/realtime.cfg.${event}

set emember = ${1}

cd ${RUNDIR}/mem${emember}
rm namelist.input.template
${LINK} ${RUNDIR}/input.nml ${RUNDIR}/mem${emember}/input.nml
#
echo ${PWD}

	# sets variables defined by environmental variables set in realtime.cfg
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
 i_parent_start                      = 1,
/j_parent_start/c \\
 j_parent_start                      = 1,
/sf_surface_physics/c \\
 sf_surface_physics                  = ${lsm}, ${lsm},
/num_soil_layers/c \\
 num_soil_layers                     = ${num_soil_levels},
/parent_grid_ratio/c \\
 parent_grid_ratio                   = 1, 5,
/parent_time_step_ratio/c \\
 parent_time_step_ratio              = 1, 5,
/p_top_requested/c \\
 p_top_requested                     = 2500,
/num_land_cat/c \\
 num_land_cat                        = 21,
/nssl_aero_opt/c \\
 nssl_aero_opt                       = 0,
/use_aero_icbc/c \\
 use_aero_icbc                       = .false.,
/chem_opt/c \\
 chem_opt                            = ${CHEM},
/aer_opt/c \\
 aer_opt                             = 0,
EOF

if ( ! -e namelist.input.template) cp ${NAME_DIR}/namelist.input.member${emember} namelist.input.template
###
    sed -f script.sed namelist.input.template > namelist.input

    # ------------------------------------------------
    # run real.exe, rename wrfinput_d01 and wrfbdy_d01
    # ------------------------------------------------
   
    echo "#\!/bin/csh"                                                                >! ${RUNDIR}/mem${emember}/bc.job
    echo "#=================================================================="        >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "-J bc_mem${emember}"                                              >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "-o ${RUNDIR}/mem${emember}/bc.log"                                >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "-e ${RUNDIR}/mem${emember}/bc.err"                                >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "-p batch"                                                         >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "--mem-per-cpu=5G"                                                 >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH' "-n 12"                                                            >> ${RUNDIR}/mem${emember}/bc.job
    echo '#SBATCH -t 0:30:00'                                                         >> ${RUNDIR}/mem${emember}/bc.job
    echo "#=================================================================="        >> ${RUNDIR}/mem${emember}/bc.job

    cat >> ${RUNDIR}/mem${emember}/bc.job << EOF

    source /home/wof-torus/torusenv

    set echo

    cd \${SLURM_SUBMIT_DIR}

 
    cd ${RUNDIR}/mem${emember}/

    ln -sf ${RUNDIR}/WRF_RUN/real.exe real.exe
    ln -sf ${RUNDIR}/WRF_RUN/ETAMPNEW_DATA ETAMPNEW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/GENPARM.TBL GENPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/LANDUSE.TBL LANDUSE.TBL
    ln -sf ${RUNDIR}/WRF_RUN/RRTMG_LW_DATA RRTMG_LW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/RRTMG_SW_DATA RRTMG_SW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/RRTM_DATA RRTM_DATA
    ln -sf ${RUNDIR}/WRF_RUN/SOILPARM.TBL SOILPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/VEGPARM.TBL VEGPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/gribmap.txt gribmap.txt
    ln -sf ${RUNDIR}/WRF_RUN/tr49t67 tr49t67
    ln -sf ${RUNDIR}/WRF_RUN/tr49t85 tr49t85
    ln -sf ${RUNDIR}/WRF_RUN/tr67t85 tr67t85

    sleep 2

    srun ${RUNDIR}/WRF_RUN/real.exe

    if ( ! -e wrfinput_d01) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfinput_d01 
    else if ( ! -e wrfbdy_d01  ) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfbdy_d01
    else
       echo Done with boundary files
       #rm -rf wrfinput_d01 # keep this commented out for TORUS DA, will delete wrfinput file otherwise
       sleep 2
    endif

    ${MOVE} ${RUNDIR}/mem${emember}/wrfbdy_d01 ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember}
    sleep 1
    ${MOVE} ${RUNDIR}/mem${emember}/wrfinput_d01 ${RUNDIR}/mem${emember}/wrfinput_d01.${emember}
    sleep 1

    touch ${SEMA4}/bc_mem${emember}_done

    ${REMOVE} rsl*

EOF

chmod +x ${RUNDIR}/mem${emember}/bc.job
sbatch ${RUNDIR}/mem${emember}/bc.job

sleep 1

exit (0)

#########################################################################################################
