# Makefile created by mkmf $Id$ 

include /scratch/wofuser/DART_2023/build_templates/mkmf.template
.DEFAULT:
	-touch $@
all: fixsys grid_refl_obs
fixsys: 
	@ (cd /scratch/wofuser/DART_2023/assimilation_code/modules/utilities; ./fixsystem $(FC) )
utilities_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90
obs_def_utilities_mod.o: /scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90
default_location_mod.o: /scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90 types_mod.o ensemble_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90
module_map_utils.o: /scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90
module_couple_uv.o: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90
reg_factor_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90
obs_impact_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90 types_mod.o utilities_mod.o obs_kind_mod.o parse_args_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90
quad_utils_mod.o: /scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90 types_mod.o location_mod.o utilities_mod.o options_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90
parse_args_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90 utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90
quality_control_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90 types_mod.o utilities_mod.o location_mod.o obs_sequence_mod.o obs_def_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90
state_vector_io_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90 adaptive_inflate_mod.o direct_netcdf_mod.o types_mod.o null_mpi_utilities_mod.o ensemble_manager_mod.o utilities_mod.o time_manager_mod.o io_filenames_mod.o model_mod.o state_structure_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90
location_mod.o: /scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90 types_mod.o utilities_mod.o random_seq_mod.o obs_kind_mod.o null_mpi_utilities_mod.o ensemble_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90
random_seq_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90
filter_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90 types_mod.o options_mod.o obs_sequence_mod.o obs_def_mod.o obs_def_utilities_mod.o time_manager_mod.o utilities_mod.o assim_model_mod.o assim_tools_mod.o obs_model_mod.o ensemble_manager_mod.o adaptive_inflate_mod.o null_mpi_utilities_mod.o smoother_mod.o random_seq_mod.o state_vector_io_mod.o io_filenames_mod.o direct_netcdf_mod.o state_structure_mod.o forward_operator_mod.o quality_control_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90
dart_time_io_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90 types_mod.o time_manager_mod.o utilities_mod.o netcdf_utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90
model_mod.o: /scratch/wofuser/DART_2023/models/wrf/model_mod.f90 types_mod.o time_manager_mod.o location_mod.o utilities_mod.o netcdf_utilities_mod.o null_mpi_utilities_mod.o random_seq_mod.o obs_kind_mod.o ensemble_manager_mod.o sort_mod.o distributed_state_mod.o default_model_mod.o state_structure_mod.o module_map_utils.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/model_mod.f90
obs_def_mod.o: /scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90 types_mod.o utilities_mod.o location_mod.o assim_model_mod.o obs_kind_mod.o ensemble_manager_mod.o obs_def_utilities_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90
test_interpolate_threed_sphere.o: /scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90 types_mod.o utilities_mod.o netcdf_utilities_mod.o location_mod.o obs_kind_mod.o ensemble_manager_mod.o model_check_utilities_mod.o model_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90
f2kcli.o: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90
wrf_data_module.o: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90
netcdf_utilities_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90
options_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90
assim_model_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90 types_mod.o time_manager_mod.o ensemble_manager_mod.o model_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90
distributed_state_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90 null_mpi_utilities_mod.o types_mod.o ensemble_manager_mod.o null_win_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90
types_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90
null_win_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90 types_mod.o ensemble_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90
forward_operator_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90 types_mod.o time_manager_mod.o utilities_mod.o null_mpi_utilities_mod.o obs_sequence_mod.o obs_def_mod.o obs_kind_mod.o ensemble_manager_mod.o distributed_state_mod.o quality_control_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90
location_io_mod.o: /scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90 types_mod.o netcdf_utilities_mod.o location_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90
default_model_mod.o: /scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90 types_mod.o time_manager_mod.o location_mod.o utilities_mod.o netcdf_utilities_mod.o ensemble_manager_mod.o dart_time_io_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90
schedule_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90
sampling_error_correction_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90 types_mod.o utilities_mod.o netcdf_utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90
obs_model_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90 utilities_mod.o assim_model_mod.o state_vector_io_mod.o obs_sequence_mod.o obs_def_mod.o time_manager_mod.o ensemble_manager_mod.o null_mpi_utilities_mod.o io_filenames_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90
module_timediff.o: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90 types_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90
ensemble_manager_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o null_mpi_utilities_mod.o sort_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90
io_filenames_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o null_mpi_utilities_mod.o state_structure_mod.o ensemble_manager_mod.o netcdf_utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90
state_structure_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90 utilities_mod.o obs_kind_mod.o types_mod.o netcdf_utilities_mod.o sort_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90
cov_cutoff_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90 types_mod.o utilities_mod.o location_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90
null_mpi_utilities_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90
assim_tools_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90 types_mod.o options_mod.o utilities_mod.o sort_mod.o random_seq_mod.o obs_sequence_mod.o obs_def_mod.o obs_kind_mod.o cov_cutoff_mod.o reg_factor_mod.o obs_impact_mod.o sampling_error_correction_mod.o location_mod.o ensemble_manager_mod.o null_mpi_utilities_mod.o adaptive_inflate_mod.o time_manager_mod.o assim_model_mod.o distributed_state_mod.o quality_control_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90
module_netcdf_interface.o: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90
sort_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90
obs_kind_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90
assert_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90
smoother_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90 types_mod.o null_mpi_utilities_mod.o utilities_mod.o ensemble_manager_mod.o time_manager_mod.o options_mod.o assim_tools_mod.o obs_sequence_mod.o adaptive_inflate_mod.o io_filenames_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90
time_manager_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90
model_check_utilities_mod.o: /scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90 types_mod.o utilities_mod.o location_mod.o obs_kind_mod.o ensemble_manager_mod.o model_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90
adaptive_inflate_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90 types_mod.o time_manager_mod.o utilities_mod.o random_seq_mod.o ensemble_manager_mod.o null_mpi_utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90
direct_netcdf_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90 types_mod.o options_mod.o ensemble_manager_mod.o time_manager_mod.o utilities_mod.o netcdf_utilities_mod.o null_mpi_utilities_mod.o state_structure_mod.o io_filenames_mod.o assim_model_mod.o model_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90
grid_refl_obs.o: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90 types_mod.o obs_sequence_mod.o obs_def_mod.o obs_kind_mod.o module_map_utils.o location_mod.o time_manager_mod.o utilities_mod.o f2kcli.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90
obs_sequence_mod.o: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90 types_mod.o location_mod.o obs_def_mod.o obs_kind_mod.o time_manager_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	/scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90
./time_manager_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90 .
./sort_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90 .
./random_seq_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90 .
./options_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90 .
./sampling_error_correction_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90 .
./parse_args_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90 .
./location_io_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90 .
./obs_kind_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90 .
./direct_netcdf_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90 .
./f2kcli.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90 .
./null_mpi_utilities_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90 .
./reg_factor_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90 .
./utilities_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90 .
./forward_operator_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90 .
./smoother_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90 .
./obs_model_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90 .
./assim_tools_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90 .
./default_model_mod.f90: /scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90
	cp /scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90 .
./assert_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90 .
./state_vector_io_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90 .
./default_location_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90 .
./test_interpolate_threed_sphere.f90: /scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90
	cp /scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90 .
./obs_def_mod.f90: /scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90
	cp /scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90 .
./grid_refl_obs.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90 .
./filter_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90 .
./ensemble_manager_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90 .
./obs_def_utilities_mod.f90: /scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90
	cp /scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90 .
./module_netcdf_interface.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90 .
./types_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90 .
./adaptive_inflate_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90 .
./io_filenames_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90 .
./module_timediff.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90 .
./module_couple_uv.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90 .
./netcdf_utilities_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90 .
./location_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90 .
./quad_utils_mod.f90: /scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90
	cp /scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90 .
./assim_model_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90 .
./null_win_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90 .
./model_check_utilities_mod.f90: /scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90
	cp /scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90 .
./obs_sequence_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90 .
./obs_impact_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90 .
./quality_control_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90 .
./state_structure_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90 .
./cov_cutoff_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90 .
./dart_time_io_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90 .
./model_mod.f90: /scratch/wofuser/DART_2023/models/wrf/model_mod.f90
	cp /scratch/wofuser/DART_2023/models/wrf/model_mod.f90 .
./module_map_utils.f90: /scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90
	cp /scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90 .
./schedule_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90 .
./wrf_data_module.f90: /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90
	cp /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90 .
./distributed_state_mod.f90: /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90
	cp /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90 .
SRC = /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90 /scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90 /scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90 /scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90 /scratch/wofuser/DART_2023/models/wrf/model_mod.f90 /scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90 /scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90 /scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90 /scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90
OBJ = utilities_mod.o obs_def_utilities_mod.o default_location_mod.o module_map_utils.o module_couple_uv.o reg_factor_mod.o obs_impact_mod.o quad_utils_mod.o parse_args_mod.o quality_control_mod.o state_vector_io_mod.o location_mod.o random_seq_mod.o filter_mod.o dart_time_io_mod.o model_mod.o obs_def_mod.o test_interpolate_threed_sphere.o f2kcli.o wrf_data_module.o netcdf_utilities_mod.o options_mod.o assim_model_mod.o distributed_state_mod.o types_mod.o null_win_mod.o forward_operator_mod.o location_io_mod.o default_model_mod.o schedule_mod.o sampling_error_correction_mod.o obs_model_mod.o module_timediff.o ensemble_manager_mod.o io_filenames_mod.o state_structure_mod.o cov_cutoff_mod.o null_mpi_utilities_mod.o assim_tools_mod.o module_netcdf_interface.o sort_mod.o obs_kind_mod.o assert_mod.o smoother_mod.o time_manager_mod.o model_check_utilities_mod.o adaptive_inflate_mod.o direct_netcdf_mod.o grid_refl_obs.o obs_sequence_mod.o
OFF = /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/time_manager_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/sort_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/random_seq_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/options_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/sampling_error_correction_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/parse_args_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/utilities//location_io_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_kind_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/direct_netcdf_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/f2kcli.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_mpi_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/reg_factor_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/forward_operator_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/smoother_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/obs_model_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_tools_mod.f90 /scratch/wofuser/DART_2023/models/utilities//default_model_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/assert_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_vector_io_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/utilities//default_location_mod.f90 /scratch/wofuser/DART_2023/models/model_mod_tools/test_interpolate_threed_sphere.f90 /scratch/wofuser/DART_2023/observations/forward_operators/obs_def_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/grid_refl_obs.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/filter_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/ensemble_manager_mod.f90 /scratch/wofuser/DART_2023//observations/forward_operators/obs_def_utilities_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_netcdf_interface.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/types_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/adaptive_inflate_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/io_filenames_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_timediff.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_BC/module_couple_uv.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/netcdf_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/location/threed_sphere/location_mod.f90 /scratch/wofuser/DART_2023/models/utilities//quad_utils_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/assim_model_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/null_win_mod.f90 /scratch/wofuser/DART_2023/models/model_mod_tools/model_check_utilities_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/observations/obs_sequence_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/obs_impact_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/quality_control_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/state_structure_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/assimilation/cov_cutoff_mod.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/io/dart_time_io_mod.f90 /scratch/wofuser/DART_2023/models/wrf/model_mod.f90 /scratch/wofuser/DART_2023/models/wrf/module_map_utils.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/schedule_mod.f90 /scratch/wofuser/DART_2023/models/wrf/WRF_DART_utilities/wrf_data_module.f90 /scratch/wofuser/DART_2023/assimilation_code/modules/utilities/distributed_state_mod.f90
clean: neat
	-rm -f .cppdefs *.mod $(OBJ) grid_refl_obs
neat:
	-rm -f $(TMPFILES)
localize: $(OFF)
	cp $(OFF) .
TAGS: $(SRC)
	etags $(SRC)
tags: $(SRC)
	ctags $(SRC)
grid_refl_obs: $(OBJ)
	$(LD) $(OBJ) -o grid_refl_obs  $(LDFLAGS)
