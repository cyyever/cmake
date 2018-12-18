# - Try to find cppcheck
#
# The following are set after configuration is done:
#  cppcheck_FOUND
#  cppcheck::cppcheck

include_guard()
include(FindPackageHandleStandardArgs)
find_program(cppcheck_BINARY NAMES cppcheck PATH_SUFFIXES "Cppcheck")
find_package_handle_standard_args(cppcheck DEFAULT_MSG cppcheck_BINARY)
if(cppcheck_FOUND AND NOT TARGET cppcheck::cppcheck)
  add_executable(cppcheck::cppcheck IMPORTED)
  set_property(TARGET cppcheck::cppcheck PROPERTY IMPORTED_LOCATION "${cppcheck_BINARY}")
endif()
