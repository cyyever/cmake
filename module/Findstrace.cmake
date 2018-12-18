# - Try to find strace
#
# The following are set after configuration is done:
#  strace_FOUND
#  strace::strace

include_guard()
include(FindPackageHandleStandardArgs)
find_program(strace_BINARY strace)
find_package_handle_standard_args(strace DEFAULT_MSG strace_BINARY)
if(strace_FOUND AND NOT TARGET strace::strace)
  add_executable(strace::strace IMPORTED)
  set_property(TARGET strace::strace PROPERTY IMPORTED_LOCATION "${strace_BINARY}")
endif()
