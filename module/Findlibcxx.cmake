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

include(CMakePushCheckState)
cmake_push_check_state(RESET)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_REQUIRED_FLAGS "-nostdinc++")
  set(CMAKE_REQUIRED_INCLUDES "/usr/lib/llvm-9/include/c++/v1")
  set(CMAKE_REQUIRED_LINK_OPTIONS -nodefaultlibs -L/usr/lib/llvm-9/lib)
  set(CMAKE_REQUIRED_LIBRARIES c++ c++abi m c gcc_s gcc)
endif()

set(_source_code
    [==[
  #include <iostream>
  int main() {
  std::cout<<"hello world!";
  return 0;
  }
  ]==])

set(CMAKE_REQUIRED_QUIET ON)
include(CheckCXXSourceRuns)
check_cxx_source_runs("${_source_code}" _run_res)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(libcxx DEFAULT_MSG _run_res)
unset(_run_res CACHE)
if(libcxx_FOUND)
  add_library(libcxx::libcxx INTERFACE IMPORTED)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(libcxx::libcxx INTERFACE ${CMAKE_REQUIRED_FLAGS})
    target_include_directories(libcxx::libcxx
                               INTERFACE ${CMAKE_REQUIRED_INCLUDES})
    target_link_directories(libcxx::libcxx INTERFACE /usr/lib/llvm-9/lib)
    target_link_libraries(libcxx::libcxx INTERFACE c++ c++abi m c gcc_s gcc)
    target_link_options(libcxx::libcxx INTERFACE -nodefaultlibs)
  endif()
endif()
cmake_pop_check_state()
