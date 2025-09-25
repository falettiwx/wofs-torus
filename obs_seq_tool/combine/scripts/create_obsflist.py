import glob

wcpaths=True          # give pathlist of wildcarded file names
dirpaths=False        # give pathlist of paths to files

# Set filepaths containing obs_seqs to merge (as many paths as needed)
pathlist = ['/scratch/wof-torus/wofs-obs-radar-output/2022052*/obs_seq_*_0206*.out', '/scratch/wof-torus/wofs-obs-radar-output/2022052*/obs_seq_*_0212*.out']
        #'/scratch/wof-torus/combine_obsq/obs_ws_mm/obs_ws_mm_3min', 
            #'/scratch/wof-torus/combine_obsq/noxp_obsq/obstype_sep/1km_grid/thres35km_std5',
            #'/scratch/wof-torus/combine_obsq/p3_obsq/obstype_sep/1km_grid/legsep/err_std_3/TAFT',
            #'/scratch/wof-torus/combine_obsq/p3_obsq/obstype_sep/1km_grid/legsep/err_std_3/TFOR']

# Set directory to write obsflist file
obsfdir = '/home/william.faletti/wof-torus/obs_seq/combine/exedir'


if wcpaths:
    # Loop through filepaths and collect obsq file lists
    filelists = []
    for path in pathlist:
        filelists.append( sorted(glob.glob(path)) )

elif dirpaths:
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


