# - Try to find lcov
#
# The following are set after configuration is done:
#  lcov_FOUND
#  lcov::lcov
#  lcov::genhtml

include_guard()
include(FindPackageHandleStandardArgs)

find_program(lcov_BINARY lcov)
find_program(genhtml_BINARY genhtml)

find_package_handle_standard_args(lcov DEFAULT_MSG lcov_BINARY genhtml_BINARY)

if(lcov_FOUND AND NOT TARGET lcov::lcov)
  add_executable(lcov::lcov IMPORTED)
  set_property(TARGET lcov::lcov PROPERTY IMPORTED_LOCATION "${lcov_BINARY}")
endif()
if(lcov_FOUND AND NOT TARGET lcov::genhtml)
  add_executable(lcov::genhtml IMPORTED)
  set_property(TARGET lcov::genhtml PROPERTY IMPORTED_LOCATION "${genhtml_BINARY}")
endif()
