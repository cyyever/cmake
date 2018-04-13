# - Try to find valgrind
#
# The following are set after configuration is done:
#  valgrind_FOUND
#  valgrind_BINARY

include(FindPackageHandleStandardArgs)
find_path(VALGRIND_DIR valgrind PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(valgrind DEFAULT_MSG VALGRIND_DIR)

if(valgrind_FOUND)
  set(valgrind_BINARY "${VALGRIND_DIR}/valgrind")
endif()
