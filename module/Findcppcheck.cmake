# - Try to find cppcheck
#
# The following are set after configuration is done:
#  cppcheck_FOUND
#  cppcheck_BINARY

include(FindPackageHandleStandardArgs)
find_path(cppcheck_DIR cppcheck PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(cppcheck DEFAULT_MSG cppcheck_DIR)

if(cppcheck_FOUND)
  set(cppcheck_BINARY "${cppcheck_DIR}/cppcheck")
endif()
