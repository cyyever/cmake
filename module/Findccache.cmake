# - Try to find ccache
#
# The following are set after configuration is done:
#  ccache_FOUND
#  ccache::ccache
#  ccache_BINARY

include_guard()
if(TARGET ccache::ccache)
  set(ccache_FOUND TRUE)
  return()
endif()
if(WIN32)
  set(ccache_FOUND FALSE)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_program(
  ccache_BINARY
  NAMES ccache
  PATH_SUFFIXES "ccache")
find_package_handle_standard_args(ccache DEFAULT_MSG ccache_BINARY)
if(ccache_FOUND)
  add_executable(ccache::ccache IMPORTED)
  set_property(TARGET ccache::ccache PROPERTY IMPORTED_LOCATION
                                              "${ccache_BINARY}")
endif()
