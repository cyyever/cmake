# - Try to find MicrosoftGSL
#
# The following are set after configuration is done:
#  MicrosoftGSL_FOUND
#  Microsoft::GSL
include_guard()
include(FindPackageHandleStandardArgs)
find_path(MicrosoftGSL_dir NAMES gsl_algorithm PATH_SUFFIXES GSL/include/gsl gsl)
find_package_handle_standard_args(MicrosoftGSL DEFAULT_MSG MicrosoftGSL_dir)
if(MicrosoftGSL_FOUND AND NOT TARGET Microsoft::GSL)
  add_library(Microsoft::GSL INTERFACE IMPORTED)
  set_property(TARGET Microsoft::GSL
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES
      "${MicrosoftGSL_dir}"
      "${MicrosoftGSL_dir}/.."
      )
endif()
