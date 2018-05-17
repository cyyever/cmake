# - Try to find gprof
#
# The following are set after configuration is done:
#  gprof_FOUND
#  gprof_BINARY
#  genhtml_BINARY

include(FindPackageHandleStandardArgs)
find_path(gprof_DIR gprof PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(gprof DEFAULT_MSG gprof_DIR)

if(gprof_FOUND)
  set(gprof_BINARY "${gprof_DIR}/gprof")
endif()
