# - Try to find gcovr
#
# The following are set after configuration is done:
#  gcovr_FOUND
#  gcovr_BINARY

include(FindPackageHandleStandardArgs)
find_path(gcovr_DIR gcovr PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(gcovr DEFAULT_MSG gcovr_DIR)

if(gcovr_FOUND)
  set(gcovr_BINARY "${gcovr_DIR}/gcovr")
endif()
