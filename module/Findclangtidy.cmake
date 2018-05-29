# - Try to find clangtidy
#
# The following are set after configuration is done:
#  clangtidy_FOUND
#  clangtidy_BINARY

include(FindPackageHandleStandardArgs)

set(_PF86 "ProgramFiles(x86)")
find_program(clangtidy_BINARY clang-tidy PATHS $ENV{PROGRAMFILES}/LLVM/bin $ENV{${_PF86}}/LLVM/bin $ENV{ProgramW6432}/LLVM/bin)

find_package_handle_standard_args(clangtidy DEFAULT_MSG clangtidy_BINARY)
