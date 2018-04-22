# - Try to find doxygen
#
# The following are set after configuration is done:
#  doxygen_FOUND
#  doxygen_BINARY

include(FindPackageHandleStandardArgs)
find_path(doxygen_DIR doxygen PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(doxygen DEFAULT_MSG doxygen_DIR)

if(doxygen_FOUND)
  set(doxygen_BINARY "${doxygen_DIR}/doxygen")
endif()
