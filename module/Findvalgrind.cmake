# - Try to find valgrind
#
# The following are set after configuration is done:
#  valgrind_FOUND
#  valgrind_BINARY

include(FindPackageHandleStandardArgs)
find_program(valgrind_BINARY valgrind PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(valgrind DEFAULT_MSG valgrind_BINARY)
