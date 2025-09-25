#!/bin/csh 
#

source /scratch/home/thomas.jones/WOFenv_dart
source ${TOP_DIR}/realtime.cfg.${event}

#if ( -e /work/rt_obs/radar_files/radars.${event}.csh ) then
#   source /work/rt_obs/radar_files/radars.${event}.csh
if ( -e /scratch/tajones/realtime/radar_files/radars.${event}_space.csh ) then
   source /scratch/tajones/realtime/radar_files/radars.${event}_space.csh
else
   source ${SCRIPTDIR}/WOFS_grid_radar/radars.20180407.csh
endif

###
set echo on
###

cd ${RUNDIR}
### First. remove residual files from last run:
rm -fr ic*
rm geogrid.log.00* 
rm geogrid.log 
rm ${SEMA4}/geogrid_done 
rm ${SEMA4}/ungrib_mem*_done
rm ${SEMA4}/metgrid_mem*_done
###

############################
# UNGRIB HRRRE ICs DATA 
############################

set n = 1
@ count = 1
while ( $n <= $ENS_SIZE )

      mkdir ${RUNDIR}/ic$n 

      cd ${RUNDIR}/ic$n

      if ( -e namelist.wps ) rm -f namelist.wps

      set startdate = " start_date = '${sdate_ic}', '${sdate_ic}',"
      set enddate = " end_date = '${edate_ic}', '${edate_ic}',"

      echo $startdate
      echo $enddate

      cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

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

      #echo " geog_data_res     = 'modis_lakes+15s+modis_fpar+modis_lai+30s', 'modis_15s_lakes+modis_fpar+modis_lai+30s'," >> namelist.wps
      echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+modis_fpar+modis_lai', 'modis_15s_lake+modis_fpar+modis_lai+30s'," >> namelist.wps

      echo " dx = ${gdspc}," >> namelist.wps
      echo " dy = ${gdspc}," >> namelist.wps
      echo " map_proj = 'lambert'," >> namelist.wps
      echo " ref_lat   =  ${cen_lat}," >> namelist.wps
      echo " ref_lon   =  ${cen_lon}," >> namelist.wps
      echo " truelat1  =  30.00," >> namelist.wps
      echo " truelat2  =  60.00," >> namelist.wps
      echo " stand_lon =  ${cen_lon}," >> namelist.wps
      echo " geog_data_path = '/scratch/tajones/geog_v4'" >> namelist.wps
      echo " opt_geogrid_tbl_path = '${TEMPLATE_DIR}'" >> namelist.wps
      echo "/" >> namelist.wps

      cat namelist.wps.template.HRRRE >> namelist.wps

      ln -sf ${TEMPLATE_DIR}/Vtable.raphrrr_IC.V4 ./Vtable  

      @ anlys_hr = ${start_hr} - 1         
      
      if ( $n <= 9 ) then
	 #${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/20200204/2300/postprd_mem000$n/wrfnat_hrrre_newse_mem000${n}_01.grib2 .
	 #${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem000$n/wrfnat_hrrre_newse_mem000${n}_01.grib2 .
	 ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/mem0$n/wrfnat_hrrre_newse_mem000${n}_01.grib2 .
      else
	 if ( $n <= 36 ) then
	    #${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/20200204/2300/postprd_mem00$n/wrfnat_hrrre_newse_mem00${n}_01.grib2 .
	    #${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem00$n/wrfnat_hrrre_newse_mem00${n}_01.grib2 .
	    ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/mem$n/wrfnat_hrrre_newse_mem00${n}_01.grib2 .
	 else
            @ n2 = ${n} - ${count}
	    if ( $n2 > 9 ) then
	       ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem00$n2/wrfnat_hrrre_newse_mem00${n2}_01.grib2 .
	    else
               ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem000$n2/wrfnat_hrrre_newse_mem000${n2}_01.grib2 .
            endif 
	    @ count = ${count} + 2
         #${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/1700/postprd_mem00$n/wrfnat_mem00${n}_00.grib2 .
         endif
      endif

      echo "Linked HRRRE grib files for member " $n

      @ n++

      cd ..

     end 
  
     echo "#\!/bin/csh"                                                           >! ${RUNDIR}/ungrib_mem.csh
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_mem.csh 
     echo '#SBATCH' "-J ungrib_mem"                                               >> ${RUNDIR}/ungrib_mem.csh
     echo '#SBATCH' "-o ${RUNDIR}/ic\%a/ungrib_mem\%a.log"                        >> ${RUNDIR}/ungrib_mem.csh
     echo '#SBATCH' "-e ${RUNDIR}/ic\%a/ungrib_mem\%a.err"                        >> ${RUNDIR}/ungrib_mem.csh
     echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/ungrib_mem.csh
     echo '#SBATCH' "-n 1"                                                        >> ${RUNDIR}/ungrib_mem.csh
     echo '#SBATCH' "--mem-per-cpu=12G"                                           >> ${RUNDIR}/ungrib_mem.csh 
     echo '#SBATCH -t 0:30:00'                                                    >> ${RUNDIR}/ungrib_mem.csh
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_mem.csh

     cat >> ${RUNDIR}/ungrib_mem.csh << EOF

     set echo

     source /scratch/home/thomas.jones/WOFenv_dart

     cd ${RUNDIR}/ic\${SLURM_ARRAY_TASK_ID}

     sleep 2

     srun ${RUNDIR}/WRF_RUN/ungrib.exe

     sleep 1

     touch ${SEMA4}/ungrib_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

     sbatch --array=1-${ENS_SIZE}  ${RUNDIR}/ungrib_mem.csh

     while ( `ls -f ${SEMA4}/ungrib_mem*_done | wc -l` != $ENS_SIZE )

           echo "Waiting for ungribbing of GSD HRRRE Files" 
           sleep 1

     end
      

###########################################################################
# METGRID FOR ALL HRRRE MEMBERS
###########################################################################

set n = 1 
while ( $n <= $ENS_SIZE )

      cd ic${n}

      ln -sf ${RUNDIR}/geo_em.d01.nc ./geo_em.d01.nc

      @ n++

      cd ..

end

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/metgrid_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-J metgrid_mem"                                              >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-o ${RUNDIR}/ic\%a/metgrid_mem\%a.log"                       >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-e ${RUNDIR}/ic\%a/metgrid_mem\%a.err"                       >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "--mem-per-cpu=5G"                                            >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-n 12"                                                       >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH -t 0:45:00'                                                    >> ${RUNDIR}/metgrid_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_mem.csh

      cat >> ${RUNDIR}/metgrid_mem.csh << EOF

      set echo

      source /scratch/home/thomas.jones/WOFenv_dart

      cd ${RUNDIR}/ic\${SLURM_ARRAY_TASK_ID}

      sleep 2    
 
      srun  ${RUNDIR}/WRF_RUN/metgrid.exe 

      sleep 1 

      #rm HRRRE* GRIBFILE* metgrid.log.*

      touch ${SEMA4}/metgrid_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${ENS_SIZE}  ${RUNDIR}/metgrid_mem.csh
    

while ( `ls -f  ${SEMA4}/metgrid_mem*_done | wc -l` != $ENS_SIZE )
    
       echo "Waiting for metgrid to finish for $ENS_SIZE members"
       sleep 1

end

echo "WPS is complete"

#rm ungrib_mem.csh metgrid_mem.csh

###########################################################################
exit (0)
###########################################################################
