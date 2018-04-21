# - Try to find ubsan
#
# The following are set after configuration is done:
#  ubsan_FOUND

include(FindPackageHandleStandardArgs)

FILE(GLOB ubsan_lib_paths /usr/lib/libubsan.so.* /usr/local/lib/libubsan.so.* /usr/lib/x86_64-linux-gnu/libubsan.so.*)
find_package_handle_standard_args(ubsan DEFAULT_MSG ubsan_lib_paths)
