# - Try to find strace
#
# The following are set after configuration is done:
#  strace_FOUND
#  strace_BINARY

include(FindPackageHandleStandardArgs)
find_path(strace_DIR strace PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(strace DEFAULT_MSG strace_DIR)

if(strace_FOUND)
  set(strace_BINARY "${strace_DIR}/strace")
endif()
