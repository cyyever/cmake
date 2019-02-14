# - Try to find ClangFormat
#
# The following are set after configuration is done:
#  ClangFormat_FOUND
#  ClangFormat::clang-format

include_guard()
include(FindPackageHandleStandardArgs)

find_program(clang-format_BINARY NAMES clang-format-8 clang-format)
find_package_handle_standard_args(ClangFormat DEFAULT_MSG clang-format_BINARY)
if(ClangFormat_FOUND AND NOT TARGET ClangFormat::clang-format)
  add_executable(ClangFormat::clang-format IMPORTED)
  set_property(TARGET ClangFormat::clang-format PROPERTY IMPORTED_LOCATION "${clang-format_BINARY}")
endif()
