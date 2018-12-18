# - Try to find cudamemcheck
#
# The following are set after configuration is done:
#  cudamemcheck_FOUND
#  cudamemcheck_BINARY

include(FindPackageHandleStandardArgs)
FIND_PACKAGE(CUDA)

if(CUDA_FOUND)
  find_program(cudamemcheck_BINARY cuda-memcheck PATHS ${CUDA_TOOLKIT_ROOT_DIR}/bin)
  find_package_handle_standard_args(cudamemcheck DEFAULT_MSG cudamemcheck_BINARY)
endif()
