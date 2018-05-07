# - Try to find tsan
#
# The following are set after configuration is done:
#  tsan_FOUND

include(FindPackageHandleStandardArgs)

FILE(GLOB tsan_lib_paths /usr/lib/libtsan.so.* /usr/local/lib/libtsan.so.* /usr/lib/x86_64-linux-gnu/libtsan.so.*)
find_package_handle_standard_args(tsan DEFAULT_MSG tsan_lib_paths)
