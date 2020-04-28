# - Try to find restbed
#
# The following are set after configuration is done:
#  restbed_FOUND
#  Corvusoft::restbed
include_guard()

if(TARGET Corvusoft::restbed)
  set(restbed_FOUND TRUE)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT "CXX" IN_LIST languages)
  set(restbed_FOUND FALSE)
  return()
endif()

include(FindPackageHandleStandardArgs)
find_path(restbed_include_dir NAMES restbed)

find_library(
  restbed_lib_path
  NAMES restbed
  PATH_SUFFIXES library)

find_package_handle_standard_args(restbed DEFAULT_MSG restbed_include_dir
                                  restbed_lib_path)
if(NOT restbed_FOUND)
  return()
endif()

add_library(Corvusoft::restbed INTERFACE IMPORTED)
target_include_directories(Corvusoft::restbed INTERFACE ${restbed_include_dir})
target_link_libraries(Corvusoft::restbed INTERFACE ${restbed_lib_path})
