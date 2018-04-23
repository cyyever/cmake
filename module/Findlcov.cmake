# - Try to find lcov
#
# The following are set after configuration is done:
#  lcov_FOUND
#  lcov_BINARY

include(FindPackageHandleStandardArgs)
find_path(lcov_DIR lcov PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(lcov DEFAULT_MSG lcov_DIR)

if(lcov_FOUND)
  set(lcov_BINARY "${lcov_DIR}/lcov")
endif()
