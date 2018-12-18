# - Try to find ltrace
#
# The following are set after configuration is done:
#  ltrace_FOUND
#  ltrace::ltrace

include_guard()
include(FindPackageHandleStandardArgs)
find_program(ltrace_BINARY NAMES ltrace)
find_package_handle_standard_args(ltrace DEFAULT_MSG ltrace_BINARY)
if(ltrace_FOUND AND NOT TARGET ltrace::ltrace)
  add_executable(ltrace::ltrace IMPORTED)
  set_property(TARGET ltrace::ltrace PROPERTY IMPORTED_LOCATION "${ltrace_BINARY}")
endif()
