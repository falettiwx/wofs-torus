#!/bin/csh
#

#source /scratch/home/thomas.jones/WOFenv_dart


source /home/william.faletti/wof-torus/torusenv
source ${TOP_DIR}/realtime.cfg.${event}

### SETTING DOMAIN CENTER...could do manunally

	# 4/22/24 meeting with Kent - we will do it manually (commented out 2nd if statement)

#if ( -e /work/rt_obs/radar_files/radars.${event}.csh ) then
	#   source /work/rt_obs/radar_files/radars.${event}.csh
#if ( -e /scratch/tajones/realtime/radar_files/radars.${event}_space.csh ) then
#   source /scratch/tajones/realtime/radar_files/radars.${event}_space.csh
#else
#   source ${SCRIPTDIR}/WOFS_grid_radar/radars.20180407.csh
#endif

###
set echo on
###

cd ${RUNDIR}
### First. remove residual files from last run:
#rm -fr mem*
rm ungrib_bc_mem.csh metgrid_bc_mem.csh
rm ${SEMA4}/geogrid_done 
rm ${SEMA4}/ungrib_bc_mem*_done
rm ${SEMA4}/metgrid_bc_mem*_done
##

# Run geogrid process if geo_em file doesn't already exist
if ( ! -e ${RUNDIR}/geo_em.d01.nc ) then

   cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

	# remove preexisting namelist if one exists
   if ( -e namelist.wps ) rm -f namelist.wps

   ############################################
   ### Set up WPS namelist for geogrid
   ############################################

   set startdate = " start_date = '${sdate_bc}', '${sdate_bc}',"
   set enddate = " end_date = '${edate_bc}', '${edate_bc}',"

   echo "&share" > namelist.wps
   echo " wrf_core = 'ARW'," >> namelist.wps
   echo " max_dom = ${domains}," >> namelist.wps
   echo ${startdate} >> namelist.wps
   echo ${enddate} >> namelist.wps
   echo " interval_seconds = ${ITVL_SEC}" >> namelist.wps #${nml_interval_seconds}" >> namelist.wps
   echo " io_form_geogrid = 2," >> namelist.wps
   echo "/" >> namelist.wps

   echo "&geogrid" >> namelist.wps
   echo " parent_id         = 1, 1," >> namelist.wps #${nml_parent_id1},  ${nml_parent_id2}, ${nml_parent_id3}," >> namelist.wps
   echo " parent_grid_ratio = 1, 3," >> namelist.wps #${nml_parent_grid_ratio1},  ${nml_parent_grid_ratio2}, ${nml_parent_grid_ratio3}," >> namelist.wps
   echo " i_parent_start    = 1, 80," >> namelist.wps #${nml_i_parent_start1},  ${nml_i_parent_start2}, ${nml_i_parent_start3}," >> namelist.wps
   echo " j_parent_start    = 1, 77," >> namelist.wps #${nml_j_parent_start1},  ${nml_j_parent_start2}, ${nml_j_parent_start3}," >> namelist.wps
   echo " e_we              = ${grdpts_ew}, 226," >> namelist.wps #${nml_grdpts_ew1},  ${nml_grdpts_ew2}, ${nml_grdpts_ew3}," >> namelist.wps
   echo " e_sn              = ${grdpts_ns}, 226," >> namelist.wps #${nml_grdpts_ns1},  ${nml_grdpts_ns2}, ${nml_grdpts_ns3}," >> namelist.wps

   #echo " geog_data_res     = 'modis_lakes+15s+modis_fpar+modis_lai+30s', 'modis_15s_lakes+modis_fpar+modis_lai+30s'," >> namelist.wps
   echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+modis_fpar+modis_lai', 'modis_15s_lake+modis_fpar+modis_lai+30s'," >> namelist.wps

   echo " dx = ${gdspc}" >> namelist.wps #${nml_gdspc1}," >> namelist.wps
   echo " dy = ${gdspc}" >> namelist.wps #${nml_gdspc1}," >> namelist.wps
   echo " map_proj = 'lambert'," >> namelist.wps
   echo " ref_lat   =  ${cen_lat}," >> namelist.wps
   echo " ref_lon   =  ${cen_lon}," >> namelist.wps
   echo " truelat1  =  30.00," >> namelist.wps
   echo " truelat2  =  60.00," >> namelist.wps
   echo " stand_lon =  ${cen_lon}," >> namelist.wps
   #echo " geog_data_path = '/scratch/wofuser/realtime/geog'" >> namelist.wps
   echo " geog_data_path = '${GEOG_DIR}'" >> namelist.wps
   echo " opt_geogrid_tbl_path = '${TEMPLATE_DIR}'" >> namelist.wps
   echo "/" >> namelist.wps

   cat namelist.wps.template.HRRRE >> namelist.wps

   ###########################################################################
   # GEOGRID
   ###########################################################################
   echo "Created namelist.wps, running geogrid.exe"

   echo "#\!/bin/csh"                                                            >! ${RUNDIR}/geogrid.job
   echo "#=================================================================="    >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "-J geogrid"                                                   >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "-o ${RUNDIR}/geogrid.log"                                     >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "-e ${RUNDIR}/geogrid.err"                                     >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "-p batch"                                                     >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "--ntasks-per-node=24"                                         >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "--exclude=cn36  "                                             >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' "-n 24"                                                        >> ${RUNDIR}/geogrid.job
   echo '#SBATCH' '-t 0:10:00'                                                   >> ${RUNDIR}/geogrid.job
   echo "#=================================================================="    >> ${RUNDIR}/geogrid.job

   cat >> ${RUNDIR}/geogrid.job << EOF

   set echo

   cd \${SLURM_SUBMIT_DIR}


   srun ${RUNDIR}/WRF_RUN/geogrid.exe

   touch ${SEMA4}/geogrid_done

EOF

  chmod +x geogrid.job
  sbatch ${RUNDIR}/geogrid.job

  while (! -e ${SEMA4}/geogrid_done)
        sleep 5
  end

  endif



############################
# UNGRIB HRRR+GEFS ENSEMBLE DATA 
############################

set n = 1
while ( $n <= $ENS_SIZE )

      mkdir mem$n

	# unindent this section when you see this next, Kent said it'll still work but I want the readability (-Billy, 4/22/24) 

         cd mem$n

         if ( -e namelist.wps ) rm -f namelist.wps

         set startdate = " start_date = '${sdate_bc}', '${sdate_bc}',"
         set enddate = " end_date = '${edate_bc}', '${edate_bc}',"

         echo $startdate
         echo $enddate

         cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

        echo "&share" > namelist.wps
        echo " wrf_core = 'ARW'," >> namelist.wps
        echo " max_dom = ${domains}," >> namelist.wps
        echo ${startdate} >> namelist.wps
        echo ${enddate} >> namelist.wps
        echo " interval_seconds = ${ITVL_SEC}" >> namelist.wps #${nml_interval_seconds}" >> namelist.wps
        echo " io_form_geogrid = 2," >> namelist.wps
        echo "/" >> namelist.wps

        echo "&geogrid" >> namelist.wps
        echo " parent_id         = 1, 1," >> namelist.wps #${nml_parent_id1},  ${nml_parent_id2}, ${nml_parent_id3}," >> namelist.wps
        echo " parent_grid_ratio = 1, 3," >> namelist.wps #${nml_parent_grid_ratio1},  ${nml_parent_grid_ratio2}, ${nml_parent_grid_ratio3}," >> namelist.wps
        echo " i_parent_start    = 1, 80," >> namelist.wps #${nml_i_parent_start1},  ${nml_i_parent_start2}, ${nml_i_parent_start3}," >> namelist.wps
        echo " j_parent_start    = 1, 77," >> namelist.wps #${nml_j_parent_start1},  ${nml_j_parent_start2}, ${nml_j_parent_start3}," >> namelist.wps
        echo " e_we              = ${grdpts_ew}, 226," >> namelist.wps #${nml_grdpts_ew1},  ${nml_grdpts_ew2}, ${nml_grdpts_ew3}," >> namelist.wps
        echo " e_sn              = ${grdpts_ns}, 226," >> namelist.wps #${nml_grdpts_ns1},  ${nml_grdpts_ns2}, ${nml_grdpts_ns3}," >> namelist.wps

	#echo " geog_data_res     = 'modis_lakes+15s+modis_fpar+modis_lai+30s', 'modis_15s_lakes+modis_fpar+modis_lai+30s'," >> namelist.wps
        echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+modis_fpar+modis_lai', 'modis_15s_lake+modis_fpar+modis_lai+30s'," >> namelist.wps

        echo " dx = ${gdspc}," >> namelist.wps #${nml_gdspc1}," >> namelist.wps
        echo " dy = ${gdspc}," >> namelist.wps #${nml_gdspc1}," >> namelist.wps
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

        ln -sf ${TEMPLATE_DIR}/Vtable.WoFS.TORUS ./Vtable           

        # 1500 OR 1700 UTC START
        # 1200 UTC HRRR + GEFS ENSEMBLE
        ### NEW LBCs
	set echo
	cp ${RUNDIR}/WRF_RUN/link_grib.csh .
	./link_grib.csh ${HRRRE_DIR}/wrfout_*_${n}.grib2 . # 5/9/24 - changed path to reflect new path since April meeting; may need changing again eventually
        ### END NEW LBCs
        
        echo "Linked HRRRE grib files for member " $n

        @ n++

        cd ..

     end 
  
     echo "#\!/bin/csh"                                                           >! ${RUNDIR}/ungrib_bc_mem.job
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_bc_mem.job 
     echo '#SBATCH' "-J ungrib_bc_mem"                                            >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "-o ${RUNDIR}/mem\%a/ungrib_bc_mem\%a.log"                    >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "-e ${RUNDIR}/mem\%a/ungrib_bc_mem\%a.err"                    >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "-n 1"                                                        >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "--exclude=cn36  "                                            >> ${RUNDIR}/ungrib_bc_mem.job
     echo '#SBATCH' "--mem-per-cpu=10G"                                           >> ${RUNDIR}/ungrib_bc_mem.job 
     echo '#SBATCH -t 2:00:00'                                                    >> ${RUNDIR}/ungrib_bc_mem.job
     echo "#=================================================================="   >> ${RUNDIR}/ungrib_bc_mem.job

     cat >> ${RUNDIR}/ungrib_bc_mem.job << EOF

     set echo

     cd ${RUNDIR}/mem\${SLURM_ARRAY_TASK_ID}

     srun ${RUNDIR}/WRF_RUN/ungrib.exe

     sleep 1

     touch ${SEMA4}/ungrib_bc_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

   sbatch --array=1-${HRRRE_BCS}  ${RUNDIR}/ungrib_bc_mem.job

     while ( `ls -f ${SEMA4}/ungrib_bc_mem*_done | wc -l` != $HRRRE_BCS )
           echo "Waiting for ungribbing of HRRR + GEFS files" 
           sleep 5
     end
      

###########################################################################
# METGRID FOR ALL WOFS MEMBERS
###########################################################################

set n = 1 
while ( $n <= $HRRRE_BCS )

      cd mem${n}

      ln -sf ${RUNDIR}/geo_em.d01.nc ./geo_em.d01.nc

      @ n++

      cd ..

end

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/metgrid_bc_mem.job
echo "#=================================================================="   >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "-J metgrid_bc_mem"                                           >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "-o ${RUNDIR}/mem\%a/metgrid_bc_mem\%a.log"                   >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "-e ${RUNDIR}/mem\%a/metgrid_bc_mem\%a.err"                   >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "-p batch"                                                    >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "--mem-per-cpu=5G"                                            >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "--exclude=cn36  "                                            >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH' "-n 12"                                                       >> ${RUNDIR}/metgrid_bc_mem.job
echo '#SBATCH -t 1:30:00'                                                    >> ${RUNDIR}/metgrid_bc_mem.job
echo "#=================================================================="   >> ${RUNDIR}/metgrid_bc_mem.job

      cat >> ${RUNDIR}/metgrid_bc_mem.job << EOF

      set echo

      cd ${RUNDIR}/mem\${SLURM_ARRAY_TASK_ID}

      srun  ${RUNDIR}/WRF_RUN/metgrid.exe 

      sleep 1 

      touch ${SEMA4}/metgrid_bc_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${HRRRE_BCS}  ${RUNDIR}/metgrid_bc_mem.job
    
while ( `ls -f  ${SEMA4}/metgrid_bc_mem*_done | wc -l` != $HRRRE_BCS )
    
       echo "Waiting for metgrid to finish for the $HRRRE_BCS HRRR + GEFS members"
       sleep 5

end

echo "WPS is complete"

#rm mem*/metgrid.log* mem*/metgrid.err*  mem*/ungrib.err* mem*/ungrib.log* 
#rm -fr mem*/GRIBFILE* mem*/HRRRE* mem*/metgrid.log*

###########################################################################
exit (0)
###########################################################################
