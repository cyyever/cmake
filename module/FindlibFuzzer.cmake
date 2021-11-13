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

set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(CMAKE_REQUIRED_FLAGS "/fsanitize=fuzzer")
  set(CMAKE_REQUIRED_LIBRARIES clang_rt.fuzzer_MDd-x86_64)
endif()
message(STATUS "aaaaaaaaa ${CMAKE_REQUIRED_LIBRARIES}")

set(_c_res)
set(_cxx_res)

set(_compile_res 0)
foreach(lang IN LISTS languages)
  if(lang STREQUAL CXX OR lang STREQUAL C)
    include(CheckSourceRuns)
    set(CMAKE_REQUIRED_LIBRARIES clang_rt.fuzzer_MDd-x86_64 libsancovd)
    check_source_runs(${lang} "${_source_code}" _${lang}_res)
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
  add_library(libFuzzer::libFuzzer INTERFACE IMPORTED)
  target_compile_options(
    libFuzzer::libFuzzer
    INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>)
  target_link_options(
    libFuzzer::libFuzzer INTERFACE
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
    $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>)
  target_link_libraries(
    libFuzzer::libFuzzer INTERFACE $<$<CONFIG:Release>:clang_rt.fuzzer_MD-x86_64
                                   libsancov>)
endif()
cmake_pop_check_state()
