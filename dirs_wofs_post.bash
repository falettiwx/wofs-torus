#!/bin/bash

#### Arranges TORUS analysis files into readable structure for WoFS viewer ######
#### Written by Billy Faletti, 5/14/2024 ######


#source torusenv
event=20220523
inittime=2200
date_ext='bc_analyses'
TOP_DIR=/work2/wof_torus/bc_full #/scratch/wof-torus/runs/1km_allrad_std3_dbz03
rundir=${TOP_DIR}/${event}
postdir=${TOP_DIR}/postpr
outfile_strfmt=wrfout_d01
newfile_strfmt=wrfwof_d01

# If date_ext set, then it is appended to $event
if [ -z "$var" ]; then 
   event=${event}_${date_ext}
fi

# Create directory structure
mkdir $postdir
mkdir $postdir/$event
mkdir $postdir/$event/$inittime
for i in {01..36}
do
  mkdir $postdir/$event/$inittime/ENS_MEM_$i 
done

rm $postdir/$event/$inittime/ENS_MEM_*/wrf*

  # Enter DART output directory
cd $rundir

# Loop through directories for each time
for dir in ${event:0:2}*
do
  datetime_str=${dir:0:4}-${dir:4:2}-${dir:6:2}_${dir:8:2}:${dir:10:2}:00
	
  mkdir $postdir/temp_$dir # Create temp dirs to copy member analyses to
  ln -sf  $rundir/$dir/$outfile_strfmt* $postdir/temp_$dir
  cd $postdir/temp_$dir/
  
  for i in {1..36} 	# Rename files to convention utilized by viewer 
  do
    i_pad=$(printf '%02d' $i)

    mv ${outfile_strfmt}_${datetime_str}_$i $postdir/$event/$inittime/ENS_MEM_$i_pad

    cd $postdir/$event/$inittime/ENS_MEM_$i_pad/
    
    mv ${outfile_strfmt}_${datetime_str}_$i ${newfile_strfmt}_${datetime_str}
    
    cd $postdir/temp_$dir/

  done

  cd $rundir

done

# Remove temporary directories
cd $postdir
rm -r temp_*

