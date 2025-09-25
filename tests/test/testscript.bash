#!/bin/bash

cd /home/wof-torus/test

filestr_format=wrfinput_d01


for i in {1..36}
do
  if [ -f  $filestr_format.$i ]; then
    echo $filestr_format.$i exists
  else
    echo Invalid filename; terminating loop
    break
  fi

  mv wrfinput_d01.$i wrfinput_d01_datetime.$i

done

#for i in {1..10}
#do
#    mv wrfinput_d01.$i wrfinput_d01_datetime.$i
#done
