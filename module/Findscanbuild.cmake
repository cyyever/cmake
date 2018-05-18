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
  execute_process(COMMAND readlink -f ${scanbuild_BINARY}
  OUTPUT_VARIABLE full_path)

  execute_process(COMMAND dirname -z ${full_path}
  OUTPUT_VARIABLE parent_dir)

execute_process(COMMAND dirname -z ${parent_dir}
  RESULT_VARIABLE res
  OUTPUT_VARIABLE scan_build_dir)
  IF(res STREQUAL "0")
    find_path(ccc_analyzer_DIR ccc-analyzer PATHS "${scan_build_dir}/libexec")
    find_package_handle_standard_args(scanbuild DEFAULT_MSG ccc_analyzer_DIR)
    if(scanbuild_FOUND)
      set(ccc_analyzer_BINARY "${ccc_analyzer_DIR}/ccc-analyzer")
      set(cpp_analyzer_BINARY "${ccc_analyzer_DIR}/c++-analyzer")
    endif()
  endif()
endif()
