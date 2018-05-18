# - Try to find cppcheck
#
# The following are set after configuration is done:
#  cppcheck_FOUND
#  cppcheck_BINARY

include(FindPackageHandleStandardArgs)

set(_PF86 "ProgramFiles(x86)")
find_program(cppcheck_BINARY cppcheck PATHS "$ENV{PROGRAMFILES}/Cppcheck" "$ENV{${_PF86}}/Cppcheck" "$ENV{ProgramW6432}/Cppcheck")
find_package_handle_standard_args(cppcheck DEFAULT_MSG cppcheck_BINARY)
