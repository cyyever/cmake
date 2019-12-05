# Find libFuzzer
#
# This module sets the following variables:
#  libFuzzer_FOUND
#  libFuzzer::libFuzzer
include_guard()
if(TARGET libFuzzer::libFuzzer)
  set(libFuzzer_FOUND TRUE)
  return()
endif()
if(WIN32)
  set(libFuzzer_FOUND FALSE)
  return()
endif()

include(FindPackageHandleStandardArgs)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")

set(_source_code [==[
  #include <stdint.h>
  #include <stddef.h>
  extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  return 0;  // Non-zero return values are reserved for future use.
  }
  ]==])

set(_c_res)
set(_cxx_res)
set(CMAKE_REQUIRED_QUIET ON)
if("CXX" IN_LIST languages)
  include(CheckCXXSourceCompiles)
  check_cxx_source_compiles("${_source_code}" _cxx_res)
endif()
if("C" IN_LIST languages)
  include(CheckCSourceCompiles)
  string(REPLACE "extern \"C\"" "" _source_code "${_source_code}")
  check_c_source_compiles("${_source_code}" _c_res)
endif()

set(_compile_res 0)
if(_c_res OR _cxx_res)
  set(_compile_res 1)
endif()

find_package_handle_standard_args(libFuzzer DEFAULT_MSG _compile_res)
if(libFuzzer_FOUND AND NOT TARGET libFuzzer::libFuzzer)
  add_library(libFuzzer::libFuzzer INTERFACE IMPORTED)
  target_compile_options(libFuzzer::libFuzzer
    INTERFACE
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
    $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>
    )
  target_link_options(libFuzzer::libFuzzer
    INTERFACE
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
    $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>
    )
endif()

set(CMAKE_REQUIRED_FLAGS)
unset(_c_res CACHE)
unset(_cxx_res CACHE)
