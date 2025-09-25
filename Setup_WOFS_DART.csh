#!/bin/tcsh

### SETUP_rlt.csh

### Preconfig directories and link associated stuff to get processing started. 
### Run this script BEFORE anything else kicks off.

set echo

source /home/william.faletti/wof-torus/torusenv
#source /scratch/home/thomas.jones/WOFenv_dart

#setenv event `date +%Y%m%d`
#setenv eventnxt = `date --date='1 day' +%Y%m%d`

#Pull date information from torusenv variables
set inityr=`echo ${event} | cut -c1-4`
set initmon=`echo ${event} | cut -c5-6`
set initday=`echo ${event} | cut -c7-8`
set inithr=`echo ${starttime} | cut -c1-2`
set initmin=`echo ${starttime} | cut -c3-4`

# Set end time for data assimilation period
set endyr="2022"
set endmon="05"
set endday="24"
set endhr="02" # Add ITVL_SEC to the valid time of your last met_em file (i.e., add it to the time of the final desired analysis)
set endmin="06"

#The following are for running in retro

### Set dates for WPS Procedure
echo "setenv sdate_bc "${inityr}-${initmon}-${initday}_${inithr}:${initmin}:00 >! ${TOP_DIR}/realtime.cfg.${event}
echo "setenv edate_bc "${endyr}-${endmon}-${endday}_${endhr}:${endmin}:00 >> ${TOP_DIR}/realtime.cfg.${event} # add an hour to the valid time of your last met_em file (i.e., add it to the time of the final desired analysis)
echo "setenv sdate_ic "2022-05-09_15:00:00 >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv edate_ic "2022-05-09_15:00:00 >> ${TOP_DIR}/realtime.cfg.${event}

### Set running days variables
echo "setenv runyr ${inityr}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runmon ${initmon}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runday ${initday}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtyr ${endyr}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtmon ${endmon}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtday ${endday}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv runDay ${inityr}${initmon}${initday}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv nxtDay ${endyr}${endmon}${endday}" >> ${TOP_DIR}/realtime.cfg.${event}

### Set BC update frequency
echo "setenv ITVL_SEC 360" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv NCYCLE 5" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv NCYCLE_IC 1" >> ${TOP_DIR}/realtime.cfg.${event}

# Set up directory paths
echo "setenv TOP_DIR ${TOP_DIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv SCRIPTDIR ${SCRIPTDIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv RUNDIR ${RUNDIR}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv TEMPLATE_DIR ${CENTRALDIR}/templates" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv PYDIR ${CENTRALDIR}/python" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv FCST_DIR ${TOP_DIR}/FCST/${event}" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv NAME_DIR ${CENTRALDIR}/templates/namelist_inputs" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv SEMA4 ${RUNDIR}/flags" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv HRRRE_DIR /scratch/home/wofuser/torus/GRIB2/FINAL" >> ${TOP_DIR}/realtime.cfg.${event} # 5/9/24 - will have to change as new case subdirs added
echo "setenv HRRRE_DIR /scratch/wof-torus/bc_full/GRIB2/FINAL" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv ASOS_DIR /work/rt_obs/ASOS" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv MESO_DIR /work/rt_obs/Mesonet" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv GEOG_DIR /scratch/wofs_fire/tajones/static/geog_v4" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv INPUTDIR /work/rt_obs/WRFINPUTS" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv CHEM 0" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv aer_opt 0" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv GSAT G16" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv WRFDIR /scratch/home/Thomas.Jones/WRF/WRFV3.9_WOFS_SMOKE_VE" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv WPSDIR /scratch/home/Thomas.Jones/WRF/WPSV3.9.1" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv DARTDIR /scratch/home/Thomas.Jones/WOFS_DART/DART_2023" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv HRRR_DIR /scratch/wofs_fire/tajones/MODEL_DATA/HRRR" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv DBZ_DIR /work/rt_obs/REF" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv DBZ_DIR /scratch/wofs_fire/tajones/realtime/OBSGEN/REF" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv VR_DIR /scratch/wofs_fire/tajones/realtime/OBSGEN/VEL/" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv CWP_DIR /scratch/wofs_fire/tajones/dart/OBS_SEQ/Satellite/CWP" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv ABI_DIR /scratch/wofs_fire/tajones/dart/OBS_SEQ/Satellite/Radiance" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv RTTOV_DIR /scratch/wofs_fire/tajones/software/intel/rttov13/rtcoef_rttov13" >> ${TOP_DIR}/realtime.cfg.${event}

### Number of ensembles
echo "setenv ENS_SIZE 36" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv HRRRE_BCS 36" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv FCST_SIZE 18" >> ${TOP_DIR}/realtime.cfg.${event}

### Length of assimilation cycle
echo "setenv cycle 3" >> ${TOP_DIR}/realtime.cfg.${event} # length of assimilation cycle in minutes
echo "setenv cycle_ref 3" >> ${TOP_DIR}/realtime.cfg.${event} # frequency of dbz assim in minutes (set to very large number if no dbz assim)
#echo "setenv start_hr ${inithr}" >> ${TOP_DIR}/realtime.cfg.${event} # UTC hour to start DA 

### Set number of domains for mesoscale DA run
echo "setenv domains 1" >> ${TOP_DIR}/realtime.cfg.${event}

### Set grid dimensions
#echo "setenv grdpts_ew 540" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv grdpts_ns 480" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv grdpts_ew 200" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv grdpts_ns 200" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv grdpts_ew 180" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv grdpts_ns 180" >> ${TOP_DIR}/realtime.cfg.${event}

### Set grid spacing
#echo "setenv gdspc 500" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv gdspc 1000" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv gdspc 3000" >> ${TOP_DIR}/realtime.cfg.${event}

### Set ref_lat and ref_lon (done by Billy Faletti 5/7/24)
#echo "setenv cen_lat 33.5" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv cen_lat 34.0" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv cen_lon -102.5" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv cen_lon -102.75" >> ${TOP_DIR}/realtime.cfg.${event}

### Set domain specs for namelists

### Add noise parameters
echo "setenv refl_thresh 35" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv refl_innov 10" >> ${TOP_DIR}/realtime.cfg.${event}

### Number of soil levels in model data
echo "setenv num_soil_levels 9" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv lsm 3" >> ${TOP_DIR}/realtime.cfg.${event}

### WRF Namelist runtime information
echo "setenv ts 15" >> ${TOP_DIR}/realtime.cfg.${event} # model time step (seconds)


##### Per Kent, probably don't have to touch the remaining blocks until the source command

### Number of cores for MPI runs
#echo "setenv FILTER_CORES 960" >> ${TOP_DIR}/realtime.cfg.${event} # all Vecna-specific numbers
echo "setenv FILTER_CORES 576" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv WRF_CORES 48" >> ${TOP_DIR}/realtime.cfg.${event}
echo "setenv FILTER_TIMEOUT 02:00:00" >> ${TOP_DIR}/realtime.cfg.${event}
#echo "setenv WRF_FCORES 96" >> ${TOP_DIR}/realtime.cfg.${event}

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

#####

source ${TOP_DIR}/realtime.cfg.${event}

### Set time of initial assimilation cycle
#echo "setenv nextCcycle ${runDay}${cycle}00" >> ${TOP_DIR}/realtime.cfg.${event}

### Make the day's run directory and internal directories
mkdir $RUNDIR
cd $RUNDIR
mkdir -p ${RUNDIR}/flags ${RUNDIR}/WRFOUT 
mkdir -p ${FCST_DIR}

### Make analysis-time directories to hold DART-based output (automated by Billy Faletti 6/13/24)
	# define start time using date command
set dir_tstamp =  `echo "${sdate_bc}" | tr '_' ' '`
set dir_tstamp = `date -d "$dir_tstamp" "+%F %T"`
	# similarly define end time (final analysis time + 1 cycling interval to stop while loop)
set end_tstamp =  `echo "${edate_bc} ${ITVL_SEC} seconds ago" | tr '_' ' '`
set end_tstamp = `date -d "$end_tstamp ${cycle} minutes" "+%F %T"`
	# while loop creates directories
while ( "$dir_tstamp" != "$end_tstamp" )
#while ( "$dir_tstamp" != "2022-05-24 02:18:00" )
   set diryr =  `echo $dir_tstamp | cut -c1-4`
   set dirmo =  `echo $dir_tstamp | cut -c6-7`
   set dirday = `echo $dir_tstamp | cut -c9-10`
   set dirhr =  `echo $dir_tstamp | cut -c12-13`
   set dirmin = `echo $dir_tstamp | cut -c15-16`

   mkdir -p ${RUNDIR}/${diryr}${dirmo}${dirday}${dirhr}${dirmin}
   		# add 1 cycling interval to time for next iteration
   set dir_tstamp = `date -d "$dir_tstamp ${cycle} minutes" "+%F %T"`

end

####################################################################################################
###### OLD DIRECTORY CREATION CODE ########
	# Make the directories
#foreach hr ( 22 23 )
#    						# before and after 00z saved to different directories because directories are separated by date
#   foreach mte ( 00 15 30 45 )
#
#     mkdir -p ${RUNDIR}/${runDay}${hr}${mte}
#
#   end
#
#end
#
#foreach hr2 ( 00 01 )
#
#   foreach mte ( 00 15 30 45 )
#     
#      mkdir -p ${RUNDIR}/${nxtDay}${hr2}${mte}
#
#   end
#    
#end

	# Automate final analysis time and make directory for it
#set end_tstamp =  `echo "${edate_bc} ${ITVL_SECONDS} seconds ago" | tr '_' ' '`
#set end_tstamp = `date -d "$end_tstamp"`
#set endhr =  `echo $end_tstamp | cut -c12-13`
#set endmin = `echo $end_tstamp | cut -c15-16`

#mkdir -p ${RUNDIR}/${nxtDay}${endhr}${endmin} # enter time for last analysis cycle
 
###################################################################################################
 
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

cp -R ${CENTRALDIR}/WRF_RUN/advance_time .
cp -R ${CENTRALDIR}/WRF_RUN/convertdate .
cp -R ${TEMPLATE_DIR}/input.nml.init ./input.nml
cp -R ${TEMPLATE_DIR}/namelists.WOFS.v3.smoke.3KM.Z60/namelist.input.member1 namelist.input
cp -R ${TEMPLATE_DIR}/restarts_in_d01.txt restarts_in_d01.txt
cp -R ${TEMPLATE_DIR}/restarts_out_d01.txt restarts_out_d01.txt
cp -R ${TEMPLATE_DIR}/bnrhf_qceff_table_torus.csv bnrhf_qceff_table_torus.csv
#cp -R ${DARTDIR}/observations/forward_operators/rttov_sensor_db.csv rttov_sensor_db.csv

#### LINK GOES RTTOV COEFFS
#ln -sf ${RTTOV_DIR}/cldaer_ir/*goes_16* .
#ln -sf ${RTTOV_DIR}/cldaer_visir/*goes_16* .
#ln -sf ${RTTOV_DIR}/mfasis_lut/*goes_16* .
#ln -sf ${RTTOV_DIR}/rttov13pred54L/*goes_16* .
#ln -sf ${RTTOV_DIR}/rttov9pred54L/*goes_16* 
#ln -sf ${RTTOV_DIR}/brdf_data/*H5 .
#ln -sf ${RTTOV_DIR}/emis_data/*H5 .


### Copy necessary DART-based executables into run directory
###########################################################################
cp -r ${CENTRALDIR}/WRF_RUN .

#cp -R ${DARTDIR}/models/wrf/work/advance_time .
#cp -R ${DARTDIR}/models/wrf/work/convertdate .
#cp -R ${DARTDIR}/models/wrf/work/add_pert_where_high_refl .
#cp -R ${DARTDIR}/models/wrf/work/grid_refl_obs .
#cp -R ${DARTDIR}/models/wrf/work/obs_seq_to_netcdf .
#cp -R ${DARTDIR}/models/wrf/work/obs_sequence_tool .
#cp -R ${DARTDIR}/models/wrf/work/update_wrf_bc .
#cp -R ${DARTDIR}/models/wrf/work/filter .
#cp -R ${DARTDIR}/observations/forward_operators/rttov_sensor_db.csv .

###########################################################################

### Copy all code/files necessary to run WPS/WRF
#cp -R ${TEMPLATE_DIR}/qr_acr_qg.dat_381 ./qr_acr_qg.dat
#cp -R ${TEMPLATE_DIR}/qr_acr_qs.dat_381 ./qr_acr_qs.dat
#cp -R ${TEMPLATE_DIR}/freezeH2O.dat_381 ./freezeH2O.dat

#cp -R ${WPSDIR}/geogrid/src/geogrid.exe .
#cp -R ${WPSDIR}/ungrib/src/ungrib.exe .
#cp -R ${WPSDIR}/metgrid/src/metgrid.exe .
#cp -R ${WPSDIR}/link_grib.csh .
#cp -R ${WRFDIR}/run/CCN_ACTIVATE.BIN .
#cp -R ${WRFDIR}/run/ETAMPNEW_DATA ETAMPNEW_DATA
#cp -R ${WRFDIR}/run/GENPARM.TBL GENPARM.TBL
#cp -R ${WRFDIR}/run/LANDUSE.TBL LANDUSE.TBL
#cp -R ${WRFDIR}/run/RRTM_DATA RRTM_DATA
#cp -R ${WRFDIR}/run/RRTMG_SW_DATA RRTMG_SW_DATA
#cp -R ${WRFDIR}/run/RRTMG_LW_DATA RRTMG_LW_DATA
#cp -R ${WRFDIR}/run/SOILPARM.TBL SOILPARM.TBL
#cp -R ${WRFDIR}/run/VEGPARM.TBL VEGPARM.TBL
#cp -R ${WRFDIR}/run/gribmap.txt gribmap.txt
#cp -R ${WRFDIR}/run/*.formatted .
#cp -R ${WRFDIR}/run/bulk* .
#cp -R ${WRFDIR}/run/CAM* .
#cp -R ${WRFDIR}/run/capacity.asc .
#cp -R ${WRFDIR}/run/CLM* .
#cp -R ${WRFDIR}/run/c* .
#cp -R ${WRFDIR}/run/grib2map.tbl .
#cp -R ${WRFDIR}/run/ker* .
#cp -R ${WRFDIR}/run/masses.asc .
#cp -R ${WRFDIR}/run/MPTABLE.TBL .
#cp -R ${WRFDIR}/run/RRTMG_LW_DATA_DBL .
#cp -R ${WRFDIR}/run/RRTMG_SW_DATA_DBL .
#cp -R ${WRFDIR}/run/termvels.asc .
#cp -R ${WRFDIR}/run/tr49t67 tr49t67
#cp -R ${WRFDIR}/run/tr49t85 tr49t85
#cp -R ${WRFDIR}/run/tr67t85 tr67t85
#cp -R ${WRFDIR}/main/real.exe .
#cp -R ${WRFDIR}/main/wrf.exe .

#cp -R ${FIREDIR}/Prep_smoke_FRP/bin/prep_chem_sources.exe .
#cp -R ${FIREDIR}/fires_ncfmake_wofs/fires_ncfmake/fires_ncfmake.x .
#cp -R /scratch/home/Thomas.Jones/SMOKE_CODE/wofs_smoke/python/wrfin_frpnoise.py .
#cp -R /scratch/home/Thomas.Jones/SMOKE_CODE/wofs_smoke/python/prepchem2wrf.py .

chmod -R 775 $RUNDIR

echo "Done with initial setup"

exit (0)
