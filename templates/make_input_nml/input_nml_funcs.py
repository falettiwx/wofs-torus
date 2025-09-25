import math

def process_vardicts(vardicts):
    """
    Returns DART input.nml formatted strings given list of vardicts

    Arguments:
    ---------
    vardicts -- list of dicts containing assimilation info

    Returns:
    -------
    varlist -- formtted str containing all vars in vardicts
    varlist_assim -- formatted str containing only vars with assim_status == True
    invalid_list -- formatted str of fill values with same length as varlist
    hhrlist -- formatted str of horiz. localization values with same length as varlist
    vnhlist -- formatted str of vert. norm. heights with same length as varlist

    """

    # Set empty containers to append to
    vardicts_new = []
    varlist = ''
    varlist_assim = ''
    invalid_list = ''
    hhrlist = ''
    vnhlist = ''

    # Loop through obs type dictionaries
    for i, vd in enumerate(vardicts):

            # Convert localization radii (m) to respective formats
        hhr_m = vd['horiz_loc_rad'] / 2
        vhr_m = vd['vert_loc_rad'] / 2
    
        hhr_rad = math.pi * hhr_m / 20000000
        vnh_m = vhr_m / hhr_rad
    
        vd['horiz_half_radius_rad'] = round(hhr_rad,6)
        vd['vert_norm_hgt_m'] = round(vnh_m,6)

            # append converted vardicts
        vardicts_new.append(vd)
    
        # Format strings to insert into DART input.nml

            # if final entry, end line at variable name
        if i == len(vardicts)-1:
            newline = ''
            newline_assim = ''
            # otherwise, format end of line
        else:
            newline = ',\n\t\t\t\t\t\t\t\t\t\t' # for varlist, append comma and indent new line
            
            if len(varlist_assim) == 0 and not vd['assim_status']: # if first line and variable is not being assimilated, leave 1st line blank
                newline_assim = ''
            elif varlist_assim[-3:] == ',\n\t' and not vd['assim_status']: # if preceding line exists and var not being assimilated, 
                newline_assim = ''
            else:
                newline_assim = ',\n\t' # if variable is being assimilated, append formatted new line

            # if var is assimilated, append name on a new line
        if vd['assim_status'] == True:
            var = f''' '{vd['name']}' '''.replace(' ', '')
            #flag = ''
        else:
            var = '' # else, leave string untouched
            #flag = '!'

            # build strings from formatted parts
        varlist = varlist + f''' '{vd['name']}' '''.replace(' ', '') + newline
        #varlist_flag = varlist_flag + flag + f''' '{vd['name']}' '''.replace(' ', '') + newline_flag
        varlist_assim = varlist_assim + var + newline_assim
        invalid_list = invalid_list + '-999999.9' + newline
        hhrlist = hhrlist + f'''{vd['horiz_half_radius_rad']}''' + newline
        vnhlist = vnhlist + f'''{vd['vert_norm_hgt_m']}''' + newline

        # if varlist_assim final line ends in formatted new line, remove it
    if varlist_assim[-3:] == ',\n\t':
        varlist_assim = varlist_assim[:-3]
    
    return varlist, varlist_assim, invalid_list, hhrlist, vnhlist




def return_nml_str(varlist, varlist_assim, hhrlist, vnhlist, invalid_list, inf_initial_rst, inf_sd_initial_rst, inf_initial,
                   inf_sd_initial, inf_lower_bound, inf_upper_bound, inf_sd_lower_bound, qceff_file, w_state_bounds, 
                   outlier_thres=3.5, inlier_thres=0.15, filter_kind=None, ens_size=36, out_itvl=1, out_mem='true', out_mean='true', out_sd='true'):
    
    """
    Returns a formatted string to write to an input.nml text file. 

    Arguments:
    ----------
    varlist -- formatted str containing list of all obs types
    varlist_assim -- formatted str containing list of only obs types to be assimilated
    hhrlist -- formatted str containing list of all horiz. localization radii in radians
    vnhlist -- formatted str containing list of all vertical norm. heights in meters
    invalid_list -- formatted str of fill values with same length as varlist
    inf_initial_rst -- sets inf_initial_from_restart variable in nml ('false' for init timestep, 'true' for subsequent cycles)
    inf_sd_initial_rst -- sets inf_sd_initial_from_restart variable in nml ('false' for init timestep, 'true' for subsequent cycles)
    inf_initial -- sets inf_initial to value to use if inf_initial_from_restart is false
    inf_sd_intial -- sets inf_sd_initial to value to use if inf_sd_initial_from_restart is false
    inf_lower_bound -- lower bound to adaptive inflation value to apply per cycle
    inf_upper_bound -- upper bound to adaptive inflation value to apply per cycle
    inf_sd_lower_bound -- lower bound to inflation standard inflation to apply per cycle
        # above 7 variables handle adaptive inflation
    qceff_file -- QCEFF table filename
    w_state_bounds -- '' for init timestep; "'W','-50.0','60.0','CLAMP'," for subsequent cycles
    outlier_thres -- omits assim. of obs beyond this # of STDs from prior mean (sets outlier_threshold in nml)
    inlier_thres -- omits assim. of obs within this # of STDs from prior mean (sets inlier_threshold in nml)
    filter_kind -- type of assim. filter to use (1 = EAKF)
    ens_size -- number of ensemble members (int)
    out_itvl -- produce output every n cycles where out_itvl is n (int)
    out_mem -- output member analyses (str - 'true' or 'false')
    out_mean -- output mean analysis (str - 'true' or 'false')
    out_sd -- output analysis standard deviation (str - 'true' or 'false')
    
    """
    outstr = f'''&filter_nml
       async                    =  2,
       adv_ens_command          = "no_model_advance"
       ens_size                 =  {ens_size},
       distributed_state        = .true.,
       obs_sequence_in_name     = "obs_seq.out",
       obs_sequence_out_name    = "obs_seq.final",
       input_state_file_list    = "restarts_in_d01.txt"
       output_state_file_list   = "restarts_out_d01.txt"
       init_time_days           = -1,
       init_time_seconds        = -1,
       first_obs_days           = -1,
       first_obs_seconds        = -1,
       last_obs_days            = -1,
       last_obs_seconds         = -1,
       num_output_state_members = 0,
       num_output_obs_members   = 0,
       output_interval          = {out_itvl},
       num_groups               = 1,
       output_forward_op_errors = .false.,
       trace_execution          = .true.,
       output_timestamps        = .true.,
       stages_to_write          = 'preassim', 'output'
       output_members           = .{out_mem}.
       output_mean              = .{out_mean}.
       output_sd                = .{out_sd}.
       write_all_stages_at_end  = .true.  
       inf_flavor                  = 2,                      0,
       inf_initial_from_restart    = .{inf_initial_rst}.,     .{inf_initial_rst}.,
       inf_sd_initial_from_restart = .{inf_sd_initial_rst}.,     .{inf_sd_initial_rst}.,
       inf_deterministic           = .true.,                 .true.,
       inf_initial                 = {inf_initial}, {inf_initial},
       inf_sd_initial              = {inf_sd_initial},  {inf_sd_initial},
       inf_damping                 = 0.90,                   1.00,
       inf_lower_bound             = {inf_lower_bound}, {inf_lower_bound},
       inf_upper_bound             = {inf_upper_bound}, {inf_upper_bound},
       inf_sd_lower_bound          = {inf_sd_lower_bound}, {inf_sd_lower_bound},
       inf_sd_max_change           = 1.025,                    1.05,
    /
    
    &quality_control_nml
      input_qc_threshold = 4,
      outlier_threshold = {outlier_thres},
      inlier_threshold = {inlier_thres},
      enable_special_outlier_code = .false.
    /
    
    &state_vector_io_nml
       single_precision_output    = .false.,
    /
    
    &ensemble_manager_nml
       layout = 2,
       tasks_per_node = 96,
       communication_configuration = 1,
    /
    
    &smoother_nml
       num_lags              = 0 
       start_from_restart    = .false.
       output_restart        = .false.
       restart_in_file_name  = 'smoother_ics'
       restart_out_file_name = 'smoother_restart' /
    

    &algorithm_info_nml
       qceff_table_filename = '{qceff_file}'
    /

    &probit_transform_nml
       fix_bound_violations        = .false.,
       use_logit_instead_of_probit = .false.,
       do_inverse_check            = .false.
   /

    &assim_tools_nml
       cutoff                          = 0.036,
       sort_obs_inc                    = .false.,
       spread_restoration              = .false.,
       sampling_error_correction       = .false.,         
       print_every_nth_obs             = 1000,
       adaptive_localization_threshold = -1,
       distribute_mean                 = .false.,
       special_localization_obs_types  = {varlist},
       special_localization_cutoffs    = {hhrlist}   /
                  
    &perfect_model_obs_nml
       start_from_restart    = .true.,
       output_restart        = .true.,
       async                 = 2,
       init_time_days        = 151512,
       init_time_seconds     = 64800,
       first_obs_days        = -1,
       first_obs_seconds     = -1,
       last_obs_days         = -1,
       last_obs_seconds      = -1,
       output_interval       = 1,
       restart_in_file_name  = "perfect_ics",
       restart_out_file_name = "perfect_restart",
       obs_seq_in_file_name  = "obs_seq.in",
       obs_seq_out_file_name = "obs_seq.out",
       adv_ens_command       = "../shell_scripts/advance_model.csh",
       output_timestamps     = .false.,
       trace_execution       = .true.,
       output_forward_op_errors = .false.,
       print_every_nth_obs   = -1,
       silence               = .false.,
       direct_netcdf_read = .true.
       direct_netcdf_write = .true.
       /
    
    
    &cov_cutoff_nml
       select_localization = 1  /
    
    &closest_member_tool_nml 
       input_file_name        = 'filter_ic_new',
       output_file_name       = 'closest_restart',
       ens_size               = 50,
       single_restart_file_in = .false.,
       difference_method      = 4,
     /
    
    &location_nml
       horiz_dist_only = .false.,
       vert_normalization_pressure = 700000.0,
       vert_normalization_height = 111111.1,
       vert_normalization_level = 2666.7,
       approximate_distance = .false.,
       output_box_info = .false.,
       nlon = 283,
       nlat = 144,  
       special_vert_normalization_obs_types =  {varlist},
       special_vert_normalization_pressures =  {invalid_list},
       special_vert_normalization_heights  =   {vnhlist},
       special_vert_normalization_levels    =  {invalid_list},
       special_vert_normalization_scale_heights = {invalid_list}   /
    
    
    &model_nml
       default_state_variables = .false.,
       wrf_state_variables     = 'U','QTY_U_WIND_COMPONENT','TYPE_U','UPDATE','999',
                                 'V','QTY_V_WIND_COMPONENT','TYPE_V','UPDATE','999',
                                 'W','QTY_VERTICAL_VELOCITY','TYPE_W','UPDATE','999',
                                 'PH','QTY_GEOPOTENTIAL_HEIGHT','TYPE_GZ','UPDATE','999',
                                 'T','QTY_POTENTIAL_TEMPERATURE','TYPE_T','UPDATE','999',
                                 'MU','QTY_PRESSURE','TYPE_MU','UPDATE','999',
                                 'QVAPOR','QTY_VAPOR_MIXING_RATIO','TYPE_QV','UPDATE','999',
                                 'QCLOUD','QTY_CLOUDWATER_MIXING_RATIO','TYPE_QC','UPDATE','999',
                                 'QRAIN','QTY_RAINWATER_MIXING_RATIO','TYPE_QR','UPDATE','999',
                                 'QICE','QTY_ICE_MIXING_RATIO','TYPE_QI','UPDATE','999',
                                 'QSNOW','QTY_SNOW_MIXING_RATIO','TYPE_QS','UPDATE','999',
                                 'QGRAUP','QTY_GRAUPEL_MIXING_RATIO','TYPE_QG','UPDATE','999',
                                 'QHAIL','QTY_HAIL_MIXING_RATIO','TYPE_QH','UPDATE','999',
                                 'QVGRAUPEL','QTY_GRAUPEL_VOLUME','TYPE_QGVOL','UPDATE','999',
                                 'QVHAIL','QTY_HAIL_VOLUME','TYPE_QHVOL','UPDATE','999',
                                 'QNDROP','QTY_DROPLET_NUMBER_CONCENTR','TYPE_QNDRP','UPDATE','999',
                                 'QNRAIN','QTY_RAIN_NUMBER_CONCENTR','TYPE_QNRAIN','UPDATE','999',
                                 'QNICE','QTY_ICE_NUMBER_CONCENTRATION','TYPE_QNICE','UPDATE','999',
                                 'QNSNOW','QTY_SNOW_NUMBER_CONCENTR','TYPE_QNSNOW','UPDATE','999',
                                 'QNGRAUPEL','QTY_GRAUPEL_NUMBER_CONCENTR','TYPE_QNGRAUPEL','UPDATE','999',
                                 'QNHAIL','QTY_HAIL_NUMBER_CONCENTR','TYPE_QNHAIL','UPDATE','999', 
                                 'U10','QTY_10M_U_WIND_COMPONENT','TYPE_U10','UPDATE','999',
                                 'V10','QTY_10M_V_WIND_COMPONENT','TYPE_V10','UPDATE','999',
                                 'T2','QTY_2M_TEMPERATURE','TYPE_T2','UPDATE','999',
                                 'TH2','QTY_POTENTIAL_TEMPERATURE','TYPE_TH2','UPDATE','999', 
                                 'Q2','QTY_2M_SPECIFIC_HUMIDITY','TYPE_Q2','UPDATE','999',
                                 'PSFC','QTY_PRESSURE','TYPE_PS','UPDATE','999',
                                 'H_DIABATIC','QTY_CONDENSATIONAL_HEATING','TYPE_H_DIABATIC','UPDATE','999',
                                 'REFL_10CM','QTY_RADAR_REFLECTIVITY','TYPE_REFL','UPDATE','999',
                           
       wrf_state_bounds        = 'QVAPOR','0.0','NULL','CLAMP',
                                 'QCLOUD','0.0','NULL','CLAMP',
                                 'QRAIN','0.0','NULL','CLAMP',
                                 'QICE','0.0','NULL','CLAMP',
                                 'QSNOW','0.0','NULL','CLAMP',
                                 'QGRAUP','0.0','NULL','CLAMP',
                                 'QHAIL','0.0','NULL','CLAMP',
                                 'QVGRAUPEL','0.0','NULL','CLAMP',
                                 'QVHAIL','0.0','NULL','CLAMP',
                                 'QNDROP','0.0','NULL','CLAMP',
                                 'QNRAIN','0.0','NULL','CLAMP',
                                 'QNICE','0.0','NULL','CLAMP',
                                 'QNSNOW','0.0','NULL','CLAMP',
                                 'QNGRAUPEL','0.0','NULL','CLAMP',
                                 'QNHAIL','0.0','NULL','CLAMP',
                                 {w_state_bounds}
     
       num_domains = 1,
       calendar_type = 3,
       allow_obs_below_vol = .true.,
       sfc_elev_max_diff = -1,
       assimilation_period_seconds = 2400,
       vert_localization_coord = 3,
       center_search_half_length = 400000.0,
       circulation_pres_level = 80000.0,
       circulation_radius = 72000.0,
       center_spline_grid_scale = 4,
    /
    
    &dart_to_wrf_nml
       adv_mod_command = "mpirun.lsf /usr/local/bin/launch ./wrf.exe",
    /
    
    &utilities_nml
       TERMLEVEL = 1,
       module_details = .false.,
       logfilename = 'dart_log.out',
       nmlfilename = 'dart_log.nml',
       write_nml   = 'file',
    /
    
    &mpi_utilities_nml
    /
    
    &reg_factor_nml
       select_regression = 1,
       input_reg_file = "time_mean_reg",
       save_reg_diagnostics = .false.,
       reg_diagnostics_file = 'reg_diagnostics'  /
    
    &obs_sequence_nml
       write_binary_obs_sequence = .false.  /
    
    # '../../../obs_def/obs_def_TES_nadir_mod.f90',
    
    &preprocess_nml
        input_obs_kind_mod_file = '../../../obs_kind/DEFAULT_obs_kind_mod.F90',
       output_obs_kind_mod_file = '../../../obs_kind/obs_kind_mod.f90',
         input_obs_def_mod_file = '../../../obs_def/DEFAULT_obs_def_mod.F90',
        output_obs_def_mod_file = '../../../obs_def/obs_def_mod.f90',
    input_files = '../../../obs_def/obs_def_AIRS_mod.f90',
          '../../../obs_def/obs_def_AOD_mod.f90',
          '../../../obs_def/obs_def_AURA_mod.f90',
          '../../../obs_def/obs_def_COSMOS_mod.f90',
          '../../../obs_def/obs_def_CO_Nadir_mod.f90',
          '../../../obs_def/obs_def_GWD_mod.f90',
          '../../../obs_def/obs_def_QuikSCAT_mod.f90',
          '../../../obs_def/obs_def_SABER_mod.f90',
          '../../../obs_def/obs_def_altimeter_mod.f90',
          '../../../obs_def/obs_def_cloud_mod.f90',
          '../../../obs_def/obs_def_cwp_mod.f90', 
          '../../../obs_def/obs_def_dew_point_mod.f90',
          '../../../obs_def/obs_def_dwl_mod.f90',
          '../../../obs_def/obs_def_eval_mod.f90',
          '../../../obs_def/obs_def_gps_mod.f90',
          '../../../obs_def/obs_def_gts_mod.f90',
          '../../../obs_def/obs_def_metar_mod.f90',
          '../../../obs_def/obs_def_ocean_mod.f90',
          '../../../obs_def/obs_def_pe2lyr_mod.f90',
          '../../../obs_def/obs_def_radar_mod.f90',
          '../../../obs_def/obs_def_reanalysis_bufr_mod.f90',
          '../../../obs_def/obs_def_rel_humidity_mod.f90',
          '../../../obs_def/obs_def_sqg_mod.f90',
          '../../../obs_def/obs_def_tower_mod.f90',
          '../../../obs_def/obs_def_tpw_mod.f90',
          '../../../obs_def/obs_def_upper_atm_mod.f90',
          '../../../obs_def/obs_def_vortex_mod.f90',
          '../../../obs_def/obs_def_wind_speed_mod.f90'
       /
    
    &obs_kind_nml
    assimilate_these_obs_types = {varlist_assim} /
    
    &obs_diag_nml
       obs_sequence_name = 'obs_seq.out',
       obs_sequence_list = '',
       first_bin_center =  2011, 2, 3, 6, 0, 0 ,
       last_bin_center  =  2011, 2, 3, 12, 0, 0 ,
       bin_separation   =     0, 0, 0, 6, 0, 0 ,
       bin_width        =     0, 0, 0, 6, 0, 0 ,
       time_to_skip     =     0, 0, 0, 0, 0, 0 ,
       max_num_bins  = 1000,
       Nregions   = 1,
       rat_cri    = 5000.0,
       lonlim1    =   0.0,   0.0,   0.0, 330.1,
       lonlim2    = 360.0, 360.0, 360.0, 334.6,
       latlim1    = 10.0,  30.0, -89.9,  21.3,
       latlim2    = 65.0,  89.9,  89.9,  23.4,
       reg_names  = 'Full Domain',
       print_mismatched_locs = .false.,
       print_obs_locations = .true.,
       verbose = .true.  /
    
    &ncepobs_nml
       year = 2010,
       month = 06,
       day = 00,
       tot_days = 1,
       max_num = 1000000,
       ObsBase = 'temp_obs.',
       select_obs  = 0,
       ADPUPA = .false.,
       AIRCAR = .false.,
       AIRCFT = .false.,
       SATEMP = .false.,
       SFCSHP = .false.,
       ADPSFC = .false.,
       SATWND = .true.,
       obs_U  = .false.,
       obs_V  = .false.,
       obs_T  = .false.,
       obs_PS = .false.,
       obs_QV = .false.,
       daily_file = .true.,
       obs_time = .false.,
       lat1 = 10.00,
       lat2 = 60.00,
       lon1 = 210.0,
       lon2 = 300.0 /
    
    &prep_bufr_nml
       obs_window_upa = 1.0,
       obs_window_air = 1.0,
       obs_window_cw = 1.0,
       otype_use      = 242.0, 243.0, 245.0, 246.0, 251.0, 252.0, 253.0, 257.0, 259.0
       qctype_use     = 0, 1, 2, 3, 4, 9, 15  /
    
    &obs_def_gps_nml
    /
    
    &obs_def_radar_mod_nml
       apply_ref_limit_to_obs     =  .true. ,
       reflectivity_limit_obs     =     0.0 ,
       lowest_reflectivity_obs    =     0.0 ,
       apply_ref_limit_to_fwd_op  =  .true. ,
       reflectivity_limit_fwd_op  =     0.0 ,
       lowest_reflectivity_fwd_op =     0.0 ,
       dielectric_factor          =   0.224 ,
       n0_rain                    =   8.0e6 ,
       n0_graupel                 =   4.0e6 ,
       n0_snow                    =   3.0e6 ,
       rho_rain                   =  1000.0 ,
       rho_graupel                =   400.0 ,
       rho_snow                   =   100.0 ,
       allow_wet_graupel          = .false. ,
       microphysics_type          =       5 ,
       allow_dbztowt_conv         = .true.  /
    
    &obs_def_tpw_nml
    /
    
    &obs_def_cwp_nml
       pressure_top               = 15000.0,
       physics                    = 8 /
    
    &obs_def_rttov_nml
       rttov_sensor_db_file   = '/scratch/home/Thomas.Jones/WOFS_DART/templates/rttov_sensor_db.csv'
       first_lvl_is_sfc       = .true.
       mw_clear_sky_only      = .false.
       interp_mode            = 1
       do_checkinput          = .true.
       apply_reg_limits       = .true.
       verbose                = .true.
       fix_hgpl               = .false.
       do_lambertian          = .false.
       lambertian_fixed_angle = .true.
       rad_down_lin_tau       = .true.
       use_q2m                = .false.
       use_uv10m              = .true.
       use_wfetch             = .false.
       use_water_type         = .false.
       addrefrac              = .true.
       plane_parallel         = .false.
       use_salinity           = .false.
       cfrac_data             = .true.
       clw_data               = .true.
       rain_data              = .true.
       ciw_data               = .true.
       snow_data              = .true.
       graupel_data           = .true.
       hail_data              = .false.
       w_data                 = .false.
       clw_scheme             = 1
       clw_cloud_top          = 300.
       fastem_version         = 6
       supply_foam_fraction   = .false.
       use_totalice           = .true.
       use_zeeman             = .false.
       cc_threshold           = 0.05
       ozone_data             = .false.
       co2_data               = .false.
       n2o_data               = .false.
       co_data                = .false.
       ch4_data               = .false.
       so2_data               = .false.
       addsolar               = .false.
       rayleigh_single_scatt  = .true.
       do_nlte_correction     = .false.
       solar_sea_brdf_model   = 2
       ir_sea_emis_model      = 2
       use_sfc_snow_frac      = .false.
       add_aerosl             = .false.
       aerosl_type            = 1
       add_clouds             = .true.
       ice_scheme             = 1
       use_icede              = .true.
       idg_scheme             = 2
       user_aer_opt_param     = .false.
       user_cld_opt_param     = .false.
       grid_box_avg_cloud     = .true.
       cldcol_threshold       = -1.0
       cloud_overlap          = 1
       cc_low_cloud_top       = 750.0
       ir_scatt_model         = 2
       vis_scatt_model        = 1
       dom_nstreams           = 8
       dom_accuracy           = 0.0
       dom_opdep_threshold    = 0.0
       addpc                  = .false.
       npcscores              = -1
       addradrec              = .false.
       ipcreg                 = 1
       use_htfrtc             = .false.
       htfrtc_n_pc            = -1
       htfrtc_simple_cloud    = .false.
       htfrtc_overcast        = .false.
     /
    
    &obs_seq_coverage_nml
       obs_sequences     = ''
       obs_sequence_list = 'obs_coverage_list.txt'
       obs_of_interest   = 'METAR_U_10_METER_WIND'
       textfile_out      = 'METAR_U_10_METER_WIND_obsdef_mask.txt'
       netcdf_out        = 'METAR_U_10_METER_WIND_obsdef_mask.nc'
       first_analysis    =  2003, 1, 1, 0, 0, 0
       last_analysis     =  2003, 1, 2, 0, 0, 0
       forecast_length_days          = 1
       forecast_length_seconds       = 0
       verification_interval_seconds = 21600
       temporal_coverage_percent     = 100.0
       lonlim1    =    0.0
       lonlim2    =  360.0
       latlim1    =  -90.0
       latlim2    =   90.0
       verbose    = .true.
       /
    
    &convert_cosmic_gps_nml
       gpsro_netcdf_file     = '',
       gpsro_netcdf_filelist = 'flist',
       gpsro_out_file        = 'obs_seq.gpsro',
       local_operator        = .true.,
       obs_levels            = 0.22, 0.55, 1.1, 1.8, 2.7, 3.7, 4.9,
                               6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
       ray_ds                = 5000.0,
       ray_htop              = 13000.1,
    /
    
    &wrf_obs_preproc_nml
       obs_boundary             = 5.0,
       increase_bdy_error       = .true.,
       maxobsfac                = 2.5,
       obsdistbdy               = 15.0,
       sfc_elevation_check      = .false.,
       sfc_elevation_tol        = 300.0,
       obs_pressure_top         = 10000.0,
       obs_height_top           = 20000.0,
       include_sig_data         = .false.,
       tc_sonde_radii           = -1.0,
       superob_aircraft         = .true.,
       aircraft_horiz_int       = 12.0,
       aircraft_pres_int        = 2500.0,
       superob_sat_winds        = .false.,
       sat_wind_horiz_int       = 90.0,
       sat_wind_pres_int        = 2500.0,
    /  
    
    &obs_sequence_tool_nml
       filename_seq         = 'obs_seq.out',
       filename_seq_list    = '',
       filename_out         = 'obs_seq.final',
       gregorian_cal        = .true.,
       print_only           = .true.,
    /
    
    &obs_seq_verify_nml
       obs_sequences     = ''
       obs_sequence_list = 'obs_verify_list.txt'
       input_template    = 'obsdef_mask.nc'
       netcdf_out        = 'forecast.nc'
       obtype_string     = 'METAR_U_10_METER_WIND'
       print_every       = 10000
       verbose           = .true.
       debug             = .false.
       /
    
    &restart_file_tool_nml
       input_file_name              = "restart_file_input",
       output_file_name             = "restart_file_output",
       ens_size                     = 1,
       single_restart_file_in       = .true.,
       single_restart_file_out      = .true.,
       write_binary_restart_files   = .true.,
       overwrite_data_time          = .false.,
       new_data_days                = -1,
       new_data_secs                = -1,
       input_is_model_advance_file  = .false.,
       output_is_model_advance_file = .true.,
       overwrite_advance_time       = .true.,
       new_advance_days             = _RESTART_DAYS_,
       new_advance_secs             = _RESTART_SECONDS_
    /
    
    &wrf_dart_to_fields_nml
       include_slp             = .true.,
       include_wind_components = .true.,
       include_height_on_pres  = .true.,
       include_temperature     = .true.,
       include_rel_humidity    = .true.,
       include_surface_fields  = .false.,
       include_sat_ir_temp     = .false.,
       pres_levels             = 70000.,
    /
    
    &schedule_nml
       calendar        = 'Gregorian',
       first_bin_start =  2000, 1, 1, 0, 0, 0,
       first_bin_end   =  2030, 1, 1, 0, 0, 0,
       last_bin_end    =  2030, 1, 1, 0, 0, 0,
       bin_interval_days    = 1000000,
       bin_interval_seconds = 0,
       max_num_bins         = 2,
       print_table          = .true.
       /
    
    &obs_seq_to_netcdf_nml
       obs_sequence_name = 'obs_seq.final'
       obs_sequence_list     = '',
       lonlim1 = 160.
       lonlim2 = 40.
       latlim1 = 10.
       latlim2 = 65.
    /
    
    &model_mod_check_nml
       verbose               = .FALSE.
       test1thru             = 5
       loc_of_interest       = 320.0, 18.0, 5.0
       x_ind                 = 100
       kind_of_interest      = 'QTY_U_WIND_COMPONENT'
       interp_test_lonrange  = 180.0, 359.0
       interp_test_dlon      = 1.0
       interp_test_latrange  = -40.0, 89.0
       interp_test_dlat      = 1.0
       interp_test_vertrange = 0.0,  1000.0
       interp_test_dvert     = 100.0
       interp_test_vertcoord = 'VERTISHEIGHT'
      /
    
    '''

    return outstr

    
