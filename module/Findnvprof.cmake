# - Try to find CUDA nvprof
#
# The following are set after configuration is done:
#  CUDA-nvprof_FOUND
#  CUDA::nvprof

include_guard()
if(CMAKE_SYSTEM_NAME MATCHES FreeBSD)
  set(CUDA-nvprof_FOUND OFF)
  return()
endif()

find_package(CUDAToolkit)
if(NOT DEFINED CUDAToolkit_BIN_DIR)
  set(CUDA-nvprof_FOUND OFF)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_program(nvprof_BINARY nvprof PATHS ${CUDAToolkit_BIN_DIR})
find_package_handle_standard_args(CUDA-nvprof DEFAULT_MSG nvprof_BINARY)
if(CUDA-nvprof_FOUND AND NOT TARGET CUDA::nvprof)
  add_executable(CUDA::nvprof IMPORTED)
  set_property(TARGET CUDA::nvprof PROPERTY IMPORTED_LOCATION
                                            "${nvprof_BINARY}")
endif()
