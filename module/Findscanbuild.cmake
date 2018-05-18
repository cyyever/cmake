# - Try to find scanbuild
#
# The following are set after configuration is done:
#  scanbuild_FOUND
#  scanbuild_BINARY
#  ccc_analyzer_BINARY
#  cpp_analyzer_BINARY

include(FindPackageHandleStandardArgs)

find_program(scanbuild_BINARY scan-build PATHS /usr/bin /usr/local/bin $ENV{PROGRAMFILES}/LLVM/bin $ENV{${_PF86}}/LLVM/bin $ENV{ProgramW6432}/LLVM/bin)
find_package_handle_standard_args(scanbuild DEFAULT_MSG scanbuild_BINARY)

if(scanbuild_FOUND)
  get_filename_component(scanbuild_BINARY ${scanbuild_BINARY} REALPATH)
  get_filename_component(scanbuild_BIN_DIR ${scanbuild_BINARY} DIRECTORY)
  get_filename_component(parent_dir ${scanbuild_BINARY} DIRECTORY)
  get_filename_component(scanbuild_DIR ${scanbuild_BIN_DIR} DIRECTORY)
  message(${scanbuild_DIR})

  find_program(ccc_analyzer_BINARY ccc-analyzer PATHS ${scanbuild_DIR}/libexec)
  find_program(cpp_analyzer_BINARY c++-analyzer PATHS ${scanbuild_DIR}/libexec)
  find_package_handle_standard_args(scanbuild DEFAULT_MSG ccc_analyzer_BINARY cpp_analyzer_BINARY)
endif()
