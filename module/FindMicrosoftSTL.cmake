# Find MicrosoftSTL
#
# This module sets the following target:
#  Microsoft::STL
include_guard(GLOBAL)

if(TARGET Microsoft::STL)
  return()
endif()

if(NOT MSVC)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT "CXX" IN_LIST languages)
  return()
endif()

set(MicrosoftSTL_ROOT_DIR
  "${CMAKE_INSTALL_PREFIX}/STL"
  CACHE PATH "root directory contains MicrosoftSTL")

include(FindPackageHandleStandardArgs)
find_path(
  MicrosoftSTL_include_dir
  NAMES __msvc_system_error_abi.hpp
  PATHS ${MicrosoftSTL_ROOT_DIR}
  PATH_SUFFIXES inc out/inc
  NO_DEFAULT_PATH)

find_library(
  MicrosoftSTL_release_lib_path
  NAMES msvcprt
  PATHS ${MicrosoftSTL_ROOT_DIR}
  PATH_SUFFIXES lib/amd64 out/lib/amd64
  NO_DEFAULT_PATH)

find_library(
  MicrosoftSTL_debug_lib_path
  NAMES msvcprtd
  PATHS ${MicrosoftSTL_ROOT_DIR}
  PATH_SUFFIXES lib/amd64 out/lib/amd64
  NO_DEFAULT_PATH)

find_package_handle_standard_args(MicrosoftSTL DEFAULT_MSG MicrosoftSTL_include_dir
  MicrosoftSTL_release_lib_path MicrosoftSTL_debug_lib_path)
if(NOT MicrosoftSTL_FOUND)
  return()
endif()
get_filename_component(MicrosoftSTL_lib_dir ${MicrosoftSTL_release_lib_path} DIRECTORY)

add_library(Microsoft::STL INTERFACE IMPORTED GLOBAL)
target_include_directories(Microsoft::STL
  SYSTEM BEFORE INTERFACE ${MicrosoftSTL_include_dir})
target_link_directories(Microsoft::STL INTERFACE ${MicrosoftSTL_lib_dir})
target_link_options(Microsoft::STL INTERFACE "/NODEFAULTLIB:LIBCMT")
