# - Try to find drmemory
#
# The following are set after configuration is done:
#  drmemory_FOUND
#  drmemory_BINARY

include(FindPackageHandleStandardArgs)

set(_PF86 "ProgramFiles(x86)")
find_program(drmemory_BINARY drmemory PATHS $ENV{PROGRAMFILES}/Dr.\ Memory/bin $ENV{${_PF86}}/Dr.\ Memory/bin $ENV{ProgramW6432}/Dr.\ Memory/bin)
find_package_handle_standard_args(drmemory DEFAULT_MSG drmemory_BINARY)
