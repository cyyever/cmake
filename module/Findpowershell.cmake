# - Try to find powershell
#
# The following are set after configuration is done:
#  powershell_FOUND
#  powershell::powershell

include_guard()
include(FindPackageHandleStandardArgs)
find_program(powershell_BINARY powershell)
find_package_handle_standard_args(powershell DEFAULT_MSG powershell_BINARY)
if(powershell_FOUND AND NOT TARGET powershell::powershell)
  add_executable(powershell::powershell IMPORTED)
  set_property(TARGET powershell::powershell PROPERTY IMPORTED_LOCATION "${powershell_BINARY}")
endif()
