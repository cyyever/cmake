# - Try to find cudamemcheck
#
# The following are set after configuration is done:
#  cudamemcheck_FOUND
#  cudamemcheck_BINARY

include(FindPackageHandleStandardArgs)
find_path(cudamemcheck_DIR cuda-memcheck PATHS /usr/local/cuda/bin)
find_package_handle_standard_args(cudamemcheck DEFAULT_MSG cudamemcheck_DIR)

if(cudamemcheck_FOUND)
  set(cudamemcheck_BINARY "${cudamemcheck_DIR}/cuda-memcheck")
endif()
