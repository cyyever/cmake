# - Try to find powershell
#
# The following are set after configuration is done:
#  powershell_FOUND
#  powershell_BINARY

include(FindPackageHandleStandardArgs)

find_program(powershell_BINARY powershell)
find_package_handle_standard_args(powershell DEFAULT_MSG powershell_BINARY)
