# - Try to find CUDA-MEMCHECK
#
# The following are set after configuration is done:
#  CUDA-MEMCHECK::cuda-memcheck

include_guard(GLOBAL)
if(CMAKE_SYSTEM_NAME MATCHES FreeBSD)
  return()
endif()

find_package(CUDAToolkit)
if(NOT DEFINED CUDAToolkit_BIN_DIR)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_program(CUDA-MEMCHECK_BINARY cuda-memcheck PATHS ${CUDAToolkit_BIN_DIR})
find_package_handle_standard_args(CUDA-MEMCHECK DEFAULT_MSG
                                  CUDA-MEMCHECK_BINARY)
if(CUDA-MEMCHECK_FOUND AND NOT TARGET CUDA-MEMCHECK::cuda-memcheck)
  add_executable(CUDA-MEMCHECK::cuda-memcheck IMPORTED GLOBAL)
  set_property(TARGET CUDA-MEMCHECK::cuda-memcheck
               PROPERTY IMPORTED_LOCATION "${CUDA-MEMCHECK_BINARY}")
endif()
