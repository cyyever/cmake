# - Try to find GSL
#
# The following are set after configuration is done:
#  GSL_FOUND
#  GSL_dir
#  GSL_parent_dir

include(FindPackageHandleStandardArgs)
find_file(GSL_dir gsl PATHS /opt/include)
find_package_handle_standard_args(GSL DEFAULT_MSG GSL_dir)
if(GSL_FOUND)
  find_file(GSL_headers FILES gsl gsl_algorithm gsl_assert gsl_byte gsl_util PATHS ${GSL_dir})
  find_package_handle_standard_args(GSL DEFAULT_MSG GSL_dir GSL_headers)
  if(GSL_FOUND)
    get_filename_component(GSL_parent_dir ${GSL_dir} DIRECTORY)
  endif()
endif()
