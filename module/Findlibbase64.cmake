# - Try to find libbase64
# - See https://github.com/aklomp/base64
#
# The following are set after configuration is done:
#  libbase64_FOUND
#  libbase64
include_guard()

if(TARGET libbase64)
  set(libbase64_FOUND TRUE)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT "CXX" IN_LIST languages AND NOT "C" IN_LIST languages)
  set(libbase64_FOUND FALSE)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_path(libbase64_include_dir NAME libbase64.h PATH_SUFFIXES include)
find_file(libbase64_lib_path NAME libbase64.o PATH_SUFFIXES lib)

find_package_handle_standard_args(libbase64 DEFAULT_MSG libbase64_include_dir
                                  libbase64_lib_path)
if(NOT libbase64_FOUND)
  return()
endif()

add_library(libbase64 OBJECT IMPORTED)
set_target_properties(libbase64 PROPERTIES IMPORTED_OBJECTS
                                           ${libbase64_lib_path})
target_include_directories(libbase64 INTERFACE ${libbase64_include_dir})
