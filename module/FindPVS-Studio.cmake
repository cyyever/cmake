# - Try to find PVS-Studio
#
# The following are set after configuration is done:
#  PVS-Studio_FOUND
#  PVS-Studio::Cmd
#  PVS-Studio::analyzer
#  PVS-Studio::plog-converter

include(FindPackageHandleStandardArgs)

find_program(plog-converter_BINARY PlogConverter plog-converter PATH_SUFFIXES PVS-Studio)
if(WIN32)
  find_program(PVS-Studio_Cmd_BINARY PVS-Studio_Cmd PATH_SUFFIXES PVS-Studio)
  find_package_handle_standard_args(PVS-Studio DEFAULT_MSG plog-converter_BINARY PVS-Studio_Cmd_BINARY)
else()
  find_program(pvs-studio-analyzer_BINARY pvs-studio-analyzer PATH_SUFFIXES PVS-Studio)
  find_package_handle_standard_args(PVS-Studio DEFAULT_MSG plog-converter_BINARY pvs-studio-analyzer_BINARY)
endif()

if(NOT PVS-Studio_FOUND)
  return()
endif()

if(DEFINED PVS-Studio_Cmd_BINARY AND NOT TARGET PVS-Studio::Cmd)
  add_executable(PVS-Studio::Cmd IMPORTED)
  set_property(TARGET PVS-Studio::Cmd PROPERTY IMPORTED_LOCATION "${PVS-Studio_Cmd_BINARY}")
endif()
if(DEFINED pvs-studio-analyzer_BINARY AND NOT TARGET PVS-Studio::analyzer)
  add_executable(PVS-Studio::analyzer IMPORTED)
  set_property(TARGET PVS-Studio::analyzer PROPERTY IMPORTED_LOCATION "${pvs-studio-analyzer_BINARY}")
endif()
if(NOT TARGET PVS-Studio::plog-converter)
  add_executable(PVS-Studio::plog-converter IMPORTED)
  set_property(TARGET PVS-Studio::plog-converter PROPERTY IMPORTED_LOCATION "${plog-converter_BINARY}")
endif()
