import glob

# Set filepaths containing obs_seqs to merge (as many paths as needed)
pathlist = ['/home/william.faletti/wof-torus/obs_seq/p3_obsq/test/TFOR']

# Set directory to write obsflist file
obsfdir = '/home/william.faletti/wof-torus/nc_from_obsq/rundir'

# Loop through filepaths and collect obsq file lists
filelists = []
for path in pathlist:
    filelists.append( sorted(glob.glob(f'{path}/obs_seq*')) )

# Merge all files to single list
obsq_files = [file for filelist in filelists for file in filelist]

# Write to obsflist file
f = open(f'{obsfdir}/obsflist', 'w')

for obsq_file in obsq_files:
    f.write(f'{obsq_file}\n')

f.close()


