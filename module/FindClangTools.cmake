# - Try to find Clang tools
#
# The following are set after configuration is done:
#  clang-tidy_FOUND
#  ClangTools::clang-tidy
#  run-clang-tidy_FOUND
#  ClangTools::run-clang-tidy

include(FindPackageHandleStandardArgs)

find_program(clang-tidy_BINARY NAMES clang-tidy PATH_SUFFIXES "LLVM/bin")
find_package_handle_standard_args(clang-tidy DEFAULT_MSG clang-tidy_BINARY)
if(clang-tidy_FOUND AND NOT TARGET ClangTools::clang-tidy)
  add_executable(ClangTools::clang-tidy IMPORTED)
  set_property(TARGET ClangTools::clang-tidy PROPERTY IMPORTED_LOCATION "${clang-tidy_BINARY}")
endif()
find_program(run-clang-tidy_BINARY NAMES run-clang-tidy PATH_SUFFIXES "LLVM/bin")
find_package_handle_standard_args(run-clang-tidy DEFAULT_MSG run-clang-tidy_BINARY)
if(run-clang-tidy_FOUND AND NOT TARGET ClangTools::run-clang-tidy)
  add_executable(ClangTools::run-clang-tidy IMPORTED)
  set_property(TARGET ClangTools::run-clang-tidy PROPERTY IMPORTED_LOCATION "${run-clang-tidy_BINARY}")
endif()
