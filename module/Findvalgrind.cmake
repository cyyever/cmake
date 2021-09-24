# - Try to find valgrind
#
# The following are set after configuration is done:
#  valgrind::valgrind

include_guard(GLOBAL)

if(TARGET valgrind::valgrind)
  return()
endif()

if(CMAKE_SYSTEM_NAME MATCHES FreeBSD)
  return()
endif()

if(WIN32)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_program(
  valgrind_BINARY
  NAMES valgrind
  PATH_SUFFIXES "valgrind")
find_package_handle_standard_args(valgrind DEFAULT_MSG valgrind_BINARY)
if(valgrind_FOUND)
  add_executable(valgrind::valgrind IMPORTED)
  set_property(TARGET valgrind::valgrind PROPERTY IMPORTED_LOCATION
                                                  "${valgrind_BINARY}")
endif()
