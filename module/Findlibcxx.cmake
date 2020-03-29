# Find libcxx
#
# This module sets the following variables:
#  libcxx_FOUND
#  libcxx::libcxx
include_guard()

if(TARGET libcxx::libcxx)
  set(libcxx_FOUND TRUE)
  return()
endif()

if(WIN32)
  set(libcxx_FOUND FALSE)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT "CXX" IN_LIST languages)
  set(libcxx_FOUND FALSE)
  return()
endif()

set(libcxx_ROOT_DIR
    ${CMAKE_INSTALL_PREFIX}
    CACHE PATH "root directory contains libcxx")

include(FindPackageHandleStandardArgs)
find_path(
  libcxx_include_dir
  NAMES __libcpp_version
  PATHS ${libcxx_ROOT_DIR}
  PATH_SUFFIXES include/c++/v1/
  NO_DEFAULT_PATH)

find_library(
  libcxx_lib_path
  NAMES c++
  PATHS ${libcxx_ROOT_DIR}
  PATH_SUFFIXES lib
  NO_DEFAULT_PATH)

find_package_handle_standard_args(libcxx DEFAULT_MSG libcxx_include_dir
                                  libcxx_lib_path)
if(NOT libcxx_FOUND)
  return()
endif()
get_filename_component(libcxx_lib_dir ${libcxx_lib_path} DIRECTORY)

include(CMakePushCheckState)
cmake_push_check_state(RESET)

set(CMAKE_REQUIRED_FLAGS "-nostdinc++")
set(CMAKE_REQUIRED_INCLUDES ${libcxx_include_dir})
set(CMAKE_REQUIRED_LINK_OPTIONS -nodefaultlibs -L${libcxx_lib_dir})
set(CMAKE_REQUIRED_LIBRARIES c++ m c gcc gcc_s)
if(NOT CMAKE_SYSTEM_NAME MATCHES FreeBSD)
  list(APPEND CMAKE_REQUIRED_LIBRARIES c++abi)
else()
  list(PREPEND CMAKE_REQUIRED_LIBRARIES pthread)
endif()

set(_source_code
    [==[
  #include <iostream>
  int main() {
  std::cout<<"hello world!";
  return 0;
  }
  ]==])

set(CMAKE_REQUIRED_QUIET OFF)
include(CheckCXXSourceRuns)
check_cxx_source_runs("${_source_code}" _run_res)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(libcxx DEFAULT_MSG _run_res)
unset(_run_res CACHE)
if(libcxx_FOUND)
  add_library(libcxx::libcxx INTERFACE IMPORTED)
  target_compile_options(libcxx::libcxx INTERFACE ${CMAKE_REQUIRED_FLAGS})
  target_include_directories(libcxx::libcxx
                             INTERFACE ${CMAKE_REQUIRED_INCLUDES})
  target_link_libraries(libcxx::libcxx INTERFACE ${CMAKE_REQUIRED_LIBRARIES})
  target_link_directories(libcxx::libcxx INTERFACE ${libcxx_lib_dir})
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(libcxx::libcxx INTERFACE -U_GLIBCXX_DEBUG
                                                    -U_GLIBCXX_SANITIZE_VECTOR)
    target_link_options(libcxx::libcxx INTERFACE -nodefaultlibs)

  endif()
  target_compile_definitions(libcxx::libcxx
                             INTERFACE $<$<CONFIG:Debug>:_LIBCPP_DEBUG=1>)
  target_compile_definitions(libcxx::libcxx
                             INTERFACE _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS)
endif()
cmake_pop_check_state()
