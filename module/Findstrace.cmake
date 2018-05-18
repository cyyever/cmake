# - Try to find strace
#
# The following are set after configuration is done:
#  strace_FOUND
#  strace_BINARY

include(FindPackageHandleStandardArgs)
find_program(strace_BINARY strace PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(strace DEFAULT_MSG strace_BINARY)
