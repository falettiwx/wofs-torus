#!/usr/bin/env python
# coding: utf-8

import math
from input_nml_funcs import *

############################################################################################################

# Set important and/or commonly changed namelist variables

outdir = '/home/william.faletti/wof-torus/templates'

out_itvl = 1 #  produce output every n cycles where out_itvl is n
out_mem = 'true' # output member analyses (str - 'true' or 'false')
out_mean = 'true' # output mean analysis (str - 'true' or 'false')
out_sd = 'true' # output analysis standard deviation (str - 'true' or 'false')

#filter_kind = 1 # EAKF; view options at https://docs.dart.ucar.edu/en/v10.10.1/assimilation_code/modules/assimilation/assim_tools_mod.html
ens_size = 36 # static for WoFS-TORUS
outlier_threshold = 3.5 # exclude obs greater than this many standard deviations from the mean
inlier_threshold = 0.15 # exclude obs less than this many standard deviations from the mean

inf_initial = 1.0 # initial inflation if inf_initial_from_restart is false
inf_sd_initial = 0.4 # initial inflation stdev if inf_sd_initial_from_restart is false
inf_lower_bound = 1.0 # lower bound on inflation value
inf_upper_bound = 5.0 # upper bound on inflation value
inf_sd_lower_bound = 0.4 # lower bound on inflation stdev using adaptive inflation

qceff_file = ''#'bnrhf_qceff_table_torus.csv'

############################################################################################################

# User sets list of dictionaries of assimilation metadata, one for each obs type to assimilate.
# Number of entries is dynamic, allowing as many obs types as necessary. 

# Description of variables:
    # name: (str) Name of obs type
    # assim_status: (bool) Whether or not to assimilate this obs type. Comments obs type out in "assimilate_these_obs_types" namelist option.
    # horiz_loc_rad: (numeric) Horizontal localization radius in meters.
    # vert_loc_rad: (numeric) Vertical localization radius in meters.

# exclude_var is an obs type to be included in some input.nmls but not others. Script will output multiple input.nml.cycle files, 
    # one with and one without said variable. This allows exclude_var to be only be assimilated some cycles. 
    # Set excluded obs type to False in vardicts, and vardicts_incl generates a copy where it is set to True.

exclude_var = 'RADAR_REFLECTIVITY' # obs type to exclude
exclude_ext = 'ref' # namelist file extension when included

vardicts = [
 # 1
{
    'name': 'METAR_ALTIMETER', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 2
{
    'name': 'METAR_U_10_METER_WIND', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 3
{
    'name': 'METAR_V_10_METER_WIND', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 4
{
    'name': 'METAR_TEMPERATURE_2_METER', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 5
{
    'name': 'METAR_DEWPOINT_2_METER', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 6
{
    'name': 'LAND_SFC_U_WIND_COMPONENT', 
    'assim_status': True,
    'horiz_loc_rad': 60000, 
    'vert_loc_rad': 8000
    }, 
 # 7
{
    'name': 'LAND_SFC_V_WIND_COMPONENT', 
    'assim_status': True,
    'horiz_loc_rad': 60000,
    'vert_loc_rad': 8000
    }, 
 # 8
{
    'name': 'LAND_SFC_TEMPERATURE', 
    'assim_status': True,
    'horiz_loc_rad': 60000,
    'vert_loc_rad': 8000
    }, 
 # 9
{
    'name': 'LAND_SFC_DEWPOINT', 
    'assim_status': True,
    'horiz_loc_rad': 60000, 
    'vert_loc_rad': 8000
    }, 
 # 10
{
    'name': 'LAND_SFC_ALTIMETER', 
    'assim_status': True,
    'horiz_loc_rad': 60000, 
    'vert_loc_rad': 8000
    }, 
 # 11
{
    'name': 'RADAR_REFLECTIVITY', 
    'assim_status': False,
    'horiz_loc_rad': 6000, 
    'vert_loc_rad': 3000
    }, 
 # 12
{
    'name': 'RADAR_CLEARAIR_REFLECTIVITY', 
    'assim_status': True,
    'horiz_loc_rad': 6000, 
    'vert_loc_rad': 3000
    }, 
 # 13
{
    'name': 'DOPPLER_RADIAL_VELOCITY', # assigned to 88D for our purposes (can be any radar)
    'assim_status': True,
    'horiz_loc_rad': 6000, 
    'vert_loc_rad': 3000
    }, 
 # 14
{
    'name': 'NOXP_RADIAL_VELOCITY', # assigned to NOXP (can be any radar)
    'assim_status': True,
    'horiz_loc_rad': 6000,
    'vert_loc_rad': 3000
    },
 # 15
{
    'name': 'P3_RADIAL_VELOCITY', # assigned to NOAA P3 TDRs (can be any radar)
    'assim_status': True,
    'horiz_loc_rad': 6000,
    'vert_loc_rad': 3000
    },
 # 16
{
    'name': 'RADIOSONDE_U_WIND_COMPONENT', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 17
{
    'name': 'RADIOSONDE_V_WIND_COMPONENT', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
     }, 
 # 18
{
    'name': 'RADIOSONDE_TEMPERATURE', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
    }, 
 # 19
 {
    'name': 'RADIOSONDE_DEWPOINT', 
    'assim_status': True,
    'horiz_loc_rad': 120000, 
    'vert_loc_rad': 8000
     }, 
 # 20
 {
    'name': 'DWLVAD_UWIND', 
    'assim_status': True,
    'horiz_loc_rad': 60000, 
    'vert_loc_rad': 8000
    }, 
 # 21
{
    'name': 'DWLVAD_VWIND', 
    'assim_status': True,
    'horiz_loc_rad': 60000, 
    'vert_loc_rad': 8000
    },
 # 22
{
    'name': 'MM_TEMPERATURE', 
    'assim_status': True,
    'horiz_loc_rad': 18000, 
    'vert_loc_rad': 6000
    }, 
 # 23
 {
    'name': 'MM_DEWPOINT', 
    'assim_status': True,
    'horiz_loc_rad': 18000, 
    'vert_loc_rad': 6000
     }, 
 # 24
 {
    'name': 'WS_TEMPERATURE', 
    'assim_status': True,
    'horiz_loc_rad': 18000, 
    'vert_loc_rad': 6000
     }, 
 # 25
 {
    'name': 'WS_DEWPOINT',
    'assim_status': True,
    'horiz_loc_rad': 18000, 
    'vert_loc_rad': 6000
     }, 
 # 26
 {
    'name': 'GOES_CWP_PATH', 
    'assim_status': False,
    'horiz_loc_rad': 40107, 
    'vert_loc_rad': 10000
     }, 
 # 27
{
    'name': 'GOES_LWP_PATH',
    'assim_status': False,
    'horiz_loc_rad': 40107, 
    'vert_loc_rad': 10000
    }, 
 # 28
{
    'name': 'GOES_LWP0_PATH', 
    'assim_status': False,
    'horiz_loc_rad': 40107, 
    'vert_loc_rad': 10000
    }, 
 # 29
{
    'name': 'GOES_IWP_PATH',
    'assim_status': False,
    'horiz_loc_rad': 40107, 
    'vert_loc_rad': 10000
    }, 
 # 30
{
    'name': 'GOES_CWP_ZERO', 
    'assim_status': False,
    'horiz_loc_rad': 44563,
    'vert_loc_rad': 7000
    },
 # 31
{
    'name': 'GOES_CWP_ZERO_NIGHT',
    'assim_status': False,
    'horiz_loc_rad': 44563,
    'vert_loc_rad': 7000
    }
]

############################################################################################################
    
# No variables to set in this section

# Create alternate vardict list for nmls to include exclude_var
vardicts_incl = []
for vardict in vardicts:
    
        # .copy() ensures new dict is created and is not simply a reference to existing one
    vardict = vardict.copy()
    
        # set assim_status from False to True
    if vardict['name'] == exclude_var:
        vardict['assim_status'] = True
        
        # append to new vardict list
    vardicts_incl.append(vardict)


############################################################################################################

# List of parameters for each namelist

# Set parameters for each namelist to create, then generate the namelists.
    # e.g., if 3 namelists are desired, all lists should contain 3 entries.
    # This whole thing could use some better automating...

nml_names = ['init', f'init.{exclude_ext}', 'cycle', f'cycle.{exclude_ext}'] # nml file name extensions
inf_initial_rsts = ['false', 'false', 'true', 'true'] # set to false in init nml only
inf_sd_initial_rsts = ['false', 'false', 'true', 'true'] # set to false in init nml only
w_state_bounds = ['', '', "'W','-50.0','60.0','CLAMP',", "'W','-50.0','60.0','CLAMP',"] # W not included in init nml
vardictlist = [vardicts, vardicts_incl, vardicts, vardicts_incl] # List of vardicts to include in each respective nml


############################################################################################################

# Generate the namelists

for i in range(len(nml_names)):
    
    varlist, varlist_assim, invalid_list, hhrlist, vnhlist = process_vardicts(vardictlist[i])
    
    # Write to namelist file
    f = open(f'{outdir}/input.nml.{nml_names[i]}', 'w')

    outstr = return_nml_str(varlist = varlist,
                            varlist_assim = varlist_assim,
                            hhrlist = hhrlist, 
                            vnhlist = vnhlist, 
                            invalid_list = invalid_list,
                            inf_initial_rst = inf_initial_rsts[i], 
                            inf_sd_initial_rst = inf_sd_initial_rsts[i], 
                            inf_initial = inf_initial,
                            inf_sd_initial = inf_sd_initial,
                            inf_lower_bound = inf_lower_bound,
                            inf_upper_bound = inf_upper_bound,
                            inf_sd_lower_bound = inf_sd_lower_bound,
                            qceff_file = qceff_file,
                            w_state_bounds = w_state_bounds[i],
                            out_itvl = out_itvl,
                            out_mean = out_mean,
                            out_sd = out_sd,
                            out_mem = out_mem)

    with open(f'{outdir}/input.nml.{nml_names[i]}', 'w') as f:
        f.write(outstr)

