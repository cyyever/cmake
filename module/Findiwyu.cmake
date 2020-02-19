# - Try to find iwyu
#
# The following are set after configuration is done:
#  iwyu_FOUND
#  iwyu::iwyu

include_guard()

include(FindPackageHandleStandardArgs)

if(NOT TARGET iwyu::iwyu)
  find_program(iwyu_BINARY NAMES iwyu.py iwyu)
  find_package_handle_standard_args(iwyu DEFAULT_MSG iwyu_BINARY)
  if(iwyu_FOUND)
    add_executable(iwyu::iwyu IMPORTED)
    set_property(TARGET iwyu::iwyu PROPERTY IMPORTED_LOCATION "${iwyu_BINARY}")
  endif()
else()
  set(iwyu_FOUND TRUE)
endif()
