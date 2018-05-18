# - Try to find gprof
#
# The following are set after configuration is done:
#  gprof_FOUND
#  gprof_BINARY

include(FindPackageHandleStandardArgs)
find_program(gprof_BINARY gprof PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(gprof DEFAULT_MSG gprof_BINARY)
