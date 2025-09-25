#!/bin/csh
#
#...Specify the account
#
#SBATCH -A wof
#
#...Specify the job name
#
#SBATCH -J UPP_3KM
#
#...Specify the number of cores
#
#SBATCH -n 48
#
#...Specify the wallclock time in HH:MM:SS
#
#SBATCH -t 00:30:00
#
#...Specify the partition
#
#SBATCH -p kjet,sjet,tjet,ujet,vjet,xjet
#
#...Specify the queue
#
#SBATCH -q batch
#
#...Join the stdout and stderr output streams
#
#SBATCH --output=%x.o%j
#SBATCH --error=%x.o%j
#
#...Automatically change the directory to where
#   the job was launched
#
#SBATCH -D .
#
source ~/varlists/varlist_nsslwrf_3km-1km.csh
#
set echo
#
limit stacksize unlimited
#
#...Specify dynamic core (ARW or NMM or NMB in upper case)
#
set dyncore = "ARW"
#
#...Set input format from model
#
set inFormat = "netcdf"
set outFormat = "grib2"
#
#...Set the serial run command
#
##set RUN_COMMAND = "${UNIPOST_DIR}/bin/unipost.exe "
#
#...Set the parallel run command
#
set RUN_COMMAND = "srun ${UNIPOST_DIR}/bin/unipost.exe "
#
#...Get the time information
#
set sy = `cut -c 1-4 ${DATE_DIR}/outdate.tp00`
set sm = `cut -c 5-6 ${DATE_DIR}/outdate.tp00`
set sd = `cut -c 7-8 ${DATE_DIR}/outdate.tp00`
set sh = `cut -c 9-10 ${DATE_DIR}/outdate.tp00`
#
set ey = `cut -c 1-4 ${DATE_DIR}/outdate.tp${fl2}`
set em = `cut -c 5-6 ${DATE_DIR}/outdate.tp${fl2}`
set ed = `cut -c 7-8 ${DATE_DIR}/outdate.tp${fl2}`
set eh = `cut -c 9-10 ${DATE_DIR}/outdate.tp${fl2}`
#
#...Delete the qsub flag file now that this job is running
#
set flag_SUBUPP = ${FLAG_DIR}/flag_SUBUPP.3km.${sy}${sm}${sd}${sh}
rm -f ${flag_SUBUPP}
#
#...First, check to see if UPP is already running
#
set flag_RUPP = ${FLAG_DIR}/flag_RUPP.3km.${sy}${sm}${sd}${sh}
if ( -e ${flag_RUPP} ) then
  echo ''
  echo 'UPP 3-km is already running; exit...'
  exit
endif
#
#...Flag this script as running
#
echo ''
echo 'Running...' > ${flag_RUPP}
#
#...Now, check to see if post-processing is already complete
#
set DataTime = ${sy}${sm}${sd}${sh}
set ready_file = wrf4nssl_${DataTime}.f${fl2}.3km_ready
if ( -e ${ready_file} ) then
  echo ''
  echo 'UPP 3-km is already finished; exit...'
  rm ${flag_RUPP}
  exit
endif
#
#...CD to the working directory
#
cd ${POST_OUT}
#
if ( ! ( -e ${DataTime} ) ) then
  mkdir ${DataTime}
endif
cd ${DataTime}

if ( ! ( -e 3km ) ) then
  mkdir 3km
endif
cd 3km
#
#...Set tag based on user defined $dyncore (ARW or NMM or NMB in upper case)
#
if ( ${dyncore} == "ARW" ) then
   set tag = NCAR
else if ( ${dyncore} == "NMM" ) then
   set tag = NMM
else if ( ${dyncore} == "NMB" ) then
   set tag = NMM
else
    echo "${dyncore} is not supported. Edit script to choose ARW or NMM or NMB dyncore."
    exit
endif
echo ${tag}
#
#...Check the input format settings
#
if ( ${dyncore} == "ARW" || ${dyncore} == "NMM" ) then
   if ( ${inFormat} != "netcdf" && ${inFormat} != "binary" && ${inFormat} != "binarympiio" ) then
      echo "ERROR: 'inFormat' must be 'netcdf' or 'binary' or 'binarympiio' for ARW or NMM model output. Exiting... "
      exit
   endif 
else if ( ${dyncore} == "NMB" ) then
   if ( ${inFormat} != "binarynemsio" ) then
      echo "ERROR: 'inFormat' must be 'binarynemsio' for NMB model output. Exiting... "
      exit
   endif
endif
#
#...Check for the necessary input files
#
if ( ${outFormat} == "grib" ) then
   if ( ! -e ${paramFile} ) then
      echo "ERROR: 'paramFile' not found in '${paramFile}'.  Exiting... "
      exit
   endif
else if ( ${outFormat} == "grib2" ) then
   set cntrl_file_xml = ${UNIPOST_DIR}/parm/hrrr_postcntrl.xml
##   set cntrl_file_xml = ${POST_OUT}/parm/hrrr_postcntrl.xml
   if ( ! -e ${cntrl_file_xml} ) then
      echo "ERROR: 'cntrl_file_xml' not found in '${cntrl_file_xml}'.  Exiting... "
      exit
   endif
endif
#
#...Check the input format settings
#
if ( ${dyncore} == "ARW" || ${dyncore} == "NMM" ) then
   if ( ${inFormat} != "netcdf" && ${inFormat} != "binary" && ${inFormat} != "binarympiio" ) then
      echo "ERROR: 'inFormat' must be 'netcdf' or 'binary' or 'binarympiio' for ARW or NMM model output. Exiting... "
      exit
   endif 
else if ( ${dyncore} == "NMB" ) then
   if ( ${inFormat} != "binarynemsio" ) then
      echo "ERROR: 'inFormat' must be 'binarynemsio' for NMB model output. Exiting... "
      exit
   endif
endif
#
#...Get local copy of parm file
#...For GRIB1 the code uses wrf_cntrl.parm to select variables for output
#   the available fields are set at compilation
#
if ( ${outFormat} == "grib" ) then
   if ( ${dyncore} == "ARW" || ${dyncore} == "NMM" ) then
      ln -fs ${paramFile} wrf_cntrl.parm 
   else if ( ${dyncore} == "NMB" ) then
      ln -fs ${paramFile} nmb_cntrl.parm
   endif
else if ( ${outFormat} == "grib2" ) then
#
#...For GRIB2 the code uses postcntrl.xml to select variables for output
#   the available fields are defined in post_avlbflds.xml -- while we
#   set a link to this file for reading during runtime it is not typical
#   for one to update this file, therefore the link goes back to the
#   program directory - this is true for params_grib2_tbl_new also - a
#   file which defines the GRIB2 table values
#
  ln -fs ${cntrl_file_xml} postcntrl.xml
  ln -fs ${UNIPOST_DIR}/parm/hrrr_postxconfig-NT.txt postxconfig-NT.txt
#  ln -fs ${UNIPOST_DIR}/parm/hrrr_postxconfig-NT.txt.CLUE_nosat postxconfig-NT.txt
#  ln -fs ${UNIPOST_DIR}/parm/hrrr_postxconfig-NT.txt.gsd_header postxconfig-NT.txt
#  ln -fs ${UNIPOST_DIR}/parm/hrrr_postxconfig-NT.txt.GSD postxconfig-NT.txt
##  ln -fs ${UNIPOST_DIR}/parm/post_avblflds.xml post_avblflds.xml
  ln -fs ${UNIPOST_DIR}/parm/hrrr_post_avblflds.xml post_avblflds.xml
##  ln -fs ${UNIPOST_DIR}/comupp/src/lib/g2tmpl_v1.3.0/params_grib2_tbl_new params_grib2_tbl_new
  ln -fs ${UNIPOST_DIR}/parm/hrrr_params_grib2_tbl_new params_grib2_tbl_new
endif
#
#...Link microphysic's tables - code will use based on mp_physics option
#   found in data
#
ln -fs ${WRF_DIR}/ETAMPNEW_DATA nam_micro_lookup.dat
ln -fs ${WRF_DIR}/ETAMPNEW_DATA.expanded_rain hires_micro_lookup.dat
#
#...Link coefficients for crtm2 (simulated synthetic satellites)
#
set CRTMDIR = ${UNIPOST_DIR}/src/lib/crtm2/src/fix
##set CRTMDIR = ${UNIPOST_DIR}/crtm_v2.0.7/fix
ln -fs ${CRTMDIR}/EmisCoeff/Big_Endian/EmisCoeff.bin           ./
ln -fs ${CRTMDIR}/AerosolCoeff/Big_Endian/AerosolCoeff.bin     ./
ln -fs ${CRTMDIR}/CloudCoeff/Big_Endian/CloudCoeff.bin         ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_g11.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_g11.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_g12.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_g12.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_g13.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_g13.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_g15.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_g15.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_mt1r.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_mt1r.TauCoeff.bin    
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_mt2.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_mt2.TauCoeff.bin    
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/imgr_insat3d.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/imgr_insat3d.TauCoeff.bin    
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/amsre_aqua.SpcCoeff.bin  ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/amsre_aqua.TauCoeff.bin  ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/tmi_trmm.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/tmi_trmm.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmi_f13.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmi_f13.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmi_f14.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmi_f14.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmi_f15.SpcCoeff.bin    ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmi_f15.TauCoeff.bin    ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmis_f16.SpcCoeff.bin   ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmis_f16.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmis_f17.SpcCoeff.bin   ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmis_f17.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmis_f18.SpcCoeff.bin   ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmis_f18.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmis_f19.SpcCoeff.bin   ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmis_f19.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/ssmis_f20.SpcCoeff.bin   ./
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/ssmis_f20.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/seviri_m10.SpcCoeff.bin   ./   
ln -fs ${CRTMDIR}/TauCoeff/ODPS/Big_Endian/seviri_m10.TauCoeff.bin   ./
ln -fs ${CRTMDIR}/SpcCoeff/Big_Endian/v.seviri_m10.SpcCoeff.bin   ./   
#
#...Ready to begin post-processing
#
set MP_SHARED_MEMORY = "yes"
set MP_LABELIO = "yes"
#
#...Top of check_model loop
#
check_model:
#
#...Exit this script if the hour is late
#
set current_hour = `date +%H | sed 's/^0//'`
##if ( ${sh} == '00' && ${current_hour} >= '10' ) then
if ( ${sh} == '00' && ${current_hour} >= '99' ) then
  echo 'Too late to continue waiting for model to run; exit...'
  rm ${flag_RUPP}
  exit
##else if ( ${sh} == '12' && ${current_hour} >= '22' ) then
else if ( ${sh} == '12' && ${current_hour} >= '99' ) then
  echo 'Too late to continue waiting for model to run; exit...'
  rm ${flag_RUPP}
  exit
endif
#
#...Now, check to make sure that the model has started running
#
set flag_RWRF = ${FLAG_DIR}/flag_RWRFP2.${sy}${sm}${sd}${sh}
if ( ! (-e ${flag_RWRF} ) ) then
  echo ''
  echo 'WRF integration has not started; sleep...'
  sleep 120
  goto check_model
endif
#
set cfhr = 12
#
#...Top of the loop ##############################
#
top_of_loop:
#
#...Exit this script if the hour is late
#
set current_hour = `date +%H | sed 's/^0//'`
##if ( ${sh} == '00' && ${current_hour} >= '10' ) then
if ( ${sh} == '00' && ${current_hour} >= '99' ) then
  echo 'Too late to continue looking for model output; exit...'
  rm ${flag_RUPP}
  exit
##else if ( ${sh} == '12' && ${current_hour} >= '22' ) then
else if ( ${sh} == '12' && ${current_hour} >= '99' ) then
  echo 'Too late to continue looking for model output; exit...'
  rm ${flag_RUPP}
  exit
endif
#
if (${cfhr} < 10) then
  set fhr = 0${cfhr}
else
  set fhr = ${cfhr}
endif
#
echo ''
echo 'In UPP; cfhr, fhr ='${cfhr}' '${fhr}
#
set ready_file = wrf4nssl_${DataTime}.f${fhr}.3km_ready
if ( -e ./${ready_file} ) then
  goto next_hour
endif
#
set yout = `cut -c 1-4 ${DATE_DIR}/outdate.tp${fhr}`
set mout = `cut -c 5-6 ${DATE_DIR}/outdate.tp${fhr}`
set dout = `cut -c 7-8 ${DATE_DIR}/outdate.tp${fhr}`
set hout = `cut -c 9-10 ${DATE_DIR}/outdate.tp${fhr}`
#
#if (${fhr} == '00') then
#  set wrftime = ${yout}-${mout}-${dout}_${hout}:00:20
#else
set wrftime = ${yout}-${mout}-${dout}_${hout}:00:00
#endif
set filetime = ${yout}-${mout}-${dout}_${hout}_00_00
set inFileName = ${OUT_DIR}/${DataTime}/wrfout_d01_${filetime}
#set inFileName = /lfs4/NAGAPE/wof/wrfout_3km-1km/new_files/wrfhly_d01_${filetime}
#
echo ''
echo 'inFileName ='${inFileName}
#
if ( ! ( -e ${inFileName} ) ) then
  echo ''
  echo 'Expected WRF output file not found; exit...'
  #sleep 60
  #goto top_of_loop
  rm ${flag_RUPP}
  exit
endif
#
#...The wrfout file is there, but sleep just to be sure
#   we're not trying to read the wrfout file while 
#   it's still being written
#
sleep 15
#
#...Create itag based on user provided info. 
#...Output format now set by user so if-block below uses this
#   to generate the correct itag. 
#
if ( ${outFormat} == "grib" ) then
cat > itag <<EOF
${inFileName}
${inFormat}
${wrftime}
${tag}
EOF
else if ( ${outFormat} == "grib2" ) then
cat > itag <<EOF
${inFileName}
${inFormat}
${outFormat}
${wrftime}
${tag}
EOF
#${wrftime}
else
  echo "ERROR: output format 'outFormat=${outFormat}' not supported, must choose 'grib' or 'grib2'. Exiting..."
  exit
endif
#
#-----------------------------------------------------------------------
#...Run unipost
#-----------------------------------------------------------------------
#
rm fort.*
#
##ln -sf ${paramFile} fort.14
#
#----------------------------------------------------------------------
#...There are two environment variables tmmark and COMSP
#
#...RUN the unipost.exe executable 
#----------------------------------------------------------------------
#
${RUN_COMMAND} >& unipost.${fhr}.out
##${RUN_COMMAND} >& /dev/null
#
if ( ! (-e ./WRFPRS.GrbF${fhr}) ) then
  echo ''
  echo 'Creation of WRFPRS failed; sleep and try again...'
  mv unipost.${fhr}.out unipost_failed.${fhr}.out
  sleep 30
  goto top_of_loop
endif
#
echo maah > ${ready_file}
#
next_hour:
#
@ cfhr = ${cfhr} + ${inc}
#
if ( ${cfhr} <= ${fl2} ) then
  goto top_of_loop
endif
#
rm ${flag_RUPP}
#
exit
