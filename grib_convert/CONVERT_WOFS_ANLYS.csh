#!/bin/csh 
#
#-----------------------------------------------------------------------
# Script to Run WoFS Forecasts at :00 past the hour
#-----------------------------------------------------------------------

#source ~/WOFenv_rlt_2022
#set ENVFILE = ${TOP_DIR}/realtime.cfg.${event}
#source $ENVFILE
#set WOFSDIR = /scratch/home/wofuser/torus
#set GRIB2DIR = /scratch/home/wofuser/torus/GRIB2
set WOFSDIR = /scratch/wof-torus/bc_full
set GRIB2DIR = ${WOFSDIR}/GRIB2
set UPPFILEDIR = /home/wofuser/WOFS/run_scripts/TORUS
#set UPPFILEDIR = /home/william.faletti/wof-torus/UPP_TORUS
set UNIPOSTDIR = /scratch/home/wofuser/UPP_KATE_kjet
set CRTMDIR = ${UNIPOSTDIR}/src/lib/crtm2/src/fix
set WRFDIR = /home/wofuser/WOFS/WRFV3.9_WOFS_TEST

set initdate = 20220523
set sdate = 2022-05-24_02:00:00
set edate = 2022-05-24_02:06:00
set dt = 6

set ITVL_SEC = `expr $dt \* 60`

set echo

mkdir -p ${GRIB2DIR}/FINAL

### Make directories for each BC time
        # define start time using date command
set dir_tstamp =  `echo "${sdate}" | tr '_' ' '`
set dir_tstamp = `date -d "$dir_tstamp" "+%F %T"`
        # similarly define end time (final analysis time + 1 cycling interval to stop while loop)
set end_tstamp =  `echo "${edate} ${ITVL_SEC} seconds ago" | tr '_' ' '`
set end_tstamp = `date -d "$end_tstamp ${dt} minutes" "+%F %T"`

	# loop through times and submit grib conversion scripts
while ( "$dir_tstamp" != "$end_tstamp" )
   
   set AYEAR  = `echo $dir_tstamp | cut -c1-4`
   set AMONTH = `echo $dir_tstamp | cut -c6-7`
   set ADAY   = `echo $dir_tstamp | cut -c9-10`
   set AHOUR  = `echo $dir_tstamp | cut -c12-13`
   set AMIN   = `echo $dir_tstamp | cut -c15-16`

   cd ${GRIB2DIR}

   set wrftime = ${AYEAR}-${AMONTH}-${ADAY}_${AHOUR}:${AMIN}:00
   set filetime = ${AYEAR}-${AMONTH}-${ADAY}_${AHOUR}_${AMIN}_00
   set btime = ${AYEAR}${AMONTH}${ADAY}${AHOUR}${AMIN}

   mkdir $btime; cd $btime

   set member = 1
   while ($member <= 36)
     if ( $member <= 9 ) then
        rm -fr ENS_MEM_0${member}
        mkdir ENS_MEM_0${member}
     else
        rm -fr ENS_MEM_${member}
        mkdir ENS_MEM_${member}
     endif
     @ member++

   end
                # add 1 cycling interval to time for next iteration
   set dir_tstamp = `date -d "$dir_tstamp ${dt} minutes" "+%F %T"`

#
#  Run unipost.exe to convert WoFS netCDF to grib2
#
   echo "#\!/bin/csh"                                                          >! ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo "#=================================================================="  >> ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo '#SBATCH' "-J wofs_conv$btime"                                         >> ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo '#SBATCH' "-o ${GRIB2DIR}/${btime}/wofs_conv\%a.log"                   >> ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo '#SBATCH' "-e ${GRIB2DIR}/${btime}/wofs_conv\%a.err"                   >> ${GRIB2DIR}/${btime}/WoFS_conv.job 
   echo '#SBATCH' "-p batch"                                                   >> ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo '#SBATCH' "--ntasks=24 --cpus-per-task=2"                              >> ${GRIB2DIR}/${btime}/WoFS_conv.job 
   echo '#SBATCH' "--exclusive"                                                >> ${GRIB2DIR}/${btime}/WoFS_conv.job 
   echo '#SBATCH -t 0:10:00'                                                   >> ${GRIB2DIR}/${btime}/WoFS_conv.job
   echo "#=================================================================="  >> ${GRIB2DIR}/${btime}/WoFS_conv.job

   cat >> ${GRIB2DIR}/${btime}/WoFS_conv.job << EOF

   set echo

   if ( \${SLURM_ARRAY_TASK_ID} <= 9 ) then
      cd ${GRIB2DIR}/${btime}/ENS_MEM_0\${SLURM_ARRAY_TASK_ID}
   else
      cd ${GRIB2DIR}/${btime}/ENS_MEM_\${SLURM_ARRAY_TASK_ID}
   endif

   ln -fs ${UPPFILEDIR}/hrrr_postcntrl.xml postcntrl.xml
   ln -fs ${UPPFILEDIR}/hrrr_post_avblflds.xml post_avblflds.xml
   ln -fs ${UPPFILEDIR}/hrrr_params_grib2_tbl_new params_grib2_tbl_new
   ln -fs ${UPPFILEDIR}/hrrr_postxconfig-NT.txt postxconfig-NT.txt

   ln -fs ${WRFDIR}/run/ETAMPNEW_DATA nam_micro_lookup.dat
   ln -fs ${WRFDIR}/run/ETAMPNEW_DATA.expanded_rain hires_micro_lookup.dat

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
  
   set inFileName = ${WOFSDIR}/${initdate}/${btime}/wrfout_d01_${wrftime}_\${SLURM_ARRAY_TASK_ID}

   cat > itag <<TEST
\${inFileName}
netcdf
grib2
${wrftime}
NCAR
TEST

rm fort.*

srun ${UNIPOSTDIR}/bin/unipost.exe

mv WRFNAT.GrbF00 wrfout_d01_${filetime}_\${SLURM_ARRAY_TASK_ID}.grib2

mv wrfout_d01_${filetime}_\${SLURM_ARRAY_TASK_ID}.grib2 ${GRIB2DIR}/FINAL

EOF

#SUBMIT ALL FORECAST MEMBERS AT ONCE
sbatch --array=1-36 ${GRIB2DIR}/${btime}/WoFS_conv.job

end

##########################################################################################
echo '       ************* GRIB CONVERSION SUBMISSION COMPLETE **************       '
##########################################################################################
exit (0)
##########################################################################################
