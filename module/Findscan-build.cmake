# - Try to find scan-build
#
# The following are set after configuration is done:
#  scan-build_FOUND
#  scan-build_BINARY
#  ccc_analyzer_BINARY
#  cpp_analyzer_BINARY

include(FindPackageHandleStandardArgs)

find_program(scan-build_BINARY scan-build PATHS /usr/bin /usr/local/bin $ENV{PROGRAMFILES}/LLVM/bin $ENV{${_PF86}}/LLVM/bin $ENV{ProgramW6432}/LLVM/bin)
find_package_handle_standard_args(scan-build DEFAULT_MSG scan-build_BINARY)

if(scan-build_FOUND)
  get_filename_component(scan-build_BINARY ${scan-build_BINARY} REALPATH)
  get_filename_component(scan-build_BIN_DIR ${scan-build_BINARY} DIRECTORY)
  get_filename_component(parent_dir ${scan-build_BINARY} DIRECTORY)
  get_filename_component(scan-build_DIR ${scan-build_BIN_DIR} DIRECTORY)

  find_program(ccc_analyzer_BINARY ccc-analyzer PATHS ${scan-build_DIR}/libexec)
  find_program(cpp_analyzer_BINARY c++-analyzer PATHS ${scan-build_DIR}/libexec)
  find_package_handle_standard_args(scan-build DEFAULT_MSG ccc_analyzer_BINARY cpp_analyzer_BINARY)
endif()
