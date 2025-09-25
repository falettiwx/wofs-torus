#!/bin/bash

#### Arranges TORUS analysis files into readable structure for WoFS viewer ######
#### Written by Billy Faletti, 5/14/2024 ######


#source torusenv

event=20220523
inittime=2200
TOP_DIR=/scratch/wof-torus
rundir=${TOP_DIR}/run1/${event}
postdir=${TOP_DIR}/run1/postpr
outfile_strfmt=wrfinput_d01
newfile_strfmt=wrfwof_d01

# Create directory structure
mkdir $postdir
mkdir $postdir/$event
mkdir $postdir/$event/$inittime
for i in {01..36}
do
  mkdir $postdir/$event/$inittime/ENS_MEM_$i 
done

  # Enter DART output directory
cd $rundir #${TOP_DIR}/run2/${event}

# Loop through directories for each time
for dir in 20*
do
  mkdir $postdir/temp_$dir	# Create temp dirs to copy member analyses to
  cp $dir/$outfile_strfmt* $postdir/temp_$dir
  cd $postdir/temp_$dir/

  for i in {1..36} 	# Rename files to convention utilized by viewer 
  do
    mv $outfile_strfmt.$i ../temp_$dir/${newfile_strfmt}_${dir:0:4}-${dir:4:2}-${dir:6:2}_${dir:8:2}:${dir:10:2}:00.$i
  done

  cd $rundir

done

cd $postdir

# Move files to appropriate member directories
for i in {1..36}
do
  i_pad=$(printf '%02d' $i)
  mv temp_*/wrfwof*.$i $event/$inittime/ENS_MEM_$i_pad
  
  # Remove member extension from filenames 
  for file in $event/$inittime/ENS_MEM_$i_pad/*
  do
    [ -f "$file" ] || continue
    mv "$file" "${file%.*}"
  done

done

# Remove temp dirs
cd $postdir
rm -r temp_*


