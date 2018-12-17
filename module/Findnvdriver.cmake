# - Try to find nvidia driver
#
# The following are set after configuration is done:
#  nvdriver_FOUND
include_guard()
include(FindPackageHandleStandardArgs)
find_program(nvidia_smi_BINARY NAMES nvidia-smi PATH_SUFFIXES "NVIDIA Corporation/NVSMI")
find_package_handle_standard_args(nvidia_smi DEFAULT_MSG nvidia_smi_BINARY)

if(nvidia_smi_FOUND)
  execute_process(COMMAND ${nvidia_smi_BINARY} RESULT_VARIABLE result OUTPUT_QUIET ERROR_QUIET)
  if(result)
    set(nvdriver_FOUND FALSE)
  else()
    set(nvdriver_FOUND TRUE)
  endif()
endif()
