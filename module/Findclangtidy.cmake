# - Try to find clangtidy
#
# The following are set after configuration is done:
#  clangtidy_FOUND
#  clangtidy_BINARY

include(FindPackageHandleStandardArgs)

if(WIN32)
  set(_PF86 "ProgramFiles(x86)")
  find_path(clangtidy_DIR clang-tidy.exe PATHS "$ENV{PROGRAMFILES}/LLVM/bin" "$ENV{${_PF86}}/LLVM/bin" "$ENV{ProgramW6432}/LLVM/bin")
else()
  find_path(clangtidy_DIR clang-tidy PATHS /usr/bin /usr/local/bin)
endif()

find_package_handle_standard_args(clangtidy DEFAULT_MSG clangtidy_DIR)

if(clangtidy_FOUND)
  if(WIN32)
    set(clangtidy_BINARY "${clangtidy_DIR}/clang-tidy.exe")
  else()
    set(clangtidy_BINARY "${clangtidy_DIR}/clang-tidy")
  endif()
endif()
