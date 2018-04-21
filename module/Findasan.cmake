# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

include(FindPackageHandleStandardArgs)

FILE(GLOB asan_lib_paths /usr/lib/libasan.so.* /usr/local/lib/libasan.so.* /usr/lib/x86_64-linux-gnu/libasan.so.*)
find_package_handle_standard_args(asan DEFAULT_MSG asan_lib_paths)
