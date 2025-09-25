#!/bin/tcsh

### SETUP_rlt.csh
### Preconfig directories and link associated stuff to get processing started. 
### Run this script BEFORE anything else kicks off.

set echo
source /scratch/home/thomas.jones/WOFenv_dart

#The following are for running in retro
### Set dates for WPS Procedure
echo "setenv sdate_bc "2023-05-02_15:00:00 >! ${TOP_DIR}/realtime.cfg.${event}
echo "setenv edate_bc "2023-05-03_12:00:00 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv sdate_ic "2023-05-02_15:00:00 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv edate_ic "2023-05-02_15:00:00 >> ${TOP_DIR}/realtime.cfg.${event}


### Set running days variables
echo "setenv runyr "2023 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runmon "05 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runday "02 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtyr "2023 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtmon "05 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtday "03 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runDay "20230502 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtDay "20230503 >> ${TOP_DIR}/realtime.cfg.${event}

### NCYCLE_* is number of particular analysis cycles
echo "setenv NCYCLE 18" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv NCYCLE_IC 1" >> ${TOP_DIR}/realtime.cfg.${event}

### Set up directory paths
echo "setenv TOP_DIR ${TOP_DIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv SCRIPTDIR ${SCRIPTDIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv RUNDIR ${RUNDIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv PYDIR ${CENTRALDIR}/python" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv FCST_DIR ${TOP_DIR}/FCST/${event}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv TEMPLATE_DIR ${CENTRALDIR}/templates" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv NAME_DIR ${CENTRALDIR}/templates/namelists.WOFS.v3.smoke.3KM.Z60" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv WRFDIR /scratch/home/Thomas.Jones/WRF/WRFV3.9_WOFS_SMOKE_VE" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv WPSDIR /scratch/home/Thomas.Jones/WRF/WPSV3.9.1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv DARTDIR /scratch/home/Thomas.Jones/WOFS_DART/DART_2023" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv SEMA4 ${RUNDIR}/flags" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv HRRRE_DIR /scratch/wofuser/MODEL_DATA/HRRRE" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv HRRR_DIR /scratch/tajones/MODEL_DATA/HRRR" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv ASOS_DIR /work/rt_obs/ASOS" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv MESO_DIR /work/rt_obs/Mesonet" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv DBZ_DIR /work/rt_obs/REF" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv DBZ_DIR /scratch/tajones/realtime/OBSGEN/REF" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv VR_DIR /scratch/tajones/realtime/OBSGEN/VEL/" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv CWP_DIR /scratch/tajones/dart/OBS_SEQ/Satellite/CWP" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv ABI_DIR /scratch/tajones/dart/OBS_SEQ/Satellite/Radiance" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv RTTOV_DIR /scratch/tajones/software/nvidia/rttov13/rtcoef_rttov13" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv INPUTDIR /work/rt_obs/WRFINPUTS" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv CHEM 18" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv aer_opt 3" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv FIREDIR /scratch/home/Thomas.Jones/SMOKE_CODE/smoke/prep-chem/" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv BBMDIR  /scratch/tajones/realtime/OBSGEN/Satellite/GOES_FIRE/" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv GSAT G16" >> ${TOP_DIR}/realtime.cfg.${event}

### Number of ensembles
echo "setenv ENS_SIZE 36" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv HRRRE_BCS 18" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv FCST_SIZE 18" >> ${TOP_DIR}/realtime.cfg.${event}

### Length of assimilation cycle
echo "setenv assim_per_meso 1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv assim_per_conv 15" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv cycle 15" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv start_hr 15" >> ${TOP_DIR}/realtime.cfg.${event}

### Set number of domains for mesoscale DA run
echo "setenv domains 1" >> ${TOP_DIR}/realtime.cfg.${event}

### Set grid dimensions
echo "setenv grdpts_ew 301" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv grdpts_ns 301" >> ${TOP_DIR}/realtime.cfg.${event}

### Set grid spacing
echo "setenv gdspc 3000" >> ${TOP_DIR}/realtime.cfg.${event}

### Add noise parameters
echo "setenv refl_thresh 35" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv refl_innov 10" >> ${TOP_DIR}/realtime.cfg.${event}

### Number of soil levels in model data
echo "setenv num_soil_levels 9" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv lsm 3 ">> ${TOP_DIR}/realtime.cfg.${event}

### WRF Namelist runtime information
echo "setenv procx -1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv procy -1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv procxf -1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv procyf -1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv tiles 1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv tilesf 1" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv ts 15" >> ${TOP_DIR}/realtime.cfg.${event}

### Number of cores for MPI runs
echo "setenv FILTER_CORES 768" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv WRF_CORES 48" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv WRF_FCORES 96" >> ${TOP_DIR}/realtime.cfg.${event}

### How long the filter and advances are for:
echo "setenv filter_time 2:00" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv filter_start 0:30" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv advance_start 1:00" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv advance_time 0:20" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv obs_wait 0:10" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv obs_wait_conv 0:05" >> ${TOP_DIR}/realtime.cfg.${event}

### Convenient utils; probably should be ALIAS's...
#  System specific commands
echo "setenv   REMOVE 'rm -vf'" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv   REMOVEDIR 'rm -vrf'" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv   COPY '/bin/cp -pv'" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv   MOVE '/bin/mv -fv'" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv   LINK 'ln -fs'" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv   WGET /usr/bin/wget" >> ${TOP_DIR}/realtime.cfg.${event}
   
### Logfiles
echo "setenv logWPS "${RUNDIR}"/WPS.log" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv logIcbc "${RUNDIR}"/ICBC.log" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv logConv "${RUNDIR}"/ConvMAIN.log" >> ${TOP_DIR}/realtime.cfg.${event} 
    
source ${TOP_DIR}/realtime.cfg.${event}

### Set time of initial assimilation cycle
echo "setenv nextCcycle ${runDay}${cycle}00" >> ${TOP_DIR}/realtime.cfg.${event}

### Make the day's run directory and internal directories
mkdir $RUNDIR
cd $RUNDIR
mkdir -p ${RUNDIR}/flags ${RUNDIR}/WRFOUT 
mkdir -p ${FCST_DIR}


### Make 15 minutes directories to hold DART-based output
foreach hr ( 15 16 17 18 19 20 21 22 23 )
    
   foreach mte ( 00 15 30 45 )

     mkdir -p ${RUNDIR}/${runDay}${hr}${mte}

   end

end

foreach hr2 ( 00 01 02 03 04 05 )

   foreach mte ( 00 15 30 45 )
     
      mkdir -p ${RUNDIR}/${nxtDay}${hr2}${mte}

   end
    
end

mkdir -p ${RUNDIR}/${nxtDay}0600
  
mkdir -p ${RUNDIR}/WRF_RUN
mkdir -p ${RUNDIR}/HRRR

cd ${RUNDIR}

touch ${SEMA4}/ConvRun
touch ${SEMA4}/sat_done
touch ${SEMA4}/mrms_done
#touch ${SEMA4}/ICBC_ready
touch ${logWPS}
touch ${logIcbc}
touch ${logConv}

cp -R ${DARTDIR}/models/wrf/work/nvidia/advance_time .
cp -R ${DARTDIR}/models/wrf/work/nvidia/convertdate .
cp -R ${TEMPLATE_DIR}/input.nml.init.tb ./input.nml
cp -R ${TEMPLATE_DIR}/namelists.WOFS.v3.smoke/namelist.input.member1 namelist.input
cp -R ${TEMPLATE_DIR}/restarts_in_d01.txt restarts_in_d01.txt
cp -R ${TEMPLATE_DIR}/restarts_out_d01.txt restarts_out_d01.txt
cp -R ${DARTDIR}/observations/forward_operators/rttov_sensor_db.csv rttov_sensor_db.csv

#### LINK GOES RTTOV COEFFS
ln -sf ${RTTOV_DIR}/cldaer_ir/*goes_16* .
ln -sf ${RTTOV_DIR}/cldaer_visir/*goes_16* .
ln -sf ${RTTOV_DIR}/mfasis_lut/*goes_16* .
ln -sf ${RTTOV_DIR}/rttov13pred54L/*goes_16* .
ln -sf ${RTTOV_DIR}/rttov9pred54L/*goes_16* 
ln -sf ${RTTOV_DIR}/brdf_data/*H5 .
ln -sf ${RTTOV_DIR}/emis_data/*H5 .


### Copy necessary DART-based executables into run directory
###########################################################################
cd ${RUNDIR}/WRF_RUN

cp -R ${DARTDIR}/models/wrf/work/nvidia/advance_time .
cp -R ${DARTDIR}/models/wrf/work/nvidia/convertdate .
cp -R ${DARTDIR}/models/wrf/work/nvidia/add_pert_where_high_refl .
cp -R ${DARTDIR}/models/wrf/work/nvidia/grid_refl_obs .
cp -R ${DARTDIR}/models/wrf/work/nvidia/obs_seq_to_netcdf .
cp -R ${DARTDIR}/models/wrf/work/nvidia/obs_sequence_tool .
cp -R ${DARTDIR}/models/wrf/work/nvidia/update_wrf_bc .
cp -R ${DARTDIR}/models/wrf/work/nvidia/filter .
#cp -R ${DARTDIR}/observations/forward_operators/rttov_sensor_db.csv .

###########################################################################

### Copy all code/files necessary to run WPS/WRF
#cp -R ${TEMPLATE_DIR}/qr_acr_qg.dat_381 ./qr_acr_qg.dat
#cp -R ${TEMPLATE_DIR}/qr_acr_qs.dat_381 ./qr_acr_qs.dat
#cp -R ${TEMPLATE_DIR}/freezeH2O.dat_381 ./freezeH2O.dat

cp -R ${WPSDIR}/geogrid/src/geogrid.exe .
cp -R ${WPSDIR}/ungrib/src/ungrib.exe .
cp -R ${WPSDIR}/metgrid/src/metgrid.exe .
cp -R ${WPSDIR}/link_grib.csh .
cp -R ${WRFDIR}/run/CCN_ACTIVATE.BIN .
cp -R ${WRFDIR}/run/ETAMPNEW_DATA ETAMPNEW_DATA
cp -R ${WRFDIR}/run/GENPARM.TBL GENPARM.TBL
cp -R ${WRFDIR}/run/LANDUSE.TBL LANDUSE.TBL
cp -R ${WRFDIR}/run/RRTM_DATA RRTM_DATA
cp -R ${WRFDIR}/run/RRTMG_SW_DATA RRTMG_SW_DATA
cp -R ${WRFDIR}/run/RRTMG_LW_DATA RRTMG_LW_DATA
cp -R ${WRFDIR}/run/SOILPARM.TBL SOILPARM.TBL
cp -R ${WRFDIR}/run/VEGPARM.TBL VEGPARM.TBL
cp -R ${WRFDIR}/run/gribmap.txt gribmap.txt
cp -R ${WRFDIR}/run/*.formatted .
cp -R ${WRFDIR}/run/bulk* .
cp -R ${WRFDIR}/run/CAM* .
cp -R ${WRFDIR}/run/capacity.asc .
cp -R ${WRFDIR}/run/CLM* .
cp -R ${WRFDIR}/run/c* .
cp -R ${WRFDIR}/run/grib2map.tbl .
cp -R ${WRFDIR}/run/ker* .
cp -R ${WRFDIR}/run/masses.asc .
cp -R ${WRFDIR}/run/MPTABLE.TBL .
cp -R ${WRFDIR}/run/RRTMG_LW_DATA_DBL .
cp -R ${WRFDIR}/run/RRTMG_SW_DATA_DBL .
cp -R ${WRFDIR}/run/termvels.asc .
cp -R ${WRFDIR}/run/tr49t67 tr49t67
cp -R ${WRFDIR}/run/tr49t85 tr49t85
cp -R ${WRFDIR}/run/tr67t85 tr67t85
cp -R ${WRFDIR}/main/nvidia/real.exe .
cp -R ${WRFDIR}/main/nvidia/wrf.exe .

cp -R ${FIREDIR}/Prep_smoke_FRP/bin/prep_chem_sources_nvidia.exe ./prep_chem_sources.exe
#cp -R ${FIREDIR}/fires_ncfmake_wofs/fires_ncfmake/fires_ncfmake.x .
#cp -R /scratch/home/Thomas.Jones/SMOKE_CODE/wofs_smoke/python/wrfin_frpnoise.py .
cp -R /scratch/home/Thomas.Jones/SMOKE_CODE/wofs_smoke/python/prepchem2wrf.py .

chmod -R 775 $RUNDIR

echo "Done with initial setup"

exit (0)
