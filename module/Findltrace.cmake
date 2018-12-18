# - Try to find ltrace
#
# The following are set after configuration is done:
#  ltrace_FOUND
#  ltrace_BINARY

include_guard()
include(FindPackageHandleStandardArgs)
if(NOT WIN32)
  find_program(ltrace_BINARY ltrace PATHS /usr/bin /usr/local/bin)
  find_package_handle_standard_args(ltrace DEFAULT_MSG ltrace_BINARY)
else()
  set(ltrace_FOUND FALSE)
endif()
