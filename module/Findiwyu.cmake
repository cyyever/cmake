# - Try to find iwyu
#
# The following are set after configuration is done:
#  iwyu_tool_FOUND
#  iwyu::iwyu_tool

include_guard()

include(FindPackageHandleStandardArgs)

if(NOT TARGET iwyu::iwyu_tool)
  find_program(iwyu_tool_BINARY NAMES iwyu_tool.py iwyu.py iwyu )
  find_package_handle_standard_args(iwyu_tool DEFAULT_MSG iwyu_tool_BINARY)
  if(iwyu_tool_FOUND)
    add_executable(iwyu::iwyu_tool IMPORTED)
    set_property(TARGET iwyu::iwyu_tool PROPERTY IMPORTED_LOCATION "${iwyu_tool_BINARY}")
  endif()
else()
  set(iwyu_tool_FOUND TRUE)
endif()
