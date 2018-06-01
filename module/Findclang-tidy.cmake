# - Try to find clang-tidy
#
# The following are set after configuration is done:
#  clang-tidy_FOUND
#  clang-tidy_BINARY
#  run-clang-tidy_FOUND
#  run-clang-tidy_BINARY

include(FindPackageHandleStandardArgs)

set(_PF86 "ProgramFiles(x86)")
find_program(clang-tidy_BINARY clang-tidy PATHS $ENV{PROGRAMFILES}/LLVM/bin $ENV{${_PF86}}/LLVM/bin $ENV{ProgramW6432}/LLVM/bin)
find_program(run-clang-tidy_BINARY run-clang-tidy PATHS $ENV{PROGRAMFILES}/LLVM/bin $ENV{${_PF86}}/LLVM/bin $ENV{ProgramW6432}/LLVM/bin)

find_package_handle_standard_args(clang-tidy DEFAULT_MSG clang-tidy_BINARY)
find_package_handle_standard_args(run-clang-tidy DEFAULT_MSG run-clang-tidy_BINARY)
