##########################################################################################################################
##                                                                                                                      ##
##        ##### NOTE: This code was unable to produce obs_seq files correctly formatted for DART.                       ##
##                    Instead, use the codebase built around obs_sequence_tool.                                         ##
##                                                                                                                      ##
##        This script takes pre-existing obs_seq files and appends NOXP obs_seq files created with code by              ##
##        Patrick Skinner. Results in new obs_seq files containing obs from existing obs_seq and from NOXP.             ##
##                                                                                                                      ##
##        Last edited by Billy Faletti - 3/11/2025                                                                      ##
##                                                                                                                      ##
##########################################################################################################################

import re
import glob
from datetime import datetime, timedelta
import numpy as np
import shutil

# Set directory paths 
mmws_dir = '/work2/wof_torus/obs_seqs/obs_ws_mm' # pre-generated obs_seqs (files in 'obs_seq.YYYYmmddHHMM.out' format)
noxp_dir = '/scratch/home/william.faletti/obs_seq/obs_seq_orig' # noxp obs_seqs (files in 'obs_seq_YYYYmmdd_HHMM_*' format)
outdir = '/scratch/home/william.faletti/obs_seq/obs_seq_final' # appended obs_seq directories

# Set cycling frequency (minutes)
cyc_freq = 5



# Grab files from input directories
mmws_files = sorted(glob.glob(f'{mmws_dir}/*'))
noxp_files = sorted(glob.glob(f'{noxp_dir}/*'))

# Parse out date/time info and convert to lists of datetime
mmws_filestrs = [mmws_file.split('/')[-1] for mmws_file in mmws_files]
mmws_timestrs = [re.split(r'\.', mmws_filestr)[1] for mmws_filestr in mmws_filestrs]
mmws_times = np.array([datetime.strptime(mmws_timestr, '%Y%m%d%H%M') for mmws_timestr in mmws_timestrs])

noxp_filestrs = [noxp_file.split('/')[-1] for noxp_file in noxp_files]
noxp_timestrs = [re.split(r'\_', noxp_filestr)[2]+re.split(r'\_', noxp_filestr)[3] for noxp_filestr in noxp_filestrs]
noxp_times = np.array([datetime.strptime(noxp_timestr, '%Y%m%d%H%M%S') for noxp_timestr in noxp_timestrs])


# Match NOXP volumes to obs_seq valid times and append those volumes

for i in range(len(mmws_files)):

        # calculate difference b/w cycling time and noxp volume times
    deltas = abs(noxp_times - mmws_times[i])

        # find noxp sweeps that fall within assimilation window
    noxp_idxs = np.where(deltas <= timedelta(minutes = cyc_freq/2))[0].tolist()
    files_match = np.array(noxp_files)[noxp_idxs]

        # create string for outfile path
    timestr = mmws_times[i].strftime('%Y%m%d%H%M')
    outfile = f'obs_seq.{timestr}.out'

    # If NOXP sweeps fall within assimilation window, append them to the existing obs_seq
    if len(files_match) >= 1:

        print(f'{len(files_match)} matches exist for {mmws_files[i]}')

            # open and parse previous obs_seq
        prev_obsq = open(mmws_files[i], 'r')
        prev_str = prev_obsq.read()
            # split header and each obs entry
        prev_strs = re.split(r'(?= OBS)', prev_str) # split text at beginning of each entry (includes the single space before "OBS")
            # parse header and obs number
        num_obs_prev = int(re.findall(r'\d+', prev_strs[-1])[0])
        header_strs = re.split(r'(?=  num_obs) | (?=last)', prev_strs[0])

            # Parse NOXP obs_seqs and append to existing obs_seq
        noxp_strs_time = []
        for file_match in files_match:
                # open noxp obs_seq and split each obs entry
            noxp_file = open(file_match, 'r')
            noxp_str = noxp_file.read()
                # split text at beginning of each entry (includes the single space before "OBS")
            noxp_strs = re.split(r'(?= OBS)', noxp_str)[1:] # remove empty str at 1st index

                # loop through noxp obs entries and insert corrected obs number
            noxp_strs_new = []
            for j in range(len(noxp_strs)):
                    # extract and correct noxp obs number
                new_obsnum = int(re.findall(r'\d+', noxp_strs[j])[0]) + num_obs_prev
                    # replace incorrect obs number with correct one
                newstr = re.sub(r'\d+', str(new_obsnum), noxp_strs[j], count=1)
                    # append to list of strings in noxp file
                noxp_strs_new.append(newstr)

                # pull total number of obs entries from final corrected noxp entry
            num_obs_total = int(re.findall(r'\d+', noxp_strs_new[-1])[0])

                # if not the final obs_seq time, update obs number to num_obs_total
                    # allows correct numbering in subsequent noxp file appending
            if file_match != files_match[-1]:
                num_obs_prev = num_obs_total

            noxp_strs_time.append( ''.join(noxp_strs_new) )

            noxp_file.close()

            # join all corrected noxp obs entries
        noxp_str_final = ''.join(noxp_strs_time)

            # reconstruct obs_seq header
        header_str0 = header_strs[0] + ' '
        header_str1 = re.sub(r'\d+', str(num_obs_total), header_strs[1], count=2)   # replace total obs numbers in header
        header_str2 = re.sub(r'\d+', str(num_obs_total), header_strs[2], count=1)   # join header
        header = ''.join([header_str0, header_str1, header_str2])

            # join obs entries for old obs_seqs
        prev_obs = ''.join(prev_strs[1:])

            # construct final obs_seq
        obsq_final = ''.join(header + prev_obs + noxp_str_final)

        prev_obsq.close()

            # write obs_seq
        obsq_out = open(f'{outdir}/{outfile}', "w")
        obsq_out.write(obsq_final)

        print(f'Saved file {outdir}/{outfile}')

        obsq_out.close()

    # If no NOXP volumes fall within assimilation window, copy original obs_seq to outdir
    else:
        print(f'No match exists for {mmws_files[i]}')

        shutil.copy(f'{mmws_dir}/{outfile}', f'{outdir}/{outfile}')

        print(f'Copied from {mmws_dir[:-9]}/{outfile} to {outdir}/{outfile}')


