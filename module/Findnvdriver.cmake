# - Try to find nvidia driver
#
# The following are set after configuration is done:
#  nvdriver_FOUND

include(FindPackageHandleStandardArgs)
find_program(nvidiasmi_BINARY nvidia-smi PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(nvidiasmi DEFAULT_MSG nvidiasmi_BINARY)

set(nvdriver_FOUND FALSE)
if(nvidiasmi_FOUND)
  execute_process(COMMAND ${nvidiasmi_BINARY} RESULT_VARIABLE return_code OUTPUT_VARIABLE output_str)
  if("${return_code}" STREQUAL "0")
    set(nvdriver_FOUND TRUE)
  endif()
endif()
