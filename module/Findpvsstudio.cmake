# - Try to find pvsstudio
#
# The following are set after configuration is done:
#  pvsstudio_FOUND
#  pvsstudio_BINARY

include(FindPackageHandleStandardArgs)

IF(WIN32)
  set(_PF86 "ProgramFiles(x86)")
  find_program(PVS-Studio_Cmd_BINARY PVS-Studio_Cmd PATHS $ENV{PROGRAMFILES}/PVS-Studio $ENV{${_PF86}}/PVS-Studio $ENV{ProgramW6432}/PVS-Studio)
  find_program(PlogConverter_BINARY PlogConverter PATHS $ENV{PROGRAMFILES}/PVS-Studio $ENV{${_PF86}}/PVS-Studio $ENV{ProgramW6432}/PVS-Studio)
  find_package_handle_standard_args(pvsstudio DEFAULT_MSG PVS-Studio_Cmd_BINARY PlogConverter_BINARY)
else()
  find_program(pvs-studio-analyzer_BINARY pvs-studio-analyzer PATHS $ENV{PROGRAMFILES}/PVS-Studio $ENV{${_PF86}}/PVS-Studio $ENV{ProgramW6432}/PVS-Studio)
  find_program(plog-converter_BINARY plog-converter PATHS $ENV{PROGRAMFILES}/PVS-Studio $ENV{${_PF86}}/PVS-Studio $ENV{ProgramW6432}/PVS-Studio)
  find_package_handle_standard_args(pvsstudio DEFAULT_MSG pvs-studio-analyzer_BINARY plog-converter_BINARY)
ENDIF()
