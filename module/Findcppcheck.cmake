# - Try to find cppcheck
#
# The following are set after configuration is done:
#  cppcheck_FOUND
#  cppcheck_BINARY

include(FindPackageHandleStandardArgs)

if(WIN32)
  set(_PF86 "ProgramFiles(x86)")
  find_path(cppcheck_DIR cppcheck.exe PATHS "$ENV{PROGRAMFILES}/Cppcheck" "$ENV{${_PF86}}/Cppcheck" "$ENV{ProgramW6432}/Cppcheck"  )
else()
  find_path(cppcheck_DIR cppcheck PATHS /usr/bin /usr/local/bin)
endif()
find_package_handle_standard_args(cppcheck DEFAULT_MSG cppcheck_DIR)

if(cppcheck_FOUND)
  if(WIN32)
    set(cppcheck_BINARY "${cppcheck_DIR}/cppcheck.exe")
  else()
    set(cppcheck_BINARY "${cppcheck_DIR}/cppcheck")
  endif()
endif()
