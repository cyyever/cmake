include_guard()
if(TARGET mold::mold)
  return()
endif()
include(FindPackageHandleStandardArgs)
find_program(
  mold_BINARY
  NAMES mold
  PATHS usr/local/libexec/)
find_package_handle_standard_args(mold DEFAULT_MSG mold_BINARY)
if(mold_FOUND)
  add_executable(mold::mold IMPORTED)
  set_property(TARGET mold::mold PROPERTY IMPORTED_LOCATION "${mold_BINARY}")
endif()
