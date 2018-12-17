# - Try to find MicrosoftGSL
#
# The following are set after configuration is done:
#  MicrosoftGSL_FOUND
#  MicrosoftGSL::GSL
include_guard()
include(FindPackageHandleStandardArgs)
find_path(MicrosoftGSL_dir NAMES gsl_algorithm PATH_SUFFIXES gsl)
find_package_handle_standard_args(GSL DEFAULT_MSG MicrosoftGSL_dir)
if(MicrosoftGSL_FOUND AND NOT TARGET MicrosoftGSL::GSL)
  add_library(MicrosoftGSL::GSL INTERFACE IMPORTED)
  set_property(TARGET MicrosoftGSL::GSL
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES
      "${MicrosoftGSL_dir}"
      "${MicrosoftGSL_dir}/.."
      )
endif()
