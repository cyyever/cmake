# - Try to find gprof
#
# The following are set after configuration is done:
#  gprof_FOUND
#  gprof::gprof

include_guard()
include(FindPackageHandleStandardArgs)
find_program(gprof_BINARY NAMES gprof)
find_package_handle_standard_args(gprof DEFAULT_MSG gprof_BINARY)
if(gprof_FOUND AND NOT TARGET gprof::gprof)
  add_executable(gprof::gprof IMPORTED)
  set_property(TARGET gprof::gprof PROPERTY IMPORTED_LOCATION "${gprof_BINARY}")
endif()
