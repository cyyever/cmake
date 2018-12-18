# - Try to find lcov
#
# The following are set after configuration is done:
#  lcov_FOUND
#  lcov_BINARY
#  genhtml_BINARY

include_guard()
include(FindPackageHandleStandardArgs)
find_program(lcov_BINARY lcov PATHS /usr/bin /usr/local/bin)
find_program(genhtml_BINARY genhtml PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(lcov DEFAULT_MSG lcov_BINARY genhtml_BINARY)
