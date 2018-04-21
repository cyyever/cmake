# - Try to find ubsan
#
# The following are set after configuration is done:
#  ubsan_FOUND
#  ubsan_BINARY

include(FindPackageHandleStandardArgs)
find_path(ubsan_DIR libubsan.so PATHS /usr/lib /usr/local/lib)
find_package_handle_standard_args(ubsan DEFAULT_MSG ubsan_DIR)

