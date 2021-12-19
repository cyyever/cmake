# Find libFuzzer
#
# This module sets the following variables:
#  libFuzzer::libFuzzer
include_guard(GLOBAL)
if(TARGET libFuzzer::libFuzzer)
  return()
endif()

include(FindPackageHandleStandardArgs)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

set(_source_code
    [==[
  #include <stdint.h>
  #include <stddef.h>
  extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  return 0;  // Non-zero return values are reserved for future use.
  }
  ]==])

include(CMakePushCheckState)
cmake_push_check_state(RESET)

set(CMAKE_REQUIRED_QUIET ON)
set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(CMAKE_REQUIRED_FLAGS "/fsanitize=fuzzer")
  set(CMAKE_TRY_COMPILE_CONFIGURATION "Release")
endif()

set(_c_res)
set(_cxx_res)

set(_compile_res 0)
foreach(lang IN LISTS languages)
  if(lang STREQUAL CXX OR lang STREQUAL C)
    include(CheckSourceCompiles)
    check_source_compiles(${lang} "${_source_code}" _${lang}_res)
    if(_${lang}_res)
      set(_compile_res 1)
    endif()
  endif()
endforeach()
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(_compile_res 1)
endif()

find_package_handle_standard_args(libFuzzer DEFAULT_MSG _compile_res)
if(libFuzzer_FOUND)
  add_library(libFuzzer::libFuzzer INTERFACE IMPORTED GLOBAL)
  target_compile_options(
    libFuzzer::libFuzzer
    INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>)
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND NOT CMAKE_C_COMPILER_ID
                                                   STREQUAL "MSVC")
    target_link_options(
      libFuzzer::libFuzzer
      INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>)
  endif()
endif()
cmake_pop_check_state()
