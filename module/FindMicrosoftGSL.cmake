# - Try to find MicrosoftGSL
#
# The following are set after configuration is done:
#  MicrosoftGSL_FOUND
#  MicrosoftGSL::GSL

include(FindPackageHandleStandardArgs)
find_file(MicrosoftGSL_dir gsl PATHS "${CMAKE_INSTALL_PREFIX}/include")
find_package_handle_standard_args(MicrosoftGSL DEFAULT_MSG MicrosoftGSL_dir)
if(MicrosoftGSL_FOUND)
  find_file(MicrosoftGSL_headers FILES gsl gsl_algorithm gsl_assert gsl_byte gsl_util PATHS "${MicrosoftGSL_dir}")
  find_package_handle_standard_args(GSL DEFAULT_MSG MicrosoftGSL_dir MicrosoftGSL_headers)
endif()
if(MicrosoftGSL_FOUND AND NOT TARGET MicrosoftGSL::GSL)
  add_library(MicrosoftGSL::GSL INTERFACE IMPORTED)
  set_property(TARGET MicrosoftGSL::GSL
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES
      "${MicrosoftGSL_dir}"
      "${MicrosoftGSL_dir}/.."
      )
endif()
