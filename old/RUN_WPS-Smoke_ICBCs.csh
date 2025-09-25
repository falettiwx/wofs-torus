#!/bin/csh -f
#

source ~/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

if ( -e /scratch/tajones/realtime/radar_files/radars.${event}_space.csh ) then
   source /scratch/tajones/realtime/radar_files/radars.${event}_space.csh
else
   source ${SCRIPTDIR}/WOFS_grid_radar/radars.20180407.csh
endif

###
set echo on
###

setenv RUNDIR /scratch/tajones/dart/${event}/HRRR

cd ${RUNDIR}

############################
# UNGRIB HRRR  DATA 
############################

      if ( -e namelist.wps ) rm -f namelist.wps

      set startdate = " start_date = '${sdate_bc}', '${sdate_bc}',"
      set enddate = " end_date = '${edate_bc}', '${edate_bc}',"

      echo $startdate
      echo $enddate

      cp ${TEMPLATE_DIR}/namelist.wps.template.HRRR_smoke .

      echo "&share" > namelist.wps
      echo " wrf_core = 'ARW'," >> namelist.wps
      echo " max_dom = ${domains}," >> namelist.wps
      echo ${startdate} >> namelist.wps
      echo ${enddate} >> namelist.wps
      echo " interval_seconds = 3600" >> namelist.wps
      echo " io_form_geogrid = 2," >> namelist.wps
      echo "/" >> namelist.wps

      echo "&geogrid" >> namelist.wps
      echo " parent_id         = 1,  1," >> namelist.wps
      echo " parent_grid_ratio = 1,  3," >> namelist.wps
      echo " i_parent_start    = 1,  80," >> namelist.wps
      echo " j_parent_start    = 1,  77," >> namelist.wps
      echo " e_we              = ${grdpts_ew},  226," >> namelist.wps
      echo " e_sn              = ${grdpts_ns},  226," >> namelist.wps

      #echo " geog_data_res     = 'modis_15s+modis_fpar+modis_lai+30s', 'modis_15s+modis_fpar+modis_lai+30s'," >> namelist.wps
      #echo " geog_data_res     = 'modis_lakes+15s+modis_fpar+modis_lai+30s', 'modis_15s+modis_fpar+modis_lai+30s'," >> namelist.wps
      echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+modis_fpar+modis_lai', 'modis_15s_lake+modis_fpar+modis_lai+30s'," >> namelist.wps

      echo " dx = ${gdspc}," >> namelist.wps
      echo " dy = ${gdspc}," >> namelist.wps
      echo " map_proj = 'lambert'," >> namelist.wps
      echo " ref_lat   =  ${cen_lat}," >> namelist.wps
      echo " ref_lon   =  ${cen_lon}," >> namelist.wps
      echo " truelat1  =  30.00," >> namelist.wps
      echo " truelat2  =  60.00," >> namelist.wps
      echo " stand_lon =  ${cen_lon}," >> namelist.wps
      echo " geog_data_path = '/scratch/tajones/geog_V4'" >> namelist.wps
      echo " opt_geogrid_tbl_path = '${TEMPLATE_DIR}'" >> namelist.wps
      echo "/" >> namelist.wps

      cat namelist.wps.template.HRRR_smoke >> namelist.wps

      ln -sf ${TEMPLATE_DIR}/Vtable.raphrrr_BC.V4 ./Vtable           

      # 1400 UTC HRRR RUN
      ${EXEDIR}/link_grib.csh ${HRRR_DIR}/${event}12/hrrr.t12z.wrfnatf0[0-9].grib2 ${HRRR_DIR}/${event}12/hrrr.t12z.wrfnatf1[0-9].grib2 ${HRRR_DIR}/${event}12/hrrr.t12z.wrfnatf2[0-5].grib2 .
      #${RUNDIR}/WRF_RUN/link_grib.csh /work/Thomas.Jones/MODEL_DATA/HRRR/${event}15/hrrr.t15z.wrfnatf0[0-9].grib2 /oldscratch/tajones/MODEL_DATA/HRRR/${event}15/hrrr.t15z.wrfnatf1[0-9].grib2 .
      echo "Linked HRRR grib files"

  
     echo "#\!/bin/csh"                                                           >! ${RUNDIR}/ungrib_icbc.csh
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_icbc.csh 
     echo '#SBATCH' "-J ungrib_icbc"                                              >> ${RUNDIR}/ungrib_icbc.csh
     echo '#SBATCH' "-o ${RUNDIR}/ungrib_icbc.log"                                >> ${RUNDIR}/ungrib_icbc.csh
     echo '#SBATCH' "-e ${RUNDIR}/ungrib_icbc.err"                                >> ${RUNDIR}/ungrib_icbc.csh 
     echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/ungrib_icbc.csh
     echo '#SBATCH' "--mem-per-cpu=10G"                                           >> ${RUNDIR}/ungrib_icbc.csh 
     echo '#SBATCH' "-n 1"                                                        >> ${RUNDIR}/ungrib_icbc.csh
     echo '#SBATCH -t 1:30:00'                                                    >> ${RUNDIR}/ungrib_icbc.csh
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_icbc.csh

     cat >> ${RUNDIR}/ungrib_icbc.csh << EOF

     set echo

     source /scratch/home/thomas.jones/WOFenv_dart

     cd ${RUNDIR}

     srun  ${EXEDIR}/ungrib.exe

     sleep 1

     touch ${SEMA4}/ungrib_hrrr_done

EOF

     sbatch ${RUNDIR}/ungrib_icbc.csh

     while (! -e ${SEMA4}/ungrib_hrrr_done)
           echo "Waiting for ungribbing of GSD HRRR Files" 
           sleep 5
     end
      

###########################################################################
# METGRID FOR DETERM HRRR
###########################################################################

ln -sf ${TOP_DIR}/${event}/geo_em.d01.nc ./geo_em.d01.nc


echo "#\!/bin/csh"                                                           >! ${RUNDIR}/metgrid_icbc.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH' "-J metgrid_icbc"                                             >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH' "-o ${RUNDIR}/metgrid_icbc.log"                               >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH' "-e ${RUNDIR}/metgrid_icbc.err"                               >> ${RUNDIR}/metgrid_icbc.csh  
echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH' "--mem-per-cpu=5G"                                            >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH' "-n 12"                                                       >> ${RUNDIR}/metgrid_icbc.csh
echo '#SBATCH -t 0:45:00'                                                    >> ${RUNDIR}/metgrid_icbc.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_icbc.csh

      cat >> ${RUNDIR}/metgrid_icbc.csh << EOF

      set echo

      source /scratch/home/thomas.jones/WOFenv_dart

      cd ${RUNDIR}

      srun ${EXEDIR}/metgrid.exe 

      sleep 1 

      touch ${SEMA4}/metgrid_icbc_done

EOF

sbatch ${RUNDIR}/metgrid_icbc.csh
    
while (! -e ${SEMA4}/metgrid_icbc_done) 
       echo "Waiting for metgrid to finish"
       sleep 5
end

echo "WPS is complete"

#rm geogrid.log geogrid.err geogrid.csh ungrib_icbc.csh metgrid_icbc.csh
#rm -fr mem*/GRIBFILE* mem*/HRRRE* mem*/metgrid.log*

###########################################################################
exit (0)
###########################################################################
