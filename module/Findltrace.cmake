# - Try to find ltrace
#
# The following are set after configuration is done:
#  ltrace_FOUND
#  ltrace_BINARY

include(FindPackageHandleStandardArgs)
find_path(ltrace_DIR ltrace PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(ltrace DEFAULT_MSG ltrace_DIR)

if(ltrace_FOUND)
  set(ltrace_BINARY "${ltrace_DIR}/ltrace")
endif()
