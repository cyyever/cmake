# - Try to find Clang tools
#
# The following are set after configuration is done:
#  clang-tidy_FOUND
#  ClangTools::clang-tidy
#  clang-apply-replacements_FOUND
#  ClangTools::clang-apply-replacements
#  run-clang-tidy_FOUND
#  ClangTools::run-clang-tidy

include_guard()
include(FindPackageHandleStandardArgs)
find_program(clang-tidy_BINARY NAMES clang-tidy clang-tidy-devel PATH_SUFFIXES "LLVM/bin")
find_package_handle_standard_args(clang-tidy DEFAULT_MSG clang-tidy_BINARY)
if(clang-tidy_FOUND AND NOT TARGET ClangTools::clang-tidy)
  add_executable(ClangTools::clang-tidy IMPORTED)
  set_property(TARGET ClangTools::clang-tidy PROPERTY IMPORTED_LOCATION "${clang-tidy_BINARY}")
endif()

find_program(clang-apply-replacements_BINARY NAMES clang-apply-replacements clang-apply-replacements-devel PATH_SUFFIXES "LLVM/bin")
find_package_handle_standard_args(clang-apply-replacements DEFAULT_MSG clang-apply-replacements_BINARY)
if(clang-apply-replacements_FOUND AND NOT TARGET ClangTools::clang-apply-replacements)
  add_executable(ClangTools::clang-apply-replacements IMPORTED)
  set_property(TARGET ClangTools::clang-apply-replacements PROPERTY IMPORTED_LOCATION "${clang-apply-replacements_BINARY}")
endif()

find_program(run-clang-tidy_BINARY NAMES run-clang-tidy.py PATH_SUFFIXES "LLVM/bin" "llvm-devel/share/clang")
find_package_handle_standard_args(run-clang-tidy DEFAULT_MSG run-clang-tidy_BINARY)
if(run-clang-tidy_FOUND AND NOT TARGET ClangTools::run-clang-tidy)
  add_executable(ClangTools::run-clang-tidy IMPORTED)
  set_property(TARGET ClangTools::run-clang-tidy PROPERTY IMPORTED_LOCATION "${run-clang-tidy_BINARY}")
endif()
